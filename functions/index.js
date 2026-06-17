const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

/**
 * Utility function to calculate geographical distance in miles (Haversine formula)
 */
function getDistanceInMiles(lat1, lon1, lat2, lon2) {
  const R = 3958.8; // Radius of the earth in miles
  const dLat = deg2rad(lat2 - lat1);
  const dLon = deg2rad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const d = R * c; // Distance in miles
  return d;
}

function deg2rad(deg) {
  return deg * (Math.PI / 180);
}

/**
 * 1. Matchmaking Engine Trigger: onReportCreated
 * Listens to new items reported in Firestore under `/reports/{reportId}`.
 * Scans active Alert subscriptions within range and dispatches alerts/notifications.
 */
exports.onReportCreated = functions.firestore
  .document('reports/{reportId}')
  .onCreate(async (snapshot, context) => {
    const reportData = snapshot.data();
    if (!reportData) return null;

    const reportId = context.params.reportId;
    const { title, category, isLost, createdBy, latitude, longitude } = reportData;

    // We need coordinates to perform geographic proximity matchmaking
    if (latitude === undefined || longitude === undefined || latitude === null || longitude === null) {
      console.log(`Report ${reportId} matches skipped: No coordinates found.`);
      return null;
    }

    try {
      // Find all alerts in the same category
      const alertsSnapshot = await db
        .collection('alerts')
        .where('category', '==', category)
        .get();

      console.log(`Scanning ${alertsSnapshot.size} alerts for category "${category}"`);

      const notificationsPromises = [];

      for (const doc of alertsSnapshot.docs) {
        const alert = doc.data();
        const alertId = doc.id;

        // Skip if the alert was created by the same person who posted the report
        if (alert.createdBy === createdBy) continue;

        // Skip if alert type matches report type (e.g. lost alert should only match found posts)
        // If alert.isLostAlert is true, we alert when someone FINDS a matching item (isLost == false)
        if (alert.isLostAlert === isLost) continue;

        const distance = getDistanceInMiles(
          latitude,
          longitude,
          alert.latitude,
          alert.longitude
        );

        console.log(`Alert ${alertId} created by ${alert.createdBy} is ${distance.toFixed(2)} miles away (radius: ${alert.radius} miles).`);

        if (distance <= alert.radius) {
          // Write an in-app notification document
          const notificationRef = db.collection('notifications').doc();
          const notifyPromise = notificationRef.set({
            id: notificationRef.id,
            recipientId: alert.createdBy,
            title: `Nearby Match Found!`,
            description: `A new matched ${isLost ? 'lost' : 'found'} item "${title}" has been reported in your alert zone.`,
            type: 'alert',
            relatedItemId: reportId,
            isRead: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          notificationsPromises.push(notifyPromise);

          // Attempt to dispatch FCM Push Notification
          const userDoc = await db.collection('users').doc(alert.createdBy).get();
          if (userDoc.exists) {
            const userData = userDoc.data();
            const fcmToken = userData.fcmToken;

            if (fcmToken) {
              const payload = {
                notification: {
                  title: `Nearby Match Found!`,
                  body: `A new matched item "${title}" was reported within your alert zone.`,
                  sound: 'default',
                },
                data: {
                  click_action: 'FLUTTER_NOTIFICATION_CLICK',
                  type: 'alert',
                  itemId: reportId,
                },
              };

              console.log(`Dispatching FCM push to user ${alert.createdBy}`);
              const fcmPromise = admin.messaging().sendToDevice(fcmToken, payload)
                .catch(err => console.error(`Failed to send FCM token push to user ${alert.createdBy}:`, err));
              notificationsPromises.push(fcmPromise);
            }
          }
        }
      }

      await Promise.all(notificationsPromises);
      console.log(`Matchmaking completed successfully for report ${reportId}`);
    } catch (error) {
      console.error(`Error executing matchmaking onReportCreated:`, error);
    }

    return null;
  });

/**
 * 2. Real-time Messaging Push Notification Trigger: onMessageSent
 * Dispatches a push notification to the conversation partner when a new message is posted.
 */
exports.onMessageSent = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snapshot, context) => {
    const messageData = snapshot.data();
    if (!messageData) return null;

    const { chatId } = context.params;
    const { senderId, senderName, text } = messageData;

    try {
      // Get the parent chat conversation to resolve the recipient
      const chatDoc = await db.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return null;

      const chatData = chatDoc.data();
      const participantIds = chatData.participantIds || [];
      const recipientId = participantIds.find(id => id !== senderId);

      if (!recipientId) return null;

      // Update the chat room unread count for recipient
      const unreadKey = `unreadCounts.${recipientId}`;
      await chatDoc.reference.update({
        [unreadKey]: admin.firestore.FieldValue.increment(1),
        lastMessageText: text,
        lastMessageSenderId: senderId,
        lastMessageTimestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Get the recipient's FCM registration token
      const userDoc = await db.collection('users').doc(recipientId).get();
      if (!userDoc.exists) return null;

      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (fcmToken) {
        const payload = {
          notification: {
            title: `New Message from ${senderName}`,
            body: text,
            sound: 'default',
          },
          data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            type: 'chat',
            chatId: chatId,
          },
        };

        console.log(`Dispatching message FCM push to user ${recipientId}`);
        await admin.messaging().sendToDevice(fcmToken, payload);
      }
    } catch (e) {
      console.error(`Error executing message trigger:`, e);
    }

    return null;
  });

/**
 * 3. Claim Request Notification Trigger: onClaimCreated
 * Dispatches notification to item owner when a user submits a claim request.
 */
exports.onClaimCreated = functions.firestore
  .document('claim_requests/{claimId}')
  .onCreate(async (snapshot, context) => {
    const claimData = snapshot.data();
    if (!claimData) return null;

    const { itemId, itemTitle, requesterName, ownerUid } = claimData;

    try {
      // 1. Write in-app notification for the post owner
      const notificationRef = db.collection('notifications').doc();
      await notificationRef.set({
        id: notificationRef.id,
        recipientId: ownerUid,
        title: 'New Claim Request',
        description: `${requesterName} has submitted a claim request for your item "${itemTitle}".`,
        type: 'claim',
        relatedItemId: itemId,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 2. Fetch the owner's FCM registration token to send push
      const userDoc = await db.collection('users').doc(ownerUid).get();
      if (!userDoc.exists) return null;

      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (fcmToken) {
        const payload = {
          notification: {
            title: 'New Claim Request',
            body: `${requesterName} has claimed your item "${itemTitle}".`,
            sound: 'default',
          },
          data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            type: 'claim',
            itemId: itemId,
          },
        };

        console.log(`Dispatching claim FCM push to owner ${ownerUid}`);
        await admin.messaging().sendToDevice(fcmToken, payload);
      }
    } catch (e) {
      console.error(`Error executing claim request trigger:`, e);
    }

    return null;
  });

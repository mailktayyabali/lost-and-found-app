import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final notificationsStreamProvider = StreamProvider<List<QueryDocumentSnapshot>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(<QueryDocumentSnapshot>[]);
      }

      return FirebaseFirestore.instance
          .collection('notifications')
          .where('recipientId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
        final docs = List<QueryDocumentSnapshot>.from(snapshot.docs);
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>?;
          final bData = b.data() as Map<String, dynamic>?;
          final aTime = aData?['createdAt'];
          final bTime = bData?['createdAt'];
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          } else {
            return bTime.toString().compareTo(aTime.toString());
          }
        });
        return docs;
      });
    },
    error: (err, stack) => Stream.value(<QueryDocumentSnapshot>[]),
    loading: () => Stream.value(<QueryDocumentSnapshot>[]),
  );
});

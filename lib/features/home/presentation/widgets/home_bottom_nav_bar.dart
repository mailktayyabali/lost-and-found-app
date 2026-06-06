import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../messages/data/repositories/firebase_chat_repository.dart';
import '../../../messages/presentation/messages_screen.dart';
import '../home_screen.dart';
import '../search_screen.dart';
import '../../../reports/presentation/create_report_screen.dart';
import '../../../profile/presentation/profile_screen.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const HomeBottomNavBar({super.key, this.currentIndex = 0});


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: context.colors.primaryTeal.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (index) {
            if (index == 0 && currentIndex != 0) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => const HomeScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            } else if (index == 1 && currentIndex != 1) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => const SearchScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            } else if (index == 2 && currentIndex != 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateReportScreen(),
                ),
              );
            } else if (index == 3 && currentIndex != 3) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => const MessagesScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            } else if (index == 4 && currentIndex != 4) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => const ProfileScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: context.colors.primaryTeal,
          unselectedItemColor: context.colors.textLight.withValues(alpha: 0.5),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          items: [
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home_filled),
              ),
              label: 'HOME',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.search),
              ),
              label: 'SEARCH',
            ),
            BottomNavigationBarItem(
              icon: Container(
                margin: EdgeInsets.only(bottom: 4),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primaryTeal,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
              label: 'REPORT',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseChatRepository().getConversationsStreamFallback(),
                  builder: (context, snapshot) {
                    int totalUnread = 0;
                    if (snapshot.hasData && snapshot.data != null) {
                      final userId = FirebaseAuth.instance.currentUser?.uid;
                      if (userId != null) {
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>?;
                          final unreadCounts = data?['unreadCounts'] as Map<String, dynamic>?;
                          totalUnread += (unreadCounts?[userId] as num?)?.toInt() ?? 0;
                        }
                      }
                    }

                    if (totalUnread > 0) {
                      return Badge(
                        label: Text(totalUnread > 99 ? '99+' : totalUnread.toString()),
                        backgroundColor: context.colors.primaryTeal,
                        child: const Icon(Icons.chat_bubble_outline),
                      );
                    }
                    
                    return const Icon(Icons.chat_bubble_outline);
                  },
                ),
              ),
              label: 'MESSAGES',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.person),
              ),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/models/claim_request_model.dart';
import '../../auth/domain/auth_service.dart';
import '../../reports/data/repositories/firebase_claim_repository.dart';

class ClaimRequestsScreen extends StatefulWidget {
  const ClaimRequestsScreen({super.key});

  @override
  State<ClaimRequestsScreen> createState() => _ClaimRequestsScreenState();
}

class _ClaimRequestsScreenState extends State<ClaimRequestsScreen> {
  final FirebaseClaimRepository _claimRepository = FirebaseClaimRepository();
  List<ClaimRequest> _allRequests = [];
  bool _isLoading = true;
  String? _processingRequestId;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final currentUser = AuthService().currentUser;
    if (currentUser != null) {
      try {
        final list = await _claimRepository.getIncomingRequests(currentUser.uid);
        if (mounted) {
          setState(() {
            _allRequests = list;
          });
        }
      } catch (e) {
        debugPrint('ClaimRequestsScreen: Error loading requests: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load claim requests. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveRequest(ClaimRequest request) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final themeColors = context.colors;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeColors.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Approve Claim Request',
            style: TextStyle(color: themeColors.textDark, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to approve this claim? This will mark the item "${request.itemTitle}" as resolved and hide it from the feed.',
            style: TextStyle(color: themeColors.textLight, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: themeColors.textLight, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColors.primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (!mounted) return;
      setState(() => _processingRequestId = 'approve_${request.id}');
      try {
        await _claimRepository.approveClaimRequest(request.id, request.itemId);
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Claim approved successfully for "${request.itemTitle}"!'),
              backgroundColor: themeColors.primaryTeal,
            ),
          );
        }
        await _loadRequests();
      } catch (e) {
        debugPrint('ClaimRequestsScreen: Failed to approve request: $e');
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Failed to approve claim request. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _processingRequestId = null);
        }
      }
    }
  }

  Future<void> _rejectRequest(ClaimRequest request) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final themeColors = context.colors;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeColors.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Reject Claim Request',
            style: TextStyle(color: themeColors.textDark, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to reject this claim? This will allow other users to claim this item.',
            style: TextStyle(color: themeColors.textLight, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: themeColors.textLight, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColors.tagLostRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (!mounted) return;
      setState(() => _processingRequestId = 'reject_${request.id}');
      try {
        await _claimRepository.rejectClaimRequest(request.id);
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text('Claim request rejected.'),
              backgroundColor: themeColors.tagLostRed,
            ),
          );
        }
        await _loadRequests();
      } catch (e) {
        debugPrint('ClaimRequestsScreen: Failed to reject request: $e');
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Failed to reject claim request. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _processingRequestId = null);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingRequests = _allRequests.where((r) => r.status == 'PENDING').toList();
    final historyRequests = _allRequests.where((r) => r.status != 'PENDING').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.surfaceWhite,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.colors.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Claim Requests',
            style: TextStyle(
              color: context.colors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: context.colors.primaryTeal,
            unselectedLabelColor: context.colors.textLight,
            indicatorColor: context.colors.primaryTeal,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildPendingList(pendingRequests),
                  _buildHistoryList(historyRequests),
                ],
              ),
      ),
    );
  }

  Widget _buildPendingList(List<ClaimRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pending_actions_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No pending claim requests',
              style: TextStyle(color: context.colors.textLight, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.colors.dividerColor),
          ),
          color: context.colors.surfaceWhite,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        request.itemImageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: context.colors.dividerColor,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.itemTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.colors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Requested by: ${request.requesterName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.colors.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: context.colors.dividerColor),
                const SizedBox(height: 8),
                Text(
                  'Reason for Claim:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  request.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textDark,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.tagLostRed,
                        side: BorderSide(color: context.colors.tagLostRed),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _processingRequestId != null
                          ? null
                          : () => _rejectRequest(request),
                      child: _processingRequestId == 'reject_${request.id}'
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(context.colors.tagLostRed),
                              ),
                            )
                          : const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: _processingRequestId != null
                          ? null
                          : () => _approveRequest(request),
                      child: _processingRequestId == 'approve_${request.id}'
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryList(List<ClaimRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No history of claim requests',
              style: TextStyle(color: context.colors.textLight, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        final isApproved = request.status == 'APPROVED';

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.colors.dividerColor),
          ),
          color: context.colors.surfaceWhite,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        request.itemImageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 50,
                          color: context.colors.dividerColor,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.itemTitle,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: context.colors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Claimer: ${request.requesterName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.colors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isApproved 
                            ? context.colors.tagFoundGreen.withValues(alpha: 0.1)
                            : context.colors.tagLostRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        request.status,
                        style: TextStyle(
                          color: isApproved ? context.colors.tagFoundGreen : context.colors.tagLostRed,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  request.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.textDark,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

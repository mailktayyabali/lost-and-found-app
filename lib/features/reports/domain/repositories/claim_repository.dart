import '../../../../shared/models/claim_request_model.dart';

abstract class ClaimRepository {
  Future<void> submitClaimRequest(ClaimRequest request);
  Future<List<ClaimRequest>> getIncomingRequests(String ownerUid);
  Future<ClaimRequest?> getPendingRequestForItem(String itemId);
  Future<void> approveClaimRequest(String requestId, String itemId);
  Future<void> rejectClaimRequest(String requestId);
}

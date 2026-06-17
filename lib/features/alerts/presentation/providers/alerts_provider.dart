import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_alerts_repository.dart';
import '../../../../shared/models/alert_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final alertsRepositoryProvider = Provider<FirebaseAlertsRepository>((ref) {
  return FirebaseAlertsRepository();
});

final userAlertsProvider = StreamProvider<List<Alert>>((ref) {
  final repository = ref.watch(alertsRepositoryProvider);
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(<Alert>[]);
      }
      return repository.streamUserAlerts(user.uid);
    },
    error: (err, stack) => Stream.value(<Alert>[]),
    loading: () => Stream.value(<Alert>[]),
  );
});

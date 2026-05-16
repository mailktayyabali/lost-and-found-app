import 'package:flutter/material.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class OfflineWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const OfflineWidget({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
      icon: Icons.wifi_off_rounded,
      actionLabel: 'Try Again',
      onActionPressed: onRetry,
    );
  }
}

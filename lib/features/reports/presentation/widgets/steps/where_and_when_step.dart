import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/mock_map_widget.dart';
import '../report_text_field.dart';

class WhereAndWhenStep extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final bool isLost;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;
  final VoidCallback onTapMap;

  const WhereAndWhenStep({
    super.key,
    required this.locationController,
    required this.dateController,
    required this.timeController,
    required this.isLost,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.onTapMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.colors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        MockMapWidget(
          isPicker: true,
          height: 150,
          onTap: onTapMap,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: locationController,
          decoration: InputDecoration(
            hintText: 'Or enter address manually',
            hintStyle: TextStyle(color: context.colors.textLight, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.primaryTeal),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ReportTextField(
                label: 'Date ${isLost ? 'Lost' : 'Found'}',
                hint: 'dd/mm/yyyy',
                controller: dateController,
                readOnly: true,
                onTap: onSelectDate,
                suffixIcon: Icons.calendar_today,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ReportTextField(
                label: 'Approximate Time',
                hint: '--:-- --',
                controller: timeController,
                readOnly: true,
                onTap: onSelectTime,
                suffixIcon: Icons.access_time,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/carbon_calculator.dart';
import '../models/usage_log_model.dart';
import '../models/appliance_model.dart';

class ActivityCard extends StatelessWidget {
  final UsageLogModel log;
  final ApplianceModel? appliance;

  const ActivityCard({
    super.key,
    required this.log,
    this.appliance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightTeal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                appliance != null
                    ? ApplianceUtils.getApplianceIcon(appliance!.applianceType)
                    : Icons.electrical_services,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appliance?.name ?? 'Unknown Appliance',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${log.hours} hours • ${DateFormatter.formatDateForDisplay(log.date)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.ecoGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                CarbonCalculator.formatEmission(log.carbonEmission),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

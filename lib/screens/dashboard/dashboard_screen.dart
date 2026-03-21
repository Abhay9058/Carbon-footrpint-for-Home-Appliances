import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/carbon_calculator.dart';
import '../../providers/app_data_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/eco_tip_card.dart';
import '../../widgets/activity_card.dart';
import '../../widgets/charts.dart';
import '../../models/appliance_model.dart';
import '../../models/usage_log_model.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToAddAppliance;
  final Function(int) onNavigateToLogUsage;

  const DashboardScreen({
    super.key,
    required this.onNavigateToAddAppliance,
    required this.onNavigateToLogUsage,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppDataProvider>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AppDataProvider>().loadInitialData();
            },
          ),
        ],
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadInitialData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCards(provider),
                  const SizedBox(height: 24),
                  _buildWeeklyChart(provider),
                  const SizedBox(height: 24),
                  _buildPieChart(provider),
                  const SizedBox(height: 24),
                  _buildEcoTips(provider),
                  const SizedBox(height: 24),
                  _buildRecentActivity(provider),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCards(AppDataProvider provider) {
    final analytics = provider.analytics;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Carbon Footprint Overview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "Today's Emission",
                value: CarbonCalculator.formatEmissionKg(
                  analytics?.todayEmission ?? 0,
                ),
                icon: Icons.today,
                iconColor: AppColors.lightGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Weekly Total',
                value: CarbonCalculator.formatEmissionKg(
                  analytics?.weeklyTotal ?? 0,
                ),
                icon: Icons.calendar_view_week,
                iconColor: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Daily Average',
                value: CarbonCalculator.formatEmissionKg(
                  analytics?.dailyAverage ?? 0,
                ),
                icon: Icons.trending_up,
                iconColor: AppColors.tealAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Appliances',
                value: '${provider.appliances.length}',
                icon: Icons.devices,
                iconColor: AppColors.ecoGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(AppDataProvider provider) {
    final dailyEmissions = provider.analytics?.dailyEmissions ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Emission Trend',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: dailyEmissions.isEmpty
                  ? const Center(child: Text('No data available'))
                  : EmissionLineChart(data: dailyEmissions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(AppDataProvider provider) {
    final emissionsByAppliance = provider.analytics?.emissionsByAppliance ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emissions by Appliance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: emissionsByAppliance.isEmpty
                  ? const Center(child: Text('No data available'))
                  : EmissionPieChart(data: emissionsByAppliance),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoTips(AppDataProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Eco Friendly Tips',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...provider.ecoTips.take(3).map((tip) => EcoTipCard(tip: tip)),
      ],
    );
  }

  Widget _buildRecentActivity(AppDataProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (provider.recentActivity.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: AppColors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No recent activity',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...provider.recentActivity.take(5).map((log) {
            final appliance = provider.getApplianceById(log.applianceId);
            return ActivityCard(log: log, appliance: appliance);
          }),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onNavigateToAddAppliance,
            icon: const Icon(Icons.add),
            label: const Text('Add Appliance'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showLogUsageDialog(),
            icon: const Icon(Icons.add_chart),
            label: const Text('Log Usage'),
          ),
        ),
      ],
    );
  }

  void _showLogUsageDialog() {
    final provider = context.read<AppDataProvider>();
    if (provider.appliances.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add an appliance first'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    ApplianceModel? selectedAppliance;
    final hoursController = TextEditingController();
    String selectedDate = DateFormatter.getTodayString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Log Usage'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ApplianceModel>(
                  decoration: const InputDecoration(
                    labelText: 'Select Appliance',
                  ),
                  items: provider.appliances.map((app) {
                    return DropdownMenuItem(
                      value: app,
                      child: Text(app.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAppliance = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: hoursController,
                  decoration: const InputDecoration(
                    labelText: 'Hours Used',
                    suffixText: 'hours',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormatter.formatDate(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date.toIso8601String().split('T')[0];
                      });
                    }
                  },
                ),
                if (selectedAppliance != null && hoursController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated Emission:'),
                          Text(
                            CarbonCalculator.formatEmissionKg(
                              CarbonCalculator.calculateEmission(
                                wattage: selectedAppliance!.wattage,
                                hours: double.tryParse(hoursController.text) ?? 0,
                                quantity: selectedAppliance!.quantity,
                              ),
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedAppliance == null || hoursController.text.isEmpty) {
                  return;
                }

                final log = UsageLogCreate(
                  applianceId: selectedAppliance!.id,
                  hours: double.tryParse(hoursController.text) ?? 0,
                  date: selectedDate,
                );

                final success = await provider.logUsage(log);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Usage logged successfully!'
                            : 'Failed to log usage',
                      ),
                      backgroundColor: success
                          ? AppColors.primaryGreen
                          : AppColors.errorRed,
                    ),
                  );
                }
              },
              child: const Text('Log'),
            ),
          ],
        ),
      ),
    );
  }
}

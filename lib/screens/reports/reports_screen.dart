import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/carbon_calculator.dart';
import '../../providers/app_data_provider.dart';
import '../../widgets/charts.dart';
import '../../widgets/activity_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Charts', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Usage Logs', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildChartsTab(provider),
              _buildLogsTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChartsTab(AppDataProvider provider) {
    final analytics = provider.analytics;

    return RefreshIndicator(
      onRefresh: () => provider.loadAnalytics(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(analytics),
            const SizedBox(height: 24),
            _buildLineChart(provider),
            const SizedBox(height: 24),
            _buildBarChart(provider),
            const SizedBox(height: 24),
            _buildPieChart(provider),
            const SizedBox(height: 24),
            _buildTopAppliances(provider),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Weekly Total',
                CarbonCalculator.formatEmissionKg(analytics?.weeklyTotal ?? 0),
                Icons.calendar_view_week,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Daily Average',
                CarbonCalculator.formatEmissionKg(analytics?.dailyAverage ?? 0),
                Icons.trending_up,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Emissions',
                CarbonCalculator.formatEmissionKg(
                  context.read<AppDataProvider>().user?.totalCarbonEmissions ?? 0,
                ),
                Icons.eco,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Appliances',
                '${analytics?.emissionsByAppliance.length ?? 0}',
                Icons.devices,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(AppDataProvider provider) {
    final dailyEmissions = provider.analytics?.dailyEmissions ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Emissions (Last 7 Days)',
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

  Widget _buildBarChart(AppDataProvider provider) {
    final monthlyEmissions = provider.analytics?.monthlyEmissions ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Emissions (Last 4 Weeks)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: monthlyEmissions.isEmpty
                  ? const Center(child: Text('No data available'))
                  : EmissionBarChart(data: monthlyEmissions),
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
              height: 220,
              child: emissionsByAppliance.isEmpty
                  ? const Center(child: Text('No data available'))
                  : EmissionPieChart(data: emissionsByAppliance),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppliances(AppDataProvider provider) {
    final topAppliances = provider.analytics?.topAppliances ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Contributing Appliances',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (topAppliances.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No data available',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          )
        else
          ...topAppliances.asMap().entries.map((entry) {
            final index = entry.key;
            final appliance = entry.value;
            final maxEmission = topAppliances.first.emission;
            final percentage = maxEmission > 0 ? appliance.emission / maxEmission : 0.0;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              appliance.name,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          CarbonCalculator.formatEmissionKg(appliance.emission),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: AppColors.grey.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildLogsTab(AppDataProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadUsageLogs(),
      child: provider.usageLogs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: AppColors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No usage logs yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start logging your appliance usage',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.usageLogs.length,
              itemBuilder: (context, index) {
                final log = provider.usageLogs[index];
                final appliance = provider.getApplianceById(log.applianceId);
                return ActivityCard(log: log, appliance: appliance);
              },
            ),
    );
  }
}

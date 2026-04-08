import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/carbon_calculator.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/app_data_provider.dart';
import '../../models/appliance_model.dart';
import '../../models/usage_log_model.dart';
import '../../widgets/appliance_card.dart';

class AddApplianceScreen extends StatefulWidget {
  const AddApplianceScreen({super.key});

  @override
  State<AddApplianceScreen> createState() => _AddApplianceScreenState();
}

class _AddApplianceScreenState extends State<AddApplianceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _wattageController = TextEditingController();
  final _quantityController = TextEditingController();
  
  String _selectedType = '';
  bool _isLoading = false;

  final List<String> _applianceTypes = [
    '',
    'Lighting',
    'Cooling',
    'Heating',
    'Entertainment',
    'Kitchen',
    'Laundry',
    'Computing',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _wattageController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add appliances'),
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildForm(),
                const SizedBox(height: 24),
                _buildCalculationTip(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
                const SizedBox(height: 32),
                _buildApplianceList(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Card(
        color: AppColors.glassWhite,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appliance Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.black),
                decoration: const InputDecoration(
                  labelText: 'Appliance Name',
                  labelStyle: TextStyle(color: AppColors.black),
                  hintText: 'e.g., LED Bulb, Air Conditioner',
                  hintStyle: TextStyle(color: Colors.black54),
                  prefixIcon: Icon(Icons.devices),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter appliance name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  hintText: 'Appliance Type',
                  hintStyle: TextStyle(color: Colors.black54),
                  prefixIcon: Icon(Icons.category),
                ),
                dropdownColor: AppColors.white,
                items: _applianceTypes.map((type) {
                  final displayText = type.isEmpty ? 'Select Type' : type;
                  return DropdownMenuItem(
                    value: type,
                    child: Text(displayText, style: const TextStyle(color: AppColors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _wattageController,
                style: const TextStyle(color: AppColors.black),
                decoration: const InputDecoration(
                  labelText: 'Wattage (W)',
                  labelStyle: TextStyle(color: AppColors.black),
                  hintText: 'e.g., 100',
                  hintStyle: TextStyle(color: Colors.black54),
                  prefixIcon: Icon(Icons.electrical_services),
                  suffixText: 'W',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter wattage';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                style: const TextStyle(color: AppColors.black),
                decoration: const InputDecoration(
                  hintText: 'Quantity',
                  hintStyle: TextStyle(color: Colors.black54),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculationTip() {
    return Card(
      color: AppColors.softGreen,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'How Emissions Are Calculated',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CO₂ (kg) = (Wattage × Hours × Quantity / 1000) × ${AppConstants.emissionFactor}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Where 0.82 is India\'s average emission factor per kWh',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_wattageController.text.isNotEmpty && 
                _quantityController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGreen),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estimated hourly emission:'),
                    Text(
                      CarbonCalculator.formatEmission(
                        CarbonCalculator.calculateEmission(
                          wattage: double.tryParse(_wattageController.text) ?? 0,
                          hours: 1,
                          quantity: int.tryParse(_quantityController.text) ?? 1,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _submitForm,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Icon(Icons.add),
        label: Text(_isLoading ? 'Adding...' : 'Add Appliance'),
      ),
    );
  }

  Widget _buildApplianceList(AppDataProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Appliances (${provider.appliances.length})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (provider.appliances.isEmpty)
          Card(
            color: AppColors.softGreen,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.devices_other,
                      size: 48,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No appliances added yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add your first appliance above',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.black),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...provider.appliances.map((appliance) => ApplianceCard(
            appliance: appliance,
            onDelete: () => _deleteAppliance(appliance.id),
            onLogUsage: () => _showLogUsageDialog(appliance),
          )),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final appliance = ApplianceCreate(
      name: _nameController.text.trim(),
      applianceType: _selectedType,
      wattage: double.parse(_wattageController.text),
      quantity: int.parse(_quantityController.text),
    );

    try {
      final success = await context.read<AppDataProvider>().addAppliance(appliance);

      if (mounted) {
        if (success) {
          _nameController.clear();
          _wattageController.clear();
          _quantityController.clear();
          setState(() {
            _selectedType = _applianceTypes[1];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text('Appliance added successfully!'),
                ],
              ),
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          
          // Get the newly added appliance and show log usage dialog
          final provider = context.read<AppDataProvider>();
          if (provider.appliances.isNotEmpty) {
            final newAppliance = provider.appliances.last;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showLogUsageDialog(newAppliance);
            });
          }
        } else {
          final error = context.read<AppDataProvider>().error ?? 'Unknown error';
          _showErrorDialog('Failed to add appliance.\n\nError: $error');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Connection error: ${e.toString()}';
        if (e.toString().contains('SocketException')) {
          errorMessage = 'Cannot connect to server. Is the backend running?';
        }
        _showErrorDialog(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.errorRed),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAppliance(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appliance'),
        content: const Text('Are you sure you want to delete this appliance?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AppDataProvider>().deleteAppliance(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appliance deleted'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    }
  }

  void _showLogUsageDialog(ApplianceModel appliance) {
    final hoursController = TextEditingController();
    String selectedDate = DateFormatter.getTodayString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.glassWhite,
          title: Text(
            'Log Usage: ${appliance.name}',
            style: const TextStyle(color: AppColors.primaryGreen),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: hoursController,
                  style: const TextStyle(color: AppColors.black),
                  decoration: const InputDecoration(
                    labelText: 'Hours Used',
                    labelStyle: TextStyle(color: AppColors.black),
                    hintText: 'Enter hours',
                    hintStyle: TextStyle(color: Colors.black54),
                    suffixText: 'hours',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date', style: TextStyle(color: AppColors.black)),
                  subtitle: Text(DateFormatter.formatDate(selectedDate), style: const TextStyle(color: AppColors.black)),
                  trailing: const Icon(Icons.calendar_today, color: AppColors.black),
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
                if (hoursController.text.isNotEmpty)
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
                          const Text('Estimated Emission:', style: TextStyle(color: AppColors.black)),
                          Text(
                            CarbonCalculator.formatEmissionKg(
                              CarbonCalculator.calculateEmission(
                                wattage: appliance.wattage,
                                hours: double.tryParse(hoursController.text) ?? 0,
                                quantity: appliance.quantity,
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
              child: const Text('Cancel', style: TextStyle(color: AppColors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (hoursController.text.isEmpty) return;

                final log = UsageLogCreate(
                  applianceId: appliance.id,
                  hours: double.tryParse(hoursController.text) ?? 0,
                  date: selectedDate,
                );

                final success = await context.read<AppDataProvider>().logUsage(log);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Usage logged successfully!' : 'Failed to log usage',
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

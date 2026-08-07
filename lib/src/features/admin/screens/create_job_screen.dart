import 'package:flutter/material.dart';
import '../../../../src/config/theme.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _customerNameController = TextEditingController();
  final _carMakeController = TextEditingController();
  final _carModelController = TextEditingController();
  final _registrationController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isMobile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('Create New Job'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Customer Details'),
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Vehicle Information'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _carMakeController,
                      decoration: const InputDecoration(
                        labelText: 'Make (e.g. BMW)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _carModelController,
                      decoration: const InputDecoration(
                        labelText: 'Model (e.g. X5)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _registrationController,
                decoration: const InputDecoration(
                  labelText: 'Registration (Number Plate)',
                  prefixIcon: Icon(Icons.directions_car),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Service Type'),
              SwitchListTile(
                title: const Text('Is this a Mobile Service?'),
                subtitle: const Text(
                  'Toggle on if the mechanic travels to the customer',
                ),
                value: _isMobile,
                onChanged: (val) => setState(() => _isMobile = val),
                activeColor: AppColors.brandPrimary,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Logic to save job would go here
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Job Created (Mock)')),
                      );
                    }
                  },
                  child: const Text('Create Job'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: AppTextStyles.h4),
    );
  }
}

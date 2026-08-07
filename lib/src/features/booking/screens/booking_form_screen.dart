import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/job_provider.dart';
import '../widgets/licence_disc_image_picker.dart';
import '../widgets/additional_images_picker.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _carMakeController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carYearController = TextEditingController();
  final _registrationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _serviceType = 'Minor';
  String _serviceLocation = 'Mobile';
  String? _licenceDiscBase64;
  List<String> _additionalImagesBase64 = [];

  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Customer Details'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('Car Details'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _carMakeController,
                decoration: const InputDecoration(
                  labelText: 'Car Make (e.g. Toyota)',
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _carModelController,
                decoration: const InputDecoration(
                  labelText: 'Car Model (e.g. Corolla)',
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _carYearController,
                decoration: const InputDecoration(labelText: 'Car Year'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _registrationController,
                decoration: const InputDecoration(
                  labelText: 'Registration Number',
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('Service Type'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _serviceType,
                items: ['Minor', 'Major', 'Diagnostics']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _serviceType = v!),
                decoration: const InputDecoration(labelText: 'Select Service'),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('Service Location'),
              const SizedBox(height: 8),
              RadioListTile<String>(
                title: const Text('Mobile Service (We come to you)'),
                value: 'Mobile',
                groupValue: _serviceLocation,
                onChanged: (v) => setState(() => _serviceLocation = v!),
              ),
              RadioListTile<String>(
                title: const Text(
                  'Tow / Fetch Service (We tackle car at workshop)',
                ),
                value: 'Workshop',
                groupValue: _serviceLocation,
                onChanged: (v) => setState(() => _serviceLocation = v!),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('Issue Description'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Describe the issue or service needed',
                  hintText: 'e.g. Engine noise, Brake check, etc.',
                ),
                maxLines: 3,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('Images (Optional)'),
              const SizedBox(height: 16),
              LicenceDiscImagePicker(
                base64Image: _licenceDiscBase64,
                onImageSelected: (base64) =>
                    setState(() => _licenceDiscBase64 = base64),
                onImageRemoved: () => setState(() => _licenceDiscBase64 = null),
              ),
              const SizedBox(height: 16),
              AdditionalImagesPicker(
                images: _additionalImagesBase64,
                onImagesSelected: (list) =>
                    setState(() => _additionalImagesBase64 = list),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isUploading ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Booking'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);
      try {
        final jobProvider = Provider.of<JobProvider>(context, listen: false);
        await jobProvider.addJob(
          customerName: _nameController.text,
          phoneNumber: _phoneController.text,
          carMake: _carMakeController.text,
          carModel: _carModelController.text,
          carYear: int.parse(_carYearController.text),
          registration: _registrationController.text,
          serviceType: _serviceType,
          description: _descriptionController.text,
          serviceLocation: _serviceLocation,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking submitted successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }
}

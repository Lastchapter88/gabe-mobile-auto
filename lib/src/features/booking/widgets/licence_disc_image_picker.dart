import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/image_service.dart';

class LicenceDiscImagePicker extends StatelessWidget {
  final String? base64Image;
  final Function(String?) onImageSelected;
  final VoidCallback onImageRemoved;

  const LicenceDiscImagePicker({
    super.key,
    required this.base64Image,
    required this.onImageSelected,
    required this.onImageRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
      ),
      child: base64Image == null
          ? _buildImageSelector(context)
          : _buildImagePreview(context),
    );
  }

  Widget _buildImageSelector(BuildContext context) {
    return Row(
      children: [
        // Camera Button
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await ImageService.pickImageBase64(
                fromCamera: true,
              );
              if (picked != null) onImageSelected(picked);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 48, color: Colors.blue),
                const SizedBox(height: 8),
                const Text('Camera', style: TextStyle(color: Colors.blue)),
              ],
            ),
          ),
        ),

        // Gallery Button
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await ImageService.pickImageBase64(
                fromCamera: false,
              );
              if (picked != null) onImageSelected(picked);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey[800]!)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library, size: 48, color: Colors.blue),
                  const SizedBox(height: 8),
                  const Text('Gallery', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Stack(
      children: [
        // Image Preview
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(base64Image!),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.error)),
          ),
        ),

        // Remove Button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onImageRemoved,
            child: CircleAvatar(
              backgroundColor: Colors.red.withOpacity(0.8),
              radius: 18,
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

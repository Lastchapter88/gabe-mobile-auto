import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/image_service.dart';

class AdditionalImagesPicker extends StatelessWidget {
  final List<String> images;
  final Function(List<String>) onImagesSelected;
  final int maxImages;

  const AdditionalImagesPicker({
    super.key,
    required this.images,
    required this.onImagesSelected,
    this.maxImages = 3, // Lower limit for Base64 storage safety
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Image Button
        if (images.length < maxImages)
          TextButton.icon(
            onPressed: () => _showImageSourceDialog(context),
            icon: const Icon(Icons.add_a_photo),
            label: Text('Add Photo (${images.length}/$maxImages)'),
          ),

        const SizedBox(height: 8),

        // Images Grid
        if (images.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      base64Decode(images[index]),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Remove Button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red.withOpacity(0.8),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImageService.pickImageBase64(
                  fromCamera: true,
                );
                if (picked != null) _addImage(picked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImageService.pickImageBase64(
                  fromCamera: false,
                );
                if (picked != null) _addImage(picked);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addImage(String image) {
    List<String> updated = List.from(images);
    updated.add(image);
    onImagesSelected(updated);
  }

  void _removeImage(int index) {
    List<String> updated = List.from(images);
    updated.removeAt(index);
    onImagesSelected(updated);
  }
}

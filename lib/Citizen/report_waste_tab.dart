import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/firestore_service.dart';

class ReportWasteTab extends StatefulWidget {
  const ReportWasteTab({super.key});

  @override
  State<ReportWasteTab> createState() => _ReportWasteTabState();
}

class _ReportWasteTabState extends State<ReportWasteTab> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String? _selectedImageBase64;

  bool isLoading = false;

  // 📸 Pick image from camera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = File(pickedFile.path);
        _selectedImageBase64 = base64Encode(bytes);
      });
    }
  }

  // 🚀 Submit report
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirestoreService.addWasteReport(
        description: descriptionController.text.trim(),
        location: locationController.text.trim(),
        imageBase64: _selectedImageBase64!,
      );

      descriptionController.clear();
      locationController.clear();

      setState(() {
        _selectedImage = null;
        _selectedImageBase64 = null;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waste reported successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit report')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Waste')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Add Photo'),
              ),

              if (_selectedImage != null) ...[
                const SizedBox(height: 12),
                Image.file(
                  _selectedImage!,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ],

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : _submitReport,
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import '../services/image_helper.dart';

class ReportWasteTab extends StatefulWidget {
  const ReportWasteTab({super.key});

  @override
  State<ReportWasteTab> createState() => _ReportWasteTabState();
}

class _ReportWasteTabState extends State<ReportWasteTab> {

  final TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;

  File? imageFile;
  final ImagePicker picker = ImagePicker();

  double? latitude;
  double? longitude;
  String locationName = "";

  // 🔹 Generate Auto Report ID
  String generateReportId() {
    final random = Random();
    return "REP-${10000 + random.nextInt(90000)}";
  }

  // 🔹 Get Live Location
  Future<void> getLiveLocation() async {

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    latitude = position.latitude;
    longitude = position.longitude;

    List<Placemark> placemarks =
    await placemarkFromCoordinates(latitude!, longitude!);

    Placemark place = placemarks.first;

    locationName =
    "${place.street}, ${place.locality}, ${place.administrativeArea}";

    setState(() {});
  }

  // 📷 Capture Image
  Future<void> captureImage() async {

    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  // 🔹 Submit Report
  Future<void> submitReport() async {

    if (descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter description")),
      );
      return;
    }

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please get location")),
      );
      return;
    }

    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Capture waste photo")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {

      final compressedImage =
      await ImageHelper.compressImage(imageFile!);

      await FirebaseFirestore.instance
          .collection('reports')
          .add({

        'reportId': generateReportId(),
        'description': descriptionController.text.trim(),
        'locationName': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'beforeImage': compressedImage,
        'status': 'pending',
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'createdAt': Timestamp.now(),

      });

      descriptionController.clear();
      latitude = null;
      longitude = null;
      locationName = "";
      imageFile = null;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report Submitted Successfully")),
      );

      setState(() {});

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [

          const Text(
            "Report Waste",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: "Waste Description",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: getLiveLocation,
            icon: const Icon(Icons.my_location),
            label: const Text("Get Live Location"),
          ),

          const SizedBox(height: 12),

          if (latitude != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Address: $locationName"),
                Text("Latitude: $latitude"),
                Text("Longitude: $longitude"),
              ],
            ),

          const SizedBox(height: 20),

          // 📷 Camera Button
          ElevatedButton.icon(
            onPressed: captureImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text("Take Photo"),
          ),

          const SizedBox(height: 12),

          // 🖼 Image Preview
          if (imageFile != null)
            Image.file(
              imageFile!,
              height: 200,
              fit: BoxFit.cover,
            ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: isLoading ? null : submitReport,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Submit Report"),
          ),
        ],
      ),
    );
  }
}
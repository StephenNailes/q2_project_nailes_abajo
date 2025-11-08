import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'stepper_header.dart';
import 'step5_submit.dart';

class Step4Photo extends StatefulWidget {
  final String itemType;
  final String action;
  final int quantity;
  final String location;
  
  const Step4Photo({
    super.key,
    required this.itemType,
    required this.action,
    required this.quantity,
    required this.location,
  });

  @override
  State<Step4Photo> createState() => _Step4PhotoState();
}

class _Step4PhotoState extends State<Step4Photo> {
  File? _imageFile;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2ECC71)),
                title: const Text('Take a photo', style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF2ECC71)),
                title: const Text('Choose from gallery', style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: const Color(0xFFF7F8FA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepperHeader(currentStep: 4),
            const SizedBox(height: 32),
            const Text(
              "Upload a photo",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF222B45)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Add a photo of your item to dispose.",
              style: TextStyle(color: Color(0xFF8F9BB3), fontSize: 15),
            ),
            const SizedBox(height: 28),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 240,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _imageFile == null
                              ? const Color(0xFFE3E6ED)
                              : const Color(0xFF2ECC71),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _imageFile == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(Icons.camera_alt_outlined,
                                      color: const Color(0xFF2ECC71), size: 48),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  "Tap to upload or take a photo",
                                  style: TextStyle(
                                      color: Color(0xFF8F9BB3),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "JPG, PNG up to 10MB",
                                  style: TextStyle(
                                      color: Color(0xFFBFC8D6), fontSize: 13),
                                ),
                              ],
                            )
                          : Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  height: 240,
                                ),
                              ),
                            ),
                    ),
                  ),
                  // Remove image button (red X)
                  if (_imageFile != null)
                    Positioned(
                      top: -8,
                      right: -8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _imageFile = null;
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD2E3FC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb_outline, color: Color(0xFF4285F4), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Photo Tips",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF222B45),
                          ),
                        ),
                        SizedBox(height: 10),
                        _PhotoTipBullet("Take photos in good lighting"),
                        _PhotoTipBullet("Show the entire item clearly"),
                        _PhotoTipBullet("Include any damage or wear"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => Step5Review(
                                itemType: widget.itemType,
                                action: widget.action,
                                quantity: widget.quantity,
                                location: widget.location,
                                imageFile: null, // Skip photo
                              )));
                    },
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFE3E6ED)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    child: const Text("Skip", style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => Step5Review(
                                itemType: widget.itemType,
                                action: widget.action,
                                quantity: widget.quantity,
                                location: widget.location,
                                imageFile: _imageFile,
                              )));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child: const Text("Continue"),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF222B45)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Dispose Items",
        style: TextStyle(
            color: Color(0xFF222B45),
            fontWeight: FontWeight.w600,
            fontSize: 18),
      ),
      centerTitle: true,
    );
  }
}

class _PhotoTipBullet extends StatelessWidget {
  final String text;
  const _PhotoTipBullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Color(0xFF6B7A90), fontSize: 15)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF6B7A90),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

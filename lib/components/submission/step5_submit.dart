import 'package:flutter/material.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/supabase_service.dart';
import '../../utils/toast_utils.dart';
import 'stepper_header.dart';

class Step5Review extends StatefulWidget {
  final String itemType;
  final String action;
  final int quantity;
  final String location;
  final File? imageFile;
  
  const Step5Review({
    super.key,
    required this.itemType,
    required this.action,
    required this.quantity,
    required this.location,
    this.imageFile,
  });

  @override
  State<Step5Review> createState() => _Step5ReviewState();
}

class _Step5ReviewState extends State<Step5Review> {
  bool _isSubmitting = false;

  Future<void> _submitDisposal() async {
    setState(() => _isSubmitting = true);

    try {
      // Get current Firebase Auth user
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('User not logged in');
      }

      final userId = firebaseUser.uid;
      final supabaseService = SupabaseService();

      // Upload image if provided
      String? imageUrl;
      if (widget.imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${widget.imageFile!.path.split('/').last}';
        final filePath = 'community_posts/$userId/$fileName';

        imageUrl = await supabaseService.uploadFile(
          bucket: 'community-posts',
          path: filePath,
          file: widget.imageFile!,
        );
      }

      // Create community post
      await supabaseService.createCommunityPost(
        userId: userId,
        description: 'Successfully ${widget.action.toLowerCase()} ${widget.quantity} ${widget.itemType}(s) at ${widget.location}',
        itemType: widget.itemType,
        brandModel: null,
        quantity: widget.quantity,
        dropOffLocation: widget.location,
        action: widget.action.toLowerCase(),
        photoUrls: imageUrl != null ? [imageUrl] : [],
      );

      if (mounted) {
        // Success toast
        ToastUtils.showSuccess(
          context,
          message: 'Disposal submitted successfully! Your contribution has been recorded. 🎉',
          duration: const Duration(seconds: 3),
        );

        // Navigate to community feed
        context.go('/community');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        
        // Error toast
        ToastUtils.showError(
          context,
          message: 'Failed to submit disposal: ${e.toString()}',
        );
      }
      debugPrint('❌ Error submitting disposal: $e');
    }
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
            const StepperHeader(currentStep: 5),
            const SizedBox(height: 32),
            const Text(
              "Review and submit",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222B45),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please review your recycling log details before submitting.",
              style: TextStyle(
                color: Color(0xFF8F9BB3),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Request Summary",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Color(0xFF222B45),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildSummaryItem(
                    icon: Icons.smartphone,
                    iconBg: const Color(0xFFE3F0FF),
                    iconColor: const Color(0xFF4285F4),
                    label: "Item Type",
                    value: widget.itemType,
                  ),
                  _divider(),
                  _buildSummaryItem(
                    icon: widget.action == 'Disposed' ? Icons.recycling : Icons.autorenew,
                    iconBg: widget.action == 'Disposed' ? const Color(0xFFE3FCEC) : const Color(0xFFE3F0FF),
                    iconColor: widget.action == 'Disposed' ? const Color(0xFF34A853) : const Color(0xFF4285F4),
                    label: "Action",
                    value: widget.action,
                  ),
                  _divider(),
                  _buildSummaryItem(
                    icon: Icons.tag,
                    iconBg: const Color(0xFFFFF3E3),
                    iconColor: const Color(0xFFFFA726),
                    label: "Quantity",
                    value: "${widget.quantity} item${widget.quantity > 1 ? 's' : ''}",
                  ),
                  _divider(),
                  _buildSummaryItem(
                    icon: Icons.location_on,
                    iconBg: const Color(0xFFE3FCEC),
                    iconColor: const Color(0xFF34A853),
                    label: "Drop-off Location",
                    value: widget.location,
                  ),
                  if (widget.imageFile != null) ...[
                    _divider(),
                    _buildImageSummaryItem(
                      imageFile: widget.imageFile!,
                      label: "Photo Uploaded",
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitDisposal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text("Submit & Share"),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                "Your recycled item will be saved to your history.",
                style: TextStyle(
                  color: Color(0xFF8F9BB3),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    color: Color(0xFF222B45),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
              Text(value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF8F9BB3),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSummaryItem({
    required File imageFile,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: FileImage(imageFile),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    color: Color(0xFF222B45),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
              Text(imageFile.path.split('/').last,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF8F9BB3),
                  )),
            ],
          ),
        ),
        const Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 20),
      ],
    );
  }

  Widget _divider() {
    return const Divider(height: 28, color: Color(0xFFF0F2F5), thickness: 1);
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
        "Recycle Items",
        style: TextStyle(
          color: Color(0xFF222B45),
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }
}

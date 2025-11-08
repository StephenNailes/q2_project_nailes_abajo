import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../components/eco_bottom_nav.dart';
import '../components/shared/swipe_nav_wrapper.dart';
import '../services/supabase_service.dart';
import '../utils/toast_utils.dart';

class SubmissionScreen extends StatefulWidget {
  const SubmissionScreen({super.key});

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<File> _selectedImages = [];
  String _selectedAction = 'Disposed';
  int _quantity = 1;
  String? _selectedItemType;
  String? _selectedLocation;
  
  // Item types matching Step1Select and Community Feed filters
  final List<Map<String, dynamic>> _itemTypes = [
    {
      'name': 'Smartphone',
      'icon': Icons.smartphone,
      'description': 'Mobile phones and smartphones',
    },
    {
      'name': 'Laptop',
      'icon': Icons.laptop_mac,
      'description': 'Laptops and notebooks',
    },
    {
      'name': 'Charger',
      'icon': Icons.battery_charging_full,
      'description': 'Phone chargers, cables, adapters',
    },
    {
      'name': 'Tablet',
      'icon': Icons.tablet,
      'description': 'Tablets and iPads',
    },
    {
      'name': 'Headphones',
      'icon': Icons.headphones,
      'description': 'Headphones, earbuds, speakers',
    },
  ];
  
  // User profile data
  String _userName = 'Loading...';
  String? _userProfileImage;
  
  // Available disposal locations from maps
  final List<Map<String, dynamic>> _allDisposalLocations = [
    {
      'name': 'SM City Davao E-Waste Collection',
      'address': 'Ecoland Drive, Matina, Davao City',
      'services': ['Disposed'],
    },
    {
      'name': 'Davao Tech Refurbish Hub',
      'address': 'Poblacion District, Davao City',
      'services': ['Repurposed'],
    },
    {
      'name': 'Gaisano Mall Disposal Point',
      'address': 'J.P. Laurel Ave, Bajada, Davao City',
      'services': ['Disposed'],
    },
    {
      'name': 'EcoCenter Repair Shop',
      'address': 'Torres St, Davao City',
      'services': ['Repurposed'],
    },
    {
      'name': 'City Hall E-Waste Drop-off',
      'address': 'City Hall Complex, Davao City',
      'services': ['Disposed'],
    },
    {
      'name': 'GreenTech Refurbishing Center',
      'address': 'Tech Park Ave, Davao City',
      'services': ['Repurposed'],
    },
  ];

  List<Map<String, dynamic>> get _disposalLocations {
    return _allDisposalLocations
        .where((location) => (location['services'] as List).contains(_selectedAction))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _postController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  /// Load current user's profile from Supabase
  Future<void> _loadUserProfile() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      final supabaseService = SupabaseService();
      final profile = await supabaseService.getUserProfile(firebaseUser.uid);

      if (mounted && profile != null) {
        setState(() {
          _userName = profile.name;
          _userProfileImage = profile.profileImageUrl;
        });
      } else if (mounted) {
        // Fallback to Firebase user data if profile not in Supabase yet
        setState(() {
          _userName = firebaseUser.displayName ?? 'User';
          _userProfileImage = firebaseUser.photoURL;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading user profile: $e');
      // Fallback to Firebase user data on error
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (mounted && firebaseUser != null) {
        setState(() {
          _userName = firebaseUser.displayName ?? 'User';
          _userProfileImage = firebaseUser.photoURL;
        });
      }
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty && mounted) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
    if (photo != null && mounted) {
      setState(() {
        _selectedImages.add(File(photo.path));
      });
    }
  }

  void _removeImage(int index) {
    if (mounted) {
      setState(() {
        _selectedImages.removeAt(index);
      });
    }
  }

  Future<void> _submitPost() async {
    // Validation
    if (_postController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something about your disposal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedItemType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the item type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a drop-off location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
        ),
      ),
    );

    try {
      // Get current Firebase Auth user
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('User not logged in');
      }
      
      final userId = firebaseUser.uid;
      final supabaseService = SupabaseService();

      // Upload images to Supabase Storage
      List<String> uploadedImageUrls = [];
      for (var imageFile in _selectedImages) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        final filePath = 'community_posts/$userId/$fileName';
        
        // Upload to Supabase Storage
        final uploadResult = await supabaseService.uploadFile(
          bucket: 'community-posts',
          path: filePath,
          file: imageFile,
        );
        
        if (uploadResult != null) {
          uploadedImageUrls.add(uploadResult);
        }
      }

      // Create community post
      await supabaseService.createCommunityPost(
        userId: userId,
        description: _postController.text.trim(),
        itemType: _selectedItemType!,
        brandModel: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        quantity: _quantity,
        dropOffLocation: _selectedLocation!,
        action: _selectedAction.toLowerCase(),
        photoUrls: uploadedImageUrls,
      );

      if (mounted) {
        // Close loading
        Navigator.of(context).pop();
        
        // Show modern toast notification
        ToastUtils.showSuccess(
          context,
          message: 'Post created successfully! Your disposal story has been shared with the community. 🎉',
          duration: const Duration(seconds: 4),
        );
        
        // Navigate to community feed
        context.go('/community');
      }
    } catch (e) {
      if (mounted) {
        // Close loading
        Navigator.of(context).pop();
        
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('❌ Error submitting post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwipeNavWrapper(
      currentIndex: 2,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9FBEF), Color(0xFFD6F5E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87, size: 28),
            onPressed: () => context.go('/community'),
          ),
          title: const Text(
            "Create Post",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 20,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              child: ElevatedButton(
                onPressed: _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Post',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info section with gradient background
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2ECC71).withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundImage: _userProfileImage != null
                            ? NetworkImage(_userProfileImage!)
                            : const AssetImage('lib/assets/images/kert.jpg') as ImageProvider,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF2ECC71).withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.public, size: 13, color: Color(0xFF2ECC71)),
                              const SizedBox(width: 5),
                              Text(
                                'Public',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Post description section
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: TextField(
                  controller: _postController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Share your disposal story... What did you dispose? Where did you go?',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                      height: 1.5,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Disposal Details Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_note,
                            color: Color(0xFF2ECC71),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Disposal Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Item Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedItemType,
                      decoration: InputDecoration(
                        labelText: 'Item Type',
                        labelStyle: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'Select item type',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.category, color: Color(0xFF2ECC71), size: 20),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                      isExpanded: true,
                      items: _itemTypes.map((itemType) {
                        return DropdownMenuItem<String>(
                          value: itemType['name'],
                          child: Row(
                            children: [
                              Icon(
                                itemType['icon'] as IconData,
                                color: const Color(0xFF2ECC71),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      itemType['name'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      itemType['description'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedItemType = newValue;
                        });
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return _itemTypes.map((itemType) {
                          return Row(
                            children: [
                              Icon(
                                itemType['icon'] as IconData,
                                color: const Color(0xFF2ECC71),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                itemType['name'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    const SizedBox(height: 14),

                    // Brand
                    TextField(
                      controller: _brandController,
                      decoration: InputDecoration(
                        labelText: 'Brand/Model (Optional)',
                        labelStyle: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'e.g., iPhone 12, MacBook Pro',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.label_outline, color: Color(0xFF2ECC71), size: 20),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Action selector (Disposed/Repurposed)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedAction = 'Disposed';
                                // Reset location if it doesn't support new action
                                if (_selectedLocation != null) {
                                  final currentLocationStillValid = _disposalLocations
                                      .any((loc) => loc['name'] == _selectedLocation);
                                  if (!currentLocationStillValid) {
                                    _selectedLocation = null;
                                  }
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: _selectedAction == 'Disposed'
                                    ? const LinearGradient(
                                        colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                                      )
                                    : null,
                                color: _selectedAction != 'Disposed' ? Colors.grey[100] : null,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _selectedAction == 'Disposed'
                                      ? const Color(0xFF2ECC71)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                                boxShadow: _selectedAction == 'Disposed'
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF2ECC71).withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.recycling,
                                    color: _selectedAction == 'Disposed'
                                        ? Colors.white
                                        : Colors.grey[600],
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Disposed',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: _selectedAction == 'Disposed'
                                          ? Colors.white
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedAction = 'Repurposed';
                                // Reset location if it doesn't support new action
                                if (_selectedLocation != null) {
                                  final currentLocationStillValid = _disposalLocations
                                      .any((loc) => loc['name'] == _selectedLocation);
                                  if (!currentLocationStillValid) {
                                    _selectedLocation = null;
                                  }
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: _selectedAction == 'Repurposed'
                                    ? const LinearGradient(
                                        colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                                      )
                                    : null,
                                color: _selectedAction != 'Repurposed' ? Colors.grey[100] : null,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _selectedAction == 'Repurposed'
                                      ? const Color(0xFF3498DB)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                                boxShadow: _selectedAction == 'Repurposed'
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF3498DB).withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.autorenew,
                                    color: _selectedAction == 'Repurposed'
                                        ? Colors.white
                                        : Colors.grey[600],
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Repurposed',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: _selectedAction == 'Repurposed'
                                          ? Colors.white
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quantity selector
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.format_list_numbered, color: Color(0xFF2ECC71), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Quantity:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (_quantity > 1) {
                                      setState(() => _quantity--);
                                    }
                                  },
                                  icon: const Icon(Icons.remove),
                                  color: _quantity > 1 ? const Color(0xFF2ECC71) : Colors.grey[400],
                                  iconSize: 20,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$_quantity',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2ECC71),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _quantity++);
                                  },
                                  icon: const Icon(Icons.add),
                                  color: const Color(0xFF2ECC71),
                                  iconSize: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Location Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedLocation,
                      decoration: InputDecoration(
                        labelText: 'Drop-off Location',
                        labelStyle: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'Select disposal center',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.location_on, color: Color(0xFF2ECC71), size: 20),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                      isExpanded: true,
                      items: _disposalLocations.map((location) {
                        return DropdownMenuItem<String>(
                          value: location['name'],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                location['name']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                location['address']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedLocation = newValue;
                        });
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return _disposalLocations.map((location) {
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  location['name']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Add Photos Section
              if (_selectedImages.isNotEmpty) ...[
                // Display selected images
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(_selectedImages[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Photo action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImages,
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.photo_library, size: 18),
                        ),
                        label: const Text(
                          'Gallery',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2ECC71),
                          side: const BorderSide(color: Color(0xFF2ECC71), width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt, size: 20),
                        label: const Text(
                          'Camera',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2ECC71),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
        bottomNavigationBar: const EcoBottomNavBar(currentIndex: 3),
        floatingActionButton: const SubmissionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ), // Scaffold
    ), // Container
  ); // SwipeNavWrapper
  }
}

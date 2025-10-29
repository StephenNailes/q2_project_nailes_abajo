/// Submission model for e-waste recycling submissions
class SubmissionModel {
  final String id;
  final String userId;
  final String itemType; // 'phone', 'laptop', 'charger', 'tablet', 'other'
  final int quantity;
  final String dropOffLocation;
  final List<String> photoUrls;
  final String status; // 'pending', 'processing', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime? completedAt;

  SubmissionModel({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.quantity,
    required this.dropOffLocation,
    this.photoUrls = const [],
    this.status = 'pending',
    required this.createdAt,
    this.completedAt,
  });

  /// Create SubmissionModel from JSON
  factory SubmissionModel.fromJson(Map<String, dynamic> json, String docId) {
    return SubmissionModel(
      id: docId,
      userId: json['userId'] ?? json['user_id'] ?? '',
      itemType: json['itemType'] ?? json['item_type'] ?? '',
      quantity: json['quantity'] ?? 0,
      dropOffLocation: json['dropOffLocation'] ?? json['drop_off_location'] ?? '',
      photoUrls: json['photoUrls'] != null
          ? List<String>.from(json['photoUrls'])
          : (json['photo_urls'] != null
              ? List<String>.from(json['photo_urls'])
              : []),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'].toString())
              : DateTime.now()),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'].toString())
          : (json['completed_at'] != null
              ? DateTime.parse(json['completed_at'].toString())
              : null),
    );
  }

  /// Convert to JSON for Firebase
  Map<String, dynamic> toFirebaseJson() {
    return {
      'userId': userId,
      'itemType': itemType,
      'quantity': quantity,
      'dropOffLocation': dropOffLocation,
      'photoUrls': photoUrls,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toSupabaseJson() {
    return {
      'user_id': userId,
      'item_type': itemType,
      'quantity': quantity,
      'drop_off_location': dropOffLocation,
      'photo_urls': photoUrls,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  SubmissionModel copyWith({
    String? id,
    String? userId,
    String? itemType,
    int? quantity,
    String? dropOffLocation,
    List<String>? photoUrls,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemType: itemType ?? this.itemType,
      quantity: quantity ?? this.quantity,
      dropOffLocation: dropOffLocation ?? this.dropOffLocation,
      photoUrls: photoUrls ?? this.photoUrls,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Check if submission is completed
  bool get isCompleted => status == 'completed';

  /// Check if submission is pending
  bool get isPending => status == 'pending';

  /// Get item type display name
  String get itemTypeDisplay {
    switch (itemType.toLowerCase()) {
      case 'phone':
        return 'Phone';
      case 'laptop':
        return 'Laptop';
      case 'charger':
        return 'Charger';
      case 'tablet':
        return 'Tablet';
      default:
        return 'Other';
    }
  }

  @override
  String toString() {
    return 'SubmissionModel(id: $id, itemType: $itemType, quantity: $quantity, status: $status)';
  }
}

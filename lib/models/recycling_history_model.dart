/// Recycling history model
class RecyclingHistoryModel {
  final String id;
  final String userId;
  final String? submissionId;
  final String itemType;
  final int quantity;
  final int earnedPoints;
  final DateTime recycledDate;

  RecyclingHistoryModel({
    required this.id,
    required this.userId,
    this.submissionId,
    required this.itemType,
    required this.quantity,
    this.earnedPoints = 0,
    required this.recycledDate,
  });

  /// Create from JSON
  factory RecyclingHistoryModel.fromJson(Map<String, dynamic> json, String docId) {
    return RecyclingHistoryModel(
      id: docId,
      userId: json['userId'] ?? json['user_id'] ?? '',
      submissionId: json['submissionId'] ?? json['submission_id'],
      itemType: json['itemType'] ?? json['item_type'] ?? '',
      quantity: json['quantity'] ?? 0,
      earnedPoints: json['earnedPoints'] ?? json['earned_points'] ?? 0,
      recycledDate: json['recycledDate'] != null
          ? DateTime.parse(json['recycledDate'].toString())
          : (json['recycled_date'] != null
              ? DateTime.parse(json['recycled_date'].toString())
              : DateTime.now()),
    );
  }

  /// Convert to Firebase JSON
  Map<String, dynamic> toFirebaseJson() {
    return {
      'userId': userId,
      'submissionId': submissionId,
      'itemType': itemType,
      'quantity': quantity,
      'earnedPoints': earnedPoints,
      'recycledDate': recycledDate.toIso8601String(),
    };
  }

  /// Convert to Supabase JSON
  Map<String, dynamic> toSupabaseJson() {
    return {
      'user_id': userId,
      'submission_id': submissionId,
      'item_type': itemType,
      'quantity': quantity,
      'earned_points': earnedPoints,
      'recycled_date': recycledDate.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'RecyclingHistoryModel(id: $id, itemType: $itemType, quantity: $quantity, points: $earnedPoints)';
  }
}

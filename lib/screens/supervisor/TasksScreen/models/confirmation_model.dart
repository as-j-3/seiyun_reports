class ConfirmationModel {
  final int assignmentId;
  final String note;
  final String image; // رابط الصورة بعد الرفع أو المسار المحلي

  ConfirmationModel({
    required this.assignmentId,
    required this.note,
    required this.image,
  });

  factory ConfirmationModel.fromJson(Map<String, dynamic> json) {
    return ConfirmationModel(
      assignmentId: json['assignment_id'] != null 
          ? int.parse(json['assignment_id'].toString()) 
          : 0,
      note: json['note'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignment_id': assignmentId,
      'note': note,
      'image': image,
    };
  }
}

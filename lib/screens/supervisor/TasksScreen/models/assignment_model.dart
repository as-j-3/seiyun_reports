class AssignmentModel {
  final int idAssignments;
  final int reportId;
  final String status;
  final String reportType;
  final String priority;
  final String title;
  final String description;
  final String reportImage;
  final String supervisorName;
  final String assignedAt;

  final String square;
  final String area;
  final String lat;
  final String lng;

  final String? confirmationNote;
  final String? confirmationImage;

  AssignmentModel({
    required this.idAssignments,
    required this.reportId,
    required this.status,
    required this.reportType,
    required this.priority,
    required this.title,
    required this.description,
    required this.reportImage,
    required this.supervisorName,
    required this.assignedAt,
    required this.square,
    required this.area,
    required this.lat,
    required this.lng,
    this.confirmationNote,
    this.confirmationImage,
  });

  AssignmentModel copyWith({
    int? idAssignments,
    int? reportId,
    String? status,
    String? reportType,
    String? priority,
    String? title,
    String? description,
    String? reportImage,
    String? supervisorName,
    String? assignedAt,
    String? square,
    String? area,
    String? lat,
    String? lng,
    String? confirmationNote,
    String? confirmationImage,
  }) {
    return AssignmentModel(
      idAssignments: idAssignments ?? this.idAssignments,
      reportId: reportId ?? this.reportId,
      status: status ?? this.status,
      reportType: reportType ?? this.reportType,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      reportImage: reportImage ?? this.reportImage,
      supervisorName: supervisorName ?? this.supervisorName,
      assignedAt: assignedAt ?? this.assignedAt,
      square: square ?? this.square,
      area: area ?? this.area,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      confirmationNote: confirmationNote ?? this.confirmationNote,
      confirmationImage: confirmationImage ?? this.confirmationImage,
    );
  }

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};

    return AssignmentModel(
      idAssignments: json['id_assignments'] != null ? int.parse(json['id_assignments'].toString()) : 0,
      reportId: json['report_id'] != null ? int.parse(json['report_id'].toString()) : 0,
      status: json['status'] ?? 'قيد الانتظار',
      reportType: json['report_type'] ?? 'رفع',
      priority: json['priority'] ?? 'عادي',
      title: json['title'] ?? 'تكليف بدون عنوان',
      description: json['description'] ?? '',
      reportImage: json['report_image'] != null && json['report_image'].toString().isNotEmpty
          ? json['report_image'].toString()
          : "https://via.placeholder.com/150",
      supervisorName: json['supervisor_name'] ?? 'غير معين',
      assignedAt: json['assigned_at'] ?? '',

      square: location['square'] ?? '',
      area: location['area'] ?? '',
      lat: location['lat']?.toString() ?? '0.0',
      lng: location['lng']?.toString() ?? '0.0',

      confirmationNote: json['confirmation_note'] ?? json['note'],
      confirmationImage: json['confirmation_image'] ?? json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_assignments': idAssignments,
      'report_id': reportId,
      'status': status,
      'report_type': reportType,
      'priority': priority,
      'title': title,
      'description': description,
      'report_image': reportImage,
      'supervisor_name': supervisorName,
      'assigned_at': assignedAt,
      'location': {
        'square': square,
        'area': area,
        'lat': double.tryParse(lat) ?? 0.0,
        'lng': double.tryParse(lng) ?? 0.0,
      },
      'confirmation_note': confirmationNote,
      'confirmation_image': confirmationImage,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id_assignments': idAssignments,
      'report_id': reportId,
      'status': status,
      'report_type': reportType,
      'priority': priority,
      'title': title,
      'description': description,
      'report_image': reportImage,
      'supervisor_name': supervisorName,
      'assigned_at': assignedAt,
      'square': square,
      'area': area,
      'lat': lat,
      'lng': lng,
      'confirmation_note': confirmationNote,
      'confirmation_image': confirmationImage,
    };
  }

  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      idAssignments: map['id_assignments'],
      reportId: map['report_id'],
      status: map['status'],
      reportType: map['report_type'],
      priority: map['priority'],
      title: map['title'],
      description: map['description'],
      reportImage: map['report_image'],
      supervisorName: map['supervisor_name'],
      assignedAt: map['assigned_at'],
      square: map['square'],
      area: map['area'],
      lat: map['lat'],
      lng: map['lng'],

      confirmationNote: map['confirmation_note'] ?? map['note'],
      confirmationImage: map['confirmation_image'] ?? map['image'],
    );
  }
}
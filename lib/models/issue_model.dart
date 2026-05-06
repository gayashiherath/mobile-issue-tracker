class IssueModel {
  static const _unset = Object();

  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final String? assignee;
  final String createdDate;
  final String updatedDate;
  final String? attachmentPath;
  final bool isSynced;

  IssueModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.assignee,
    required this.createdDate,
    required this.updatedDate,
    this.attachmentPath,
    this.isSynced = true,
  });

  IssueModel copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? status,
    Object? assignee = _unset,
    String? createdDate,
    String? updatedDate,
    Object? attachmentPath = _unset,
    bool? isSynced,
  }) {
    return IssueModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignee: assignee == _unset ? this.assignee : assignee as String?,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      attachmentPath: attachmentPath == _unset
          ? this.attachmentPath
          : attachmentPath as String?,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      status: json['status'],
      assignee: json['assignee'],
      createdDate: json['createdDate'],
      updatedDate: json['updatedDate'],
      attachmentPath: json['attachmentPath'],
      isSynced: json['isSynced'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'assignee': assignee,
      'createdDate': createdDate,
      'updatedDate': updatedDate,
      'attachmentPath': attachmentPath,
      'isSynced': isSynced,
    };
  }
}

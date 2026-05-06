class SyncQueueItem {
  static const createAction = 'create';
  static const updateAction = 'update';
  static const resolveAction = 'resolve';
  static const closeAction = 'close';
  static const deleteAction = 'delete';

  final String id;
  final String issueId;
  final String action;
  final String queuedAt;
  final Map<String, dynamic> payload;

  SyncQueueItem({
    required this.id,
    required this.issueId,
    required this.action,
    required this.queuedAt,
    required this.payload,
  });

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'],
      issueId: json['issueId'],
      action: json['action'],
      queuedAt: json['queuedAt'],
      payload: Map<String, dynamic>.from(json['payload'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'issueId': issueId,
      'action': action,
      'queuedAt': queuedAt,
      'payload': payload,
    };
  }
}

class Task {
  final String id;
  final String description;
  final String type;
  final int status;
  final DateTime? dueDate;
  final String? assignedTo; // User ID of assignee
  final DateTime createdAt;
  final DateTime? updated;

  Task({
    String? id,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.updated,
    this.assignedTo, // Can be null for unassigned tasks
  }) : id = id ?? _generateId();

  // Copy with method
  Task copyWith({
    String? id,
    String? description,
    String? type,
    int? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updated,
    String? assignedTo,
  }) {
    return Task(
      id: id ?? this.id,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updated: updated ?? this.updated,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Helper method to check if task is assigned
  bool get isAssigned => assignedTo != null;

  // For JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'type': type,
      'status': status,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updated': updated?.toIso8601String(),
      'assignedTo': assignedTo,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      description: json['description'],
      type: json['type'],
      status: json['status'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt:  DateTime.parse(json['createdAt']),
      updated: json['updated'] != null ? DateTime.parse(json['updated']) : null,
      assignedTo: json['assignedTo'],
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, description: $description, type: $type, '
        'status: $status, dueDate: $dueDate, createdAt: $createdAt, updated: $updated,'
        'assignedTo: $assignedTo)';
  }
}
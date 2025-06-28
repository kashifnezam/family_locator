class Task {
  final String id;
  String description;
  String type;
  bool isSelected;

  Task({
    required this.id,
    required this.description,
    required this.type,
    this.isSelected = false,
  });
}
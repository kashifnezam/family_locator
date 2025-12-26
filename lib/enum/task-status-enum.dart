enum TaskStatusEnum {
  unscheduled(0, 'Unscheduled'),
  assigned(1, 'Assigned'),
  unassigned(2, 'Unassigned'),
  inProgress(3, 'In Progress'),
  completed(4, 'Completed'),
  cancelled(5, 'Cancelled'),
  overdue(6, 'Overdue');

  final int dbValue;
  final String uiValue;

  const TaskStatusEnum(this.dbValue, this.uiValue);

  // Convert from DB value to enum
  static TaskStatusEnum fromDbValue(int dbValue) {
    return values.firstWhere(
      (status) => status.dbValue == dbValue,
      orElse: () => TaskStatusEnum.unscheduled, // default if not found
    );
  }

  // Convert from UI value to enum
  static TaskStatusEnum fromUiValue(String uiValue) {
    return values.firstWhere(
      (status) => status.uiValue == uiValue,
      orElse: () => TaskStatusEnum.unscheduled, // default if not found
    );
  }

  // Get all UI values for dropdowns or lists
  static List<String> getAllUiValues() {
    return values.map((status) => status.uiValue).toList();
  }

  @override
  String toString() => uiValue;
}


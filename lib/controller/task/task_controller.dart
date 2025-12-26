import 'package:get/get.dart';
import '../../enum/task-status-enum.dart';
import '../../models/task/task_model.dart';

class TaskController extends GetxController {
  var tasks = <Task>[].obs;
  var isSelectionMode = false.obs;
  var taskId = ''.obs;
  var taskDescription = ''.obs;
  var taskType = 'simple'.obs;
  var taskStatus = TaskStatusEnum.unscheduled.dbValue.obs;
  final int tasksPerPage = 10;
  var currentPage = 1.obs;
  var allTasks = <Task>[].obs; // This holds all tasks
  // Track selected task IDs separately
  final selectedTaskIds = <String>{}.obs;
  final RxString searchQuery = ''.obs;
  final RxMap<String, bool> activeFilters = {
    'simple': false,
    'location': false,
    'highPriority': false,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  void setTaskId(String id) => taskId.value = id;
  void setTaskDescription(String description) => taskDescription.value = description;
  void setTaskType(String type) => taskType.value = type;
  void setTaskStatus(int status) => taskStatus.value = status;

  void addTask() {
    if (taskId.isEmpty || taskDescription.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    tasks.add(Task(
      id: taskId.value,
      description: taskDescription.value,
      type: taskType.value,
      status: taskStatus.value,
      createdAt: DateTime.now(),
    ));

    Get.snackbar('Success', 'Task added successfully');
    Get.back();
    clearFields();
  }

  void clearFields() {
    taskId.value = '';
    taskDescription.value = '';
    taskType.value = 'simple';
    taskStatus.value = TaskStatusEnum.unscheduled.dbValue;
  }

  void loadTasks() {
    allTasks.assignAll([
      // Your existing sample tasks
      // Add more sample data for pagination testing
      for (int i = 4; i <= 50; i++)
        Task(
          id: 'T${i.toString().padLeft(3, '0')}',
          description: 'Task description $i',
          type: i.isEven ? 'simple' : 'location',
          status: TaskStatusEnum.values[i % TaskStatusEnum.values.length].dbValue,
          assignedTo: i % 3 == 0 ? 'user${i % 5 + 1}' : null,
          createdAt: DateTime.now(),
          dueDate: DateTime.now()
        ),
    ]);
    _updateDisplayedTasks();
  }

  bool hasMoreTasks() {
    return currentPage * tasksPerPage < allTasks.length;
  }

  Future<void> refreshTasks() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    currentPage.value = 1;
    loadTasks();
  }
  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      clearSelections();
    }
  }

  void toggleTaskSelection(String taskId) {
    if (selectedTaskIds.contains(taskId)) {
      selectedTaskIds.remove(taskId);
    } else {
      selectedTaskIds.add(taskId);
    }
  }

  void clearSelections() {
    selectedTaskIds.clear();
  }

  void deleteSelectedTasks() {
    tasks.removeWhere((task) => selectedTaskIds.contains(task.id));
    selectedTaskIds.clear();
    Get.snackbar('Success', 'Tasks deleted successfully');
    isSelectionMode.value = false;
  }

  void updateTask(String id, String description, String type, int status) {
    final index = tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      tasks[index] = tasks[index].copyWith(
        description: description,
        type: type,
        status: status,
      );
      tasks.refresh();
      Get.snackbar('Success', 'Task updated successfully');
    }
  }

  bool isTaskSelected(String taskId) {
    return selectedTaskIds.contains(taskId);
  }

  String getStatusText(int statusValue) {
    return TaskStatusEnum.fromDbValue(statusValue).uiValue;
  }

  void changeTaskStatus(String taskId, int newStatus) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      tasks[index] = tasks[index].copyWith(status: newStatus);
      tasks.refresh();
    }
  }

  // New methods for enhanced features
  void assignTasksToUser(String userId) {
    for (final taskId in selectedTaskIds) {
      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        tasks[index] = tasks[index].copyWith(
          assignedTo: userId,
          status: TaskStatusEnum.assigned.dbValue,
        );
      }
    }
    selectedTaskIds.clear();
    isSelectionMode.value = false;
    tasks.refresh();
  }

  void cancelSelectedTasks() {
    for (final taskId in selectedTaskIds) {
      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1 && tasks[index].status != TaskStatusEnum.completed.dbValue) {
        tasks[index] = tasks[index].copyWith(
          status: TaskStatusEnum.cancelled.dbValue,
        );
      }
    }
    selectedTaskIds.clear();
    isSelectionMode.value = false;
    tasks.refresh();
  }

  // Filtering methods
  List<Task> get unscheduledTasks => tasks.where((t) => t.status == TaskStatusEnum.unscheduled.dbValue).toList();
  List<Task> get assignedTasks => tasks.where((t) => t.status == TaskStatusEnum.assigned.dbValue).toList();
  List<Task> get completedTasks => tasks.where((t) => t.status == TaskStatusEnum.completed.dbValue).toList();
  List<Task> get cancelledTasks => tasks.where((t) => t.status == TaskStatusEnum.cancelled.dbValue).toList();
// Add these to TaskController


  void loadMoreTasks() {
    if (currentPage * tasksPerPage < allTasks.length) {
      currentPage++;
      _updateDisplayedTasks();
    }
  }

  void _updateDisplayedTasks() {
    tasks.value = allTasks.take(currentPage.value * tasksPerPage).toList();
  }

// Update your loadTasks method
}
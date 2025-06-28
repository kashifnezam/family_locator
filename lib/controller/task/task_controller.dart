import 'package:get/get.dart';

import '../../models/task/task_model.dart';

class TaskController extends GetxController {
  var tasks = <Task>[].obs;
  var isSelectionMode = false.obs;
  var taskId = ''.obs;
  var taskDescription = ''.obs;
  var taskType = 'simple'.obs; // 'simple' or 'location'
  @override
  void onInit() {
    super.onInit();
    // Load tasks from storage or API
    loadTasks();
  }

  void setTaskId(String id) => taskId.value = id;
  void setTaskDescription(String description) => taskDescription.value = description;
  void setTaskType(String type) => taskType.value = type;

  void addTask() {
    if (taskId.isEmpty || taskDescription.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    // Add to the tasks list
   tasks.add(Task(
      id: taskId.value,
      description: taskDescription.value,
      type: taskType.value,
    ));

    Get.snackbar('Success', 'Task added successfully');
    Get.back(); // Return to task list
    clearFields();
  }
  void clearFields() {
    taskId.value = '';
    taskDescription.value = '';
    taskType.value = 'simple';
  }

  void loadTasks() {
    // Replace with actual data loading
    tasks.assignAll([
      Task(id: 'T001', description: 'Complete project documentation', type: 'simple'),
      Task(id: 'T002', description: 'Visit client location', type: 'location'),
      Task(id: 'T003', description: 'Review code changes', type: 'simple'),
    ]);
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      clearSelections();
    }
  }

  void toggleTaskSelection(int index) {
    tasks[index].isSelected = !tasks[index].isSelected;
    tasks.refresh();
  }

  void clearSelections() {
    for (var task in tasks) {
      task.isSelected = false;
    }
    tasks.refresh();
  }

  void deleteSelectedTasks() {
    tasks.removeWhere((task) => task.isSelected);
    Get.snackbar('Success', 'Tasks deleted successfully');
    isSelectionMode.value = false;
  }

  void updateTask(String id, String description, String type) {
    final index = tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      tasks[index].description = description;
      tasks[index].type = type;
      tasks.refresh();
      Get.snackbar('Success', 'Task updated successfully');
    }
  }

}
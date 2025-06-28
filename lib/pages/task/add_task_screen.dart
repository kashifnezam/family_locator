import 'package:family_room/pages/dashboard_page/create_employee_view.dart';
import 'package:family_room/pages/members/create_member_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/task/task_controller.dart';

class AddTaskScreen extends StatelessWidget {
  final TaskController _taskController = Get.put(TaskController());

  AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTaskIdField(),
            const SizedBox(height: 20),
            _buildTaskDescriptionField(),
            const SizedBox(height: 20),
            _buildTaskTypeSelector(),
            const SizedBox(height: 30),
            _buildAddTaskButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskIdField() {
    return Obx(() => TextField(
          onChanged: _taskController.setTaskId,
          decoration: InputDecoration(
            labelText: 'Task ID',
            hintText: 'Enter unique task ID',
            prefixIcon: const Icon(Icons.numbers),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            errorText: _taskController.taskId.isEmpty &&
                    _taskController.taskId.isNotEmpty
                ? 'Please enter a task ID'
                : null,
          ),
          keyboardType: TextInputType.text,
        ));
  }

  Widget _buildTaskDescriptionField() {
    return Obx(() => TextField(
          onChanged: _taskController.setTaskDescription,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Task Description',
            hintText: 'Enter task details',
            alignLabelWithHint: true,
            prefixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            errorText: _taskController.taskDescription.isEmpty &&
                    _taskController.taskDescription.isNotEmpty
                ? 'Please enter a description'
                : null,
          ),
        ));
  }

  Widget _buildTaskTypeSelector() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Task Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Simple Task'),
                    selected: _taskController.taskType.value == 'simple',
                    onSelected: (selected) {
                      if (selected) _taskController.setTaskType('simple');
                    },
                    selectedColor: Theme.of(Get.context!).primaryColor,
                    labelStyle: TextStyle(
                      color: _taskController.taskType.value == 'simple'
                          ? Colors.white
                          : Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Location Task'),
                    selected: _taskController.taskType.value == 'location',
                    onSelected: (selected) {
                      if (selected) _taskController.setTaskType('location');
                    },
                    selectedColor: Theme.of(Get.context!).primaryColor,
                    labelStyle: TextStyle(
                      color: _taskController.taskType.value == 'location'
                          ? Colors.white
                          : Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Get.to(() => CreateMemberScreen()),
              child: Text("Create Employee"),
            ),
          ],
        ));
  }

  Widget _buildAddTaskButton() {
    return ElevatedButton(
      onPressed: _taskController.addTask,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(Get.context!).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 2,
      ),
      child: const Text(
        'ADD TASK',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

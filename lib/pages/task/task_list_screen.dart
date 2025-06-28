import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/task/task_controller.dart';
import '../../models/task/task_model.dart';
import 'add_task_screen.dart';


class TaskListScreen extends StatelessWidget {
  final TaskController _taskController = Get.put(TaskController());

  TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() => _buildTaskList()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddTaskScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
        title: Obx(() => Text(
      _taskController.isSelectionMode.value
          ? '${_taskController.tasks.where((task) => task.isSelected).length} Selected'
          : 'Task List',
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),),
    centerTitle: true,
    actions: [
    Obx(() => _taskController.isSelectionMode.value
    ? IconButton(
    icon: const Icon(Icons.delete),
    onPressed: _taskController.deleteSelectedTasks,
    )
        : IconButton(
    icon: const Icon(Icons.select_all),
    onPressed: _taskController.toggleSelectionMode,
    )),
    ],
    );
  }

  Widget _buildTaskList() {
    if (_taskController.tasks.isEmpty) {
      return const Center(
        child: Text('No tasks available. Add a new task!'),
      );
    }

    return ListView.builder(
      itemCount: _taskController.tasks.length,
      itemBuilder: (context, index) {
        final task = _taskController.tasks[index];
        return Obx(() => Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          child: InkWell(
            onTap: () {
              if (_taskController.isSelectionMode.value) {
                _taskController.toggleTaskSelection(index);
              } else {
                _navigateToEditScreen(task);
              }
            },
            onLongPress: () {
              _taskController.toggleSelectionMode();
              _taskController.toggleTaskSelection(index);
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  _buildSelectionCheckbox(index, task),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.id,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(
                              task.type.toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: task.type == 'simple'
                                ? Colors.blue[100]
                                : Colors.green[100],
                            visualDensity: VisualDensity.compact,
                          ),
                        ]),
                  ),
                  if (!_taskController.isSelectionMode.value)
                    const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        ));
      },
    );
  }

  Widget _buildSelectionCheckbox(int index, Task task) {
    return _taskController.isSelectionMode.value
        ? Checkbox(
      value: task.isSelected,
      onChanged: (value) {
        _taskController.toggleTaskSelection(index);
      },
    )
        : Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: task.type == 'simple' ? Colors.blue : Colors.green,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.task, color: Colors.white, size: 16),
    );
  }

  void _navigateToEditScreen(Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Task ID: ${task.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: TextEditingController(text: task.description),
                onChanged: (value) => task.description = value,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: task.type,
                items: const [
                  DropdownMenuItem(
                    value: 'simple',
                    child: Text('Simple Task'),
                  ),
                  DropdownMenuItem(
                    value: 'location',
                    child: Text('Location Task'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    task.type = value;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Task Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _taskController.updateTask(
                    task.id,
                    task.description,
                    task.type,
                  );
                  Get.back();
                },
                child: const Text('SAVE CHANGES'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('CANCEL'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
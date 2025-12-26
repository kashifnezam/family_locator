import 'package:family_room/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/task/task_controller.dart';
import '../../enum/task-status-enum.dart';
import '../../models/task/task_model.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  final TaskController _taskController = Get.put(TaskController());
  final RxString _currentFilter = 'all'.obs;

  TaskListScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchField(),
          _buildFilterChips(),
          _buildAdvancedFilters(),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _taskController.refreshTasks,
              child: _buildTaskList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Get.to(() => AddTaskScreen()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  AppBar _buildAppBar() {
    return AppBar(
      title: Obx(() => Text(
            _taskController.isSelectionMode.value
                ? '${_taskController.selectedTaskIds.length} Selected'
                : 'Task List',
            style: const TextStyle(fontWeight: FontWeight.bold),
          )),
      centerTitle: true,
      actions: [
        Obx(() {
          if (_taskController.isSelectionMode.value) {
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.person_add),
                  tooltip: 'Assign to user',
                  onPressed: () => _showUserSelectionDialog(),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  tooltip: 'Cancel tasks',
                  onPressed: _taskController.cancelSelectedTasks,
                ),
                if (_taskController.selectedTaskIds.every((id) {
                  final task =
                      _taskController.tasks.firstWhere((t) => t.id == id);
                  return task.status == TaskStatusEnum.unscheduled.dbValue;
                }))
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete tasks',
                    onPressed: _taskController.deleteSelectedTasks,
                  ),
              ],
            );
          } else {
            return IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _taskController.toggleSelectionMode,
            );
          }
        }),
      ],
    );
  }

  Widget _buildTaskList() {
    List<Task> filteredTasks;
    switch (_currentFilter.value) {
      case 'unscheduled':
        filteredTasks = _taskController.unscheduledTasks;
        break;
      case 'assigned':
        filteredTasks = _taskController.assignedTasks;
        break;
      case 'completed':
        filteredTasks = _taskController.completedTasks;
        break;
      case 'cancelled':
        filteredTasks = _taskController.cancelledTasks;
        break;
      default:
        filteredTasks = _taskController.tasks;
    }

    if (filteredTasks.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'No tasks available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentFilter.value == 'all'
                ? 'Tap + to add your first task'
                : 'No tasks match this filter',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _taskController.refreshTasks();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification &&
              scrollNotification.metrics.pixels ==
                  scrollNotification.metrics.maxScrollExtent) {
            _taskController.loadMoreTasks();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: filteredTasks.length + 1,
          itemBuilder: (context, index) {
            if (index == filteredTasks.length) {
              return _taskController.hasMoreTasks()
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const SizedBox();
            }

            final task = filteredTasks[index];
            return Obx(() => Card(
                  color: _getStatusTextColor(task.status),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      if (_taskController.isSelectionMode.value) {
                        _taskController.toggleTaskSelection(task.id);
                      } else {
                        _navigateToEditScreen(task);
                      }
                    },
                    onLongPress: () {
                      _taskController.toggleSelectionMode();
                      _taskController.toggleTaskSelection(task.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          _buildSelectionCheckbox(task),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      task.id,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (!_taskController.isSelectionMode.value)
                                      Text(
                                        _taskController
                                            .getStatusText(task.status),
                                        style: TextStyle(
                                          color:
                                              _getStatusTextColor(task.status),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  task.description,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
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
                                    if (task.assignedTo != null)
                                      Chip(
                                        label: Text(
                                          'Assigned: ${task.assignedTo!}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: Colors.purple[50],
                                        visualDensity: VisualDensity.compact,
                                        avatar: const Icon(
                                          Icons.person_outline,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!_taskController.isSelectionMode.value)
                            const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ));
          },
        ),
      ),
    );
  }

  Widget _buildSelectionCheckbox(Task task) {
    return _taskController.isSelectionMode.value
        ? Obx(() => Checkbox(
              value: _taskController.selectedTaskIds.contains(task.id),
              onChanged: (value) {
                _taskController.toggleTaskSelection(task.id);
              },
            ))
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
    final descriptionController = TextEditingController(text: task.description);
    final typeController = RxString(task.type);
    final statusController = RxInt(task.status);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Task Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // View-only fields
              _buildDetailRow('Task ID', task.id),
              _buildDetailRow('Created', task.createdAt.toString()),
              _buildDetailRow(
                  'Status', _taskController.getStatusText(task.status)),
              if (task.assignedTo != null)
                _buildDetailRow('Assigned To', task.assignedTo!),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Editable fields
              Text(
                'Edit Task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Obx(() => DropdownButtonFormField<String>(
                    value: typeController.value,
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
                    onChanged: (value) => typeController.value = value!,
                    decoration: InputDecoration(
                      labelText: 'Task Type',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _taskController.updateTask(
                    task.id,
                    descriptionController.text,
                    typeController.value,
                    task.status,
                  );
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('SAVE CHANGES'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _currentFilter.value == 'all',
                onSelected: (val) => _currentFilter.value = 'all',
              ),
              const SizedBox(width: 4),
              FilterChip(
                label: const Text('Unscheduled'),
                selected: _currentFilter.value == 'unscheduled',
                onSelected: (val) => _currentFilter.value = 'unscheduled',
              ),
              const SizedBox(width: 4),
              FilterChip(
                label: const Text('Assigned'),
                selected: _currentFilter.value == 'assigned',
                onSelected: (val) => _currentFilter.value = 'assigned',
              ),
              const SizedBox(width: 4),
              FilterChip(
                label: const Text('Completed'),
                selected: _currentFilter.value == 'completed',
                onSelected: (val) => _currentFilter.value = 'completed',
              ),
              const SizedBox(width: 4),
              FilterChip(
                label: const Text('Cancelled'),
                selected: _currentFilter.value == 'cancelled',
                onSelected: (val) => _currentFilter.value = 'cancelled',
              ),
            ],
          ),
        ));
  }

  void _showUserSelectionDialog() {
    final users =
        List.generate(100, (index) => 'user${index + 1}'); // Sample data
    final filteredUsers = users.obs;
    final searchController = TextEditingController();
    final scrollController = ScrollController();
    int currentPage = 1;
    const usersPerPage = 20;

    void filterUsers(String query) {
      if (query.isEmpty) {
        filteredUsers.value = users.take(usersPerPage).toList();
      } else {
        filteredUsers.value = users
            .where((user) => user.toLowerCase().contains(query.toLowerCase()))
            .take(usersPerPage)
            .toList();
      }
      currentPage = 1;
    }

    void loadMoreUsers() {
      final nextPageUsers =
          users.skip(currentPage * usersPerPage).take(usersPerPage).toList();

      if (nextPageUsers.isNotEmpty) {
        filteredUsers.addAll(nextPageUsers);
        currentPage++;
      }
    }

    // Initialize with first page
    filterUsers('');

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadMoreUsers();
      }
    });

    Get.dialog(
      AlertDialog(
        title: const Text('Assign to User'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: filterUsers,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Obx(() => ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      itemCount: filteredUsers.length,
                      itemBuilder: (ctx, index) {
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(filteredUsers[index]),
                          onTap: () {
                            _taskController
                                .assignTasksToUser(filteredUsers[index]);
                            Get.back();
                          },
                        );
                      },
                    )),
              ),
              Obx(() => filteredUsers.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No users found'),
                    )
                  : const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusTextColor(int status) {
    switch (TaskStatusEnum.fromDbValue(status)) {
      case TaskStatusEnum.assigned:
        return Colors.blue;
      case TaskStatusEnum.completed:
        return Colors.green;
      case TaskStatusEnum.cancelled:
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) => _taskController.searchQuery.value = value,
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(
            label: const Text('Simple Tasks'),
            selected: _taskController.activeFilters['simple']!,
            onSelected: (val) => _taskController.activeFilters['simple'] = val,
            backgroundColor: Colors.white,
            selectedColor: Colors.blue[100],
            checkmarkColor: AppColors.primary,
          ),
          FilterChip(
            label: const Text('Location Tasks'),
            selected: _taskController.activeFilters['location']!,
            onSelected: (val) => _taskController.activeFilters['location'] = val,
            backgroundColor: Colors.white,
            selectedColor: Colors.green[100],
            checkmarkColor: AppColors.primary,
          ),
          FilterChip(
            label: const Text('High Priority'),
            selected: _taskController.activeFilters['highPriority']!,
            onSelected: (val) => _taskController.activeFilters['highPriority'] = val,
            backgroundColor: Colors.white,
            selectedColor: Colors.red[100],
            checkmarkColor: AppColors.primary,
          ),
        ],
      ),
    ));
  }
}

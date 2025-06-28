// lib/controllers/employee_controller.dart
import 'package:get/get.dart';
import '../../models/dashboard_models/employee_model.dart';

class EmployeeController extends GetxController {
  final RxList<Employee> employees = <Employee>[].obs;

  Future<void> fetchEmployees() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    employees.assignAll([
      Employee(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        position: 'Senior Developer',
      ),
      Employee(
        id: '2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        phone: '+0987654321',
        position: 'Project Manager',
      ),
    ]);
  }

  Future<void> createEmployee(Employee employee) async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    employees.add(employee);
  }
}
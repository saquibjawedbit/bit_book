import 'package:f_star/controllers/attendance_list_controller.dart';
import 'package:f_star/controllers/premium_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/attendance_model.dart';

class AddSubjectScreen extends StatelessWidget {
  AddSubjectScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _requiredPercentageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceListController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Subject'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final subjectCount = controller.attendanceList.length;
              final isPremium = Get.find<PremiumController>().isPremium;

              return Text(
                isPremium
                    ? 'Premium User: Unlimited Subjects'
                    : 'Subjects: $subjectCount/${AttendanceListController.FREE_SUBJECT_LIMIT}',
                style: TextStyle(
                  color: subjectCount >=
                          AttendanceListController.FREE_SUBJECT_LIMIT
                      ? Colors.red
                      : Colors.white,
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      hintText: 'Subject Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter subject name';
                      }

                      if (controller.attendanceList
                          .any((a) => a.subject == value.trim())) {
                        return "Subject already exists";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _requiredPercentageController,
                    decoration: const InputDecoration(
                      hintText: 'Required Attendance Percentage [Optional]',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                      final percentage = double.tryParse(value);
                      if (percentage == null ||
                          percentage <= 0 ||
                          percentage > 100) {
                        return 'Please enter a valid percentage (1-100)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final subject = _subjectController.text;
                        final percentage = double.parse(
                            _requiredPercentageController.text.isNotEmpty
                                ? _requiredPercentageController.text
                                : "0.0");

                        final newSubject = AttendanceModel(
                          subject: subject,
                          requiredPercentage: percentage,
                          uid:
                              'subject_${DateTime.now().millisecondsSinceEpoch}',
                        );

                        controller.addSubject(newSubject);

                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Subject added successfully',
                          duration: const Duration(seconds: 1),
                          dismissDirection: DismissDirection.horizontal,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Add Subject'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

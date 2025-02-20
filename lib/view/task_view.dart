import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class TaskView extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    print(controller.speechService.transcribedText);
    return Scaffold(
      appBar: AppBar(title: Text("Tasks")),
      body: Obx(() {
        if (controller.tasks.isEmpty) {
          return Center(child: Text("No tasks available"));
        }

        return ListView.builder(
          itemCount: controller.tasks.length,
          itemBuilder: (context, index) {
            final task = controller.tasks[index];
            return Card(
              child: ListTile(
                title: Text(task.title,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Due: ${task.deadline}\n${task.details}"),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        );
      }),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nlp/controllers/home_controller.dart';
import 'package:nlp/services/database_service.dart';
import '../models/task_model.dart';

class HomeView extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: SweepGradient(colors: [
              Color(0xFF111516),
              Color(0xFF13423d),
              Color(0xFF1E5F5B),
              Color(0xFF2184A3),
              Color(0xFF153149),
              Color(0xFF0f1415),
            ])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black, Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    height: 80,
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 44,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            "Voice Assistant",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => controller.tasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/empty.png',
                                    height: 200, fit: BoxFit.cover),
                                Text(
                                  "No tasks available!",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 16.0),
                            child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: controller.tasks.length,
                              itemBuilder: (context, index) {
                                final task = controller.tasks[index];

                                return ClipRRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white12,
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      child: ListTile(
                                        title: Text(
                                          _capitalizeEachWord(task.title),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "Due: ${task.deadline}",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit,
                                                  color: Colors.blue),
                                              onPressed: () =>
                                                  _editTask(context, task),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () => _deleteTask(
                                                  context, task.id!),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Obx(() => Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          controller.speechService.transcribedText.value.isEmpty
                              ? "Press the button and start speaking..."
                              : controller.speechService.transcribedText.value,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )),
                SizedBox(height: 20),
                Obx(() {
                  if (controller.speechService.isListening.value) {
                    return Column(
                      children: [
                        Text(
                          "Listening for: ${controller.speechService.timerSeconds.value}s",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  }
                  return SizedBox();
                }),
                SizedBox(
                  height: 8,
                ),
                SizedBox(
                  height: 80,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 26,
            left: 0,
            right: 0,
            child: Obx(() => GestureDetector(
                  onTap: () async {
                    if (controller.speechService.isListening.value) {
                      await controller.speechService.stopListening();
                      await controller.processTranscription();
                    } else {
                      await controller.speechService.startListening();
                    }
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.all(
                        controller.speechService.isListening.value ? 16 : 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.speechService.isListening.value
                          ? Colors.red
                          : Colors.blue,
                      boxShadow: [
                        BoxShadow(
                          color: controller.speechService.isListening.value
                              ? Colors.redAccent
                              : Colors.blueAccent,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      controller.speechService.isListening.value
                          ? Icons.mic
                          : Icons.mic_none,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                )),
          )
        ],
      ),
    );
  }

  void _deleteTask(BuildContext context, int taskId) async {
    await DatabaseService().deleteTask(taskId);
    controller.fetchTasks();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Task deleted")));
  }

  void _editTask(BuildContext context, Task task) {
    TextEditingController titleController =
        TextEditingController(text: task.title);
    TextEditingController detailsController =
        TextEditingController(text: task.details);
    TextEditingController deadlineController =
        TextEditingController(text: task.deadline);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Title")),
              TextField(
                  controller: detailsController,
                  decoration: InputDecoration(labelText: "Details")),
              TextField(
                  controller: deadlineController,
                  decoration: InputDecoration(labelText: "Deadline")),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Save"),
              onPressed: () async {
                Task updatedTask = Task(
                  id: task.id,
                  title: titleController.text,
                  details: detailsController.text,
                  deadline: deadlineController.text,
                  createdAt: task.createdAt, // Keep original createdAt
                );

                await DatabaseService().updateTask(updatedTask);
                controller.fetchTasks();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Function to capitalize first letter of each word
  String _capitalizeEachWord(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word; // Handle empty strings
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}


  // ElevatedButton(
  //               onPressed: () {
  //                 controller.processTranscription();
  //               },
  //               child: Text("Process transcription")),
            
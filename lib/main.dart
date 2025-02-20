import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nlp/bindings/home_bindings.dart';
import 'package:nlp/view/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: HomeBinding(),
      debugShowCheckedModeBanner: false,
      title: 'Smart Voice Assistant',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeView(),
    );
  }
}

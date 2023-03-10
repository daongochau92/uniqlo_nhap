import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniqlo_nhap/routes/app_pages.dart';

import 'database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MyDatabase instance = MyDatabase.instance;
  await instance.getdatabase;
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ignore: unnecessary_new
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );
  }
}

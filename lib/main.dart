import 'package:flutter/material.dart';
import 'package:contacts_by_call_history/home_page.dart';
import 'package:provider/provider.dart';
import 'call_history_list.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CallHistoryList(),
      child: MaterialApp(
        title: 'Least Used Contacts',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)
        ),
        home: HomePage(),
      )
    );
  }
}

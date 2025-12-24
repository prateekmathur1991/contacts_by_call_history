import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';

class CallHistoryList extends ChangeNotifier {
  
  List<CallLogEntry> historyList = [];
  
  void fetchContactHistory() async {
    final Iterable<CallLogEntry> result = await CallLog.query();
    historyList = result.toList();
    notifyListeners();
  }
}
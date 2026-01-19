import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';

class CalendarPage extends StatelessWidget {
  final ApiService apiService;
  const CalendarPage({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        title: const Text('Calendar', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1c1842),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'Calendar Page (UI Placeholder)',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

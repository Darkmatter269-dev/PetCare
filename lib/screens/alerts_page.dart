import 'package:flutter/material.dart';
import '../widgets/in_page_nav.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'Alerts page (placeholder)',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const InPageNav(activeIndex: 3),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
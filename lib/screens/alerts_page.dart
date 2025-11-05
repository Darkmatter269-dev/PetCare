import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/in_page_nav.dart';
import '../models/alert_store.dart';


class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AlertStore>();
    final alerts = store.alerts;

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
              child: alerts.isEmpty
                  ? Center(child: Text('No alerts yet', style: TextStyle(color: Colors.grey[700])))
                  : ListView.separated(
                      itemCount: alerts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final a = alerts[i];
                        return ListTile(
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(a.message),
                          trailing: Text(
                            _formatTime(a.timestamp),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          onTap: () => store.markRead(a.id),
                        );
                      },
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

  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final am = t.hour >= 12 ? 'PM' : 'AM';
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m $am';
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule_store.dart';
import '../models/schedule.dart';
import 'contact_page.dart'; // <--- add this import
import '../models/alert_store.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color mintA = Color(0xFF97E8C6);
  static const Color mintB = Color(0xFF7FE1B6);
  static const Color bgMint = Color(0xFFF3FBF7);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final store = context.watch<ScheduleStore>();
    final today = DateTime.now();
    final todayList = store.forDate(today);
  final alertStore = context.watch<AlertStore>();
  final alerts = alertStore.alerts;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, bgMint],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PetCare',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: mintB,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: mintB.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Paw background + 2x2 feature buttons (reduced spacing)
                SizedBox(
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        child: Icon(
                          Icons.pets,
                          size: w * 0.62,
                          color: mintB.withOpacity(0.16),
                        ),
                      ),
                      Positioned(
                        child: SizedBox(
                          width: w - 40,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _FeatureCircle(
                                    icon: Icons.pets,
                                    label: 'MyPets',
                                    onTap: () => Navigator.of(context).pushNamed('/mypets'),
                                  ),
                                  const SizedBox(width: 18),
                                  _FeatureCircle(
                                    icon: Icons.phone_outlined,
                                    label: 'Contacts',
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const ContactPage()),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _FeatureCircle(
                                    icon: Icons.calendar_today,
                                    label: 'Calendar',
                                    onTap: () => Navigator.of(context).pushNamed('/calendar'),
                                  ),
                                  const SizedBox(width: 18),
                                  _FeatureCircle(
                                    icon: Icons.notifications_none,
                                    label: 'Alerts',
                                    onTap: () => Navigator.of(context).pushNamed('/alerts'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Today's Schedule header + divider
                const Text(
                  "Today's Schedule",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 64,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [mintA, mintB]),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: mintB.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // If there are no schedules, show Alerts immediately under the
                // Today's Schedule header. When schedules exist the Alerts header
                // will be rendered as a footer inside the schedule list so it
                // appears after the schedule items.
                if (todayList.isEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Alerts',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/alerts'),
                        child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // show a small preview of recent alerts
                  if (alerts.isNotEmpty)
                    Column(
                      children: alerts.take(2).map((a) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(a.message, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Text(a.timestamp.hour.toString().padLeft(2, '0')),
                        );
                      }).toList(),
                    ),
                ],

                // Schedules or placeholder. If there are schedules, render the Alerts
                // header as a footer inside the scrollable list so it appears directly
                // below the schedule items. If there are no schedules, keep Alerts
                // below the placeholder (rendered after Expanded).
                Expanded(
                  child: todayList.isEmpty
                      ? Center(
                          child: Text(
                            'No scheduled tasks for today. Add one from the Calendar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: todayList.length + 1, // extra footer for Alerts
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            if (i < todayList.length) {
                              final s = todayList[i];
                              return _HomeScheduleCard(schedule: s);
                            }
                            // Footer: Alerts header (appears after schedules)
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Alerts',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pushNamed('/alerts'),
                                      child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (alerts.isNotEmpty)
                                  Column(
                                    children: alerts.take(2).map((a) {
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                        subtitle: Text(a.message, maxLines: 1, overflow: TextOverflow.ellipsis),
                                        trailing: Text(a.timestamp.hour.toString().padLeft(2, '0')),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            );
                          },
                        ),
                ),

                // no additional footer here; Alerts is either shown above (when
                // no schedules) or included inside the list (when schedules exist).
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureCircle({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  static const Color mintA = Color(0xFF97E8C6);
  static const Color mintB = Color(0xFF7FE1B6);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [mintA, mintB]),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: mintB.withOpacity(0.18), width: 5),
            ),
            child: Center(
              child: Icon(icon, size: 32, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _HomeScheduleCard extends StatelessWidget {
  final Schedule schedule;
  const _HomeScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: Colors.teal[100], borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.event_note, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(schedule.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('${_formatTime(schedule.start)}  •  ${schedule.description}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ]),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
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
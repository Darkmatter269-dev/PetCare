import 'package:flutter/material.dart';

class InPageNav extends StatelessWidget {
  final int activeIndex; // 0: MyPets, 1: Contacts, 2: Calendar, 3: Alerts
  const InPageNav({super.key, this.activeIndex = 0});

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF7FE1B6);
    Widget navItem(IconData icon, String label, int index, String route) {
      final active = index == activeIndex;
      return GestureDetector(
        onTap: () {
          if (!active) Navigator.of(context).pushReplacementNamed(route);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? activeColor : Colors.white,
                boxShadow: active
                    ? [BoxShadow(color: activeColor.withOpacity(0.22), blurRadius: 10, offset: Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: Offset(0, 2))],
                border: Border.all(color: active ? activeColor.withOpacity(0.18) : Colors.grey.withOpacity(0.08), width: 2),
              ),
              child: Icon(icon, color: active ? Colors.white : Colors.black54, size: 20),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.black87 : Colors.black54)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navItem(Icons.pets, 'MyPets', 0, '/mypets'),
          navItem(Icons.phone_outlined, 'Contacts', 1, '/contact'),
          navItem(Icons.calendar_today, 'Calendar', 2, '/calendar'),
          navItem(Icons.notifications_none, 'Alerts', 3, '/alerts'),
        ],
      ),
    );
  }
}
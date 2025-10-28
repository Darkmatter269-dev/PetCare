import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule_store.dart';
import '../models/schedule.dart';
import '../widgets/in_page_nav.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _prevMonth() => setState(() => displayedMonth = DateTime(displayedMonth.year, displayedMonth.month - 1));
  void _nextMonth() => setState(() => displayedMonth = DateTime(displayedMonth.year, displayedMonth.month + 1));

  List<DateTime> _visibleDays() {
    final first = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final start = first.subtract(Duration(days: first.weekday % 7)); // start on Sunday
    return List.generate(42, (i) => start.add(Duration(days: i)));
  }

  String _monthName(int m) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return names[m - 1];
  }

  void _showAddModal(BuildContext ctx, DateTime initialDate) {
    // isScrollControlled + FractionallySizedBox + SingleChildScrollView
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final kb = MediaQuery.of(ctx).viewInsets.bottom;
        return FractionallySizedBox(
          heightFactor: 0.62, // tune if you want taller/shorter sheet
          child: Padding(
            padding: EdgeInsets.only(bottom: kb),
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AddEditForm(date: initialDate),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ScheduleStore>();
    final days = _visibleDays();
    final monthLabel = "${_monthName(displayedMonth.month)} ${displayedMonth.year}";
    const horizontalPadding = 16.0;

    // compute responsive cell sizes based on available width (prevents per-cell overflow)
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = max(0.0, screenWidth - horizontalPadding * 2);
    final cellWidth = availableWidth / 7;
    // choose a minimum cell height to fit circle + small text; cellHeight scales with width
    final cellHeight = max(56.0, cellWidth * 0.9);
    final childAspectRatio = cellWidth / cellHeight; // width / height

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                    Text(monthLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: ['S','M','T','W','T','F','S']
                      .map((d) => Expanded(child: Center(child: Text(d, style: TextStyle(color: Colors.grey[600])))))
                      .toList(),
                ),
              ),
            ),

            // Responsive grid: childAspectRatio computed above so cells have enough vertical room
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: childAspectRatio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (gridCtx, index) {
                    final d = days[index];
                    final inMonth = d.month == displayedMonth.month;
                    final hasEvents = context.read<ScheduleStore>().forDate(d).isNotEmpty;
                    final now = DateTime.now();
                    final isToday = now.year == d.year && now.month == d.month && now.day == d.day;
                    final isSelected = store.selectedDate.year == d.year &&
                        store.selectedDate.month == d.month &&
                        store.selectedDate.day == d.day;

                    // circle size scales to the cell width but capped
                    final circleSize = min(cellWidth * 0.62, 46.0);

                    return GestureDetector(
                      onTap: () => store.setSelectedDate(d),
                      child: Opacity(
                        opacity: inMonth ? 1.0 : 0.45,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: circleSize,
                                height: circleSize,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF7FE1B6) : isToday ? const Color(0xFF97E8C6) : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${d.day}',
                                  style: TextStyle(
                                    color: isSelected || isToday ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                    fontSize: max(12.0, circleSize * 0.36),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (hasEvents)
                                Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.teal[300], shape: BoxShape.circle)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: days.length,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pet Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    TextButton(onPressed: () => _showAddModal(context, store.selectedDate), child: const Text('+ Add Reminder')),
                  ],
                ),
              ),
            ),

            // Reminders list (sliver)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
              sliver: Consumer<ScheduleStore>(builder: (ctx, s, _) {
                final items = s.forDate(s.selectedDate);
                if (items.isEmpty) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 220,
                      child: Center(child: Text('No reminders for selected date.', style: TextStyle(color: Colors.grey[600]))),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (c, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ReminderCard(schedule: items[i]),
                    ),
                    childCount: items.length,
                  ),
                );
              }),
            ),

            // bottom spacer so content isn't hidden behind nav
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.bottom + 12)),
          ],
        ),
      ),

      // fixed in-page nav at bottom (outside scroll area) — prevents overlap/overflow
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: const InPageNav(activeIndex: 2),
        ),
      ),
    );
  }
}

/* ---------- Add / Edit form and reminder card (kept minimal/functional) ---------- */

class _AddEditForm extends StatefulWidget {
  final DateTime date;
  final Schedule? editing;
  const _AddEditForm({required this.date, this.editing});

  @override
  State<_AddEditForm> createState() => _AddEditFormState();
}

class _AddEditFormState extends State<_AddEditForm> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    _date = widget.editing?.start ?? DateTime(widget.date.year, widget.date.month, widget.date.day);
    _time = widget.editing != null ? TimeOfDay.fromDateTime(widget.editing!.start) : TimeOfDay.now();
    if (widget.editing != null) {
      _title.text = widget.editing!.title;
      _desc.text = widget.editing!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<ScheduleStore>();

    // The sheet is already wrapped in a SingleChildScrollView; keep this column minimal and flexible.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // header
          Row(children: [
            IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
            const Expanded(child: Center(child: Text('Add Reminder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)))),
            const SizedBox(width: 48),
          ]),
          const SizedBox(height: 8),

          // title
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Task Title')),
          const SizedBox(height: 12),

          // description
          TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          const SizedBox(height: 12),

          // date & time row
          Row(children: [
            TextButton.icon(
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: _date!, firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (d != null) setState(() => _date = d);
              },
              icon: const Icon(Icons.calendar_today),
              label: Text('${_date!.month}/${_date!.day}/${_date!.year}'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () async {
                final t = await showTimePicker(context: context, initialTime: _time ?? TimeOfDay.now());
                if (t != null) setState(() => _time = t);
              },
              icon: const Icon(Icons.access_time),
              label: Text(_time!.format(context)),
            ),
          ]),
          const SizedBox(height: 12),

          // actions
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final dt = DateTime(_date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute);
                final id = widget.editing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
                final s = Schedule(
                  id: id,
                  title: _title.text.trim().isEmpty ? 'Untitled' : _title.text.trim(),
                  description: _desc.text.trim(),
                  start: dt,
                  end: dt.add(const Duration(minutes: 30)),
                );
                if (widget.editing == null) {
                  store.add(s);
                } else {
                  store.update(s);
                }
                store.setSelectedDate(dt);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ]),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Schedule schedule;
  const _ReminderCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final store = context.read<ScheduleStore>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.teal[100], borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.event, color: Colors.white)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(schedule.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('${_fmt(schedule.start)}  •  ${schedule.description}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ]),
        ),
        IconButton(onPressed: () => _edit(context, schedule), icon: const Icon(Icons.edit_outlined)),
        IconButton(onPressed: () => store.remove(schedule.id), icon: const Icon(Icons.delete_outline)),
      ]),
    );
  }

  void _edit(BuildContext ctx, Schedule s) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _AddEditForm(date: s.start, editing: s),
      ),
    );
  }

  String _fmt(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final am = t.hour >= 12 ? 'PM' : 'AM';
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m $am';
  }
}
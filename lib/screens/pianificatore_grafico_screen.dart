import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/planner_activity.dart';
import '../providers/app_choice_provider.dart';
import '../providers/planner_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/planner_layout.dart';
import '../widgets/planner_activity_modal.dart';

const _hourHeight = 64.0;
const _timeColumnWidth = 52.0;

class PianificatoreGraficoScreen extends ConsumerStatefulWidget {
  const PianificatoreGraficoScreen({super.key});

  @override
  ConsumerState<PianificatoreGraficoScreen> createState() =>
      _PianificatoreGraficoScreenState();
}

class _PianificatoreGraficoScreenState
    extends ConsumerState<PianificatoreGraficoScreen> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _changeDay(int delta) {
    setState(() {
      _selectedDay = _selectedDay.add(Duration(days: delta));
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('it', 'IT'),
    );
    if (picked != null) {
      setState(() {
        _selectedDay = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  void _openAddModal(List<PlannerActivity> allActivities) {
    showPlannerActivityModal(
      context,
      selectedDay: _selectedDay,
      defaultColorIndex: allActivities.length,
    );
  }

  void _openEditModal(PlannerActivity activity) {
    HapticFeedback.mediumImpact();
    showPlannerActivityModal(
      context,
      selectedDay: _selectedDay,
      activity: activity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final activitiesAsync = ref.watch(plannerActivitiesStreamProvider);

    final dayName = DateFormat.EEEE('it_IT').format(_selectedDay);
    final formattedDate =
        DateFormat('d MMMM yyyy', 'it_IT').format(_selectedDay);
    final capitalizedDayName = dayName.isNotEmpty
        ? '${dayName[0].toUpperCase()}${dayName.substring(1)}'
        : dayName;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.apps_rounded),
          tooltip: 'Cambia applicazione',
          onPressed: () {
            ref.read(appChoiceProvider.notifier).setAppChoice(null);
          },
        ),
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Giorno precedente',
              onPressed: () => _changeDay(-1),
            ),
            Expanded(
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        capitalizedDayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Giorno successivo',
              onPressed: () => _changeDay(1),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Seleziona data',
            onPressed: _pickDate,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Aggiungi attività',
            onPressed: () {
              final all = activitiesAsync.asData?.value ?? [];
              _openAddModal(all);
            },
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            tooltip: 'Cambia tema',
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: activitiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Errore nel caricamento: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (allActivities) {
          final dayActivities = activitiesForDay(allActivities, _selectedDay);
          final layout = computeDayLayout(dayActivities, _selectedDay);

          return LayoutBuilder(
            builder: (context, constraints) {
              final timelineWidth = constraints.maxWidth - _timeColumnWidth;

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: SizedBox(
                  height: _hourHeight * 24,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TimeColumn(isDarkMode: isDarkMode),
                      Expanded(
                        child: _DayTimeline(
                          layout: layout,
                          timelineWidth: timelineWidth,
                          isDarkMode: isDarkMode,
                          onLongPress: _openEditModal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final bool isDarkMode;

  const _TimeColumn({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _timeColumnWidth,
      height: _hourHeight * 24,
      child: Stack(
        children: [
          for (var hour = 0; hour < 24; hour++)
            Positioned(
              top: hour * _hourHeight - 8,
              left: 0,
              right: 4,
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.white54 : Colors.black45,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}

class _DayTimeline extends StatelessWidget {
  final List<PlannerLayoutItem> layout;
  final double timelineWidth;
  final bool isDarkMode;
  final void Function(PlannerActivity) onLongPress;

  const _DayTimeline({
    required this.layout,
    required this.timelineWidth,
    required this.isDarkMode,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final gridColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final halfGridColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.03);

    return Stack(
      children: [
        for (var slot = 0; slot < 48; slot++)
          Positioned(
            top: slot * (_hourHeight / 2),
            left: 0,
            right: 0,
            child: Divider(
              height: 1,
              thickness: slot.isEven ? 1 : 0.5,
              color: slot.isEven ? gridColor : halfGridColor,
            ),
          ),
        for (final item in layout)
          _ActivityBlock(
            item: item,
            timelineWidth: timelineWidth,
            onLongPress: () => onLongPress(item.activity),
          ),
      ],
    );
  }
}

class _ActivityBlock extends StatelessWidget {
  final PlannerLayoutItem item;
  final double timelineWidth;
  final VoidCallback onLongPress;

  const _ActivityBlock({
    required this.item,
    required this.timelineWidth,
    required this.onLongPress,
  });

  double _topOffset(DateTime time) {
    final minutes = time.hour * 60 + time.minute;
    return (minutes / 60) * _hourHeight;
  }

  double _height(DateTime start, DateTime end) {
    final minutes = end.difference(start).inMinutes;
    return (minutes / 60) * _hourHeight;
  }

  @override
  Widget build(BuildContext context) {
    final top = _topOffset(item.displayStart);
    final height =
        _height(item.displayStart, item.displayEnd).clamp(4.0, double.infinity);
    final columnWidth = timelineWidth / item.totalColumns;
    const horizontalPadding = 2.0;
    final left = item.column * columnWidth + horizontalPadding;
    final width = columnWidth - horizontalPadding * 2;

    return Positioned(
      top: top,
      left: left,
      width: width,
      height: height,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: item.activity.color.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: item.activity.color.withValues(alpha: 0.3),
            ),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              item.activity.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/planner_activity.dart';
import '../providers/planner_provider.dart';

class PlannerActivityModal extends ConsumerStatefulWidget {
  final DateTime selectedDay;
  final PlannerActivity? activity;
  final int defaultColorIndex;

  const PlannerActivityModal({
    super.key,
    required this.selectedDay,
    this.activity,
    this.defaultColorIndex = 0,
  });

  @override
  ConsumerState<PlannerActivityModal> createState() =>
      _PlannerActivityModalState();
}

class _PlannerActivityModalState extends ConsumerState<PlannerActivityModal> {
  late final TextEditingController _nameController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _colorValue;
  String? _errorMessage;

  bool get _isEditing => widget.activity != null;

  @override
  void initState() {
    super.initState();
    final activity = widget.activity;
    if (activity != null) {
      _nameController = TextEditingController(text: activity.name);
      _startTime = TimeOfDay.fromDateTime(activity.startDateTime);
      _endTime = TimeOfDay.fromDateTime(activity.endDateTime);
      _colorValue = activity.colorValue;
    } else {
      _nameController = TextEditingController();
      final now = TimeOfDay.now();
      _startTime = TimeOfDay(hour: now.hour, minute: 0);
      _endTime = TimeOfDay(
        hour: (now.hour + 1) % 24,
        minute: 0,
      );
      _colorValue = PlannerActivity.defaultColorForIndex(
        widget.defaultColorIndex,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  DateTime _resolveEndDateTime(DateTime start, TimeOfDay endTime) {
    var end = _combineDateAndTime(
      DateTime(start.year, start.month, start.day),
      endTime,
    );
    if (!end.isAfter(start)) {
      end = end.add(const Duration(days: 1));
    }
    return end;
  }

  String? _validate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return 'Il nome attività è obbligatorio';
    }

    final startDate = widget.activity?.startDateTime ?? widget.selectedDay;
    final start = _combineDateAndTime(startDate, _startTime);
    final end = _resolveEndDateTime(start, _endTime);

    if (end.difference(start).inMinutes < 10) {
      return 'La durata minima è di 10 minuti';
    }

    return null;
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
      _errorMessage = null;
    });
  }

  Future<void> _save() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    final startDate = widget.activity?.startDateTime ?? widget.selectedDay;
    final start = _combineDateAndTime(startDate, _startTime);
    final end = _resolveEndDateTime(start, _endTime);

    final activity = PlannerActivity(
      id: widget.activity?.id ?? '',
      name: _nameController.text.trim(),
      startDateTime: start,
      endDateTime: end,
      colorValue: _colorValue,
    );

    await ref.read(plannerServiceProvider).saveActivity(activity);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina attività'),
        content: const Text('Sei sicuro di voler eliminare questa attività?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed != true || widget.activity == null) return;

    await ref
        .read(plannerServiceProvider)
        .deleteActivity(widget.activity!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hm('it_IT');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? 'Modifica attività' : 'Nuova attività',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome attività *',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() => _errorMessage = null),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(isStart: true),
                    icon: const Icon(Icons.access_time),
                    label: Text('Inizio: ${timeFormat.format(_timeAsDate(_startTime))}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(isStart: false),
                    icon: const Icon(Icons.access_time),
                    label: Text('Fine: ${timeFormat.format(_timeAsDate(_endTime))}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Colore',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: PlannerActivity.defaultPalette.map((color) {
                final value = color.toARGB32();
                final selected = value == _colorValue;
                return GestureDetector(
                  onTap: () => setState(() => _colorValue = value),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Salva modifiche' : 'Aggiungi attività'),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Elimina attività'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  DateTime _timeAsDate(TimeOfDay time) {
    return DateTime(2000, 1, 1, time.hour, time.minute);
  }
}

Future<void> showPlannerActivityModal(
  BuildContext context, {
  required DateTime selectedDay,
  PlannerActivity? activity,
  int defaultColorIndex = 0,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => PlannerActivityModal(
      selectedDay: selectedDay,
      activity: activity,
      defaultColorIndex: defaultColorIndex,
    ),
  );
}

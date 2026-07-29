import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../models/app_task.dart';
import '../providers/routine_provider.dart';
import '../services/notification_service.dart';
import '../services/watch_service.dart';
import 'package:intl/intl.dart';

class RoutineDetailScreen extends ConsumerStatefulWidget {
  final Routine? routine;

  const RoutineDetailScreen({super.key, this.routine});

  @override
  ConsumerState<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends ConsumerState<RoutineDetailScreen> {
  late TextEditingController _nameController;
  late DateTime _targetEndTime;
  late List<AppTask> _tasks;
  late List<AppTask> _bedtimeTasks;
  late int _sleepCycles;
  bool _isSaving = false;
  bool _isSleepEnabled = false;
  String? _pendingDeleteTaskId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.routine?.name ?? '');
    _targetEndTime = widget.routine?.targetEndTime ?? DateTime.now().copyWith(hour: 8, minute: 30);
    _tasks = widget.routine != null ? List.from(widget.routine!.tasks) : [];
    _bedtimeTasks = widget.routine != null ? List.from(widget.routine!.bedtimeTasks) : [];
    _sleepCycles = widget.routine?.sleepCycles ?? 0;
    _isSleepEnabled = _sleepCycles > 0;
    
    // Ensure all tasks have unique IDs for ReorderableListView keys
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].id.isEmpty) {
        _tasks[i] = _tasks[i].copyWith(id: 'task_${i}_${DateTime.now().microsecondsSinceEpoch}');
      }
    }
    for (int i = 0; i < _bedtimeTasks.length; i++) {
      if (_bedtimeTasks[i].id.isEmpty) {
        _bedtimeTasks[i] = _bedtimeTasks[i].copyWith(id: 'btask_${i}_${DateTime.now().microsecondsSinceEpoch}');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_targetEndTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        _targetEndTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      });
    }
  }

  void _addTask({bool isBedtime = false}) {
    setState(() {
      final newTask = AppTask(
        id: '${isBedtime ? 'bt' : 'mt'}_${DateTime.now().microsecondsSinceEpoch}_${(isBedtime ? _bedtimeTasks : _tasks).length}',
        title: '',
        duration: const Duration(minutes: 15),
      );
      if (isBedtime) {
        _bedtimeTasks.add(newTask);
      } else {
        _tasks.add(newTask);
      }
    });
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci un nome per la routine')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final routineToSave = Routine(
        id: widget.routine?.id ?? '',
        name: _nameController.text,
        targetEndTime: _targetEndTime,
        tasks: _tasks,
        sleepCycles: _isSleepEnabled ? _sleepCycles : 0,
        bedtimeTasks: _isSleepEnabled ? _bedtimeTasks : [],
      );

      await ref.read(routineServiceProvider).saveRoutine(routineToSave);
      
      // Sincronizza con Apple Watch
      await WatchService().syncRoutine(routineToSave);
      
      // Schedule notifications for this routine
      await NotificationService().scheduleRoutineNotifications(routineToSave);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante il salvataggio: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a dummy routine to calculate the temporary schedule
    final tempRoutine = Routine(
      id: '',
      name: '',
      targetEndTime: _targetEndTime,
      tasks: _tasks,
      sleepCycles: _isSleepEnabled ? (_sleepCycles == 0 ? 5 : _sleepCycles) : 0,
      bedtimeTasks: _bedtimeTasks,
    );
    final schedule = tempRoutine.getSchedule();
    final bedtimeSchedule = tempRoutine.getBedtimeSchedule();
    final timeFormat = DateFormat('HH:mm');

    final wakeUpTime = schedule.isNotEmpty ? schedule.first['startTime'] as DateTime : null;
    final fallAsleepTime = wakeUpTime != null && _isSleepEnabled 
        ? wakeUpTime.subtract(Duration(minutes: (_sleepCycles == 0 ? 5 : _sleepCycles) * 90)) 
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine == null ? 'Nuova Routine' : 'Modifica Routine'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('SALVA', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Nome della routine (es: Mattina)',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => _selectTime(context),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text('Orario di fine/uscita', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeFormat.format(_targetEndTime),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // SLEEP MANAGEMENT SECTION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isSleepEnabled 
                    ? Colors.indigo.withValues(alpha: 0.1) 
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isSleepEnabled ? Colors.indigo.withValues(alpha: 0.3) : Colors.transparent,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.nightlight_round, color: _isSleepEnabled ? Colors.indigoAccent : Colors.grey),
                          const SizedBox(width: 12),
                          const Text('Gestione Sonno', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Switch(
                        value: _isSleepEnabled,
                        onChanged: (val) {
                          setState(() {
                            _isSleepEnabled = val;
                            if (val && _sleepCycles == 0) _sleepCycles = 5;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isSleepEnabled) ...[
                    const SizedBox(height: 20),
                    const Text('Quanti cicli di sonno vuoi fare?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [4, 5, 6].map((c) => ChoiceChip(
                          label: Text('$c Cicli (${(c * 1.5).toString().replaceAll('.0', '')} ore)'),
                          selected: _sleepCycles == c,
                          onSelected: (selected) {
                            if (selected) setState(() => _sleepCycles = c);
                          },
                        )).toList(),
                      ),
                    ),
                    if (fallAsleepTime != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('Dovrai addormentarti alle: ', style: TextStyle(fontSize: 14)),
                            Text(timeFormat.format(fallAsleepTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigoAccent)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('PREPARAZIONE AL SONNO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigoAccent, letterSpacing: 1.2, fontSize: 12)),
                      const SizedBox(height: 16),
                      _buildTaskList(bedtimeSchedule, isBedtime: true),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _addTask(isBedtime: true),
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text('AGGIUNGI COMPITO SERALE', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(foregroundColor: Colors.indigoAccent),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            const Text('PIANIFICAZIONE MATTUTINA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 1.2, fontSize: 12)),
            const SizedBox(height: 16),
            _buildTaskList(schedule, isBedtime: false),
            const SizedBox(height: 20),
            Center(
              child: TextButton.icon(
                onPressed: () => _addTask(isBedtime: false),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('AGGIUNGI COMPITO MATTUTINO'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> schedule, {required bool isBedtime}) {
    final tasks = isBedtime ? _bedtimeTasks : _tasks;
    
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        final item = schedule[index];
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            return Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(15),
              color: Colors.transparent,
              child: _buildTaskCard(item, index, isBedtime, isDragging: true),
            );
          },
        );
      },
      onReorderItem: (oldIndex, newIndex) {
        setState(() {
          final item = tasks.removeAt(oldIndex);
          tasks.insert(newIndex, item);
        });
      },
      children: schedule.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final task = item['task'] as AppTask;

        return Padding(
          key: ValueKey(task.id),
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTaskCard(item, index, isBedtime),
        );
      }).toList(),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> item, int index, bool isBedtime, {bool isDragging = false}) {
    final task = item['task'] as AppTask;
    final startTime = item['startTime'] as DateTime;
    final timeFormat = DateFormat('HH:mm');
    final tasks = isBedtime ? _bedtimeTasks : _tasks;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDragging 
            ? Theme.of(context).colorScheme.surface 
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDragging 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)
        ),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator, 
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: isDragging ? 0.54 : 0.24)
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text(timeFormat.format(startTime),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Icon(Icons.arrow_downward, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
              Text(timeFormat.format(item['endTime']),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 12)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: task.title,
                  onChanged: (val) {
                    if (isBedtime) {
                      _bedtimeTasks[index] = _bedtimeTasks[index].copyWith(title: val);
                    } else {
                      _tasks[index] = _tasks[index].copyWith(title: val);
                    }
                  },
                  decoration: const InputDecoration(
                      border: InputBorder.none, isDense: true, hintText: 'Cosa devi fare?'),
                ),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 40,
                      child: TextFormField(
                        initialValue: task.duration.inMinutes.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          final mins = int.tryParse(val) ?? 0;
                          setState(() {
                            if (isBedtime) {
                              _bedtimeTasks[index] = _bedtimeTasks[index].copyWith(duration: Duration(minutes: mins));
                            } else {
                              _tasks[index] = _tasks[index].copyWith(duration: Duration(minutes: mins));
                            }
                          });
                        },
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                      ),
                    ),
                    const Text('minuti', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _pendingDeleteTaskId == task.id ? Icons.delete : Icons.delete_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: () {
              if (_pendingDeleteTaskId == task.id) {
                setState(() {
                  tasks.removeAt(index);
                  _pendingDeleteTaskId = null;
                });
              } else {
                setState(() {
                  _pendingDeleteTaskId = task.id;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

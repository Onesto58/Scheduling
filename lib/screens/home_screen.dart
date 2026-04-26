import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/routine_provider.dart';
import '../providers/cache_provider.dart';
import '../models/routine.dart';
import 'routine_detail_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesStreamProvider);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    // Keep cache active
    ref.watch(routinesCacheProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text(
              'Routines',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
                onPressed: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
            ],
          ),
          routinesAsync.when(
            skipLoadingOnReload: true,
            data: (routines) => _buildRoutineList(context, routines),
            loading: () {
              final cachedRoutines = ref.read(routinesCacheProvider);
              if (cachedRoutines != null) {
                return _buildRoutineList(context, cachedRoutines);
              }
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            },
            error: (err, stack) =>
                SliverFillRemaining(child: Center(child: Text('Errore: $err'))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const RoutineDetailScreen(routine: null),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRoutineList(BuildContext context, List<Routine> routines) {
    if (routines.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'Nessuna routine salvata.\nInizia premendo il tasto +',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          routines.map((routine) => _RoutineCard(routine: routine)).toList(),
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final Routine routine;

  const _RoutineCard({required this.routine});

  @override
  Widget build(BuildContext context) {
    final schedule = routine.getSchedule();
    final firstTaskStartTime = schedule.isNotEmpty
        ? schedule.first['startTime'] as DateTime
        : null;
    final bedtimeSchedule = routine.getBedtimeSchedule();
    final firstBedtimeStartTime = bedtimeSchedule.isNotEmpty
        ? bedtimeSchedule.first['startTime'] as DateTime
        : null;
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        title: Text(
          routine.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.exit_to_app,
                  size: 16,
                  color: Colors.blueAccent,
                ),
                const SizedBox(width: 4),
                Text('Uscita: ${timeFormat.format(routine.targetEndTime)}'),
                const SizedBox(width: 16),
                if (firstTaskStartTime != null) ...[
                  Text('Sveglia: ${timeFormat.format(firstTaskStartTime)}'),
                ],
              ],
            ),
            if (firstBedtimeStartTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.nightlight_round,
                    size: 16,
                    color: Colors.indigoAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Inizio prep. sonno: ${timeFormat.format(firstBedtimeStartTime)}',
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${routine.tasks.length} compiti pianificati',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  RoutineDetailScreen(routine: routine),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
      ),
    );
  }
}

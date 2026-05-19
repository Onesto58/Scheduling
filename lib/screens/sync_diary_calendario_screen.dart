import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/sync_appointment.dart';
import '../providers/sync_appointment_provider.dart';
import '../providers/theme_provider.dart';
import 'sync_diary_appuntamento_detail_screen.dart';

class SyncDiaryCalendarioScreen extends ConsumerStatefulWidget {
  const SyncDiaryCalendarioScreen({super.key});

  @override
  ConsumerState<SyncDiaryCalendarioScreen> createState() => _SyncDiaryCalendarioScreenState();
}

class _SyncDiaryCalendarioScreenState extends ConsumerState<SyncDiaryCalendarioScreen> {
  DateTime _currentDate = DateTime.now();
  String _viewMode = 'month'; // 'month' or 'week'

  Color _getStatusColor(String status, bool isDarkMode) {
    switch (status) {
      case 'previsto':
        return isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8); // Slate
      case 'svolto':
        return const Color(0xFF0EA5E9); // Sky blue
      case 'pagato':
        return const Color(0xFF16A34A); // Green
      case 'annullato':
        return const Color(0xFFEF4444); // Red
      default:
        return isDarkMode ? Colors.white24 : Colors.black26;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'previsto':
        return 'Previsto';
      case 'svolto':
        return 'Svolto';
      case 'pagato':
        return 'Pagato';
      case 'annullato':
        return 'Annullato';
      default:
        return status;
    }
  }

  DateTime _getMonday(DateTime date) {
    final diff = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: diff));
  }

  void _handlePrevious() {
    setState(() {
      if (_viewMode == 'month') {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      } else {
        _currentDate = _currentDate.subtract(const Duration(days: 7));
      }
    });
  }

  void _handleNext() {
    setState(() {
      if (_viewMode == 'month') {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      } else {
        _currentDate = _currentDate.add(const Duration(days: 7));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointments = ref.watch(syncAppointmentsProvider);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    // Filter appointments for active range to display count (optional info)
    final dateFormatted = _viewMode == 'month'
        ? DateFormat('MMMM yyyy', 'it_IT').format(_currentDate)
        : 'Settimana del ${DateFormat('dd/MM/yyyy', 'it_IT').format(_getMonday(_currentDate))}';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // View Mode Selectors (Mese / Settimana)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _viewMode = 'month'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _viewMode == 'month'
                                  ? (isDarkMode ? const Color(0xFF0F172A) : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _viewMode == 'month'
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              'Mese',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _viewMode == 'month'
                                    ? (isDarkMode ? Colors.white : const Color(0xFF0F172A))
                                    : (isDarkMode ? Colors.white60 : const Color(0xFF64748B)),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _viewMode = 'week'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _viewMode == 'week'
                                  ? (isDarkMode ? const Color(0xFF0F172A) : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _viewMode == 'week'
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              'Settimana',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _viewMode == 'week'
                                    ? (isDarkMode ? Colors.white : const Color(0xFF0F172A))
                                    : (isDarkMode ? Colors.white60 : const Color(0xFF64748B)),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Calendar Navigation Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: _handlePrevious,
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                        side: BorderSide(
                          color: isDarkMode ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      dateFormatted[0].toUpperCase() + dateFormatted.substring(1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _handleNext,
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                        side: BorderSide(
                          color: isDarkMode ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Render Calendar
                Expanded(
                  child: _viewMode == 'month'
                      ? _buildMonthView(appointments, isDarkMode)
                      : _buildWeekView(appointments, isDarkMode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthView(List<SyncAppointment> appointments, bool isDarkMode) {
    final year = _currentDate.year;
    final month = _currentDate.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;
    final adjustedStart = firstDay.weekday - 1; // Monday = 0, Sunday = 6

    final List<Widget> children = [];
    final weekDays = ["Lun", "Mar", "Mer", "Gio", "Ven", "Sab", "Dom"];

    // Headers
    for (var d in weekDays) {
      children.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              d,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isDarkMode ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
        ),
      );
    }

    // Empty spots
    for (int i = 0; i < adjustedStart; i++) {
      children.add(const SizedBox.shrink());
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      // Find appointment
      final appointment = appointments.cast<SyncAppointment?>().firstWhere(
            (a) => a?.date == dateStr,
            orElse: () => null,
          );

      children.add(
        GestureDetector(
          onTap: () {
            if (appointment != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SyncDiaryAppuntamentoDetailScreen(appointmentId: appointment.id),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: appointment != null
                  ? (isDarkMode ? const Color(0xFF1E293B) : Colors.white)
                  : Colors.transparent,
              border: Border.all(
                color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                const Spacer(),
                if (appointment != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(appointment.status, isDarkMode),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusLabel(appointment.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 1.0,
      mainAxisSpacing: 0,
      crossAxisSpacing: 0,
      children: children,
    );
  }

  Widget _buildWeekView(List<SyncAppointment> appointments, bool isDarkMode) {
    final monday = _getMonday(_currentDate);
    final List<Widget> dayCards = [];

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final dayName = DateFormat('EEEE', 'it_IT').format(date);
      final dayNameShort = dayName[0].toUpperCase() + dayName.substring(1);

      // Find appointment
      final appointment = appointments.cast<SyncAppointment?>().firstWhere(
            (a) => a?.date == dateStr,
            orElse: () => null,
          );

      dayCards.add(
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: appointment != null
                  ? _getStatusColor(appointment.status, isDarkMode).withValues(alpha: 0.5)
                  : (isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              width: appointment != null ? 1.5 : 1.0,
            ),
          ),
          child: InkWell(
            onTap: () {
              if (appointment != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SyncDiaryAppuntamentoDetailScreen(appointmentId: appointment.id),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Day Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayNameShort,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white60 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Appointment Info
                  if (appointment != null) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(appointment.status, isDarkMode),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusLabel(appointment.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (appointment.note != null && appointment.note!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            appointment.note!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.white60 : Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ] else ...[
                    Text(
                      'Nessun appuntamento',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white30 : Colors.black38,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: dayCards,
    );
  }
}

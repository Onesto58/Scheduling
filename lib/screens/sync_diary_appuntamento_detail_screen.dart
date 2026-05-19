import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/sync_appointment.dart';
import '../providers/sync_appointment_provider.dart';
import '../providers/theme_provider.dart';

class SyncDiaryAppuntamentoDetailScreen extends ConsumerStatefulWidget {
  final int appointmentId;

  const SyncDiaryAppuntamentoDetailScreen({super.key, required this.appointmentId});

  @override
  ConsumerState<SyncDiaryAppuntamentoDetailScreen> createState() => _SyncDiaryAppuntamentoDetailScreenState();
}

class _SyncDiaryAppuntamentoDetailScreenState extends ConsumerState<SyncDiaryAppuntamentoDetailScreen> {
  late TextEditingController _overridePriceController;
  late TextEditingController _noteController;
  String _selectedStatus = 'previsto';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _overridePriceController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _overridePriceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatCurrency(int cents) {
    return NumberFormat.currency(
      locale: 'it_IT',
      symbol: '€',
      decimalDigits: 2,
    ).format(cents / 100);
  }

  @override
  Widget build(BuildContext context) {
    final appointments = ref.watch(syncAppointmentsProvider);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    // Find the appointment in the state
    final appointment = appointments.cast<SyncAppointment?>().firstWhere(
          (a) => a?.id == widget.appointmentId,
          orElse: () => null,
        );

    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dettaglio')),
        body: const Center(
          child: Text(
            'Appuntamento non trovato',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    // Initialize controller values on first build
    if (!_isInitialized) {
      _selectedStatus = appointment.status;
      _overridePriceController.text = appointment.overridePriceCents != null
          ? (appointment.overridePriceCents! / 100).toStringAsFixed(2)
          : '';
      _noteController.text = appointment.note ?? '';
      _isInitialized = true;
    }

    final parsedDate = DateTime.parse(appointment.date);
    final formattedDate = DateFormat('EEEE d MMMM yyyy', 'it_IT').format(parsedDate);
    final formattedDateCap = formattedDate[0].toUpperCase() + formattedDate.substring(1);

    final isPaid = appointment.status == 'pagato';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dettaglio Appuntamento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Date Card
                  Card(
                    elevation: 0,
                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: isDarkMode ? Colors.indigoAccent : Colors.blueAccent,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              formattedDateCap,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Fields
                  // 1. Stato Dropdown
                  const Text(
                    'Stato',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white10 : Colors.black12,
                        ),
                      ),
                    ),
                    dropdownColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    items: [
                      const DropdownMenuItem(
                        value: 'previsto',
                        child: Text('Previsto'),
                      ),
                      const DropdownMenuItem(
                        value: 'svolto',
                        child: Text('Svolto'),
                      ),
                      const DropdownMenuItem(
                        value: 'annullato',
                        child: Text('Annullato'),
                      ),
                      DropdownMenuItem(
                        value: 'pagato',
                        enabled: false, // Disabled just like React
                        child: Text(
                          'Pagato (non modificabile)',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white30 : Colors.black38,
                          ),
                        ),
                      ),
                    ],
                    onChanged: isPaid
                        ? null // Readonly if already paid
                        : (val) {
                            if (val != null) {
                              setState(() {
                                _selectedStatus = val;
                              });
                            }
                          },
                  ),
                  const SizedBox(height: 20),

                  // 2. Prezzo Corrente (Read-Only)
                  const Text(
                    'Prezzo corrente (da regole)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Text(
                      _formatCurrency(appointment.priceCents),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Override Prezzo
                  Text(
                    isPaid
                        ? 'Override prezzo (€) - Non modificabile'
                        : 'Override prezzo (€)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _overridePriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: !isPaid,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                      hintText: 'Lascia vuoto per usare prezzo corrente',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white10 : Colors.black12,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {}); // trigger build to show preview
                    },
                  ),
                  if (_overridePriceController.text.isNotEmpty && !isPaid) ...[
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final parsedVal = double.tryParse(_overridePriceController.text) ?? 0.0;
                        final cents = (parsedVal * 100).round();
                        return Text(
                          'Prezzo effettivo: ${_formatCurrency(cents)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white60 : Colors.black54,
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 20),

                  // 4. Note
                  const Text(
                    'Note',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                      hintText: 'Note aggiuntive...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white10 : Colors.black12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Green confirmation box if already paid
                  if (isPaid && appointment.paidAt != null) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Appuntamento Pagato',
                                style: TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pagato il: ${DateFormat('dd/MM/yyyy', 'it_IT').format(DateTime.parse(appointment.paidAt!))}',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white60 : Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Action Buttons
                  ElevatedButton(
                    onPressed: () {
                      // Save modifications
                      final overridePriceText = _overridePriceController.text;
                      int? overrideCents;
                      if (overridePriceText.isNotEmpty) {
                        final parsed = double.tryParse(overridePriceText);
                        if (parsed != null) {
                          overrideCents = (parsed * 100).round();
                        }
                      }

                      final updatedAppointment = appointment.copyWith(
                        status: _selectedStatus,
                        note: () => _noteController.text.isEmpty ? null : _noteController.text,
                        overridePriceCents: () => _selectedStatus == 'pagato' ? appointment.overridePriceCents : overrideCents,
                      );

                      ref.read(syncAppointmentsProvider.notifier).updateAppointment(updatedAppointment);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Appuntamento salvato con successo!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? const Color(0xFF2563EB) : const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Salva Modifiche',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Optional back button
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: isDarkMode ? Colors.white24 : Colors.black26,
                      ),
                    ),
                    child: Text(
                      'Annulla',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

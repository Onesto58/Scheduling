import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/sync_appointment_provider.dart';
import '../providers/sync_payment_provider.dart';
import '../providers/theme_provider.dart';
import 'sync_diary_pagamento_detail_screen.dart';

class SyncDiaryRegistraPagamentoScreen extends ConsumerStatefulWidget {
  const SyncDiaryRegistraPagamentoScreen({super.key});

  @override
  ConsumerState<SyncDiaryRegistraPagamentoScreen> createState() => _SyncDiaryRegistraPagamentoScreenState();
}

class _SyncDiaryRegistraPagamentoScreenState extends ConsumerState<SyncDiaryRegistraPagamentoScreen> {
  final TextEditingController _noteController = TextEditingController();
  DateTime _paidOnDate = DateTime.now();
  final Map<String, bool> _selectedAppointments = {};
  bool _isInitialized = false;

  @override
  void dispose() {
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

  String _getStatusLabel(String status) {
    switch (status) {
      case 'previsto':
        return 'Previsto';
      case 'svolto':
        return 'Svolto';
      case 'annullato':
        return 'Annullato';
      default:
        return status;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paidOnDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('it', 'IT'),
    );
    if (picked != null && picked != _paidOnDate) {
      setState(() {
        _paidOnDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointments = ref.watch(syncAppointmentsProvider);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    // Filter unpaid appointments and sort by appointment date
    final unpaidAppointments = appointments.where((a) => a.status != 'pagato').toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Auto-select status 'svolto' on first load
    if (!_isInitialized && unpaidAppointments.isNotEmpty) {
      for (final appt in unpaidAppointments) {
        _selectedAppointments[appt.id] = appt.status == 'svolto';
      }
      _isInitialized = true;
    }

    // Calculate selected total
    int selectedTotalCents = 0;
    for (final appt in unpaidAppointments) {
      if (_selectedAppointments[appt.id] == true) {
        selectedTotalCents += appt.effectivePriceCents;
      }
    }

    final hasSelection = _selectedAppointments.values.any((selected) => selected);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registra Pagamento',
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
                  // Form Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dettagli Pagamento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 1. Paid On Date Selector
                          const Text(
                            'Data Pagamento',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode ? Colors.white10 : Colors.black12,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('dd/MM/yyyy', 'it_IT').format(_paidOnDate),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  const Icon(Icons.calendar_month, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 2. Notes Textarea
                          const Text(
                            'Note (facoltative)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _noteController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              hintText: 'Note aggiuntive sul pagamento...',
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Appointments Selection Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Appuntamenti nel periodo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Seleziona gli appuntamenti da includere nel pagamento',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.white60 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),

                          unpaidAppointments.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24.0),
                                    child: Text(
                                      'Nessun appuntamento da pagare',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: unpaidAppointments.length,
                                  itemBuilder: (context, index) {
                                    final appt = unpaidAppointments[index];
                                    final apptDate = DateTime.parse(appt.date);
                                    final formattedApptDate =
                                        DateFormat('EEEE d MMMM yyyy', 'it_IT').format(apptDate);
                                    final formattedApptDateCap =
                                        formattedApptDate[0].toUpperCase() + formattedApptDate.substring(1);

                                    final isSelected = _selectedAppointments[appt.id] ?? false;
                                    final isDisabled = appt.status != 'svolto';

                                    return Opacity(
                                      opacity: isDisabled ? 0.5 : 1.0,
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected
                                                ? (isDarkMode ? Colors.indigoAccent : Colors.blueAccent)
                                                : (isDarkMode ? Colors.white10 : Colors.black12),
                                            width: isSelected ? 1.5 : 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          color: isSelected
                                              ? (isDarkMode
                                                  ? Colors.indigoAccent.withValues(alpha: 0.1)
                                                  : Colors.blueAccent.withValues(alpha: 0.05))
                                              : Colors.transparent,
                                        ),
                                        child: CheckboxListTile(
                                          value: isSelected,
                                          onChanged: isDisabled
                                              ? null
                                              : (val) {
                                                  setState(() {
                                                    _selectedAppointments[appt.id] = val ?? false;
                                                  });
                                                },
                                          title: Text(
                                            formattedApptDateCap,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            _getStatusLabel(appt.status),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDarkMode ? Colors.white60 : Colors.black54,
                                            ),
                                          ),
                                          secondary: Text(
                                            _formatCurrency(appt.effectivePriceCents),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          controlAffinity: ListTileControlAffinity.leading,
                                          contentPadding: EdgeInsets.zero,
                                          activeColor: isDarkMode ? Colors.indigoAccent : Colors.blueAccent,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Total and Confirm Box
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Totale',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _formatCurrency(selectedTotalCents),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.indigoAccent : Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: !hasSelection
                                ? null
                                : () async {
                                    final selectedList = unpaidAppointments
                                        .where((a) => _selectedAppointments[a.id] == true)
                                        .toList();

                                    final paidOnStr =
                                        "${_paidOnDate.year}-${_paidOnDate.month.toString().padLeft(2, '0')}-${_paidOnDate.day.toString().padLeft(2, '0')}";

                                    final paymentId = await ref.read(syncPaymentActionsProvider).registerPayment(
                                          userId: 1,
                                          paidOn: paidOnStr,
                                          note: _noteController.text.isEmpty ? null : _noteController.text,
                                          selectedAppointments: selectedList,
                                        );

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Pagamento registrato con successo!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SyncDiaryPagamentoDetailScreen(paymentId: paymentId),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Conferma Pagamento',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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

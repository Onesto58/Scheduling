import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/sync_payment.dart';
import '../providers/sync_payment_provider.dart';
import '../providers/theme_provider.dart';

class SyncDiaryPagamentoDetailScreen extends ConsumerWidget {
  final int paymentId;

  const SyncDiaryPagamentoDetailScreen({super.key, required this.paymentId});

  String _formatCurrency(int cents) {
    return NumberFormat.currency(
      locale: 'it_IT',
      symbol: '€',
      decimalDigits: 2,
    ).format(cents / 100);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(syncPaymentsProvider);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    // Find the payment
    final payment = payments.cast<SyncPayment?>().firstWhere(
          (p) => p?.id == paymentId,
          orElse: () => null,
        );

    if (payment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dettaglio Pagamento')),
        body: const Center(
          child: Text(
            'Pagamento non trovato',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    final parsedDate = DateTime.parse(payment.paidOn);
    final formattedDate = DateFormat('d MMMM yyyy', 'it_IT').format(parsedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dettaglio Pagamento',
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
                          // Header Date
                          Text(
                            'Pagamento del $formattedDate',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Notes if any
                          if (payment.note != null && payment.note!.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Note',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    payment.note!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Receipt Table Box
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Receipt title header
                                Container(
                                  width: double.infinity,
                                  color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  child: const Text(
                                    'Ricevuta',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Allocation Rows
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: payment.appointments.length,
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                  ),
                                  itemBuilder: (context, index) {
                                    final appt = payment.appointments[index];
                                    final apptDate = DateTime.parse(appt.date);
                                    final formattedApptDate = DateFormat('EEEE d MMMM yyyy', 'it_IT').format(apptDate);
                                    final formattedApptDateCap = formattedApptDate[0].toUpperCase() + formattedApptDate.substring(1);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Appuntamento del $formattedApptDateCap',
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatCurrency(appt.allocatedCents),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                // Receipt Total footer
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  color: isDarkMode
                                      ? const Color(0xFF1E1B4B) // Dark purple/indigo theme
                                      : const Color(0xFFEEF2FF), // Indigo 50
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Totale',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(payment.amountCents),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.indigoAccent : Colors.blueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

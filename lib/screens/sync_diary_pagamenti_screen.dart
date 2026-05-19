import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/sync_payment_provider.dart';
import '../providers/theme_provider.dart';
import 'sync_diary_pagamento_detail_screen.dart';
import 'sync_diary_registra_pagamento_screen.dart';

class SyncDiaryPagamentiScreen extends ConsumerWidget {
  const SyncDiaryPagamentiScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Storico Pagamenti',
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
            child: payments.isEmpty
                ? Center(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nessun pagamento registrato',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      // Order descending by paidOn
                      final sortedPayments = List.from(payments)
                        ..sort((a, b) => b.paidOn.compareTo(a.paidOn));
                      final payment = sortedPayments[index];

                      final parsedDate = DateTime.parse(payment.paidOn);
                      final formattedDate = DateFormat('d MMMM yyyy', 'it_IT').format(parsedDate);

                      final count = payment.appointments.length;
                      final apptText = count == 1 ? '1 appuntamento' : '$count appuntamenti';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SyncDiaryPagamentoDetailScreen(paymentId: payment.id),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Left details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        apptText,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDarkMode ? Colors.white60 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right Amount
                                Text(
                                  _formatCurrency(payment.amountCents),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.indigoAccent : Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SyncDiaryRegistraPagamentoScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        tooltip: 'Registra Pagamento',
        child: const Icon(Icons.add),
      ),
    );
  }
}

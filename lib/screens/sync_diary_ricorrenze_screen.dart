import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/sync_recurrence_provider.dart';
import '../providers/theme_provider.dart';

class SyncDiaryRicorrenzeScreen extends ConsumerStatefulWidget {
  const SyncDiaryRicorrenzeScreen({super.key});

  @override
  ConsumerState<SyncDiaryRicorrenzeScreen> createState() => _SyncDiaryRicorrenzeScreenState();
}

class _SyncDiaryRicorrenzeScreenState extends ConsumerState<SyncDiaryRicorrenzeScreen> {
  String? _selectedRecurrenceId;
  final TextEditingController _priceAmountController = TextEditingController();
  DateTime? _priceEffectiveDate;
  DateTime? _generateStartDate;

  // New Recurrence Dialog Controllers
  final TextEditingController _newTitleController = TextEditingController();
  int _newWeekday = 2; // Martedì by default

  final Map<int, String> _weekdayNames = {
    1: "Lunedì",
    2: "Martedì",
    3: "Mercoledì",
    4: "Giovedì",
    5: "Venerdì",
    6: "Sabato",
    7: "Domenica",
  };

  @override
  void dispose() {
    _priceAmountController.dispose();
    _newTitleController.dispose();
    super.dispose();
  }

  String _formatCurrency(int cents) {
    return NumberFormat.currency(
      locale: 'it_IT',
      symbol: '€',
      decimalDigits: 2,
    ).format(cents / 100);
  }

  Future<void> _selectPriceDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('it', 'IT'),
    );
    if (picked != null) {
      setState(() {
        _priceEffectiveDate = picked;
      });
    }
  }

  Future<void> _selectGenerateDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('it', 'IT'),
    );
    if (picked != null) {
      setState(() {
        _generateStartDate = picked;
      });
    }
  }

  void _showNewRecurrenceDialog(BuildContext context, bool isDarkMode) {
    _newTitleController.clear();
    _newWeekday = 2;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              title: const Text(
                'Nuova Ricorrenza',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Titolo',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _newTitleController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      hintText: 'Es: Seduta fisioterapia',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Giorno della settimana',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    initialValue: _newWeekday,
                    dropdownColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _weekdayNames.entries.map((e) {
                      return DropdownMenuItem<int>(
                        value: e.key,
                        child: Text(e.value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          _newWeekday = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annulla'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = _newTitleController.text.trim();
                    if (title.isNotEmpty) {
                      await ref.read(syncRecurrenceActionsProvider).addRecurrence(title, _newWeekday);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ricorrenza creata con successo'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Crea Ricorrenza'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(syncRecurrencesProvider);
    final loadState = ref.watch(syncRecurrencesLoadStateProvider);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ricorrenze',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showNewRecurrenceDialog(context, isDarkMode),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (loadState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Errore caricamento ricorrenze: ${loadState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (loadState.isLoading && state.recurrences.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  // List of recurrences
                  if (!loadState.isLoading || state.recurrences.isNotEmpty)
                  if (state.recurrences.isEmpty)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.repeat_rounded, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Nessuna ricorrenza configurata. Creane una per iniziare.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...state.recurrences.map((rec) {
                      final isSelected = _selectedRecurrenceId == rec.id;
                      final rules = state.priceRules
                          .where((r) => r.recurrenceId == rec.id)
                          .toList()
                        ..sort((a, b) => b.effectiveFrom.compareTo(a.effectiveFrom));

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Recurrence Header
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rec.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _weekdayNames[rec.weekday] ?? '',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDarkMode ? Colors.white60 : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: rec.isActive,
                                    onChanged: (_) {
                                      ref.read(syncRecurrenceActionsProvider).toggleRecurrence(rec.id);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),

                              // Price rules section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Regole Prezzo',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedRecurrenceId = null;
                                        } else {
                                          _selectedRecurrenceId = rec.id;
                                          _priceEffectiveDate = null;
                                          _priceAmountController.clear();
                                        }
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(isSelected ? 'Nascondi' : 'Gestisci'),
                                  ),
                                ],
                              ),

                              if (isSelected) ...[
                                const SizedBox(height: 12),
                                // List existing price rules
                                ...rules.map((rule) {
                                  final parsedRuleDate = DateTime.parse(rule.effectiveFrom);
                                  final formattedRuleDate = DateFormat('dd/MM/yyyy', 'it_IT').format(parsedRuleDate);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Dal $formattedRuleDate',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        Text(
                                          _formatCurrency(rule.priceCents),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                const SizedBox(height: 16),

                                // Add new price rule form
                                const Text(
                                  'Nuovo Prezzo da Data',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _selectPriceDate(context),
                                        style: OutlinedButton.styleFrom(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          _priceEffectiveDate != null
                                              ? DateFormat('dd/MM/yyyy', 'it_IT').format(_priceEffectiveDate!)
                                              : 'Scegli Data',
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 100,
                                      child: TextField(
                                        controller: _priceAmountController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                          hintText: '€',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: (_priceEffectiveDate == null || _priceAmountController.text.trim().isEmpty)
                                      ? null
                                      : () async {
                                          final parsedAmount = double.tryParse(_priceAmountController.text.trim());
                                          if (parsedAmount != null && _priceEffectiveDate != null) {
                                            final cents = (parsedAmount * 100).round();
                                            final dateStr = DateFormat('yyyy-MM-dd').format(_priceEffectiveDate!);
                                            await ref.read(syncRecurrenceActionsProvider).addPriceRule(rec.id, dateStr, cents);
                                            if (!context.mounted) return;
                                            setState(() {
                                              _priceEffectiveDate = null;
                                              _priceAmountController.clear();
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Regola prezzo aggiunta con successo'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDarkMode ? const Color(0xFF2563EB) : const Color(0xFF3B82F6),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(42),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text('Aggiungi Regola'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 16),

                  // Appointments Generation Card
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
                            'Generazione Appuntamenti',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Genera 30 mesi da questa data',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _selectGenerateDate(context),
                                  style: OutlinedButton.styleFrom(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    _generateStartDate != null
                                        ? DateFormat('dd/MM/yyyy', 'it_IT').format(_generateStartDate!)
                                        : 'Scegli Data di Inizio',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _generateStartDate == null
                                    ? null
                                    : () async {
                                        final dateStr = DateFormat('yyyy-MM-dd').format(_generateStartDate!);
                                        final count = await ref.read(syncRecurrenceActionsProvider).generateAppointmentsFrom(dateStr, 30);
                                        if (!context.mounted) return;
                                        setState(() {
                                          _generateStartDate = null;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Generati $count appuntamenti!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode ? const Color(0xFF2563EB) : const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text('Genera'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              final count = await ref.read(syncRecurrenceActionsProvider).extendTo30MonthsFromToday();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Estensione completata: $count appuntamenti creati!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text('Estendi a 30 mesi da oggi'),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'Crea solo gli appuntamenti mancanti',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode ? Colors.white30 : Colors.black38,
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

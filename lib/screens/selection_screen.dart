import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/app_choice_provider.dart';

class SelectionScreen extends ConsumerWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E1B4B),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFEEF2F6),
                    const Color(0xFFF1F5F9),
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Top Actions (Theme Toggle)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isDarkMode
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                      ),
                      onPressed: () {
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                    ),
                  ),
                ),
              ),

              // Main Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.indigo.withValues(alpha: 0.15)
                              : Colors.blue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.dashboard_customize_rounded,
                          size: 64,
                          color: isDarkMode ? Colors.indigoAccent : Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Seleziona Applicazione',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scegli quale ambiente caricare per iniziare a lavorare',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDarkMode ? Colors.white70 : const Color(0xFF475569),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Card 1: Scheduling App (Existing)
                      _buildAppCard(
                        context: context,
                        title: 'Scheduling App',
                        subtitle: 'Gestione Routine & Compiti',
                        description: 'Organizza le tue giornate, imposta le sveglie, la preparazione al sonno e traccia le tue abitudini.',
                        icon: Icons.alarm_on_rounded,
                        accentColor: Colors.blue,
                        gradientColors: isDarkMode
                            ? [const Color(0xFF2563EB), const Color(0xFF1D4ED8)]
                            : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                        onTap: () {
                          ref.read(appChoiceProvider.notifier).setAppChoice('scheduling');
                        },
                      ),
                      const SizedBox(height: 20),

                      // Card 2: Psico
                      _buildAppCard(
                        context: context,
                        title: 'Psico',
                        subtitle: 'Appuntamenti e pagamenti',
                        //description: 'Visualizza il calendario, registra nuovi pagamenti, gestisci scadenze e controlla gli arretrati.',
                        description: '',
                        icon: Icons.calendar_month_rounded,
                        accentColor: const Color(0xFF10B981),
                        gradientColors: isDarkMode
                            ? [const Color(0xFF059669), const Color(0xFF047857)]
                            : [const Color(0xFF10B981), const Color(0xFF059669)],
                        onTap: () {
                          ref.read(appChoiceProvider.notifier).setAppChoice('sync_diary');
                        },
                      ),
                      const SizedBox(height: 20),

                      // Card 3: Pianificatore grafico
                      _buildAppCard(
                        context: context,
                        title: 'Pianificatore grafico',
                        subtitle: 'Visualizza la tua giornata',
                        description: 'Pianifica e visualizza le attività svolte durante la giornata con una timeline oraria.',
                        icon: Icons.view_timeline_rounded,
                        accentColor: const Color(0xFF8B5CF6),
                        gradientColors: isDarkMode
                            ? [const Color(0xFF7C3AED), const Color(0xFF6D28D9)]
                            : [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
                        onTap: () {
                          ref.read(appChoiceProvider.notifier).setAppChoice('pianificatore_grafico');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color accentColor,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: accentColor.withValues(alpha: 0.1),
          highlightColor: accentColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon block with gradient background
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

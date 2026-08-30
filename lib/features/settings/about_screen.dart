import 'package:flutter/material.dart';

import '../../core/l10n/app_texts.dart';
import '../../core/theme/momento_colors.dart';
import '../../core/theme/momento_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/momento_logo.dart';

/// Wer hinter Momento steckt.
///
/// Die Idee, die Marke und der ganze Aufbau stammen aus einem Businessplan,
/// der in der Berufsmaturitaet entstanden ist. Diese Seite nennt die
/// Menschen dahinter.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  /// Die Autorinnen des Businessplans "Momento AG" (GBMc, 10. Mai 2026).
  static const ideaAuthors = <String>[
    'Sara Alina Dörring',
    'Djellza Imeraj',
    'Blerta Zejnaj',
    'Dalila Barroso Carvalho',
  ];

  static const developer = 'Nilton Barroso Carvalho';

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 290,
            pinned: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: MomentoGradients.header),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MomentoAppIcon(size: 88),
                      const SizedBox(height: 18),
                      MomentoWordmark(height: 52, tint: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        t.vision,
                        style: TextStyle(
                          fontFamily: MomentoFonts.body,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 22, 16, MomentoInsets.bottom(context)),
            sliver: SliverList.list(
              children: [
                Text(
                  t.aboutIntro,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 22),

                _CreditCard(
                  label: t.aboutIdeaLabel,
                  icon: Icons.lightbulb_outline_rounded,
                  color: MomentoColors.rose,
                  names: ideaAuthors,
                ),
                const SizedBox(height: 12),
                _CreditCard(
                  label: t.aboutDevLabel,
                  icon: Icons.code_rounded,
                  color: MomentoColors.violet,
                  names: const [developer],
                ),
                const SizedBox(height: 12),

                SoftCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: MomentoColors.peach.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(Icons.menu_book_rounded,
                            size: 20, color: Color(0xFF9A6234)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(t.aboutSourceLabel,
                                style: theme.textTheme.labelSmall),
                            Text(t.aboutSourceValue,
                                style: theme.textTheme.titleSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // --- Konzeptbild ---------------------------------------
                Text(t.aboutConceptTitle, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 5),
                Text(t.aboutConceptBody, style: theme.textTheme.bodySmall),
                const SizedBox(height: 14),
                SoftCard(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/brand/concept_mockup.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                // --- Widmung -------------------------------------------
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: MomentoGradients.softCardFor(theme.brightness),
                    borderRadius: BorderRadius.circular(MomentoRadii.card),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.favorite_rounded,
                          color: MomentoColors.rose, size: 26),
                      const SizedBox(height: 12),
                      Text(
                        t.aboutThanks,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Center(
                  child: Text('${t.version} 1.0.0',
                      style: theme.textTheme.labelSmall),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Eine Karte mit Rolle und den zugehoerigen Namen.
class _CreditCard extends StatelessWidget {
  const _CreditCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.names,
  });

  final String label;
  final IconData icon;
  final Color color;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Text(label, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          for (final name in names)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: MomentoGradients.action,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(name),
                      style: const TextStyle(
                        fontFamily: MomentoFonts.display,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(name, style: theme.textTheme.bodyLarge),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

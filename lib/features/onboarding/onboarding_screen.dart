import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n/app_texts.dart';
import '../../core/momento_controller.dart';
import '../../core/theme/momento_colors.dart';
import '../../data/models/memory.dart';
import '../../widgets/common.dart';
import '../../widgets/momento_logo.dart';
import '../../widgets/scene_cover.dart';

/// Die kurze Einfuehrung beim ersten Oeffnen der App
/// (Businessplan, Kapitel 7.2).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next(int total) {
    if (_page >= total - 1) {
      AppScope.read(context).completeOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pages = <_OnboardingPage>[
      _OnboardingPage(
        title: t.onboarding1Title,
        body: t.onboarding1Body,
        illustration: const _PhotoStackArt(),
      ),
      _OnboardingPage(
        title: t.onboarding2Title,
        body: t.onboarding2Body,
        illustration: const _SensesArt(),
      ),
      _OnboardingPage(
        title: t.onboarding3Title,
        body: t.onboarding3Body,
        illustration: const _FlashbackArt(),
      ),
      _OnboardingPage(
        title: t.onboarding4Title,
        body: t.onboarding4Body,
        illustration: const _SearchArt(),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF2A1E38), Color(0xFF17121D)]
                : const [Color(0xFFFFF1E6), Color(0xFFFFF9FB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
                child: Row(
                  children: [
                    const Flexible(child: MomentoWordmark(height: 34)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => AppScope.read(context).completeOnboarding(),
                      child: Text(t.actionSkip),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) => setState(() => _page = index),
                  itemBuilder: (context, index) => pages[index],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 26),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < pages.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _page ? 26 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: i == _page ? MomentoGradients.action : null,
                              color: i == _page
                                  ? null
                                  : theme.colorScheme.outline,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    GradientButton(
                      label: _page == pages.length - 1
                          ? t.onboardingStart
                          : t.actionContinue,
                      icon: _page == pages.length - 1
                          ? Icons.auto_awesome_rounded
                          : null,
                      onPressed: () => _next(pages.length),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.illustration,
  });

  final String title;
  final String body;
  final Widget illustration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Auf kleinen Bildschirmen darf die Seite scrollen und die Illustration
    // schrumpfen, statt ueber den Rand zu laufen.
    return LayoutBuilder(
      builder: (context, constraints) {
        final artHeight = (constraints.maxHeight * 0.44).clamp(140.0, 250.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: artHeight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(height: 250, child: Center(child: illustration)),
                  ),
                ),
                const SizedBox(height: 34),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- Illustrationen -------------------------------------------------------

/// Ein Stapel leicht gedrehter Erinnerungskarten.
class _PhotoStackArt extends StatelessWidget {
  const _PhotoStackArt();

  @override
  Widget build(BuildContext context) {
    Widget card(CoverScene scene, double angle, Offset offset, double scale) =>
        Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 150,
                height: 190,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: MomentoColors.plum.withValues(alpha: 0.22),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: SceneCover(scene: scene),
                ),
              ),
            ),
          ),
        );

    return Stack(
      alignment: Alignment.center,
      children: [
        card(CoverScene.mountains, -0.22, const Offset(-62, 8), 0.88),
        card(CoverScene.springMeadow, 0.20, const Offset(62, 8), 0.88),
        card(CoverScene.lakeSunset, -0.02, Offset.zero, 1.0),
      ],
    );
  }
}

/// Bild, Duft und Geraeusch als drei schwebende Kacheln.
class _SensesArt extends StatelessWidget {
  const _SensesArt();

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    Widget tile(IconData icon, String label, Color color, double dy) =>
        Transform.translate(
          offset: Offset(0, dy),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.35), width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 11),
                Text(label, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        tile(Icons.photo_camera_rounded, t.memoryPhoto, MomentoColors.memoryAccent, -8),
        const SizedBox(height: 16),
        tile(Icons.auto_awesome_rounded, t.memoryScent, MomentoColors.scentAccent, 10),
        const SizedBox(height: 16),
        tile(Icons.graphic_eq_rounded, t.memorySound, MomentoColors.soundAccent, -6),
      ],
    );
  }
}

/// Eine Karte, die aus der Vergangenheit auftaucht.
class _FlashbackArt extends StatelessWidget {
  const _FlashbackArt();

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        for (var i = 2; i >= 1; i--)
          Transform.translate(
            offset: Offset(0, -18.0 * i),
            child: Transform.scale(
              scale: 1 - i * 0.09,
              child: Opacity(
                opacity: 0.35 / i,
                child: _flashbackCard(context, t),
              ),
            ),
          ),
        _flashbackCard(context, t),
      ],
    );
  }

  Widget _flashbackCard(BuildContext context, AppTexts t) => Container(
        width: 232,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: MomentoColors.plum.withValues(alpha: 0.20),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 118,
              width: double.infinity,
              child: SceneCover(scene: CoverScene.celebration),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded,
                      size: 18, color: MomentoColors.rose),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.flashbackYearsAgo(1),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

/// Ein Suchfeld mit einem beschreibenden Satz.
class _SearchArt extends StatelessWidget {
  const _SearchArt();

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: MomentoColors.plum.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_rounded, color: MomentoColors.plumInk),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  t.searchExample1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Transform.rotate(
          angle: -math.pi / 2,
          child: const Icon(Icons.arrow_back_rounded,
              size: 22, color: MomentoColors.violet),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 96,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final scene in const [
                CoverScene.lakeSunset,
                CoverScene.beach,
                CoverScene.autumnPark,
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 74,
                      height: 92,
                      child: SceneCover(scene: scene),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

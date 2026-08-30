import 'package:flutter/material.dart';

import '../../core/l10n/app_texts.dart';
import '../../core/momento_controller.dart';
import '../../core/theme/momento_colors.dart';
import '../../core/theme/momento_theme.dart';
import '../../widgets/momento_logo.dart';
import '../albums/albums_screen.dart';
import '../memories/memory_editor_screen.dart';
import '../search/search_screen.dart';
import '../settings/about_screen.dart';
import '../settings/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../sync/sync_screen.dart';
import 'home_screen.dart';

/// Das Grundgeruest der App: Inhalt, Menue oben links und die untere Leiste
/// mit den drei Knoepfen aus dem Businessplan.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawer: const MomentoDrawer(),
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onOpenMenu: () => _scaffoldKey.currentState?.openDrawer()),
          const SyncScreen(),
          const SearchScreen(),
        ],
      ),
      bottomNavigationBar: MomentoNavBar(
        index: _index,
        onChanged: (value) => setState(() => _index = value),
        labels: [t.navMemories, t.navSync, t.navSearch],
      ),
    );
  }
}

/// Die untere Leiste mit dem hervorgehobenen Sync-Knopf in der Mitte -
/// so wie im Konzeptbild (Abbildung 1).
class MomentoNavBar extends StatelessWidget {
  const MomentoNavBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.labels,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF8A6379).withValues(alpha: 0.13),
                  blurRadius: 26,
                  offset: const Offset(0, -6),
                ),
              ],
      ),
      child: SizedBox(
        height: 74,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.photo_library_rounded,
                label: labels[0],
                selected: index == 0,
                onTap: () => onChanged(0),
              ),
            ),
            SizedBox(
              width: 96,
              child: _CenterSyncButton(
                label: labels[1],
                selected: index == 1,
                onTap: () => onChanged(1),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.saved_search_rounded,
                label: labels[2],
                selected: index == 2,
                onTap: () => onChanged(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? MomentoColors.rose : theme.colorScheme.onSurfaceVariant;

    return InkResponse(
      onTap: onTap,
      radius: 46,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            decoration: BoxDecoration(
              color: selected
                  ? MomentoColors.rose.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 23, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Der runde Knopf in der Mitte, der ueber die Leiste hinausragt.
class _CenterSyncButton extends StatelessWidget {
  const _CenterSyncButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pending = AppScope.of(context).pendingMemories.length;

    return Transform.translate(
      offset: const Offset(0, -16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            selected: selected,
            // Die Zahl am Knopf wird sonst nicht vorgelesen.
            label: pending == 0
                ? label
                : '$label, ${AppTexts.of(context).syncPending(pending)}',
            child: GestureDetector(
            onTap: onTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: MomentoGradients.action,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MomentoColors.rose.withValues(alpha: 0.38),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.cloud_upload_rounded,
                      color: Colors.white, size: 25),
                ),
                if (pending > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: MomentoColors.warning,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: theme.colorScheme.surface, width: 2),
                      ),
                      child: Text(
                        '$pending',
                        style: const TextStyle(
                          fontFamily: MomentoFonts.body,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            ),
          ),
          const SizedBox(height: 5),
          // Der Text darunter wiederholt nur, was oben schon vorgelesen wird.
          ExcludeSemantics(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected ? MomentoColors.rose : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Das Menue hinter der Taste oben links.
class MomentoDrawer extends StatelessWidget {
  const MomentoDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final controller = AppScope.of(context);
    final user = controller.user;

    void go(Widget screen) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => screen),
      );
    }

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
              decoration: const BoxDecoration(gradient: MomentoGradients.header),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MomentoWordmark(height: 44, tint: Colors.white),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.28),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 1.6,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          user?.initials ?? '?',
                          style: const TextStyle(
                            fontFamily: MomentoFonts.display,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user?.displayName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: MomentoFonts.display,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              user?.email ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: MomentoFonts.body,
                                fontSize: 12.5,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                children: [
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    label: t.profile,
                    onTap: () => go(const ProfileScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.folder_special_outlined,
                    label: t.albums,
                    onTap: () => go(const AlbumsScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.add_circle_outline_rounded,
                    label: t.newMemory,
                    onTap: () => go(const MemoryEditorScreen()),
                  ),
                  const SizedBox(height: 6),
                  Divider(color: theme.colorScheme.outline),
                  const SizedBox(height: 6),
                  _DrawerItem(
                    icon: Icons.tune_rounded,
                    label: t.settings,
                    onTap: () => go(const SettingsScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.favorite_outline_rounded,
                    label: t.about,
                    onTap: () => go(const AboutScreen()),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: _DrawerItem(
                icon: Icons.logout_rounded,
                label: t.signOut,
                danger: true,
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(t.signOut),
                      content: Text(t.signOutConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          child: Text(t.actionCancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          child: Text(t.signOut),
                        ),
                      ],
                    ),
                  );
                  if (confirmed ?? false) {
                    await controller.signOut();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = danger ? MomentoColors.danger : theme.colorScheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MomentoRadii.tile),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              Icon(icon, size: 21, color: color),
              const SizedBox(width: 14),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

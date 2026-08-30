import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../core/l10n/app_texts.dart';
import '../../core/momento_controller.dart';
import '../../core/theme/momento_colors.dart';
import '../../data/local/backup_service.dart';
import '../../widgets/common.dart';
import 'about_screen.dart';

/// Einstellungen: Light-/Dark-Mode, Sprache, Beispieldaten und Sicherung
/// (Businessplan, Kapitel 7.2).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;

  // --- Sicherung ---------------------------------------------------------

  Future<void> _createBackup() async {
    final t = AppTexts.of(context);
    final controller = AppScope.read(context);
    final messenger = ScaffoldMessenger.of(context);

    if (controller.memories.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(t.backupNothingToSave)));
      return;
    }

    setState(() => _busy = true);
    try {
      final bytes = await controller.createBackup();
      // Öffnet den "Speichern unter"-Dialog des Geräts: die Person wählt
      // selbst, wo die Sicherung landet.
      final saved = await FilePicker.saveFile(
        fileName: BackupService.fileNameFor(DateTime.now()),
        bytes: bytes,
        mimeType: 'application/zip',
      );
      if (saved != null) {
        messenger.showSnackBar(SnackBar(content: Text(t.backupSaved)));
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.backupFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreBackup() async {
    final t = AppTexts.of(context);
    final controller = AppScope.read(context);
    final messenger = ScaffoldMessenger.of(context);

    final replace = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.backupRestore),
        content: Text(t.backupModeQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: Text(t.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              t.backupModeReplace,
              style: const TextStyle(color: MomentoColors.danger),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t.backupModeMerge),
          ),
        ],
      ),
    );
    if (replace == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final picked = await FilePicker.pickFile();
      if (picked == null) return;
      final bytes = await picked.readAsBytes();

      final result = await controller.restoreBackup(
        bytes,
        replaceExisting: replace,
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            [
              t.backupRestored(result.memoriesAdded, result.albumsAdded),
              if (result.memoriesSkipped > 0)
                t.backupSkipped(result.memoriesSkipped),
            ].join(' · '),
          ),
        ),
      );
    } on InvalidBackupException {
      messenger.showSnackBar(SnackBar(content: Text(t.backupInvalid)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.backupFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final controller = AppScope.of(context);
    final settings = controller.settings;

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, MomentoInsets.bottom(context)),
        children: [
          // --- Darstellung -------------------------------------------
          _Group(
            title: t.appearance,
            icon: Icons.palette_outlined,
            children: [
              _SegmentedRow(
                options: [
                  (ThemeMode.system, t.themeSystem, Icons.brightness_auto_rounded),
                  (ThemeMode.light, t.themeLight, Icons.light_mode_rounded),
                  (ThemeMode.dark, t.themeDark, Icons.dark_mode_rounded),
                ],
                selected: settings.themeMode,
                onChanged: controller.setThemeMode,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // --- Sprache ------------------------------------------------
          _Group(
            title: t.language,
            icon: Icons.translate_rounded,
            children: [
              // Bewusst ohne "System": Momento gibt es nur auf Deutsch und
              // Englisch. Beim ersten Start wird die Geraetesprache
              // beruecksichtigt, danach entscheidet diese Einstellung.
              _SegmentedRow<Locale>(
                options: [
                  (const Locale('de'), t.languageGerman, Icons.flag_outlined),
                  (const Locale('en'), t.languageEnglish, Icons.flag_outlined),
                ],
                selected: settings.locale ?? const Locale('de'),
                equals: (a, b) => a.languageCode == b.languageCode,
                onChanged: controller.setLocale,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // --- Daten --------------------------------------------------
          _Group(
            title: t.data,
            icon: Icons.dataset_outlined,
            children: [
              Text(t.demoDataBody, style: theme.textTheme.bodySmall),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await controller.reloadDemoData();
                        messenger.showSnackBar(
                          SnackBar(content: Text(t.demoDataLoaded)),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 19),
                      label: Text(t.demoDataReload),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.hasDemoData
                          ? () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await controller.removeDemoData();
                              messenger.showSnackBar(
                                SnackBar(content: Text(t.demoDataRemoved)),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.cleaning_services_rounded, size: 19),
                      label: Text(t.demoDataRemove),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // --- Sicherung ----------------------------------------------
          _Group(
            title: t.backupTitle,
            icon: Icons.shield_outlined,
            children: [
              Text(t.backupBody, style: theme.textTheme.bodySmall),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _createBackup,
                      icon: const Icon(Icons.ios_share_rounded, size: 19),
                      label: Text(_busy ? t.backupWorking : t.backupCreate),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _restoreBackup,
                      icon: const Icon(Icons.settings_backup_restore_rounded, size: 19),
                      label: Text(t.backupRestore),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // --- Ueber --------------------------------------------------
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.favorite_outline_rounded),
              title: Text(t.about),
              subtitle: Text(t.aboutSourceValue),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
              ),
            ),
          ),
          const SizedBox(height: 26),

          // --- Achtung ------------------------------------------------
          Text(
            t.dangerZone,
            style: theme.textTheme.labelMedium?.copyWith(
              color: MomentoColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SoftCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.deleteAllTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(t.deleteAllBody, style: theme.textTheme.bodySmall),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MomentoColors.danger,
                    side: BorderSide(
                      color: MomentoColors.danger.withValues(alpha: 0.5),
                      width: 1.4,
                    ),
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(t.deleteAllTitle),
                        content: Text(t.deleteAllConfirm),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: Text(t.actionCancel),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: Text(
                              t.actionDelete,
                              style: const TextStyle(color: MomentoColors.danger),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed ?? false) {
                      await controller.deleteEverything();
                      messenger.showSnackBar(
                        SnackBar(content: Text(t.deleteAllDone)),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_forever_rounded, size: 19),
                  label: Text(t.deleteAllTitle),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '${t.version} $momentoVersion',
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(title, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

/// Drei Knoepfe nebeneinander, von denen genau einer aktiv ist.
class _SegmentedRow<T> extends StatelessWidget {
  const _SegmentedRow({
    required this.options,
    required this.selected,
    required this.onChanged,
    this.equals,
  });

  final List<(T, String, IconData)> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool Function(T a, T b)? equals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isSelected(T value) =>
        equals?.call(value, selected) ?? value == selected;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option.$1),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    gradient: isSelected(option.$1)
                        ? MomentoGradients.action
                        : null,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        option.$3,
                        size: 18,
                        color: isSelected(option.$1)
                            ? Colors.white
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        option.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isSelected(option.$1)
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

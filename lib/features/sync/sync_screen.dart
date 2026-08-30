import 'package:flutter/material.dart';

import '../../core/l10n/app_texts.dart';
import '../../core/momento_controller.dart';
import '../../core/theme/momento_colors.dart';
import '../../core/theme/momento_theme.dart';
import '../../core/utils/date_format.dart';
import '../../data/models/memory.dart';
import '../../widgets/common.dart';
import '../../widgets/memory_widgets.dart';
import '../memories/memory_detail_screen.dart';

/// Der mittlere Knopf aus dem Konzeptbild.
///
/// Hier laufen alle Erinnerungen zusammen, die noch nicht verarbeitet wurden -
/// zum Beispiel weil sie unterwegs ohne Internet erfasst wurden.
class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  int _done = 0;
  int _total = 0;

  Future<void> _sync() async {
    final t = AppTexts.of(context);
    final controller = AppScope.read(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _done = 0;
      _total = controller.pendingMemories.length;
    });

    final count = await controller.synchronise(
      onProgress: (done, total) {
        if (!mounted) return;
        setState(() {
          _done = done;
          _total = total;
        });
      },
    );

    if (!mounted) return;
    setState(() {
      _done = 0;
      _total = 0;
    });
    messenger.showSnackBar(SnackBar(content: Text(t.syncFinished(count))));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final controller = AppScope.of(context);
    final pending = controller.pendingMemories;
    final syncing = controller.isSyncing;
    final lastSync = controller.settings.lastSync;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 14, 16, MomentoInsets.aboveNavBar(context)),
          children: [
            Text(t.syncTitle, style: theme.textTheme.displaySmall),
            const SizedBox(height: 2),
            Text(t.syncSubtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),

            _StatusCard(
              pending: pending.length,
              syncing: syncing,
              done: _done,
              total: _total,
            ),
            const SizedBox(height: 16),

            GradientButton(
              label: syncing ? t.syncRunning : t.syncNow,
              icon: Icons.cloud_upload_rounded,
              busy: syncing,
              onPressed: syncing ? null : _sync,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  '${t.syncLastRun}: ${lastSync == null ? t.syncNever : MomentoDates.dayAndTime(lastSync, t)}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 26),

            if (pending.isNotEmpty) ...[
              SectionHeader(
                title: t.syncQueueTitle,
                subtitle: t.syncPendingBody,
                icon: Icons.pending_actions_rounded,
              ),
              const SizedBox(height: 12),
              for (final memory in pending)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MemoryTile(
                    memory: memory,
                    trailing: _StateBadge(state: memory.syncState),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MemoryDetailScreen(memoryId: memory.id),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],

            SoftCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.wifi_off_rounded,
                      size: 20, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(t.syncOfflineHint,
                        style: theme.textTheme.bodySmall),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_outlined,
                          size: 20, color: MomentoColors.violet),
                      const SizedBox(width: 10),
                      Text(t.syncCloudTitle, style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(t.syncCloudBody, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.pending,
    required this.syncing,
    required this.done,
    required this.total,
  });

  final int pending;
  final bool syncing;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final allDone = pending == 0 && !syncing;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: MomentoGradients.softCardFor(theme.brightness),
        borderRadius: BorderRadius.circular(MomentoRadii.card),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: Icon(
              allDone ? Icons.cloud_done_rounded : Icons.cloud_sync_rounded,
              size: 36,
              color: allDone ? MomentoColors.success : MomentoColors.plumInk,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            allDone ? t.syncAllDone : t.syncPending(pending),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 5),
          Text(
            allDone ? t.syncAllDoneBody : t.syncPendingBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          if (syncing && total > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: done / total,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.5),
                valueColor: const AlwaysStoppedAnimation(MomentoColors.rose),
              ),
            ),
            const SizedBox(height: 8),
            Text('$done / $total', style: theme.textTheme.labelSmall),
          ],
        ],
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.state});

  final SyncState state;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final (color, icon, label) = switch (state) {
      SyncState.synced => (MomentoColors.success, Icons.check_circle_rounded, t.syncStateSynced),
      SyncState.failed => (MomentoColors.danger, Icons.error_rounded, t.syncStateFailed),
      SyncState.pending => (MomentoColors.warning, Icons.schedule_rounded, t.syncStatePending),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

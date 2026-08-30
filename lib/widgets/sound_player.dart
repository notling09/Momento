import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../core/l10n/app_texts.dart';
import '../core/theme/momento_colors.dart';
import '../core/utils/date_format.dart';
import '../data/models/memory.dart';
import '../data/models/stored_media.dart';

/// Abspielleiste fuer die Tonaufnahme einer Erinnerung.
///
/// Zeigt eine Wellenform, die sich waehrend der Wiedergabe einfaerbt.
class SoundPlayerBar extends StatefulWidget {
  const SoundPlayerBar({
    super.key,
    required this.clip,
    this.onDelete,
    this.compact = false,
  });

  final SoundClip clip;
  final VoidCallback? onDelete;
  final bool compact;

  @override
  State<SoundPlayerBar> createState() => _SoundPlayerBarState();
}

class _SoundPlayerBarState extends State<SoundPlayerBar> {
  final _player = AudioPlayer();
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration? _total;

  @override
  void initState() {
    super.initState();
    _total = widget.clip.duration;
    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state == PlayerState.playing);
    });
    _player.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() => _position = position);
    });
    _player.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() => _total = duration);
    });
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
      return;
    }
    final source = _sourceFor(widget.clip.media);
    if (source == null) return;
    await _player.play(source);
  }

  Source? _sourceFor(StoredMedia media) {
    final bytes = media.bytes;
    if (bytes != null) return BytesSource(bytes, mimeType: media.mimeType);
    final path = media.path;
    if (path != null) return DeviceFileSource(path);
    return null;
  }

  double get _progress {
    final total = _total;
    if (total == null || total.inMilliseconds == 0) return 0;
    return (_position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final label = widget.clip.label?.trim();

    return Container(
      padding: EdgeInsets.all(widget.compact ? 9 : 12),
      decoration: BoxDecoration(
        color: MomentoColors.soundAccent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: MomentoColors.soundAccent.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          _PlayButton(playing: _playing, onTap: _toggle, size: widget.compact ? 38 : 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label != null && label.isNotEmpty)
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  )
                else
                  Text(t.memorySound, style: theme.textTheme.titleSmall),
                const SizedBox(height: 6),
                SizedBox(
                  height: widget.compact ? 20 : 26,
                  child: CustomPaint(
                    painter: _WaveformPainter(
                      progress: _progress,
                      seed: (label ?? 'sound').hashCode,
                      active: MomentoColors.soundAccent,
                      inactive: MomentoColors.soundAccent.withValues(alpha: 0.30),
                    ),
                    size: Size.infinite,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _total == null
                ? '--:--'
                : MomentoDates.duration(_playing ? _position : _total!),
            style: theme.textTheme.labelSmall,
          ),
          if (widget.onDelete != null)
            IconButton(
              onPressed: widget.onDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              tooltip: t.memorySoundDelete,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.playing, required this.onTap, required this.size});

  final bool playing;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) => Material(
        color: MomentoColors.soundAccent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: size * 0.52,
            ),
          ),
        ),
      );
}

/// Gezeichnete Wellenform. Die Balken sind aus dem Namen der Aufnahme
/// abgeleitet, damit dieselbe Aufnahme immer gleich aussieht.
class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.progress,
    required this.seed,
    required this.active,
    required this.inactive,
  });

  final double progress;
  final int seed;
  final Color active;
  final Color inactive;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    const barWidth = 3.0;
    const gap = 3.0;
    final count = math.max(1, (size.width / (barWidth + gap)).floor());
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (var i = 0; i < count; i++) {
      final t = i / count;
      // Eine sanfte Huellkurve, damit es nicht wie ein Zufallszaun aussieht.
      final envelope = 0.35 + 0.65 * math.sin(math.pi * t).abs();
      final height = size.height * envelope * (0.30 + random.nextDouble() * 0.70);
      final x = i * (barWidth + gap) + barWidth / 2;
      paint.color = t <= progress ? active : inactive;
      paint.strokeWidth = barWidth;
      canvas.drawLine(
        Offset(x, size.height / 2 - height / 2),
        Offset(x, size.height / 2 + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.seed != seed;
}

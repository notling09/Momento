import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../core/l10n/app_texts.dart';
import '../core/momento_controller.dart';
import '../core/theme/momento_colors.dart';
import '../core/utils/date_format.dart';
import '../core/utils/wav.dart';
import '../data/models/memory.dart';
import 'sound_player.dart';

/// Nimmt ein Geraeusch auf und haengt es an die Erinnerung.
///
/// Aufgenommen wird als roher PCM-Strom, den wir selbst zu einer WAV-Datei
/// zusammensetzen. Das verhaelt sich auf Android, iOS und im Browser gleich
/// und liefert Daten, die sich dauerhaft speichern lassen.
class SoundRecorderField extends StatefulWidget {
  const SoundRecorderField({
    super.key,
    required this.clip,
    required this.onChanged,
  });

  final SoundClip? clip;
  final ValueChanged<SoundClip?> onChanged;

  @override
  State<SoundRecorderField> createState() => _SoundRecorderFieldState();
}

class _SoundRecorderFieldState extends State<SoundRecorderField> {
  static const _sampleRate = 16000;

  final _recorder = AudioRecorder();
  final _label = TextEditingController();

  StreamSubscription<Uint8List>? _subscription;
  final _chunks = <Uint8List>[];
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  bool _recording = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _label.text = widget.clip?.label ?? '';
    _label.addListener(_onLabelChanged);
  }

  @override
  void dispose() {
    _label.removeListener(_onLabelChanged);
    _label.dispose();
    _ticker?.cancel();
    _subscription?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  void _onLabelChanged() {
    final clip = widget.clip;
    if (clip == null) return;
    widget.onChanged(clip.copyWith(label: _label.text));
  }

  Future<void> _start() async {
    setState(() => _error = null);
    final t = AppTexts.of(context);

    try {
      if (!await _recorder.hasPermission()) {
        if (!mounted) return;
        setState(() => _error = t.memorySoundPermission);
        return;
      }

      _chunks.clear();
      _elapsed = Duration.zero;

      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
        ),
      );

      _subscription = stream.listen(_chunks.add);
      _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (!mounted) return;
        setState(() => _elapsed += const Duration(milliseconds: 200));
      });

      if (mounted) setState(() => _recording = true);
    } catch (_) {
      // Kein Mikrofon, kein Zugriff oder ein Fehler im Geraet: die App soll
      // deswegen nicht stehen bleiben.
      if (!mounted) return;
      setState(() {
        _recording = false;
        _error = t.memorySoundFailed;
      });
    }
  }

  Future<void> _stop() async {
    setState(() => _busy = true);
    _ticker?.cancel();
    try {
      await _recorder.stop();
    } catch (_) {
      // Bereits gestoppt - das aufgenommene Material bleibt trotzdem gueltig.
    }
    await _subscription?.cancel();
    _subscription = null;

    final totalLength = _chunks.fold<int>(0, (sum, chunk) => sum + chunk.length);
    final pcm = Uint8List(totalLength);
    var offset = 0;
    for (final chunk in _chunks) {
      pcm.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    _chunks.clear();

    if (!mounted) return;
    if (totalLength == 0) {
      setState(() {
        _recording = false;
        _busy = false;
      });
      return;
    }

    final wav = WavCodec.fromPcm16(pcm, sampleRate: _sampleRate);
    final duration = WavCodec.durationOfPcm16(totalLength, sampleRate: _sampleRate);

    final media = await AppScope.read(context).storeMedia(
      wav,
      extension: 'wav',
      mimeType: 'audio/wav',
      durationMs: duration.inMilliseconds,
    );

    if (!mounted) return;
    widget.onChanged(SoundClip(
      media: media,
      label: _label.text.trim().isEmpty ? null : _label.text.trim(),
    ));
    setState(() {
      _recording = false;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final clip = widget.clip;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (clip != null && !_recording) ...[
          SoundPlayerBar(
            key: ValueKey(clip.media.path ?? clip.media.base64Data?.length),
            clip: clip,
            onDelete: () {
              widget.onChanged(null);
              _label.clear();
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _label,
            decoration: InputDecoration(
              labelText: t.memorySoundLabel,
              hintText: t.memorySoundLabelHint,
              prefixIcon: const Icon(Icons.label_outline_rounded),
            ),
          ),
        ] else if (_recording)
          _RecordingBox(elapsed: _elapsed, busy: _busy, onStop: _stop)
        else
          _StartRecordingBox(onStart: _busy ? null : _start),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(
            _error!,
            style: theme.textTheme.bodySmall?.copyWith(color: MomentoColors.danger),
          ),
        ],
      ],
    );
  }
}

class _StartRecordingBox extends StatelessWidget {
  const _StartRecordingBox({required this.onStart});

  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);

    return InkWell(
      onTap: onStart,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: MomentoColors.soundAccent.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: MomentoColors.soundAccent.withValues(alpha: 0.32),
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: MomentoColors.soundAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t.memorySoundRecord, style: theme.textTheme.titleMedium),
                  Text(t.memorySoundLabelHint, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingBox extends StatelessWidget {
  const _RecordingBox({
    required this.elapsed,
    required this.busy,
    required this.onStop,
  });

  final Duration elapsed;
  final bool busy;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: MomentoColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MomentoColors.danger.withValues(alpha: 0.35), width: 1.4),
      ),
      child: Row(
        children: [
          const _PulsingDot(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(MomentoDates.duration(elapsed),
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: 6),
                const SizedBox(height: 18, child: _LiveWave()),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: MomentoColors.danger,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            onPressed: busy ? null : onStop,
            child: Text(
              t.memorySoundStop,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
        child: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: MomentoColors.danger,
            shape: BoxShape.circle,
          ),
        ),
      );
}

/// Bewegte Balken waehrend der Aufnahme.
class _LiveWave extends StatefulWidget {
  const _LiveWave();

  @override
  State<_LiveWave> createState() => _LiveWaveState();
}

class _LiveWaveState extends State<_LiveWave>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _LiveWavePainter(_controller.value),
          size: Size.infinite,
        ),
      );
}

class _LiveWavePainter extends CustomPainter {
  _LiveWavePainter(this.phase);

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MomentoColors.danger.withValues(alpha: 0.75)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const spacing = 6.0;
    final count = (size.width / spacing).floor();
    for (var i = 0; i < count; i++) {
      final t = i / count;
      final wave = math.sin((t * 5 + phase * 2) * math.pi * 2).abs();
      final height = size.height * (0.20 + wave * 0.80);
      final x = i * spacing + 1.5;
      canvas.drawLine(
        Offset(x, size.height / 2 - height / 2),
        Offset(x, size.height / 2 + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LiveWavePainter oldDelegate) => oldDelegate.phase != phase;
}

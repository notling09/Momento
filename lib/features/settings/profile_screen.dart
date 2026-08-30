import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/app_texts.dart';
import '../../core/momento_controller.dart';
import '../../core/theme/momento_colors.dart';
import '../../core/theme/momento_theme.dart';
import '../../core/utils/date_format.dart';
import '../../widgets/common.dart';

/// Das Profil - im Businessplan ausdruecklich freiwillig
/// ("in dem man seine Daten angeben (optional) ... kann").
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  DateTime? _birthday;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final user = AppScope.read(context).user;
    if (user == null) return;
    _name.text = user.displayName;
    _birthday = user.birthday;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final controller = AppScope.read(context);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 640,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final media = await controller.storeMedia(
        bytes,
        extension: 'jpg',
        mimeType: 'image/jpeg',
      );
      await controller.updateProfile(avatar: media);
    } catch (_) {
      // Kein Zugriff auf die Galerie - Profil bleibt ohne Bild.
    }
  }

  Future<void> _save() async {
    final t = AppTexts.of(context);
    final controller = AppScope.read(context);
    final messenger = ScaffoldMessenger.of(context);

    await controller.updateProfile(
      displayName: _name.text.trim().isEmpty ? null : _name.text.trim(),
      birthday: _birthday,
      clearBirthday: _birthday == null,
    );
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(t.profileSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);
    final controller = AppScope.of(context);
    final user = controller.user;

    return Scaffold(
      appBar: AppBar(title: Text(t.profile)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: const BoxDecoration(
                      gradient: MomentoGradients.header,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    child: user?.avatar != null
                        ? StoredImageView(media: user!.avatar!)
                        : Text(
                            user?.initials ?? '?',
                            style: const TextStyle(
                              fontFamily: MomentoFonts.display,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: Icon(Icons.photo_camera_rounded,
                          size: 15, color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(user?.email ?? '', style: theme.textTheme.bodySmall),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(t.profileOptionalNote, style: theme.textTheme.labelSmall),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: t.displayName,
              hintText: t.displayNameHint,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _birthday ?? DateTime(2000),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _birthday = date);
            },
            borderRadius: BorderRadius.circular(MomentoRadii.tile),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.surfaceContainerHighest
                    : Colors.white,
                borderRadius: BorderRadius.circular(MomentoRadii.tile),
                border: Border.all(color: theme.colorScheme.outline, width: 1.2),
              ),
              child: Row(
                children: [
                  Icon(Icons.cake_outlined,
                      size: 21, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t.birthday, style: theme.textTheme.labelSmall),
                        Text(
                          _birthday == null
                              ? t.birthdayNotSet
                              : MomentoDates.day(_birthday!, t),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  if (_birthday != null)
                    IconButton(
                      onPressed: () => setState(() => _birthday = null),
                      icon: const Icon(Icons.close_rounded, size: 19),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.colorScheme.outline)),
        ),
        child: GradientButton(
          label: t.actionSave,
          icon: Icons.check_rounded,
          onPressed: _save,
        ),
      ),
    );
  }
}

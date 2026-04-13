import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/utils/assets_utils.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/communities_actions.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<CreateCommunityScreen> createState() =>
      _CreateCommunityDialogState();
}

class _CreateCommunityDialogState extends ConsumerState<CreateCommunityScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  File? _selectedImage;
  final _picker = ImagePicker();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // static const _redditOrange = Color(0xFFFF4500);
  // static const _maxNameLength = 21;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  bool get _canCreate => !_isLoading && _nameController.text.trim().isNotEmpty;

  Future<void> _createCommunity() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await ref
            .read(communitiesActionsProvider.notifier)
            .uploadCommunityImage(_selectedImage!);
      }

      final res = await ref
          .read(communitiesActionsProvider.notifier)
          .createCommunity(
            name: name,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            imageUrl: imageUrl,
          );

      if (res != null && res['success'] == false) {
        setState(() {
          _isLoading = false;
          _error = res['message'];
        });
      } else {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text('r/$name created successfully!'),
                ],
              ),
              backgroundColor: const Color(0xFF46D160),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("error in create community ${e.toString()}");
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    // final isDark = Theme.of(context).brightness == Brightness.dark;
    // final bg = isDark ? const Color(0xFF0D1117) : Colors.white;
    // final surface = isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA);
    // final border = isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE);
    // final textPrimary = isDark ? Colors.white : const Color(0xFF1C2128);
    // final textSecondary = isDark
    //     ? const Color(0xFF8B949E)
    //     : const Color(0xFF656D76);

    return Scaffold(
      backgroundColor: tokens.bgCanvas,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──────────────────────────────────────────
              _TopBar(
                context: context,
                // isDark: isDark,
                // border: border,
                // textPrimary: textPrimary,
                canCreate: _canCreate,
                isLoading: _isLoading,
                onClose: () => Navigator.pop(context),
                onCreate: _createCommunity,
              ),

              // ── Scrollable Content ────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar picker centered
                      Center(
                        child: _AvatarPicker(
                          // isDark: isDark,
                          selectedImage: _selectedImage,
                          onTap: _pickImage,
                          context: context,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Community Name
                      _SectionLabel(label: 'Community Name', context: context),
                      const SizedBox(height: 4),
                      Text(
                        'Names including capitalization cannot be changed.',
                        style: TextStyle(fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      _NameField(
                        controller: _nameController,
                        onChanged: (_) => setState(() {}),
                        context: context,
                      ),
                      const SizedBox(height: 8),
                      _CharCounter(
                        current: _nameController.text.length.toDouble(),
                        max: 21,
                        textSecondary: context.tokens.textSecondary,
                      ),
                      const SizedBox(height: 24),

                      // Description
                      _SectionLabel(
                        context: context,
                        label: 'Description',
                        optional: true,
                      ),
                      const SizedBox(height: 12),
                      _DescriptionField(
                        controller: _descriptionController,
                        context: context,
                        // isDark: null,
                        // surface: null,
                        // border: null,
                        // textPrimary: null,
                        // textSecondary: null,
                        // isDark: isDark,
                        // surface: surface,
                        // border: border,
                        // textPrimary: textPrimary,
                        // textSecondary: textSecondary,
                      ),

                      // Error Banner
                      if (_error != null) ...[
                        const SizedBox(height: 20),
                        _ErrorBanner(message: _error!),
                      ],
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
}

class _TopBar extends StatelessWidget {
  _TopBar({
    required this.context,
    // required this.isDark,
    // required this.border,
    // required this.textPrimary,
    required this.canCreate,
    required this.isLoading,
    required this.onClose,
    required this.onCreate,
  });
  final BuildContext context;
  // final bool isDark;
  // final Color border;
  // final Color textPrimary;
  final bool canCreate;
  final bool isLoading;
  final VoidCallback onClose;
  final VoidCallback onCreate;

  late final tokens = context.tokens;
  late final border = tokens.cardBorder;
  late final textPrimary = tokens.textPrimary;

  static const _redditOrange = Color(0xFFFF4500);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Close
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, color: textPrimary, size: 22),
            splashRadius: 20,
          ),
          // Title
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AssetsUtils.emojiLaughing, width: 18, height: 18),
                const SizedBox(width: 8),
                Text(
                  'Create Community',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          // Create button
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: AnimatedOpacity(
              opacity: canCreate ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: TextButton(
                onPressed: canCreate ? onCreate : null,
                style: TextButton.styleFrom(
                  backgroundColor: canCreate
                      ? _redditOrange
                      : Colors.transparent,
                  foregroundColor: canCreate ? Colors.white : Colors.grey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(72, 36),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.context,
    // required this.isDark,
    required this.selectedImage,
    required this.onTap,
  });

  final BuildContext context;
  // final bool isDark;
  final File? selectedImage;
  final VoidCallback onTap;

  static const _redditOrange = Color(0xFFFF4500);

  @override
  Widget build(BuildContext context) {
    final hasImage = selectedImage != null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              // Avatar circle
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.tokens.bgPage,
                  border: Border.all(
                    color: hasImage
                        ? context.tokens.brandOrange
                        : context.tokens.cardBorder,
                    width: hasImage ? 2.5 : 1.5,
                  ),
                  image: hasImage
                      ? DecorationImage(
                          image: FileImage(selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !hasImage
                    ? Icon(
                        Icons.photo_camera_rounded,
                        size: 32,
                        color: context.tokens.textSecondary,
                      )
                    : null,
              ),
              // Edit badge
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: _redditOrange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasImage ? Icons.edit_rounded : Icons.add_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hasImage ? 'Change icon' : 'Add community icon',
            style: TextStyle(
              color: _redditOrange,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.context,
    required this.label,
    this.optional = false,
  });

  final String label;
  final BuildContext context;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.tokens.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          Text(
            'optional',
            style: TextStyle(
              color: const Color(0xFF8B949E),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.context,
    required this.onChanged,
  });

  final BuildContext context;

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  static const _redditOrange = Color(0xFFFF4500);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      onChanged: onChanged,
      maxLength: 21,
      buildCounter:
          (_, {required currentLength, required isFocused, maxLength}) => null,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
      ],
      style: TextStyle(color: context.tokens.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        prefixText: 'r/',
        prefixStyle: TextStyle(
          color: _redditOrange,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        filled: true,
        fillColor: context.tokens.bgInput,
        hintText: 'community_name',
        hintStyle: TextStyle(color: context.tokens.textSecondary, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.tokens.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.tokens.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _redditOrange, width: 1.5),
        ),
      ),
    );
  }
}

class _CharCounter extends StatelessWidget {
  const _CharCounter({
    required this.current,
    required this.max,
    required this.textSecondary,
  });

  final double current;
  final double max;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final remaining = max - current;
    final isNearLimit = remaining <= 5;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$current / $max',
          style: TextStyle(
            color: isNearLimit ? const Color(0xFFFF4500) : textSecondary,
            fontSize: 12,
            fontWeight: isNearLimit ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _DescriptionField extends StatelessWidget {
  _DescriptionField({
    required this.context,
    required this.controller,
    // required this.isDark,
    // required this.surface,
    // required this.border,
    // required this.textPrimary,
  });

  late final tokens = context.tokens;
  late final border = tokens.cardBorder;
  late final textPrimary = tokens.textPrimary;
  final BuildContext context;
  final TextEditingController controller;
  // final bool isDark;
  // final Color surface;
  // final Color border;
  // final Color textPrimary;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 4,
      minLines: 3,
      style: TextStyle(color: textPrimary, fontSize: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: tokens.bgPage,
        hintText: 'What is this community about?',
        hintStyle: TextStyle(color: tokens.textSecondary, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.brandOrange, width: 1.5),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4500).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFF4500).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF4500),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFF4500),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

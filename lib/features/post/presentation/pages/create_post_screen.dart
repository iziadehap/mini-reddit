import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/core/theme/app_theme_v2.dart';
import 'package:mini_reddit_v2/core/utils/image_utils.dart';
import 'package:mini_reddit_v2/features/communities/presentation/riverpod/user_communities_provider.dart';
import 'package:mini_reddit_v2/features/post/presentation/providers/create_post_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final CommunityModel? initialCommunity;
  const CreatePostScreen({super.key, this.initialCommunity});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  UserCommunityModel? _selectedCommunity;
  List<File> _selectedImages = [];

  // Tab: 0 = Text, 1 = Image
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userCommunitiesProvider.notifier).fetchUserCommunities();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  bool get _canPost {
    final isUploading = ref.watch(createPostProvider).isLoading;
    return !isUploading &&
        _titleController.text.trim().isNotEmpty &&
        _selectedCommunity != null &&
        (_contentController.text.trim().isNotEmpty ||
            _selectedImages.isNotEmpty);
  }

  void _handlePost() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) return _snack('Please enter a title');
    if (content.isEmpty && _selectedImages.isEmpty)
      return _snack('Please add content or an image');
    if (_selectedCommunity == null)
      return _snack('Please select a community');

    ref.read(createPostProvider.notifier).createPost(
          communityId: _selectedCommunity!.id,
          title: title,
          content: content,
          imageFiles: _selectedImages,
        );
  }

  void _snack(String msg) {
    final t = context.tokens;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 13,
                color: t.textPrimary)),
        backgroundColor: t.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),
    );
  }

  Future<void> _pickImage() async {
    final images = await ImageUtils.pickMultipleImages();
    if (images.isNotEmpty) setState(() => _selectedImages.addAll(images));
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final typo = context.rTypo;

    ref.listen<SnackbarState>(createPostSnackbarProvider, (previous, next) {
      if (next.message != null) {
        _snack(next.message!);
        if (!next.isError && next.message == "Post created successfully") {
          Navigator.pop(context);
        }
      }
    });

    return Scaffold(
      backgroundColor: t.bgCanvas,
      appBar: _buildAppBar(t, typo),
      body: Column(
        children: [
          // ── Community selector row
          _CommunitySelector(
            selected: _selectedCommunity,
            tokens: t,
            typo: typo,
            onTap: () => _showCommunityPicker(),
          ),

          Divider(height: 1, thickness: 0.8, color: t.divider),

          // ── Post type tabs
          _PostTypeTabs(controller: _tabController, tokens: t),

          Divider(height: 1, thickness: 0.8, color: t.divider),

          // ── Content area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TextPostBody(
                  titleController: _titleController,
                  contentController: _contentController,
                  tokens: t,
                  typo: typo,
                  onChanged: () => setState(() {}),
                ),
                _ImagePostBody(
                  titleController: _titleController,
                  images: _selectedImages,
                  tokens: t,
                  typo: typo,
                  onChanged: () => setState(() {}),
                  onPickImage: _pickImage,
                  onRemoveImage: (i) =>
                      setState(() => _selectedImages.removeAt(i)),
                ),
              ],
            ),
          ),

          // ── Bottom toolbar
          _BottomToolbar(
            tokens: t,
            selectedImages: _selectedImages,
            onPickImage: _pickImage,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(RedditTokens t, RedditTypography typo) {
    final isUploading = ref.watch(createPostProvider).isLoading;
    return AppBar(
      backgroundColor: t.bgSurface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: t.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Create Post',
          style: typo.titleMedium.copyWith(color: t.textPrimary)),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, thickness: 0.8, color: t.divider),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: AnimatedOpacity(
            opacity: _canPost ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: TextButton(
              onPressed: _canPost ? _handlePost : null,
              style: TextButton.styleFrom(
                backgroundColor:
                    _canPost ? t.brandOrange : t.brandOrange.withOpacity(0.3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.xs + 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full)),
                minimumSize: const Size(64, 34),
              ),
              child: isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Post',
                      style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Community picker bottom sheet ──────────────────────────
  void _showCommunityPicker() {
    final t = context.tokens;
    final typo = context.rTypo;

    showModalBottomSheet(
      context: context,
      backgroundColor: t.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final communitiesAsync = ref.watch(userCommunitiesProvider);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: AppSpacing.md),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: t.borderDefault,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
                child: Text('Post to',
                    style: typo.titleLarge.copyWith(color: t.textPrimary)),
              ),
              Divider(height: 1, color: t.divider),

              if (communitiesAsync.isLoading)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.huge),
                  child: Center(
                    child: CircularProgressIndicator(color: t.brandOrange),
                  ),
                )
              else
                Flexible(
                  child: Builder(builder: (_) {
                    final communities = communitiesAsync.value ?? [];
                    if (communities.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          "You haven't joined any communities yet.",
                          style: typo.bodyMedium
                              .copyWith(color: t.textSecondary),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: communities.length,
                      itemBuilder: (_, index) {
                        final community = communities[index];
                        final isSelected =
                            _selectedCommunity?.id == community.id;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.xs),
                          tileColor: isSelected
                              ? t.brandOrange.withOpacity(0.08)
                              : null,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: t.bgElevated,
                            // ✅ null-safe: only load image if url is non-null & non-empty
                            backgroundImage: (community.imageUrl != null &&
                                    community.imageUrl!.isNotEmpty)
                                ? CachedNetworkImageProvider(
                                    community.imageUrl!)
                                : null,
                            child: (community.imageUrl == null ||
                                    community.imageUrl!.isEmpty)
                                ? Icon(Icons.people_rounded,
                                    size: 16, color: t.textSecondary)
                                : null,
                          ),
                          title: Text(
                            'r/${community.name}',
                            style: typo.communityName
                                .copyWith(color: t.textPrimary),
                          ),
                          subtitle: Text(
                            '${community.membersCount} members',
                            style: typo.postMeta
                                .copyWith(color: t.textSecondary),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle_rounded,
                                  color: t.brandOrange, size: 20)
                              : null,
                          onTap: () {
                            setState(() => _selectedCommunity = community);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    );
                  }),
                ),
              SizedBox(
                  height: MediaQuery.of(ctx).padding.bottom +
                      AppSpacing.md),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────

class _CommunitySelector extends StatelessWidget {
  const _CommunitySelector({
    required this.selected,
    required this.tokens,
    required this.typo,
    required this.onTap,
  });

  final UserCommunityModel? selected;
  final RedditTokens tokens;
  final RedditTypography typo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final hasSelection = selected != null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: t.bgElevated,
              backgroundImage: (hasSelection &&
                      selected!.imageUrl != null &&
                      selected!.imageUrl!.isNotEmpty)
                  ? CachedNetworkImageProvider(selected!.imageUrl!)
                  : null,
              child: (!hasSelection ||
                      selected!.imageUrl == null ||
                      selected!.imageUrl!.isEmpty)
                  ? Icon(
                      hasSelection
                          ? Icons.people_rounded
                          : Icons.add_circle_outline_rounded,
                      size: 16,
                      color: hasSelection ? t.textSecondary : t.brandOrange,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                hasSelection ? 'r/${selected!.name}' : 'Choose a community',
                style: hasSelection
                    ? typo.communityName.copyWith(color: t.textPrimary)
                    : typo.bodyMedium.copyWith(color: t.brandOrange),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: t.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PostTypeTabs extends StatelessWidget {
  const _PostTypeTabs(
      {required this.controller, required this.tokens});

  final TabController controller;
  final RedditTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return TabBar(
      controller: controller,
      indicatorColor: t.brandOrange,
      indicatorWeight: 2.5,
      labelColor: t.brandOrange,
      unselectedLabelColor: t.textSecondary,
      labelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 13,
          fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 13,
          fontWeight: FontWeight.w500),
      tabs: const [
        Tab(icon: Icon(Icons.text_fields_rounded, size: 18), text: 'Text'),
        Tab(icon: Icon(Icons.image_outlined, size: 18), text: 'Image'),
      ],
    );
  }
}

class _TextPostBody extends StatelessWidget {
  const _TextPostBody({
    required this.titleController,
    required this.contentController,
    required this.tokens,
    required this.typo,
    required this.onChanged,
  });

  final TextEditingController titleController;
  final TextEditingController contentController;
  final RedditTokens tokens;
  final RedditTypography typo;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          // Title
          TextField(
            controller: titleController,
            onChanged: (_) => onChanged(),
            maxLines: null,
            style: typo.postTitle.copyWith(color: t.textPrimary),
            decoration: InputDecoration(
              hintText: 'An interesting title',
              hintStyle: typo.postTitle.copyWith(color: t.textSecondary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Divider(color: t.divider, height: AppSpacing.xl),
          // Body
          TextField(
            controller: contentController,
            onChanged: (_) => onChanged(),
            maxLines: null,
            minLines: 8,
            style: typo.bodyLarge.copyWith(color: t.textPrimary),
            decoration: InputDecoration(
              hintText: "What's on your mind?",
              hintStyle: typo.bodyLarge.copyWith(color: t.textSecondary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePostBody extends StatelessWidget {
  const _ImagePostBody({
    required this.titleController,
    required this.images,
    required this.tokens,
    required this.typo,
    required this.onChanged,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  final TextEditingController titleController;
  final List<File> images;
  final RedditTokens tokens;
  final RedditTypography typo;
  final VoidCallback onChanged;
  final VoidCallback onPickImage;
  final void Function(int) onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          // Title
          TextField(
            controller: titleController,
            onChanged: (_) => onChanged(),
            maxLines: null,
            style: typo.postTitle.copyWith(color: t.textPrimary),
            decoration: InputDecoration(
              hintText: 'An interesting title',
              hintStyle: typo.postTitle.copyWith(color: t.textSecondary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Divider(color: t.divider, height: AppSpacing.xl),

          // Image grid or add button
          if (images.isEmpty)
            _AddImageButton(tokens: t, typo: typo, onTap: onPickImage)
          else ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1,
              ),
              itemCount: images.length + 1, // +1 for add button
              itemBuilder: (_, i) {
                if (i == images.length) {
                  return _AddImageTile(tokens: t, onTap: onPickImage);
                }
                return _ImageTile(
                  file: images[i],
                  tokens: t,
                  onRemove: () => onRemoveImage(i),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _AddImageButton extends StatelessWidget {
  const _AddImageButton(
      {required this.tokens, required this.typo, required this.onTap});

  final RedditTokens tokens;
  final RedditTypography typo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: t.bgInput,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
              color: t.borderDefault,
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 40, color: t.textSecondary),
            const SizedBox(height: AppSpacing.sm),
            Text('Add images',
                style: typo.labelLarge.copyWith(color: t.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            Text('Tap to browse your gallery',
                style: typo.bodySmall.copyWith(color: t.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _AddImageTile extends StatelessWidget {
  const _AddImageTile({required this.tokens, required this.onTap});

  final RedditTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: tokens.bgInput,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border:
              Border.all(color: tokens.borderDefault, width: 1.5),
        ),
        child: Icon(Icons.add_rounded, color: tokens.textSecondary, size: 32),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile(
      {required this.file, required this.tokens, required this.onRemove});

  final File file;
  final RedditTokens tokens;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Image.file(file, fit: BoxFit.cover),
        ),
        Positioned(
          top: AppSpacing.xs,
          right: AppSpacing.xs,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomToolbar extends StatelessWidget {
  const _BottomToolbar({
    required this.tokens,
    required this.selectedImages,
    required this.onPickImage,
  });

  final RedditTokens tokens;
  final List<File> selectedImages;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Container(
      decoration: BoxDecoration(
        color: t.bgSurface,
        border: Border(top: BorderSide(color: t.divider, width: 0.8)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              selectedImages.isNotEmpty
                  ? Icons.image_rounded
                  : Icons.image_outlined,
              color: selectedImages.isNotEmpty ? t.brandBlue : t.textSecondary,
              size: 22,
            ),
            onPressed: onPickImage,
            tooltip: 'Add image',
          ),
          IconButton(
            icon: Icon(Icons.link_rounded, color: t.textSecondary, size: 22),
            onPressed: () {},
            tooltip: 'Add link',
          ),
          const Spacer(),
          Icon(Icons.keyboard_hide_outlined,
              color: t.textMuted, size: 20),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}
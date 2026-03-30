// lib/features/profile/presentation/widgets/profile_shimmer.dart

import 'package:flutter/material.dart';
import 'package:shimmer_ai/shimmer_ai.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // SliverAppBar with banner shimmer
            SliverAppBar(
              expandedHeight: 220.0,
              pinned: true,
              floating: false,
              backgroundColor: Theme.of(context).colorScheme.surface,
              automaticallyImplyLeading: false,
              actions: const [
                SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Banner shimmer
                    Positioned.fill(
                      child: Container(color: Colors.grey[300]).withShimmerAi(
                        loading: true,
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 80,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Avatar shimmer
                    Positioned(
                      bottom: 20,
                      left: 16,
                      child: Container(
                        width: 94,
                        height: 94,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                        ).withShimmerAi(
                          loading: true,
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    // Action buttons shimmer
                    Positioned(
                      top: 60,
                      right: 16,
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              shape: BoxShape.circle,
                            ),
                          ).withShimmerAi(
                            loading: true,
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              shape: BoxShape.circle,
                            ),
                          ).withShimmerAi(
                            loading: true,
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              shape: BoxShape.circle,
                            ),
                          ).withShimmerAi(
                            loading: true,
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info block shimmer
            SliverToBoxAdapter(
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 57),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name row
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 28,
                                  color: Colors.grey[300],
                                ).withShimmerAi(
                                  loading: true,
                                  width: double.infinity,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 40,
                                height: 20,
                                color: Colors.grey[300],
                              ).withShimmerAi(
                                loading: true,
                                width: 40,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Username and followers
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 14,
                                color: Colors.grey[300],
                              ).withShimmerAi(
                                loading: true,
                                width: 80,
                                height: 14,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text('·'),
                              ),
                              Container(
                                width: 70,
                                height: 14,
                                color: Colors.grey[300],
                              ).withShimmerAi(
                                loading: true,
                                width: 70,
                                height: 14,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Bio shimmer
                          Container(
                            height: 14,
                            width: 200,
                            color: Colors.grey[300],
                          ).withShimmerAi(
                            loading: true,
                            width: 200,
                            height: 14,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Stats row
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatCellShimmer(context),
                                ),
                                VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                Expanded(
                                  child: _buildStatCellShimmer(context),
                                ),
                                VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                Expanded(
                                  child: _buildStatCellShimmer(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // TabBar shimmer
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarShimmerDelegate(
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ];
        },
        body: const TabBarView(
          children: [
            _ShimmerTabContent(),
            _ShimmerTabContent(),
            _ShimmerTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCellShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: 50,
            color: Colors.grey[300],
          ).withShimmerAi(
            loading: true,
            width: 50,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 11,
            width: 40,
            color: Colors.grey[300],
          ).withShimmerAi(
            loading: true,
            width: 40,
            height: 11,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerTabContent extends StatelessWidget {
  const _ShimmerTabContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
            ).withShimmerAi(
              loading: true,
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 20,
              width: 120,
              color: Colors.grey[300],
            ).withShimmerAi(
              loading: true,
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 14,
              width: 180,
              color: Colors.grey[300],
            ).withShimmerAi(
              loading: true,
              width: 180,
              height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyTabBarShimmerDelegate extends SliverPersistentHeaderDelegate {






  final Color color;

  const _StickyTabBarShimmerDelegate({required this.color});

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: 20,
            width: 50,
            color: Colors.grey[300],
          ).withShimmerAi(
            loading: true,
            width: 50,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            height: 20,
            width: 70,
            color: Colors.grey[300],
          ).withShimmerAi(
            loading: true,
            width: 70,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            height: 20,
            width: 50,
            color: Colors.grey[300],
          ).withShimmerAi(
            loading: true,
            width: 50,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarShimmerDelegate oldDelegate) =>
      oldDelegate.color != color;
}




class ProfileErrorWidgetEnhanced extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback? onReport;
  final String? errorCode;

  const ProfileErrorWidgetEnhanced({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.onReport,
    this.errorCode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.error.withOpacity(0.15),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: Center(
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.signal_wifi_statusbar_null_rounded,
                        size: 50,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'Unable to Load Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    'We encountered an issue while trying to load your profile information.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Error card
                  Material(
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 20,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Error Details',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            errorMessage,
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          if (errorCode != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Error Code: $errorCode',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // HapticFeedback.lightImpact();
                            onRetry();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: const Text('Retry'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onReport ?? () {
                            _showReportDialog(context);
                          },
                          icon: const Icon(Icons.feedback_rounded, size: 20),
                          label: const Text('Report'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Help text
                  GestureDetector(
                    onTap: () {
                      _showHelpDialog(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Need help?',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Issue'),
          content: const Text('Would you like to report this error to our support team?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement report logic here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report sent successfully')),
                );
              },
              child: const Text('Report'),
            ),
          ],
        );
      },
    );
  }
  
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Troubleshooting'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('• Check your internet connection'),
              SizedBox(height: 8),
              Text('• Make sure you are logged in'),
              SizedBox(height: 8),
              Text('• Try refreshing the page'),
              SizedBox(height: 8),
              Text('• Clear app cache'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}
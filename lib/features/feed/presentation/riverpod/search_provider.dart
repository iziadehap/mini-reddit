import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mini_reddit_v2/features/communities/data/communities_data_source.dart';
import 'package:mini_reddit_v2/features/feed/data/DataSource/feed_data_source.dart';
import 'package:mini_reddit_v2/features/feed/data/feed_repo_impl.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/feed_provider.dart';
import 'package:mini_reddit_v2/features/feed/presentation/riverpod/feed_state.dart';
import 'package:mini_reddit_v2/features/post/data/post_data_source.dart';
import 'package:mini_reddit_v2/features/post/data/post_repo_impl.dart';

final searchProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(
    ref: ref,
    feedRepo: FeedRepoImpl(FeedDataSource(), CommunitiesDataSource()),
    postRepo: PostRepoImpl(PostDataSource()),
  );
});

final searchQueryProvider = StateProvider<String>((ref) => '');

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_reddit_v2/core/models/models.dart';
import 'package:mini_reddit_v2/features/profile/presentation/providers/profile_provider.dart';

class UserWidget extends ConsumerWidget {
  const UserWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(myProfileProvider);
    UserProfileModel? profile = userProfile.value;
    if (profile == null) {
      return const Icon(Icons.person);
    }
    if (profile.avatarUrl == null) {
      return const Icon(Icons.person);
    }

    return SizedBox(
      height: 30,
      width: 30,
      child: CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(profile.avatarUrl!),
      ),
    );
  }
}

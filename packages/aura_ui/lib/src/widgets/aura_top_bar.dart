import 'package:flutter/material.dart';

import '../theme/aura_theme.dart';
import '../theme/aura_tokens.dart';

/// The global top bar: breadcrumb/title, a search trigger that opens the
/// command palette, a notifications bell, and a profile avatar.
class AuraTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AuraTopBar({
    super.key,
    required this.title,
    this.onSearchTap,
    this.onNotificationsTap,
    this.onProfileTap,
    this.notificationCount = 0,
  });

  final String title;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;
  final int notificationCount;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final aura = context.aura;

    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: AuraSpace.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: aura.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Search / Command palette',
            icon: const Icon(Icons.search),
            onPressed: onSearchTap,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Notifications',
                icon: const Icon(Icons.notifications_none),
                onPressed: onNotificationsTap,
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AuraColors.error, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AuraSpace.xs),
          GestureDetector(
            onTap: onProfileTap,
            child: const CircleAvatar(radius: 16, backgroundColor: AuraColors.violet, child: Text('A')),
          ),
        ],
      ),
    );
  }
}

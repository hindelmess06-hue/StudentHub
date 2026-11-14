import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/tiles.dart';

class ClubDetail extends StatelessWidget {
  const ClubDetail({super.key, required this.club});
  final Club club;

  void _showJoinDialog(BuildContext context) {
    final noteController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Join ${club.name}', style: AppText.display(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a membership application to ${club.president} (${club.email}).',
              style: AppText.body(13.5, color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteController,
              maxLines: 2,
              style: AppText.body(14),
              decoration: InputDecoration(
                hintText: 'Why do you want to join? (optional)',
                hintStyle: AppText.body(13.5, color: AppColors.muted),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppText.body(14, color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: club.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              toast(context, 'Membership request sent to ${club.name}');
            },
            child: Text(
              'Apply to Join',
              style: AppText.body(14, w: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final events = app.eventsForClub(club.id);
    final following = app.followedClubs.contains(club.id);
    final members = club.members + (following ? 1 : 0);

    return AppScaffold(
      body: Column(
        children: [
          const DetailTopBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                FadeSlideIn(
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          club.color.withValues(alpha: 0.55),
                          club.color.withValues(alpha: 0.10),
                        ],
                      ),
                      border:
                      Border.all(color: club.color.withValues(alpha: 0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: club.color,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: club.color.withValues(alpha: 0.55),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(club.icon, color: Colors.white, size: 34),
                        ),
                        const SizedBox(height: 18),
                        Text(club.name, style: AppText.display(32, height: 1.1)),
                        const SizedBox(height: 6),
                        Text(
                          club.tagline,
                          style: AppText.body(15,
                              color: Colors.white.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _MiniStat(value: '$members', label: 'members'),
                            const SizedBox(width: 24),
                            _MiniStat(
                                value: '${events.length}', label: 'events'),
                            const Spacer(),
                            FollowButton(club: club),
                            const SizedBox(width: 8),
                            Pressable(
                              onTap: () => _showJoinDialog(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  'Join',
                                  style: AppText.body(
                                    13.5,
                                    w: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  index: 1,
                  child: Text('About', style: AppText.display(20)),
                ),
                const SizedBox(height: 10),
                FadeSlideIn(
                  index: 1,
                  child: Text(
                    club.description,
                    style: AppText.body(15.5,
                        height: 1.6,
                        color: AppColors.text.withValues(alpha: 0.9)),
                  ),
                ),
                if (club.updates.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  Text('Latest updates', style: AppText.display(20)),
                  const SizedBox(height: 14),
                  for (var i = 0; i < club.updates.length; i++)
                    _UpdateRow(
                      update: club.updates[i],
                      color: club.color,
                      last: i == club.updates.length - 1,
                    ),
                ],
                if (events.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text('Upcoming events', style: AppText.display(20)),
                  const SizedBox(height: 14),
                  for (final e in events) ...[
                    EventTile(event: e),
                    const SizedBox(height: 12),
                  ],
                ],
                const SizedBox(height: 14),
                Text('Get in touch', style: AppText.display(20)),
                const SizedBox(height: 14),
                GlassCard(
                  onTap: () =>
                      copyToClipboard(context, club.email, 'Email address'),
                  child: Row(
                    children: [
                      Avatar(name: club.president, size: 44),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(club.president,
                                style: AppText.body(15, w: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(club.email,
                                style: AppText.body(13, color: AppColors.muted)),
                          ],
                        ),
                      ),
                      const Icon(Icons.content_copy_rounded,
                          size: 18, color: AppColors.muted),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppText.display(22)),
        Text(label,
            style: AppText.body(12, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }
}

class _UpdateRow extends StatelessWidget {
  const _UpdateRow({
    required this.update,
    required this.color,
    required this.last,
  });
  final ClubUpdate update;
  final Color color;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                const SizedBox(height: 5),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: color.withValues(alpha: 0.5), blurRadius: 8),
                    ],
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(timeAgo(update.date),
                      style: AppText.body(12, color: AppColors.muted)),
                  const SizedBox(height: 4),
                  Text(update.text,
                      style: AppText.body(15, height: 1.45)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
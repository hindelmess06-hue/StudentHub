import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'club_detail.dart';

class EventDetail extends StatelessWidget {
  const EventDetail({super.key, required this.event});
  final CampusEvent event;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final going = app.goingEvents.contains(event.id);
    final color = event.category.color;
    final club = app.clubById(event.clubId);
    final goingCount = event.baseGoing + (going ? 1 : 0);

    return AppScaffold(
      body: Column(
        children: [
          DetailTopBar(
            actions: [
              GlassIconButton(
                icon: Icons.content_copy_rounded,
                onTap: () => copyToClipboard(
                  context,
                  '${event.title}\n${fmtLong(event.start)}, ${event.timeRange}\n${event.location}\nOrganised by ${event.organizer}',
                  'Event details',
                ),
              ),
            ],
          ),
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
                          color.withValues(alpha: 0.42),
                          color.withValues(alpha: 0.08),
                        ],
                      ),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Pill(
                          label: event.category.label,
                          color: color,
                          icon: event.category.icon,
                        ),
                        const SizedBox(height: 16),
                        Text(event.title,
                            style: AppText.display(27, height: 1.2)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.people_alt_rounded,
                                size: 16, color: AppColors.muted),
                            const SizedBox(width: 6),
                            Text('$goingCount students going',
                                style: AppText.body(13.5,
                                    color: AppColors.muted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  index: 1,
                  child: GlassCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.event_rounded,
                          label: 'Date',
                          value: fmtLong(event.start),
                          sub: relDay(event.start),
                        ),
                        const _Divider(),
                        _InfoRow(
                          icon: Icons.schedule_rounded,
                          label: 'Time',
                          value: event.timeRange,
                        ),
                        const _Divider(),
                        _InfoRow(
                          icon: Icons.location_on_rounded,
                          label: 'Location',
                          value: event.location,
                        ),
                        const _Divider(),
                        _InfoRow(
                          icon: Icons.groups_rounded,
                          label: 'Organiser',
                          value: event.organizer,
                          onTap: club == null
                              ? null
                              : () => Navigator.of(context)
                                  .push(fadeSlide(ClubDetail(club: club))),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                FadeSlideIn(
                  index: 2,
                  child: Text('About', style: AppText.display(20)),
                ),
                const SizedBox(height: 10),
                FadeSlideIn(
                  index: 2,
                  child: Text(
                    event.description,
                    style: AppText.body(15.5,
                        height: 1.6,
                        color: AppColors.text.withValues(alpha: 0.9)),
                  ),
                ),
                const SizedBox(height: 28),
                FadeSlideIn(
                  index: 3,
                  child: going
                      ? GhostButton(
                          label: "You're going. Tap to cancel",
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                          onTap: () {
                            context.read<AppState>().toggleGoing(event.id);
                            toast(context, 'Removed from your agenda');
                          },
                        )
                      : GradientButton(
                          label: "I'm going",
                          icon: Icons.event_available_rounded,
                          onTap: () {
                            context.read<AppState>().toggleGoing(event.id);
                            toast(context, 'Added to your agenda');
                          },
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.sub,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final row = Row(
      children: [
        IconBadge(icon: icon, color: p.b, size: 40),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.body(12, color: AppColors.muted)),
              const SizedBox(height: 2),
              Text(value, style: AppText.body(15, w: FontWeight.w600)),
            ],
          ),
        ),
        if (sub != null)
          Text(sub!,
              style: AppText.body(13, w: FontWeight.w600, color: p.b)),
        if (onTap != null)
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      ],
    );
    if (onTap == null) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: row,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(
          height: 1,
          color: Colors.white.withValues(alpha: 0.07),
        ),
      );
}

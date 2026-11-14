import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class AnnouncementDetail extends StatefulWidget {
  const AnnouncementDetail({super.key, required this.item});
  final Announcement item;

  @override
  State<AnnouncementDetail> createState() => _AnnouncementDetailState();
}

class _AnnouncementDetailState extends State<AnnouncementDetail> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppState>().markRead(widget.item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final p = app.palette;
    final a = widget.item;
    final saved = app.savedNews.contains(a.id);
    final color = a.category.color;
    final paragraphs =
        a.body.split(RegExp(r'\n\s*\n')).where((s) => s.trim().isNotEmpty);

    return AppScaffold(
      body: Column(
        children: [
          DetailTopBar(
            actions: [
              GlassIconButton(
                icon: Icons.content_copy_rounded,
                onTap: () => copyToClipboard(
                  context,
                  '${a.title}\n\n${a.body}\n\n(${a.author}, ${fmtDay(a.date)})',
                  'Announcement',
                ),
              ),
              GlassIconButton(
                icon: saved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: saved ? p.b : null,
                onTap: () => context.read<AppState>().toggleSaved(a.id),
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
                          color.withValues(alpha: 0.38),
                          color.withValues(alpha: 0.08),
                        ],
                      ),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Pill(
                                label: a.category.label,
                                color: color,
                                icon: a.category.icon),
                            if (a.pinned) ...[
                              const SizedBox(width: 8),
                              const Pill(
                                label: 'Pinned',
                                color: AppColors.muted,
                                icon: Icons.push_pin_rounded,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(a.title,
                            style: AppText.display(26, height: 1.2)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Avatar(name: a.author, size: 34),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.author,
                                      style: AppText.body(13.5,
                                          w: FontWeight.w600)),
                                  Text(
                                    '${fmtLong(a.date)}  ·  ${fmtTime(a.date)}',
                                    style: AppText.body(12,
                                        color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                for (final para in paragraphs) ...[
                  FadeSlideIn(
                    index: 2,
                    child: Text(
                      para.trim(),
                      style: AppText.body(16,
                          height: 1.65,
                          color: AppColors.text.withValues(alpha: 0.92)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/tiles.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _search = TextEditingController();
  int _cat = 0; // 0 = All, 1..n = categories, last = Saved
  String _q = '';

  static final List<String> _labels = [
    'All',
    ...AnnCategory.values.map((c) => c.label),
    'Saved',
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Announcement> _filtered(AppState app) {
    var list = app.announcements;
    if (_cat == _labels.length - 1) {
      list = list.where((a) => app.savedNews.contains(a.id)).toList();
    } else if (_cat > 0) {
      final c = AnnCategory.values[_cat - 1];
      list = list.where((a) => a.category == c).toList();
    }
    final q = _q.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((a) =>
              a.title.toLowerCase().contains(q) ||
              a.body.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = _filtered(app);
    final savedTab = _cat == _labels.length - 1;

    return Column(
      children: [
        ScreenHeader(
          title: 'News',
          subtitle: '${app.unreadCount} unread',
          trailing: app.isPublisher
              ? GlassIconButton(
                  icon: Icons.add_rounded,
                  onTap: () => showPublishSheet(context),
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppField(
            controller: _search,
            hint: 'Search announcements',
            icon: Icons.search_rounded,
            onChanged: (v) => setState(() => _q = v),
            suffix: _q.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 20, color: AppColors.muted),
                    onPressed: () {
                      _search.clear();
                      setState(() => _q = '');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 14),
        FilterChips(
          labels: _labels,
          selected: _cat,
          onSelected: (i) => setState(() => _cat = i),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: items.isEmpty
              ? EmptyState(
                  icon: savedTab
                      ? Icons.bookmark_border_rounded
                      : Icons.inbox_rounded,
                  title: savedTab ? 'Nothing saved yet' : 'No announcements',
                  subtitle: savedTab
                      ? 'Tap the bookmark on any announcement to keep it here.'
                      : 'Try another category or search term.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => FadeSlideIn(
                    index: i,
                    child: NewsCard(item: items[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Bottom sheet for admins / club reps to publish a new announcement.
/// NOTE: in this prototype posts are stored on this device only. To share
/// them with every student you need a shared backend (see README).
Future<void> showPublishSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PublishSheet(),
  );
}

class _PublishSheet extends StatefulWidget {
  const _PublishSheet();

  @override
  State<_PublishSheet> createState() => _PublishSheetState();
}

class _PublishSheetState extends State<_PublishSheet> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  AnnCategory _category = AnnCategory.administration;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_title.text.trim().length < 4) {
      setState(() => _error = 'Give your announcement a clear title.');
      return;
    }
    if (_body.text.trim().length < 10) {
      setState(() => _error = 'Add a few lines of details.');
      return;
    }
    setState(() => _busy = true);
    await context.read<AppState>().publish(
          title: _title.text,
          body: _body.text,
          category: _category,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + inset),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('New announcement', style: AppText.display(24)),
            const SizedBox(height: 16),
            AppField(
              controller: _title,
              hint: 'Title',
              icon: Icons.title_rounded,
              action: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AppField(
              controller: _body,
              hint: 'Details',
              icon: Icons.notes_rounded,
              maxLines: 5,
              keyboard: TextInputType.multiline,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in AnnCategory.values)
                  GestureDetector(
                    onTap: () => setState(() => _category = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: _category == c
                            ? c.color.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: _category == c
                              ? c.color
                              : Colors.white.withValues(alpha: 0.09),
                        ),
                      ),
                      child: Text(
                        c.label,
                        style: AppText.body(
                          13,
                          w: FontWeight.w600,
                          color: _category == c ? c.color : AppColors.muted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: AppText.body(13.5, color: AppColors.danger)),
            ],
            const SizedBox(height: 18),
            GradientButton(
              label: 'Publish',
              icon: Icons.send_rounded,
              loading: _busy,
              onTap: _publish,
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Prototype: visible on this device only.',
                style: AppText.body(12, color: p.b.withValues(alpha: 0.9)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

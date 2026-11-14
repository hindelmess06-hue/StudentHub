import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class CampusScreen extends StatelessWidget {
  const CampusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final now = DateTime.now();
    final services = app.services;
    final openCount = services.where((s) => s.isOpenAt(now)).length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 130),
      children: [
        ScreenHeader(
          title: 'Campus',
          subtitle: '$openCount of ${services.length} services open now',
        ),
        // Emergency banners if any service has an active alert
        for (final s in services)
          if (s.emergencyBanner != null && s.emergencyBanner!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: AppColors.danger),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${s.name} Alert', style: AppText.body(14, w: FontWeight.w700, color: AppColors.danger)),
                          const SizedBox(height: 2),
                          Text(s.emergencyBanner!, style: AppText.body(13, color: AppColors.text)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            itemCount: services.length,
            itemBuilder: (_, i) => FadeSlideIn(
              index: i,
              child: _ServiceCard(service: services[i], now: now),
            ),
          ),
        ),
        const SectionHeader('Useful contacts'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (final c in SeedData.contacts) ...[
                GlassCard(
                  onTap: () =>
                      copyToClipboard(context, c.email, 'Email address'),
                  child: Row(
                    children: [
                      IconBadge(icon: c.icon, color: context.pal.b),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name,
                                style: AppText.body(15, w: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(c.role,
                                style: AppText.body(12.5,
                                    color: AppColors.muted)),
                            const SizedBox(height: 2),
                            Text(c.email,
                                style: AppText.body(12.5,
                                    color: context.pal.b)),
                          ],
                        ),
                      ),
                      const Icon(Icons.content_copy_rounded,
                          size: 18, color: AppColors.muted),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.now});
  final CampusService service;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final open = service.isOpenAt(now);
    final color = open ? AppColors.success : AppColors.muted;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      onTap: () => _showDetails(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: service.icon, color: context.pal.b, size: 42),
              const Spacer(),
              Pill(label: open ? 'Open' : 'Closed', color: color),
            ],
          ),
          const Spacer(),
          Text(service.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.display(16.5)),
          const SizedBox(height: 3),
          Text(
            service.hoursLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(11.5, color: AppColors.muted, height: 1.3),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final app = context.read<AppState>();
    final user = app.user;
    final canManage = app.isSuperAdmin || (app.isFacilityManager && user?.assignedEntity?.toLowerCase() == service.name.toLowerCase());

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final open = service.isOpenAt(now);
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconBadge(icon: service.icon, color: ctx.pal.b, size: 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(service.name, style: AppText.display(24)),
                    ),
                    Pill(
                      label: open ? 'Open now' : 'Closed now',
                      color: open ? AppColors.success : AppColors.muted,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  service.description,
                  style: AppText.body(15, height: 1.55, color: AppColors.muted),
                ),
                const SizedBox(height: 18),
                _Line(icon: Icons.schedule_rounded, text: service.hoursLabel),
                const SizedBox(height: 10),
                _Line(icon: Icons.location_on_rounded, text: service.location),
                if (canManage) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ctx.pal.b.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Facility Manager Controls', style: AppText.body(14, w: FontWeight.w700, color: ctx.pal.b)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                onPressed: () {
                                  app.updateServiceStatus(serviceName: service.name, status: 'open');
                                  Navigator.of(ctx).pop();
                                  toast(context, 'Status set to Force Open');
                                },
                                child: const Text('Open', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                                onPressed: () {
                                  app.updateServiceStatus(serviceName: service.name, status: 'maintenance');
                                  Navigator.of(ctx).pop();
                                  toast(context, 'Status set to Maintenance');
                                },
                                child: const Text('Maintenance', style: TextStyle(color: Colors.black)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                                onPressed: () {
                                  app.updateServiceStatus(serviceName: service.name, status: 'closed');
                                  Navigator.of(ctx).pop();
                                  toast(context, 'Status set to Closed');
                                },
                                child: const Text('Close', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GhostButton(
                          label: 'Trigger Emergency Banner',
                          icon: Icons.warning_amber_rounded,
                          color: AppColors.danger,
                          onTap: () {
                            Navigator.of(ctx).pop();
                            _showEmergencyDialog(context, service.name);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEmergencyDialog(BuildContext context, String serviceName) {
    final bannerController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Emergency Alert', style: AppText.display(20)),
        content: TextField(
          controller: bannerController,
          decoration: const InputDecoration(hintText: 'Enter alert message (e.g., Closed due to power outage)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              context.read<AppState>().updateServiceStatus(
                serviceName: serviceName,
                status: 'closed',
                banner: bannerController.text.trim(),
              );
              Navigator.of(ctx).pop();
              toast(context, 'Emergency banner broadcasted');
            },
            child: const Text('Broadcast', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.muted),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppText.body(14.5))),
      ],
    );
  }
}
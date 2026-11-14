import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_config.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'announcements_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Sign out?', style: AppText.display(20)),
        content: Text(
          'You will need to sign in again to see your campus feed.',
          style: AppText.body(14.5, color: AppColors.muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppText.body(14.5)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Sign out',
                style: AppText.body(14.5,
                    color: AppColors.danger, w: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final app = context.read<AppState>();
      Navigator.of(context).popUntil((r) => r.isFirst);
      await app.signOut();
    }
  }

  void _showRoleRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RoleRequestSheet(),
    );
  }

  void _showAdminDashboard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AdminDashboardSheet(),
    );
  }

  void _showAuditLogs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AuditLogsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final p = app.palette;
    final user = app.user;
    final name = (user?.name ?? '').isEmpty ? 'Student' : user!.name;

    final departments = [
      'All Departments',
      'Computer Science',
      'Civil Engineering',
      'Business & Management',
      'AI & Data Science',
      'Architecture',
    ];

    final currentDept = departments.contains(app.userDepartment)
        ? app.userDepartment
        : 'All Departments';

    return AppScaffold(
      body: Column(
        children: [
          const DetailTopBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              children: [
                FadeSlideIn(
                  child: Column(
                    children: [
                      Avatar(name: name, size: 96),
                      const SizedBox(height: 16),
                      Text(name, style: AppText.display(26)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '',
                          style: AppText.body(14, color: AppColors.muted)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          const Pill(
                            label: 'Verified UEMF account',
                            color: AppColors.success,
                            icon: Icons.verified_rounded,
                          ),
                          Pill(
                            label: user?.role == 'student'
                                ? 'Student'
                                : (user?.role ?? 'Student').toUpperCase(),
                            color: p.b,
                            icon: Icons.badge_rounded,
                          ),
                          if (user?.assignedEntity != null)
                            Pill(
                              label: user!.assignedEntity!,
                              color: AppColors.warning,
                              icon: Icons.location_city_rounded,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // ─────────────────── Department Selector ───────────────────
                FadeSlideIn(
                  index: 1,
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Academic Major / Department',
                            style: AppText.body(14, w: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                            'Filter relevant announcements and campus notifications.',
                            style:
                            AppText.body(12, color: AppColors.muted)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: currentDept,
                          dropdownColor: AppColors.surface,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.06),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none),
                          ),
                          items: departments
                              .map((d) => DropdownMenuItem(
                              value: d, child: Text(d)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) app.setUserDepartment(v);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeSlideIn(
                  index: 2,
                  child: Row(
                    children: [
                      _Count(
                          value: '${app.followedClubs.length}',
                          label: 'Clubs followed'),
                      const SizedBox(width: 10),
                      _Count(
                          value: '${app.goingEvents.length}',
                          label: 'Events going'),
                      const SizedBox(width: 10),
                      _Count(
                          value: '${app.savedNews.length}',
                          label: 'Saved news'),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                FadeSlideIn(
                  index: 3,
                  child: Text('Accent colour', style: AppText.display(18)),
                ),
                const SizedBox(height: 12),
                FadeSlideIn(
                  index: 3,
                  child: GlassCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (var i = 0; i < Palette.all.length; i++)
                          GestureDetector(
                            onTap: () =>
                                context.read<AppState>().setPalette(i),
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: Palette.all[i].gradient,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: app.paletteIndex == i
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: app.paletteIndex == i
                                      ? const Icon(Icons.check_rounded,
                                      color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  Palette.all[i].name,
                                  style: AppText.body(
                                    11.5,
                                    color: app.paletteIndex == i
                                        ? Colors.white
                                        : AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                FadeSlideIn(
                  index: 4,
                  child: Column(
                    children: [
                      if (app.isPublisher) ...[
                        GradientButton(
                          label: 'Publish an announcement',
                          icon: Icons.campaign_rounded,
                          onTap: () => showPublishSheet(context),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (app.isSuperAdmin) ...[
                        GhostButton(
                          label:
                          'Review Role Requests (${app.roleRequests.length})',
                          icon: Icons.admin_panel_settings_rounded,
                          color: AppColors.warning,
                          onTap: () => _showAdminDashboard(context),
                        ),
                        const SizedBox(height: 12),
                        GhostButton(
                          label:
                          'View System Audit Logs (${app.auditLogs.length})',
                          icon: Icons.security_rounded,
                          color: AppColors.success,
                          onTap: () => _showAuditLogs(context),
                        ),
                        const SizedBox(height: 12),
                      ],
                      GhostButton(
                        label: 'Apply for Staff / Organizer Role',
                        icon: Icons.verified_user_rounded,
                        onTap: () => _showRoleRequestSheet(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                FadeSlideIn(
                  index: 5,
                  child: GlassCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.muted, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${AppConfig.appName} ${AppConfig.version}\n'
                                '${AppConfig.useFirebase ? 'Connected to Firebase.' : 'Demo mode: data and accounts stay on this phone.'}\n'
                                'Announcements, events and contacts are sample content.',
                            style: AppText.body(12.5,
                                color: AppColors.muted, height: 1.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FadeSlideIn(
                  index: 6,
                  child: GhostButton(
                    label: 'Sign out',
                    icon: Icons.logout_rounded,
                    color: AppColors.danger,
                    onTap: () => _confirmSignOut(context),
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

class _RoleRequestSheet extends StatefulWidget {
  const _RoleRequestSheet();

  @override
  State<_RoleRequestSheet> createState() => _RoleRequestSheetState();
}

class _RoleRequestSheetState extends State<_RoleRequestSheet> {
  String _role = 'facility_manager';
  String _selectedDepartment = 'Library';
  final _justification = TextEditingController();
  bool _busy = false;

  final List<String> _departments = [
    'Library',
    'Cafeteria',
    'Registrar',
    'IT Support',
    'Health Center',
    'Sports Hall',
    'Student Affairs',
  ];

  @override
  void dispose() {
    _justification.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_justification.text.trim().length < 5) return;
    setState(() => _busy = true);
    await context.read<AppState>().submitRoleRequest(
      requestedRole: _role,
      entity: _selectedDepartment,
      justification: _justification.text.trim(),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    toast(context, 'Staff application submitted to Administration');
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Campus Staff Application', style: AppText.display(24)),
            const SizedBox(height: 6),
            Text(
              'Apply for operational worker or administrative access to manage campus facilities.',
              style: AppText.body(13, color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            Text('Select Department / Facility',
                style: AppText.body(12,
                    w: FontWeight.w600, color: AppColors.muted)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedDepartment,
              dropdownColor: AppColors.surface,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              items: _departments.map((dep) {
                return DropdownMenuItem(value: dep, child: Text(dep));
              }).toList(),
              onChanged: (v) =>
                  setState(() => _selectedDepartment = v ?? 'Library'),
            ),
            const SizedBox(height: 14),
            Text('Staff Role Type',
                style: AppText.body(12,
                    w: FontWeight.w600, color: AppColors.muted)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _role,
              dropdownColor: AppColors.surface,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'facility_manager',
                    child: Text('Facility / Department Worker')),
                DropdownMenuItem(
                    value: 'professor',
                    child: Text('Professor / Faculty Member')),
              ],
              onChanged: (v) =>
                  setState(() => _role = v ?? 'facility_manager'),
            ),
            const SizedBox(height: 14),
            AppField(
              controller: _justification,
              hint:
              'Professional Justification (e.g., Staff ID or assignment reason)',
              icon: Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 18),
            GradientButton(
              label: 'Submit Staff Application',
              icon: Icons.send_rounded,
              loading: _busy,
              onTap: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDashboardSheet extends StatelessWidget {
  const _AdminDashboardSheet();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
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
          Text('Pending Demandes', style: AppText.display(24)),
          const SizedBox(height: 16),
          Expanded(
            child: app.roleRequests.isEmpty
                ? const EmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: 'All caught up',
              subtitle: 'No pending role requests from students.',
            )
                : ListView.separated(
              itemCount: app.roleRequests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final req = app.roleRequests[i];
                return GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(req.userName,
                              style: AppText.body(16,
                                  w: FontWeight.w700)),
                          const Spacer(),
                          Pill(
                              label: req.requestedRole,
                              color: AppColors.warning),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(req.userEmail,
                          style: AppText.body(13,
                              color: AppColors.muted)),
                      const SizedBox(height: 8),
                      Text('Entity: ${req.entity}',
                          style: AppText.body(13.5,
                              w: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Reason: "${req.justification}"',
                          style: AppText.body(13,
                              color: AppColors.muted)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => context
                                .read<AppState>()
                                .rejectRequest(req.id),
                            child: Text('Reject',
                                style: AppText.body(14,
                                    color: AppColors.danger)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success),
                            onPressed: () => context
                                .read<AppState>()
                                .approveRequest(
                                req.id, req.requestedRole, req.entity),
                            child: const Text('Approve',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditLogsSheet extends StatelessWidget {
  const _AuditLogsSheet();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
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
          Text('System Audit Log', style: AppText.display(24)),
          const SizedBox(height: 6),
          Text('Accountability ledger tracking all administrative actions.',
              style: AppText.body(13, color: AppColors.muted)),
          const SizedBox(height: 16),
          Expanded(
            child: app.auditLogs.isEmpty
                ? const EmptyState(
              icon: Icons.security_rounded,
              title: 'No actions logged yet',
              subtitle:
              'Admin and facility changes will be recorded here.',
            )
                : ListView.separated(
              itemCount: app.auditLogs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final log = app.auditLogs[i];
                return GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Pill(
                              label: log.action,
                              color: AppColors.warning),
                          const Spacer(),
                          Text(timeAgo(log.timestamp),
                              style: AppText.body(11.5,
                                  color: AppColors.muted)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(log.details,
                          style: AppText.body(14,
                              w: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('User: ${log.userEmail}',
                          style: AppText.body(12,
                              color: AppColors.muted)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        radius: 20,
        child: Column(
          children: [
            Text(value, style: AppText.display(26)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: AppText.body(11.5, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
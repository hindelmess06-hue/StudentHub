import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_config.dart';
import '../data/seed_data.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

enum AuthStatus { loading, signedOut, needsVerification, signedIn }

class RoleRequest {
  RoleRequest({
    required this.id,
    required this.userEmail,
    required this.userName,
    required this.requestedRole,
    required this.entity,
    required this.justification,
    required this.date,
  });

  final String id;
  final String userEmail;
  final String userName;
  final String requestedRole;
  final String entity;
  final String justification;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userEmail': userEmail,
    'userName': userName,
    'requestedRole': requestedRole,
    'entity': entity,
    'justification': justification,
    'date': date.toIso8601String(),
  };

  factory RoleRequest.fromJson(Map<String, dynamic> j) => RoleRequest(
    id: j['id'] as String,
    userEmail: j['userEmail'] as String,
    userName: j['userName'] as String,
    requestedRole: j['requestedRole'] as String,
    entity: j['entity'] as String,
    justification: j['justification'] as String,
    date: DateTime.parse(j['date'] as String),
  );
}

class AppState extends ChangeNotifier {
  AppState(this.prefs, this.auth);

  final SharedPreferences prefs;
  final AuthService auth;

  static const _kPalette = 'palette';
  static const _kFollowed = 'followed_clubs';
  static const _kGoing = 'going_events';
  static const _kSaved = 'saved_news';
  static const _kRead = 'read_news';
  static const _kCustom = 'custom_news';
  static const _kRoleRequests = 'role_requests';
  static const _kServiceOverrides = 'service_overrides';
  static const _kAuditLogs = 'audit_logs';
  static const _kDepartment = 'user_department';

  AuthStatus status = AuthStatus.loading;
  AuthUser? user;

  int paletteIndex = 0;
  Palette get palette => Palette.all[paletteIndex];

  Set<String> followedClubs = {};
  Set<String> goingEvents = {};
  Set<String> savedNews = {};
  Set<String> readNews = {};
  List<Announcement> customNews = [];
  List<RoleRequest> roleRequests = [];
  Map<String, Map<String, String>> serviceOverrides = {};
  List<AuditLogEntry> auditLogs = [];
  String userDepartment = 'All Departments';

  // ─────────────────── Role Getters ───────────────────
  bool get isSuperAdmin =>
      (user != null && AppConfig.publisherEmails.contains(user!.email)) ||
          user?.role == 'super_admin';

  bool get isFacilityManager => user?.role == 'facility_manager';
  bool get isProfessor => user?.role == 'professor';
  bool get isClubLeader => user?.role == 'club_leader';
  bool get isPublisher => isSuperAdmin || isFacilityManager || isProfessor || isClubLeader;

  // ─────────────────────── Boot ───────────────────────

  Future<void> init() async {
    final idx = prefs.getInt(_kPalette) ?? 0;
    paletteIndex = (idx >= 0 && idx < Palette.all.length) ? idx : 0;
    followedClubs = (prefs.getStringList(_kFollowed) ?? []).toSet();
    goingEvents = (prefs.getStringList(_kGoing) ?? []).toSet();
    savedNews = (prefs.getStringList(_kSaved) ?? []).toSet();
    readNews = (prefs.getStringList(_kRead) ?? []).toSet();
    userDepartment = prefs.getString(_kDepartment) ?? 'All Departments';

    final raw = prefs.getString(_kCustom);
    if (raw != null) {
      try {
        customNews = (jsonDecode(raw) as List)
            .map((e) => Announcement.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        customNews = [];
      }
    }

    final reqRaw = prefs.getString(_kRoleRequests);
    if (reqRaw != null) {
      try {
        roleRequests = (jsonDecode(reqRaw) as List)
            .map((e) => RoleRequest.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        roleRequests = [];
      }
    }

    final overrideRaw = prefs.getString(_kServiceOverrides);
    if (overrideRaw != null) {
      try {
        final decoded = jsonDecode(overrideRaw) as Map<String, dynamic>;
        serviceOverrides = decoded.map((k, v) => MapEntry(k, Map<String, String>.from(v as Map)));
      } catch (_) {
        serviceOverrides = {};
      }
    }

    final logRaw = prefs.getString(_kAuditLogs);
    if (logRaw != null) {
      try {
        auditLogs = (jsonDecode(logRaw) as List)
            .map((e) => AuditLogEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        auditLogs = [];
      }
    }

    try {
      user = await auth.currentUser();
    } catch (_) {
      user = null;
    }
    status = _statusFor(user);
    notifyListeners();
  }

  AuthStatus _statusFor(AuthUser? u) {
    if (u == null) return AuthStatus.signedOut;
    return u.verified ? AuthStatus.signedIn : AuthStatus.needsVerification;
  }

  // ─────────────────────── Auth ───────────────────────

  Future<void> signUp(String name, String email, String password) async {
    user = await auth.signUp(name: name, email: email, password: password);
    status = _statusFor(user);
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    user = await auth.signIn(email: email, password: password);
    status = _statusFor(user);
    notifyListeners();
  }

  Future<void> resendVerification() async {
    await auth.sendVerification();
    notifyListeners();
  }

  Future<bool> refreshVerification() async {
    try {
      final ok = await auth.checkVerified();
      if (ok) {
        user = await auth.currentUser();
        status = _statusFor(user);
        notifyListeners();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<bool> submitCode(String code) async {
    final ok = await auth.submitCode(code);
    if (ok) {
      user = await auth.currentUser();
      status = _statusFor(user);
      notifyListeners();
    }
    return ok;
  }

  Future<void> resetPassword(String email) => auth.sendPasswordReset(email);

  Future<void> discardUnverified() async {
    await auth.discardUnverified();
    user = null;
    status = AuthStatus.signedOut;
    notifyListeners();
  }

  Future<void> signOut() async {
    await auth.signOut();
    user = null;
    status = AuthStatus.signedOut;
    notifyListeners();
  }

  // ─────────────────────── Department Setting ───────────────────────

  Future<void> setUserDepartment(String dept) async {
    userDepartment = dept;
    await prefs.setString(_kDepartment, dept);
    notifyListeners();
  }

  // ─────────────────────── Audit Logging ───────────────────────

  Future<void> _logAction(String action, String details) async {
    final entry = AuditLogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      userEmail: user?.email ?? 'anonymous@ueuromed.org',
      action: action,
      details: details,
      timestamp: DateTime.now(),
    );
    auditLogs = [entry, ...auditLogs];
    await prefs.setString(
      _kAuditLogs,
      jsonEncode(auditLogs.map((e) => e.toJson()).toList()),
    );
  }

  // ─────────────────────── Role Demandes & Admin ───────────────────────

  Future<void> submitRoleRequest({
    required String requestedRole,
    required String entity,
    required String justification,
  }) async {
    final req = RoleRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      userEmail: user?.email ?? '',
      userName: user?.name ?? 'Student',
      requestedRole: requestedRole,
      entity: entity,
      justification: justification,
      date: DateTime.now(),
    );
    roleRequests = [req, ...roleRequests];
    await prefs.setString(
      _kRoleRequests,
      jsonEncode(roleRequests.map((e) => e.toJson()).toList()),
    );
    await _logAction('Role Request', 'Requested role: $requestedRole for $entity');
    notifyListeners();
  }

  Future<void> approveRequest(String requestId, String role, String entity) async {
    roleRequests.removeWhere((r) => r.id == requestId);
    await prefs.setString(
      _kRoleRequests,
      jsonEncode(roleRequests.map((e) => e.toJson()).toList()),
    );
    if (user != null) {
      user = AuthUser(
        uid: user!.uid,
        email: user!.email,
        name: user!.name,
        verified: user!.verified,
        role: role,
        assignedEntity: entity,
      );
    }
    await _logAction('Approve Request', 'Approved $role scope: $entity');
    notifyListeners();
  }

  Future<void> rejectRequest(String requestId) async {
    roleRequests.removeWhere((r) => r.id == requestId);
    await prefs.setString(
      _kRoleRequests,
      jsonEncode(roleRequests.map((e) => e.toJson()).toList()),
    );
    await _logAction('Reject Request', 'Rejected request ID: $requestId');
    notifyListeners();
  }

  // ─────────────────────── Campus Service Overrides ───────────────────────

  List<CampusService> get services {
    return SeedData.services.map((s) {
      final override = serviceOverrides[s.name];
      if (override == null) return s;
      return CampusService(
        name: s.name,
        description: s.description,
        icon: s.icon,
        location: s.location,
        openMinute: s.openMinute,
        closeMinute: s.closeMinute,
        days: s.days,
        contact: s.contact,
        overrideStatus: override['status'],
        emergencyBanner: override['banner'],
      );
    }).toList();
  }

  Future<void> updateServiceStatus({
    required String serviceName,
    required String status,
    String? banner,
  }) async {
    serviceOverrides[serviceName] = {
      'status': status,
      'banner': banner ?? '',
    };
    await prefs.setString(_kServiceOverrides, jsonEncode(serviceOverrides));
    await _logAction('Facility Override', 'Updated $serviceName status to "$status" ${banner != null && banner.isNotEmpty ? "with banner: $banner" : ""}');
    notifyListeners();
  }

  // ─────────────────────── Content with Department Filtering ───────────────────────

  List<Announcement> get announcements {
    var all = [...customNews, ...SeedData.announcements];
    if (userDepartment != 'All Departments') {
      all = all.where((a) => a.targetDepartment == null || a.targetDepartment == userDepartment || a.category == AnnCategory.urgent).toList();
    }
    all.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.date.compareTo(a.date);
    });
    return all;
  }

  List<Announcement> get latestNews {
    var all = [...customNews, ...SeedData.announcements];
    if (userDepartment != 'All Departments') {
      all = all.where((a) => a.targetDepartment == null || a.targetDepartment == userDepartment || a.category == AnnCategory.urgent).toList();
    }
    all.sort((a, b) => b.date.compareTo(a.date));
    return all;
  }

  int get unreadCount =>
      announcements.where((a) => !readNews.contains(a.id)).length;

  List<CampusEvent> get events {
    final all = [...SeedData.events];
    all.sort((a, b) => a.start.compareTo(b.start));
    return all;
  }

  List<CampusEvent> get upcomingEvents {
    final now = DateTime.now();
    return events.where((e) => e.end.isAfter(now)).toList();
  }

  List<CampusEvent> eventsForClub(String clubId) =>
      upcomingEvents.where((e) => e.clubId == clubId).toList();

  List<Club> get clubs => SeedData.clubs;

  Club? clubById(String? id) {
    if (id == null) return null;
    for (final c in SeedData.clubs) {
      if (c.id == id) return c;
    }
    return null;
  }

  // ─────────────────────── Preferences ───────────────────────

  void setPalette(int i) {
    paletteIndex = i;
    prefs.setInt(_kPalette, i);
    notifyListeners();
  }

  void toggleFollow(String clubId) {
    if (!followedClubs.remove(clubId)) followedClubs.add(clubId);
    prefs.setStringList(_kFollowed, followedClubs.toList());
    notifyListeners();
  }

  void toggleGoing(String eventId) {
    if (!goingEvents.remove(eventId)) goingEvents.add(eventId);
    prefs.setStringList(_kGoing, goingEvents.toList());
    notifyListeners();
  }

  void toggleSaved(String newsId) {
    if (!savedNews.remove(newsId)) savedNews.add(newsId);
    prefs.setStringList(_kSaved, savedNews.toList());
    notifyListeners();
  }

  void markRead(String newsId) {
    if (readNews.add(newsId)) {
      prefs.setStringList(_kRead, readNews.toList());
      notifyListeners();
    }
  }

  Future<void> publish({
    required String title,
    required String body,
    required AnnCategory category,
    String? targetDepartment,
  }) async {
    final name = user?.name ?? '';
    final a = Announcement(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      body: body.trim(),
      author: name.isNotEmpty ? name : 'Administration',
      category: category,
      date: DateTime.now(),
      custom: true,
      targetDepartment: targetDepartment,
    );
    customNews = [a, ...customNews];
    await prefs.setString(
      _kCustom,
      jsonEncode(customNews.map((e) => e.toJson()).toList()),
    );
    await _logAction('Publish Announcement', 'Published "${title.trim()}"');
    notifyListeners();
  }
}
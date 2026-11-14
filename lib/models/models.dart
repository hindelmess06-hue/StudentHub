import 'package:flutter/material.dart';

enum AnnCategory { academic, administration, careers, campusLife, urgent }

extension AnnCategoryX on AnnCategory {
  String get label => switch (this) {
    AnnCategory.academic => 'Academic',
    AnnCategory.administration => 'Administration',
    AnnCategory.careers => 'Careers',
    AnnCategory.campusLife => 'Campus life',
    AnnCategory.urgent => 'Urgent',
  };

  IconData get icon => switch (this) {
    AnnCategory.academic => Icons.school_rounded,
    AnnCategory.administration => Icons.account_balance_rounded,
    AnnCategory.careers => Icons.work_rounded,
    AnnCategory.campusLife => Icons.celebration_rounded,
    AnnCategory.urgent => Icons.priority_high_rounded,
  };

  Color get color => switch (this) {
    AnnCategory.academic => const Color(0xFF8B7BFF),
    AnnCategory.administration => const Color(0xFF38BDF8),
    AnnCategory.careers => const Color(0xFF34D399),
    AnnCategory.campusLife => const Color(0xFFFF7AB6),
    AnnCategory.urgent => const Color(0xFFFF5C7A),
  };
}

class AuditLogEntry {
  AuditLogEntry({
    required id,
    required this.userEmail,
    required this.action,
    required this.details,
    required this.timestamp,
  }) : id = id ?? 'log_${DateTime.now().millisecondsSinceEpoch}';

  final String id;
  final String userEmail;
  final String action;
  final String details;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userEmail': userEmail,
    'action': action,
    'details': details,
    'timestamp': timestamp.toIso8601String(),
  };

  factory AuditLogEntry.fromJson(Map<String, dynamic> j) => AuditLogEntry(
    id: j['id'] as String?,
    userEmail: (j['userEmail'] as String?) ?? 'System',
    action: (j['action'] as String?) ?? 'Action',
    details: (j['details'] as String?) ?? '',
    timestamp: j['timestamp'] != null ? DateTime.parse(j['timestamp'] as String) : DateTime.now(),
  );
}

class Announcement {
  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    required this.category,
    required this.date,
    this.pinned = false,
    this.custom = false,
    this.targetDepartment,
  });

  final String id;
  final String title;
  final String body;
  final String author;
  final AnnCategory category;
  final DateTime date;
  final bool pinned;
  final bool custom;
  final String? targetDepartment; // e.g. 'Computer Science', 'Engineering', 'Business'

  String get excerpt {
    final flat = body.replaceAll('\n', ' ').trim();
    return flat.length <= 110 ? flat : '${flat.substring(0, 107)}...';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'author': author,
    'category': category.name,
    'date': date.toIso8601String(),
    'pinned': pinned,
    'targetDepartment': targetDepartment,
  };

  factory Announcement.fromJson(Map<String, dynamic> j) => Announcement(
    id: j['id'] as String,
    title: j['title'] as String,
    body: j['body'] as String,
    author: j['author'] as String,
    category: AnnCategory.values.firstWhere(
          (c) => c.name == j['category'],
      orElse: () => AnnCategory.campusLife,
    ),
    date: DateTime.parse(j['date'] as String),
    pinned: (j['pinned'] as bool?) ?? false,
    custom: true,
    targetDepartment: j['targetDepartment'] as String?,
  );
}

enum EventCategory { academic, cultural, sport, workshop, career }

extension EventCategoryX on EventCategory {
  String get label => switch (this) {
    EventCategory.academic => 'Academic',
    EventCategory.cultural => 'Cultural',
    EventCategory.sport => 'Sport',
    EventCategory.workshop => 'Workshop',
    EventCategory.career => 'Career',
  };

  IconData get icon => switch (this) {
    EventCategory.academic => Icons.school_rounded,
    EventCategory.cultural => Icons.theater_comedy_rounded,
    EventCategory.sport => Icons.sports_soccer_rounded,
    EventCategory.workshop => Icons.build_rounded,
    EventCategory.career => Icons.work_rounded,
  };

  Color get color => switch (this) {
    EventCategory.academic => const Color(0xFF8B7BFF),
    EventCategory.cultural => const Color(0xFFFF7AB6),
    EventCategory.sport => const Color(0xFFFFB84D),
    EventCategory.workshop => const Color(0xFF22D3EE),
    EventCategory.career => const Color(0xFF34D399),
  };
}

class CampusEvent {
  CampusEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.organizer,
    required this.category,
    required this.start,
    required this.end,
    this.clubId,
    this.baseGoing = 0,
  });

  final String id;
  final String title;
  final String description;
  final String location;
  final String organizer;
  final EventCategory category;
  final DateTime start;
  final DateTime end;
  final String? clubId;
  final int baseGoing;

  String get timeRange => '${_t(start)} -${_t(end)}';

  static String _t(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

enum ClubCategory { tech, arts, sport, social, science }

extension ClubCategoryX on ClubCategory {
  String get label => switch (this) {
    ClubCategory.tech => 'Tech',
    ClubCategory.arts => 'Arts',
    ClubCategory.sport => 'Sport',
    ClubCategory.social => 'Social',
    ClubCategory.science => 'Science',
  };
}

class ClubUpdate {
  ClubUpdate({required this.text, required this.date});
  final String text;
  final DateTime date;
}

class Club {
  Club({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.category,
    required this.members,
    required this.color,
    required this.icon,
    required this.president,
    required this.email,
    required this.updates,
  });

  final String id;
  final String name;
  final String tagline;
  final String description;
  final ClubCategory category;
  final int members;
  final Color color;
  final IconData icon;
  final String president;
  final String email;
  final List<ClubUpdate> updates;
}

class CampusService {
  CampusService({
    required this.name,
    required this.description,
    required this.icon,
    required this.location,
    required this.openMinute,
    required this.closeMinute,
    required this.days,
    this.contact,
    this.overrideStatus,
    this.emergencyBanner,
  });

  final String name;
  final String description;
  final IconData icon;
  final String location;
  final int openMinute;
  final int closeMinute;
  final Set<int> days;
  final String? contact;
  final String? overrideStatus;
  final String? emergencyBanner;

  bool isOpenAt(DateTime t) {
    if (overrideStatus == 'closed' || overrideStatus == 'maintenance') return false;
    if (overrideStatus == 'open') return true;
    if (!days.contains(t.weekday)) return false;
    final m = t.hour * 60 + t.minute;
    return m >= openMinute && m < closeMinute;
  }

  String get hoursLabel {
    if (overrideStatus == 'closed') return 'Closed (Manual Override)';
    if (overrideStatus == 'maintenance') return 'Closed for Maintenance';
    String f(int m) =>
        '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
    final allDay = openMinute == 0 && closeMinute >= 1440;
    final range = allDay ? '24h' : '${f(openMinute)} -${f(closeMinute)}';
    final names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = days.toList()..sort();
    if (sorted.length == 7) return 'Every day, $range';
    return '${sorted.map((d) => names[d - 1]).join(', ')},$range';
  }
}

class CampusContact {
  CampusContact({
    required this.name,
    required this.role,
    required this.email,
    required this.icon,
  });

  final String name;
  final String role;
  final String email;
  final IconData icon;
}
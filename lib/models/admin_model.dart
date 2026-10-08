class SystemMetricsModel {
  final int totalUsers;
  final int activeUsersOnline;
  final int totalGroups;
  final int totalMessagesSent;
  final double serverUptimePercent;
  final int averageLatencyMs;
  final int reportedIssues;
  final int spamBlockedCount;
  final DateTime lastUpdated;

  SystemMetricsModel({
    this.totalUsers = 12480,
    this.activeUsersOnline = 3412,
    this.totalGroups = 890,
    this.totalMessagesSent = 458920,
    this.serverUptimePercent = 99.98,
    this.averageLatencyMs = 24,
    this.reportedIssues = 3,
    this.spamBlockedCount = 142,
    required this.lastUpdated,
  });
}

class ModerationReportModel {
  final String reportId;
  final String reportedUserId;
  final String reportedUserName;
  final String reporterName;
  final String reason;
  final String status; // 'Pending', 'Resolved', 'Banned'
  final DateTime timestamp;

  ModerationReportModel({
    required this.reportId,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reporterName,
    required this.reason,
    this.status = 'Pending',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'reportedUserId': reportedUserId,
      'reportedUserName': reportedUserName,
      'reporterName': reporterName,
      'reason': reason,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ModerationReportModel.fromMap(Map<String, dynamic> map) {
    return ModerationReportModel(
      reportId: map['reportId'] as String? ?? '',
      reportedUserId: map['reportedUserId'] as String? ?? '',
      reportedUserName: map['reportedUserName'] as String? ?? 'User',
      reporterName: map['reporterName'] as String? ?? 'Anonymous',
      reason: map['reason'] as String? ?? 'Inappropriate content',
      status: map['status'] as String? ?? 'Pending',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

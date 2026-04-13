// Model for Postgres function: get_user_devices(p_user_id uuid)
// Returns: id (uuid), platform (text), is_active (boolean), last_active (timestamptz)

class UserDevice {
  final String id;
  final String platform;
  final bool isActive;
  final DateTime lastActive;

  UserDevice({
    required this.id,
    required this.platform,
    required this.isActive,
    required this.lastActive,
  });

  factory UserDevice.fromJson(Map<String, dynamic> json) {
    // Accept both snake_case and camelCase keys
    final idVal = json['id'] ?? json['Id'];
    final platformVal = json['platform'] ?? json['Platform'];
    final isActiveVal = json['is_active'] ?? json['isActive'] ?? false;
    final lastActiveVal = json['last_active'] ?? json['lastActive'];

    DateTime parsedLastActive;
    if (lastActiveVal == null) {
      parsedLastActive = DateTime.fromMillisecondsSinceEpoch(0).toUtc();
    } else if (lastActiveVal is DateTime) {
      parsedLastActive = lastActiveVal.toUtc();
    } else {
      parsedLastActive = DateTime.parse(lastActiveVal.toString()).toUtc();
    }

    return UserDevice(
      id: idVal?.toString() ?? '',
      platform: platformVal?.toString() ?? '',
      isActive: (isActiveVal is bool)
          ? isActiveVal
          : (isActiveVal.toString().toLowerCase() == 'true'),
      lastActive: parsedLastActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'platform': platform,
    'is_active': isActive,
    'last_active': lastActive.toUtc().toIso8601String(),
  };

  UserDevice copyWith({
    String? id,
    String? platform,
    bool? isActive,
    DateTime? lastActive,
  }) {
    return UserDevice(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      isActive: isActive ?? this.isActive,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  String toString() {
    return 'UserDevices(id: $id, platform: $platform, isActive: $isActive, lastActive: $lastActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserDevice &&
        other.id == id &&
        other.platform == platform &&
        other.isActive == isActive &&
        other.lastActive == lastActive;
  }

  @override
  int get hashCode =>
      id.hashCode ^ platform.hashCode ^ isActive.hashCode ^ lastActive.hashCode;
}

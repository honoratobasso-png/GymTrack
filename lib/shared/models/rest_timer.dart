class RestTimer {
  final int durationSeconds;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const RestTimer({
    this.durationSeconds = 60,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  Map<String, dynamic> toJson() => {
    'durationSeconds': durationSeconds,
    'soundEnabled': soundEnabled,
    'vibrationEnabled': vibrationEnabled,
  };

  factory RestTimer.fromJson(Map<String, dynamic> json) => RestTimer(
    durationSeconds: json['durationSeconds'] as int? ?? 60,
    soundEnabled: json['soundEnabled'] as bool? ?? true,
    vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
  );
}

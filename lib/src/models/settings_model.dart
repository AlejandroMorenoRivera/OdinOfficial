class AppSettings {
  bool sortMode;
  AppSettings({required this.sortMode});

  AppSettings.fromJson(Map<String, Object?> json)
      : this(sortMode: json['sortMode'] as bool);

  AppSettings copyWith({bool? sortMode}) {
    return AppSettings(
      sortMode: sortMode ?? this.sortMode,
    );
  }

  // toJson
  Map<String, Object?> toJson() {
    return {
      'sortMode': sortMode,
    };
  }
}

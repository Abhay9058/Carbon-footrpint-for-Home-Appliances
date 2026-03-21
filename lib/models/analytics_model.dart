class AnalyticsModel {
  final List<DailyEmission> dailyEmissions;
  final double weeklyTotal;
  final List<WeeklyEmission> monthlyEmissions;
  final List<ApplianceEmission> emissionsByAppliance;
  final List<ApplianceEmission> topAppliances;
  final double todayEmission;
  final double dailyAverage;

  AnalyticsModel({
    required this.dailyEmissions,
    required this.weeklyTotal,
    required this.monthlyEmissions,
    required this.emissionsByAppliance,
    required this.topAppliances,
    required this.todayEmission,
    required this.dailyAverage,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      dailyEmissions: (json['daily_emissions'] as List<dynamic>?)
          ?.map((e) => DailyEmission.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      weeklyTotal: (json['weekly_total'] as num?)?.toDouble() ?? 0.0,
      monthlyEmissions: (json['monthly_emissions'] as List<dynamic>?)
          ?.map((e) => WeeklyEmission.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      emissionsByAppliance: (json['emissions_by_appliance'] as List<dynamic>?)
          ?.map((e) => ApplianceEmission.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      topAppliances: (json['top_appliances'] as List<dynamic>?)
          ?.map((e) => ApplianceEmission.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      todayEmission: (json['today_emission'] as num?)?.toDouble() ?? 0.0,
      dailyAverage: (json['daily_average'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_emissions': dailyEmissions.map((e) => e.toJson()).toList(),
      'weekly_total': weeklyTotal,
      'monthly_emissions': monthlyEmissions.map((e) => e.toJson()).toList(),
      'emissions_by_appliance': emissionsByAppliance.map((e) => e.toJson()).toList(),
      'top_appliances': topAppliances.map((e) => e.toJson()).toList(),
      'today_emission': todayEmission,
      'daily_average': dailyAverage,
    };
  }
}

class DailyEmission {
  final String date;
  final double emission;

  DailyEmission({required this.date, required this.emission});

  factory DailyEmission.fromJson(Map<String, dynamic> json) {
    return DailyEmission(
      date: json['date'] as String,
      emission: (json['emission'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'date': date, 'emission': emission};
}

class WeeklyEmission {
  final String week;
  final double emission;

  WeeklyEmission({required this.week, required this.emission});

  factory WeeklyEmission.fromJson(Map<String, dynamic> json) {
    return WeeklyEmission(
      week: json['week'] as String,
      emission: (json['emission'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'week': week, 'emission': emission};
}

class ApplianceEmission {
  final String name;
  final String type;
  final double emission;

  ApplianceEmission({required this.name, required this.type, required this.emission});

  factory ApplianceEmission.fromJson(Map<String, dynamic> json) {
    return ApplianceEmission(
      name: json['name'] as String,
      type: json['type'] as String? ?? '',
      emission: (json['emission'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'type': type, 'emission': emission};
}

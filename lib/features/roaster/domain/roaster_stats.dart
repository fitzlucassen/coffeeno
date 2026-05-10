/// A single bucket in the roaster dashboard timeseries chart.
class TimeseriesPoint {
  const TimeseriesPoint({
    required this.date,
    required this.tastingsCount,
    required this.avgRating,
  });

  /// The bucket's start date. For daily granularity this is the day itself;
  /// for weekly/monthly granularity it's the first day of the week/month.
  final DateTime date;

  /// How many tastings fell in this bucket.
  final int tastingsCount;

  /// Average `overallRating` of the tastings in this bucket, or 0 when empty.
  final double avgRating;
}

enum StatsPeriod {
  last30Days,
  last3Months,
  last12Months;

  int get durationInDays => switch (this) {
        StatsPeriod.last30Days => 30,
        StatsPeriod.last3Months => 90,
        StatsPeriod.last12Months => 365,
      };
}

/// Aggregated statistics for a roaster's coffees.
class TopCoffeeEntry {
  const TopCoffeeEntry({
    required this.name,
    required this.avgRating,
    required this.tastingsCount,
  });

  final String name;
  final double avgRating;
  final int tastingsCount;
}

class RoasterStats {
  const RoasterStats({
    required this.totalCoffees,
    required this.totalTastings,
    required this.avgRating,
    required this.ratingsCount,
    required this.topCoffees,
    required this.recentTastings,
  });

  final int totalCoffees;
  final int totalTastings;
  final double avgRating;
  final int ratingsCount;
  final List<TopCoffeeEntry> topCoffees;
  final int recentTastings;

  static const empty = RoasterStats(
    totalCoffees: 0,
    totalTastings: 0,
    avgRating: 0,
    ratingsCount: 0,
    topCoffees: [],
    recentTastings: 0,
  );
}

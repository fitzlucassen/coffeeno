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

import 'package:flutter/painting.dart' show Color;

/// SCA Coffee Taster's Flavor Wheel — reference taxonomy.
///
/// This is domain/reference data (categories → sub-categories → flavors, each
/// category with its wheel color), extracted from the flavor selector widget so
/// the UI files hold only presentation logic. The flavor strings themselves are
/// the SCA's canonical English lexicon and are intentionally not localized
/// (they're stored verbatim on tastings).
class FlavorCategory {
  const FlavorCategory(this.name, this.color, this.subCategories);
  final String name;
  final Color color;
  final List<FlavorSubCategory> subCategories;

  List<String> get allFlavors =>
      subCategories.expand((s) => s.flavors).toList();
}

class FlavorSubCategory {
  const FlavorSubCategory(this.name, this.flavors);
  final String name;
  final List<String> flavors;
}

/// The nine top-level flavor families and their nested flavors.
const List<FlavorCategory> kFlavorCategories = [
  // 1. Fruity (reds/pinks)
  FlavorCategory('Fruity', Color(0xFFE53935), [
    FlavorSubCategory('Berry', [
      'Blackberry',
      'Raspberry',
      'Blueberry',
      'Strawberry',
    ]),
    FlavorSubCategory('Dried Fruit', ['Raisin', 'Prune', 'Coconut']),
    FlavorSubCategory('Other Fruit', [
      'Pomegranate',
      'Pineapple',
      'Grape',
      'Apple',
      'Peach',
      'Pear',
    ]),
    FlavorSubCategory('Citrus Fruit', [
      'Grapefruit',
      'Orange',
      'Lemon',
      'Lime',
    ]),
  ]),

  // 2. Sour/Fermented (olive/yellow-green)
  FlavorCategory('Sour/Fermented', Color(0xFF9E9D24), [
    FlavorSubCategory('Sour', [
      'Sour Aromatics',
      'Acetic Acid',
      'Butyric Acid',
      'Citric Acid',
      'Malic Acid',
    ]),
    FlavorSubCategory('Alcohol/Fermented', [
      'Winey',
      'Whiskey',
      'Fermented',
      'Overripe',
    ]),
  ]),

  // 3. Green/Vegetative (greens)
  FlavorCategory('Green/Vegetative', Color(0xFF2E7D32), [
    FlavorSubCategory('Olive Oil', ['Olive Oil']),
    FlavorSubCategory('Raw', [
      'Under-ripe',
      'Peapod',
      'Fresh',
      'Dark Green',
      'Vegetative',
      'Hay-like',
    ]),
    FlavorSubCategory('Beany', ['Beany']),
  ]),

  // 4. Other (grays/blues)
  FlavorCategory('Other', Color(0xFF78909C), [
    FlavorSubCategory('Papery/Musty', [
      'Stale',
      'Cardboard',
      'Papery',
      'Woody',
      'Moldy/Damp',
      'Musty/Dusty',
      'Musty/Earthy',
      'Animalic',
      'Meaty/Brothy',
      'Phenolic',
    ]),
    FlavorSubCategory('Chemical', [
      'Bitter',
      'Salty',
      'Medicinal',
      'Petroleum',
      'Skunky',
      'Rubber',
    ]),
  ]),

  // 5. Roasted (browns)
  FlavorCategory('Roasted', Color(0xFF4E342E), [
    FlavorSubCategory('Pipe Tobacco', ['Pipe Tobacco', 'Tobacco']),
    FlavorSubCategory('Burnt', ['Acrid', 'Ashy', 'Smoky', 'Brown Roast']),
    FlavorSubCategory('Cereal', ['Grain', 'Malt']),
  ]),

  // 6. Spices (dark reds/browns)
  FlavorCategory('Spices', Color(0xFFBF360C), [
    FlavorSubCategory('Pungent', ['Pepper', 'Anise']),
    FlavorSubCategory('Brown Spice', ['Cinnamon', 'Nutmeg', 'Clove']),
  ]),

  // 7. Nutty/Cocoa (warm browns)
  FlavorCategory('Nutty/Cocoa', Color(0xFF795548), [
    FlavorSubCategory('Nutty', ['Peanuts', 'Hazelnut', 'Almond']),
    FlavorSubCategory('Cocoa', ['Chocolate', 'Dark Chocolate', 'Cocoa']),
  ]),

  // 8. Sweet (oranges/yellows)
  FlavorCategory('Sweet', Color(0xFFFF8F00), [
    FlavorSubCategory('Brown Sugar', [
      'Molasses',
      'Maple Syrup',
      'Caramelized',
      'Honey',
    ]),
    FlavorSubCategory('Vanilla', ['Vanilla', 'Vanillin']),
    FlavorSubCategory('Overall Sweet', ['Overall Sweet', 'Sweet Aromatics']),
  ]),

  // 9. Floral (purples/pinks)
  FlavorCategory('Floral', Color(0xFFAD1457), [
    FlavorSubCategory('Black Tea', ['Black Tea']),
    FlavorSubCategory('Floral', ['Chamomile', 'Rose', 'Jasmine']),
  ]),
];

/// Returns the wheel color of the category that contains [flavor], or null when
/// it belongs to none (e.g. a user-entered custom flavor).
Color? flavorCategoryColor(String flavor) {
  for (final cat in kFlavorCategories) {
    if (cat.allFlavors.contains(flavor)) return cat.color;
  }
  return null;
}

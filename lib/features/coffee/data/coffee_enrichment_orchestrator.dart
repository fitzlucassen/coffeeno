import 'package:flutter/foundation.dart';

import '../../farm/data/farm_repository.dart';
import '../../farm/domain/farm.dart';
import '../../roaster/data/roaster_repository.dart';
import '../../roaster/domain/roaster.dart';
import '../domain/coffee.dart';
import 'coffee_enrichment_service.dart';
import 'coffee_repository.dart';

/// Resolves and back-fills the roaster/farm entities linked to a freshly added
/// coffee, calling the AI enrichment service only when needed.
///
/// This orchestration used to live inside AddCoffeeScreen (`_resolveEntities`);
/// moving it behind a service keeps the presentation layer free of multi-repo
/// coordination and makes the flow independently testable.
class CoffeeEnrichmentOrchestrator {
  CoffeeEnrichmentOrchestrator({
    required this.enrichmentService,
    required this.coffeeRepository,
    required this.roasterRepository,
    required this.farmRepository,
  });

  final CoffeeEnrichmentService enrichmentService;
  final CoffeeRepository coffeeRepository;
  final RoasterRepository roasterRepository;
  final FarmRepository farmRepository;

  /// Fire-and-forget wrapper: runs [resolveEntities] and swallows/logs errors
  /// so a background enrichment can never surface as an unhandled exception.
  void resolveInBackground(String coffeeId, Coffee coffee) {
    resolveEntities(coffeeId, coffee).catchError((Object e) {
      debugPrint('[COFFEENO] Enrichment failed for $coffeeId: $e');
    });
  }

  /// Links the coffee to existing roaster/farm docs when they exist, otherwise
  /// asks the AI service for details and creates them, then writes the entity
  /// references back onto the coffee via a targeted partial update.
  Future<void> resolveEntities(String coffeeId, Coffee coffee) async {
    final now = DateTime.now();
    String? roasterId;
    String? farmId;
    String? roasterUrl;
    String? roasterDescription;
    String? farmUrl;
    String? farmDescription;

    // Reuse an existing roaster when one already matches by name.
    final existingRoaster = await roasterRepository.findByName(coffee.roaster);
    if (existingRoaster != null) {
      roasterId = existingRoaster.id;
      roasterUrl = existingRoaster.url;
      roasterDescription = existingRoaster.description;
    }

    // Reuse an existing farm when one matches by name + country.
    Farm? existingFarm;
    if (coffee.farmName != null && coffee.farmName!.isNotEmpty) {
      existingFarm = await farmRepository.findByName(
        coffee.farmName!,
        country: coffee.originCountry,
      );
      if (existingFarm != null) {
        farmId = existingFarm.id;
        farmUrl = existingFarm.url;
        farmDescription = existingFarm.description;
      }
    }

    final needsRoasterInfo = existingRoaster == null;
    final needsFarmInfo =
        coffee.farmName != null &&
        coffee.farmName!.isNotEmpty &&
        existingFarm == null;

    if ((needsRoasterInfo || needsFarmInfo) && enrichmentService.isAvailable) {
      final result = await enrichmentService.lookupInfo(
        roaster: coffee.roaster,
        farmName: coffee.farmName,
        originCountry: coffee.originCountry,
        originRegion: coffee.originRegion,
      );

      if (needsRoasterInfo) {
        roasterUrl = result.roasterUrl;
        roasterDescription = result.roasterDescription;
        roasterId = await roasterRepository.addRoaster(
          Roaster(
            id: '',
            name: coffee.roaster,
            description: result.roasterDescription,
            url: result.roasterUrl,
            country: result.roasterCountry,
            city: result.roasterCity,
            keyPeople: result.roasterKeyPeople,
            source: 'ai',
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      if (needsFarmInfo) {
        farmUrl = result.farmUrl;
        farmDescription = result.farmDescription;
        farmId = await farmRepository.addFarm(
          Farm(
            id: '',
            name: coffee.farmName!,
            description: result.farmDescription,
            url: result.farmUrl,
            country: coffee.originCountry,
            region: result.farmRegion ?? coffee.originRegion,
            farmerName: result.farmFarmerName ?? coffee.farmerName,
            altitude: result.farmAltitude ?? coffee.altitude,
            source: 'ai',
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }

    // Targeted partial update (only the enrichment fields) rather than a full
    // rewrite, so this can't clobber a concurrent writer such as the freshness
    // notification flag.
    await coffeeRepository.applyEnrichment(
      coffeeId,
      roasterId: roasterId,
      farmId: farmId,
      roasterUrl: roasterUrl,
      roasterDescription: roasterDescription,
      farmUrl: farmUrl,
      farmDescription: farmDescription,
    );
  }
}

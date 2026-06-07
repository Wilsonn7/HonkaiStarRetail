/// Utility untuk mapping nama resource ke asset image path
class ImageUtils {
  /// Map resource name ke asset image filename
  static String getAssetImagePath(String resourceName) {
    // Mapping nama resource ke filename di folder assets
    final assetMap = {
      'Stellar Jade': 'assets/StellarJade.jpg',
      'Oneiric Shards': 'assets/OneiricShards.jpg',
      'Parthian Shot': 'assets/ParthianShot.jpg',
      'Dance at Twilight': 'assets/DanceAtTwilight.jpg',
      'Before the Tutorial Mission Starts':
          'assets/BeforeTheTutorialMissionStarts.jpg',
      'Cosmic Dust': 'assets/CosmicDust.jpg',
    };

    return assetMap[resourceName] ?? 'assets/StellarJade.jpg';
  }

  /// Check apakah resource memiliki asset image
  static bool hasAssetImage(String resourceName) {
    return getAssetImagePath(resourceName) != 'assets/StellarJade.jpg' ||
        resourceName == 'Stellar Jade';
  }
}

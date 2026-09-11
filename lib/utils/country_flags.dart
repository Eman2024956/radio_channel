class CountryFlags {
  /// Converts a 2-letter ISO country code into a regional indicator emoji flag.
  /// Example: 'US' -> 🇺🇸, 'IQ' -> 🇮🇶, 'FR' -> 🇫🇷
  static String getFlag(String? countryCode) {
    if (countryCode == null || countryCode.trim().length != 2) {
      return '📻';
    }
    final code = countryCode.trim().toUpperCase();
    final firstChar = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final secondChar = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  /// Popular preset countries with names and codes for fast filter chips
  static const List<Map<String, String>> popularCountries = [
    {'name': 'All Countries', 'code': ''},
    {'name': 'Iraq', 'code': 'IQ'},
    {'name': 'Saudi Arabia', 'code': 'SA'},
    {'name': 'Egypt', 'code': 'EG'},
    {'name': 'United Arab Emirates', 'code': 'AE'},
    {'name': 'United States', 'code': 'US'},
    {'name': 'United Kingdom', 'code': 'GB'},
    {'name': 'France', 'code': 'FR'},
    {'name': 'Germany', 'code': 'DE'},
    {'name': 'Spain', 'code': 'ES'},
    {'name': 'Italy', 'code': 'IT'},
    {'name': 'Canada', 'code': 'CA'},
    {'name': 'Turkey', 'code': 'TR'},
    {'name': 'Morocco', 'code': 'MA'},
    {'name': 'Algeria', 'code': 'DZ'},
    {'name': 'Jordan', 'code': 'JO'},
    {'name': 'Lebanon', 'code': 'LB'},
  ];

  /// Popular languages
  static const List<Map<String, String>> popularLanguages = [
    {'name': 'All Languages', 'code': ''},
    {'name': 'Arabic', 'code': 'arabic'},
    {'name': 'English', 'code': 'english'},
    {'name': 'French', 'code': 'french'},
    {'name': 'Spanish', 'code': 'spanish'},
    {'name': 'German', 'code': 'german'},
    {'name': 'Turkish', 'code': 'turkish'},
    {'name': 'Russian', 'code': 'russian'},
    {'name': 'Italian', 'code': 'italian'},
  ];

  /// Curated genre tags
  static const List<Map<String, dynamic>> popularGenres = [
    {'tag': '', 'name': 'All Genres', 'icon': 'radio'},
    {'tag': 'news', 'name': 'News & Talk', 'icon': 'newspaper'},
    {'tag': 'pop', 'name': 'Pop', 'icon': 'music_note'},
    {'tag': 'islamic', 'name': 'Islamic & Quran', 'icon': 'mosque'},
    {'tag': 'rock', 'name': 'Rock', 'icon': 'electric_bolt'},
    {'tag': 'classical', 'name': 'Classical', 'icon': 'auto_stories'},
    {'tag': 'jazz', 'name': 'Jazz & Blues', 'icon': 'nightlife'},
    {'tag': 'dance', 'name': 'Dance & Electronic', 'icon': 'speaker'},
    {'tag': 'ambient', 'name': 'Chill & Relax', 'icon': 'waves'},
    {'tag': 'sports', 'name': 'Sports', 'icon': 'sports_soccer'},
  ];
}

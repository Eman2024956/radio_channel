import 'package:flutter_test/flutter_test.dart';
import 'package:radio_channel/models/radio_station.dart';
import 'package:radio_channel/models/country.dart';
import 'package:radio_channel/models/language.dart';
import 'package:radio_channel/models/genre_tag.dart';
import 'package:radio_channel/utils/country_flags.dart';

void main() {
  group('Radio Models and Helpers Tests', () {
    test('RadioStation.fromJson parses all fields correctly', () {
      final json = {
        'stationuuid': '1234-uuid-station',
        'name': 'Radio Baghdad Live',
        'url': 'http://stream.example.com/live',
        'url_resolved': 'https://stream.example.com/live.mp3',
        'homepage': 'https://radiobaghdad.iq',
        'favicon': 'https://radiobaghdad.iq/logo.png',
        'tags': 'news,talk,iraq,arabic',
        'country': 'Iraq',
        'countrycode': 'IQ',
        'state': 'Baghdad',
        'language': 'arabic',
        'votes': 450,
        'codec': 'MP3',
        'bitrate': 128,
        'hls': 0,
        'clickcount': 1200,
      };

      final station = RadioStation.fromJson(json);

      expect(station.stationUuid, '1234-uuid-station');
      expect(station.displayName, 'Radio Baghdad Live');
      expect(station.streamUrl, 'https://stream.example.com/live.mp3');
      expect(station.countryCode, 'IQ');
      expect(station.formatBadge, 'MP3 • 128 kbps');
      expect(station.tagList, ['news', 'talk', 'iraq', 'arabic']);
      expect(station.votes, 450);
      expect(station.clickCount, 1200);
      expect(station.isHls, false);
    });

    test('RadioStation handles null / fallback fields gracefully', () {
      final json = <String, dynamic>{
        'stationuuid': 'empty-station-1',
        'name': '',
        'url': 'http://fallback.com/stream',
      };

      final station = RadioStation.fromJson(json);

      expect(station.displayName, 'Unnamed Station');
      expect(station.streamUrl, 'http://fallback.com/stream');
      expect(station.tagList, isEmpty);
      expect(station.bitrateDisplay, 'Variable');
      expect(station.formatBadge, 'LIVE');
    });

    test('RadioStation toJson and fromJsonString serialization roundtrip', () {
      final station = RadioStation(
        stationUuid: 'roundtrip-1',
        name: 'BBC World Service',
        url: 'http://bbcwssc.ic.llnwd.net/stream/bbcwssc_mp1_ws-einws',
        urlResolved: 'http://bbcwssc.ic.llnwd.net/stream/bbcwssc_mp1_ws-einws',
        country: 'United Kingdom',
        countryCode: 'GB',
        codec: 'MP3',
        bitrate: 128,
      );

      final jsonStr = station.toJsonString();
      final decoded = RadioStation.fromJsonString(jsonStr);

      expect(decoded.stationUuid, station.stationUuid);
      expect(decoded.name, station.name);
      expect(decoded.countryCode, 'GB');
      expect(decoded.codec, 'MP3');
      expect(decoded.bitrate, 128);
    });

    test('CountryItem, LanguageItem, and GenreTag parsing', () {
      final country = CountryItem.fromJson({
        'name': 'Iraq',
        'iso_3166_1': 'IQ',
        'stationcount': 32,
      });
      expect(country.name, 'Iraq');
      expect(country.isoCode, 'IQ');
      expect(country.stationCount, 32);

      final language = LanguageItem.fromJson({
        'name': 'arabic',
        'iso_639': 'ar',
        'stationcount': 210,
      });
      expect(language.name, 'arabic');
      expect(language.stationCount, 210);

      final tag = GenreTag.fromJson({
        'name': 'classical',
        'stationcount': 840,
      });
      expect(tag.name, 'classical');
      expect(tag.stationCount, 840);
    });

    test('CountryFlags.getFlag generates emoji flag from ISO code', () {
      expect(CountryFlags.getFlag('IQ'), '🇮🇶');
      expect(CountryFlags.getFlag('US'), '🇺🇸');
      expect(CountryFlags.getFlag('FR'), '🇫🇷');
      expect(CountryFlags.getFlag(''), '📻');
      expect(CountryFlags.getFlag(null), '📻');
    });
  });
}

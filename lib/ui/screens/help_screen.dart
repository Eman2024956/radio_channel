import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_translations.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr.menuHelpDocs,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryCyan, AppTheme.secondaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryCyan.withAlpha(50),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(60),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr.helpDocsTitle,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr.helpDocsSubtitle,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 1: Search & Smart Filters
            _buildDocCard(
              context: context,
              icon: Icons.search_rounded,
              iconColor: AppTheme.primaryCyan,
              title: tr.guideStationsSearch,
              description: tr.guideStationsSearchBody,
              tips: [
                'Filter by 180+ countries with regional flags',
                'Filter by audio codecs (MP3, AAC+, OGG, FLAC)',
                'Filter by bitrate threshold (64k, 128k, 192k, 320k)',
              ],
            ),
            const SizedBox(height: 14),

            // Section 2: MP3 Live Recording
            _buildDocCard(
              context: context,
              icon: Icons.mic_rounded,
              iconColor: AppTheme.accentCoral,
              title: tr.guideRecording,
              description: tr.guideRecordingBody,
              tips: [
                'Preset timers: 30 seconds, 1 min, 3 min, 5 min',
                'Saved directly to real device storage (RadioRecordings)',
                'Play recorded tracks offline anytime in Downloads tab',
              ],
            ),
            const SizedBox(height: 14),

            // Section 3: Bookmarks & Favorites
            _buildDocCard(
              context: context,
              icon: Icons.favorite_rounded,
              iconColor: AppTheme.accentAmber,
              title: tr.guideFavorites,
              description: tr.guideFavoritesBody,
              tips: [
                'Tap the heart icon to instantly bookmark stations',
                'Stations you listen to are saved to recent history',
                'One-tap instant playback from favorites screen',
              ],
            ),
            const SizedBox(height: 14),

            // Section 4: Dark Mode & Translating
            _buildDocCard(
              context: context,
              icon: Icons.translate_rounded,
              iconColor: AppTheme.secondaryPurple,
              title: tr.guideThemesAndLanguages,
              description: tr.guideThemesAndLanguagesBody,
              tips: [
                'Full RTL Arabic typography and alignment',
                'Sleek cyber slate dark theme optimized for OLED',
                'Instant switch without restarting the application',
              ],
            ),
            const SizedBox(height: 24),

            // Footer note
            Center(
              child: Text(
                tr.developerCopyright,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMutedOf(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required List<String> tips,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textMutedOf(context),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceOf(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderOf(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tips
                  .map(
                    (tip) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 14, color: AppTheme.primaryCyan),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.textPrimaryOf(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

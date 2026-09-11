import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/player_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/download_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/country_flags.dart';
import '../../utils/app_translations.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/record_time_dialog.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PlayerScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final player = context.watch<PlayerProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final downloadProvider = context.watch<DownloadProvider>();
    final station = player.currentStation;

    if (station == null) {
      return const SizedBox.shrink();
    }

    final isPlaying = player.isPlaying;
    final isBuffering = player.isBuffering;
    final isFav = favorites.isFavorite(station.stationUuid);
    final flag = CountryFlags.getFlag(station.countryCode);
    final isRecordingThis = downloadProvider.isRecording &&
        downloadProvider.recordingStation?.stationUuid == station.stationUuid;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppTheme.borderOf(context), width: 1.5)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 14, bottom: 6),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMutedOf(context).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Top App Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
                  color: AppTheme.textSecondaryOf(context),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Text(
                  tr.nowStreaming,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppTheme.primaryOf(context),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? AppTheme.accentPink : AppTheme.textSecondaryOf(context),
                    size: 26,
                  ),
                  onPressed: () => favorites.toggleFavorite(station),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Center Vinyl / Artwork with pulsing glow
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow shadow
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: isPlaying
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryOf(context).withValues(alpha: 0.3),
                                      blurRadius: 36,
                                      spreadRadius: 6,
                                    ),
                                    BoxShadow(
                                      color: AppTheme.secondaryPurple.withValues(alpha: 0.2),
                                      blurRadius: 50,
                                      spreadRadius: 10,
                                    ),
                                  ]
                                : [],
                          ),
                        ),

                        // Vinyl outer ring
                        Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: Theme.of(context).brightness == Brightness.dark
                                  ? const [Color(0xFF1E293B), Color(0xFF0F172A)]
                                  : const [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
                            ),
                            border: Border.all(
                              color: isPlaying ? AppTheme.primaryOf(context) : AppTheme.borderOf(context),
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: ClipOval(
                              child: station.favicon.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: station.favicon,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: Text(flag, style: const TextStyle(fontSize: 56)),
                                      ),
                                      errorWidget: (context, url, error) => Center(
                                        child: Text(flag, style: const TextStyle(fontSize: 56)),
                                      ),
                                    )
                                  : Center(
                                      child: Text(flag, style: const TextStyle(fontSize: 56)),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Station Name
                  Text(
                    station.displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Country & Language
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(flag, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        station.country.isNotEmpty ? station.country : tr.global,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryOf(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (station.language.isNotEmpty) ...[
                        Text(' • ', style: TextStyle(color: AppTheme.textMutedOf(context))),
                        Text(
                          station.language,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondaryOf(context),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Visualizer Bars
                  Center(
                    child: AudioVisualizer(
                      isPlaying: isPlaying,
                      barCount: 16,
                      height: 28,
                      width: 4,
                      color: isPlaying ? AppTheme.primaryOf(context) : AppTheme.textMutedOf(context).withValues(alpha: 0.3),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Active Recording indicator banner
                  if (isRecordingThis)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPink.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.accentPink.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.fiber_smart_record_rounded, color: AppTheme.accentPink),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr.recordingInProgress,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentPink, fontSize: 13),
                                ),
                                Text(
                                  '${downloadProvider.elapsedSeconds}s / ${downloadProvider.targetDurationSeconds}s (${downloadProvider.formattedBytes})',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => downloadProvider.stopRecording(),
                            child: const Text('Stop', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),

                  // Player Error Notification
                  if (player.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              player.errorMessage!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Main Audio Controls (Play / Pause / Buffering)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Stop button
                      IconButton(
                        icon: const Icon(Icons.stop_circle_outlined, size: 34),
                        color: AppTheme.textMutedOf(context),
                        onPressed: () => player.stop(),
                      ),

                      const SizedBox(width: 20),

                      // Large Play/Pause Button
                      GestureDetector(
                        onTap: () => player.togglePlayPause(),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isPlaying
                                  ? [AppTheme.accentPink, AppTheme.secondaryPurple]
                                  : [AppTheme.primaryCyan, const Color(0xFF00B4D8)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isPlaying ? AppTheme.accentPink : AppTheme.primaryCyan).withValues(alpha: 0.4),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: isBuffering
                                ? const SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : Icon(
                                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.black,
                                    size: 38,
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Record MP3 Button
                      IconButton(
                        icon: const Icon(Icons.fiber_manual_record_rounded, size: 32),
                        color: AppTheme.accentPink,
                        tooltip: tr.recordMp3,
                        onPressed: () => RecordTimeDialog.show(context, station),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Volume Slider
                  Row(
                    children: [
                      Icon(Icons.volume_down_rounded, size: 20, color: AppTheme.textMutedOf(context)),
                      Expanded(
                        child: Slider(
                          value: player.volume,
                          min: 0.0,
                          max: 1.0,
                          activeColor: AppTheme.primaryOf(context),
                          inactiveColor: AppTheme.borderOf(context),
                          onChanged: (v) => player.setVolume(v),
                        ),
                      ),
                      Icon(Icons.volume_up_rounded, size: 20, color: AppTheme.textMutedOf(context)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Station Metadata Specs Cards
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColorOf(context),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.borderOf(context)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr.stationDetails,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildSpecRow(context, tr.audioCodec, station.codec.isNotEmpty ? station.codec : 'Unknown'),
                        _buildSpecRow(context, 'Bitrate', station.bitrateDisplay),
                        _buildSpecRow(context, tr.streamType, station.isHls ? 'HLS (.m3u8)' : 'Direct Stream'),
                        _buildSpecRow(context, tr.votes, '${station.votes}'),
                        _buildSpecRow(context, tr.totalListens, '${station.clickCount}'),

                        if (station.tagList.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            tr.tagsGenres,
                            style: TextStyle(fontSize: 11, color: AppTheme.textMutedOf(context)),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: station.tagList.map((t) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceOf(context),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.borderOf(context)),
                                ),
                                child: Text(
                                  '#$t',
                                  style: TextStyle(fontSize: 11, color: AppTheme.primaryOf(context)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Actions: Download/Record, Copy Stream URL & Visit Website
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentPink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => RecordTimeDialog.show(context, station),
                          icon: const Icon(Icons.fiber_manual_record_rounded, size: 16),
                          label: Text(tr.recordMp3, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.borderOf(context)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: station.streamUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(tr.urlCopied),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(Icons.copy_rounded, size: 16, color: AppTheme.textSecondaryOf(context)),
                          label: Text(tr.copyUrl, style: TextStyle(color: AppTheme.textSecondaryOf(context))),
                        ),
                      ),
                      if (station.homepage.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.cardColorOf(context),
                            side: BorderSide(color: AppTheme.borderOf(context)),
                          ),
                          onPressed: () async {
                            final uri = Uri.tryParse(station.homepage);
                            if (uri != null && await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                          tooltip: tr.website,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryOf(context))),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

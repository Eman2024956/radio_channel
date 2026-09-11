import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/country_flags.dart';
import '../screens/player_screen.dart';
import 'audio_visualizer.dart';
import 'record_time_dialog.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final station = player.currentStation;

    if (station == null) {
      return const SizedBox.shrink();
    }

    final isPlaying = player.isPlaying;
    final isBuffering = player.isBuffering;
    final flag = CountryFlags.getFlag(station.countryCode);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying ? AppTheme.primaryOf(context).withValues(alpha: 0.6) : AppTheme.borderOf(context),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          if (isPlaying)
            BoxShadow(
              color: AppTheme.primaryOf(context).withValues(alpha: 0.2),
              blurRadius: 10,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => PlayerScreen.show(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                // Station Favicon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceOf(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderOf(context)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: station.favicon.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: station.favicon,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: Text(flag, style: const TextStyle(fontSize: 18)),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Text(flag, style: const TextStyle(fontSize: 18)),
                            ),
                          )
                        : Center(
                            child: Text(flag, style: const TextStyle(fontSize: 18)),
                          ),
                  ),
                ),

                const SizedBox(width: 10),

                // Name & Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              station.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryOf(context),
                              ),
                            ),
                          ),
                          if (isPlaying) ...[
                            const SizedBox(width: 6),
                            const AudioVisualizer(
                              isPlaying: true,
                              barCount: 3,
                              height: 11,
                              width: 2.2,
                              color: AppTheme.liveGreen,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              station.country.isNotEmpty ? '$flag ${station.country}' : 'Global Live Radio',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondaryOf(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '• ${station.formatBadge}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryOf(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),

                // Record Button
                IconButton(
                  icon: const Icon(Icons.fiber_manual_record_rounded, size: 18, color: AppTheme.accentPink),
                  tooltip: 'Record MP3',
                  onPressed: () => RecordTimeDialog.show(context, station),
                ),

                // Play / Pause Button
                GestureDetector(
                  onTap: () => player.togglePlayPause(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPlaying
                            ? [AppTheme.accentPink, AppTheme.secondaryPurple]
                            : [AppTheme.primaryCyan, const Color(0xFF00B4D8)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isBuffering
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 22,
                            ),
                    ),
                  ),
                ),

                const SizedBox(width: 2),

                // Close Button
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: AppTheme.textMutedOf(context)),
                  onPressed: () => player.stop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/radio_station.dart';
import '../../providers/player_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/country_flags.dart';
import 'audio_visualizer.dart';
import 'record_time_dialog.dart';

class StationListTile extends StatelessWidget {
  final RadioStation station;
  final VoidCallback? onTap;

  const StationListTile({
    super.key,
    required this.station,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final favorites = context.watch<FavoritesProvider>();

    final isCurrent = player.currentStation?.stationUuid == station.stationUuid;
    final isPlaying = isCurrent && player.isPlaying;
    final isBuffering = isCurrent && player.isBuffering;
    final isFav = favorites.isFavorite(station.stationUuid);
    final flag = CountryFlags.getFlag(station.countryCode);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: isCurrent ? AppTheme.elevatedOf(context) : AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppTheme.primaryOf(context) : AppTheme.borderOf(context),
          width: isCurrent ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          if (isCurrent)
            BoxShadow(
              color: AppTheme.primaryOf(context).withValues(alpha: 0.15),
              blurRadius: 10,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ?? () => player.playStation(station),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Station Favicon / Icon Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceOf(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderOf(context)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: station.favicon.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: station.favicon,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: Text(flag, style: const TextStyle(fontSize: 22)),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: Text(flag, style: const TextStyle(fontSize: 22)),
                                ),
                              )
                            : Center(
                                child: Text(flag, style: const TextStyle(fontSize: 22)),
                              ),
                      ),
                    ),
                    if (isPlaying)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceOf(context),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.liveGreen, width: 1.5),
                        ),
                        child: const AudioVisualizer(
                          isPlaying: true,
                          barCount: 3,
                          height: 10,
                          width: 2,
                          color: AppTheme.liveGreen,
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                // Station Info: Name, Country, Tags, Bitrate
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        station.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? AppTheme.primaryOf(context) : AppTheme.textPrimaryOf(context),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (station.country.isNotEmpty) ...[
                            Flexible(
                              child: Text(
                                '$flag ${station.country}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondaryOf(context),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceOf(context),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: AppTheme.borderOf(context)),
                            ),
                            child: Text(
                              station.formatBadge,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryOf(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (station.tagList.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          station.tagList.join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textMutedOf(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 4),

                // Record MP3 Button
                IconButton(
                  icon: const Icon(
                    Icons.fiber_manual_record_rounded,
                    color: AppTheme.accentPink,
                    size: 20,
                  ),
                  tooltip: 'Record MP3',
                  onPressed: () => RecordTimeDialog.show(context, station),
                ),

                // Favorite Toggle Button
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? AppTheme.accentPink : AppTheme.textMutedOf(context),
                    size: 20,
                  ),
                  tooltip: 'Favorite',
                  onPressed: () => favorites.toggleFavorite(station),
                ),

                // Play / Pause Icon Button
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPlaying
                          ? [AppTheme.accentPink, AppTheme.secondaryPurple]
                          : [AppTheme.primaryCyan, const Color(0xFF00B4D8)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isPlaying ? AppTheme.accentPink : AppTheme.primaryCyan).withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: isBuffering
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/radio_station.dart';
import '../../providers/player_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/country_flags.dart';
import 'record_time_dialog.dart';

class StationCard extends StatelessWidget {
  final RadioStation station;
  final double width;

  const StationCard({
    super.key,
    required this.station,
    this.width = 160,
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
      width: width,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: isCurrent ? AppTheme.elevatedOf(context) : AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent ? AppTheme.primaryOf(context) : AppTheme.borderOf(context),
          width: isCurrent ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          if (isCurrent)
            BoxShadow(
              color: AppTheme.primaryOf(context).withValues(alpha: 0.25),
              blurRadius: 12,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => player.playStation(station),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image / Flag Header
                Stack(
                  children: [
                    Container(
                      height: 82,
                      width: double.infinity,
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
                                  child: Text(flag, style: const TextStyle(fontSize: 30)),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: Text(flag, style: const TextStyle(fontSize: 30)),
                                ),
                              )
                            : Center(
                                child: Text(flag, style: const TextStyle(fontSize: 30)),
                              ),
                      ),
                    ),

                    // Flag badge
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(flag, style: const TextStyle(fontSize: 12)),
                      ),
                    ),

                    // Top Right: Favorite Button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => favorites.toggleFavorite(station),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? AppTheme.accentPink : Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),

                    // Bottom Floating Play / Pause
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 30,
                        height: 30,
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
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                )
                              : Icon(
                                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.black,
                                  size: 18,
                                ),
                        ),
                      ),
                    ),

                    // Record Quick Shortcut
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: GestureDetector(
                        onTap: () => RecordTimeDialog.show(context, station),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fiber_manual_record_rounded,
                            color: AppTheme.accentPink,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Station Title
                Text(
                  station.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCurrent ? AppTheme.primaryOf(context) : AppTheme.textPrimaryOf(context),
                  ),
                ),

                const SizedBox(height: 2),

                // Station Country & Format
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        station.country.isNotEmpty ? station.country : 'Global',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textMutedOf(context),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceOf(context),
                        borderRadius: BorderRadius.circular(4),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/download_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_translations.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/language_toggle_button.dart';

class DownloadsScreen extends StatelessWidget {
  final Function(int tabIndex)? onNavigateToTab;

  const DownloadsScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final downloadProvider = context.watch<DownloadProvider>();
    final tracks = downloadProvider.savedTracks;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPink.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.download_done_rounded, color: AppTheme.accentPink, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr.mp3Downloads,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tr.savedInStorage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: AppTheme.textMutedOf(context)),
                        ),
                      ],
                    ),
                  ),
                  const LanguageToggleButton(),
                ],
              ),
            ),

            // Active Recording Progress Banner if running
            if (downloadProvider.isRecording)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentPink.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentPink.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.fiber_smart_record_rounded, color: AppTheme.accentPink, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${tr.recordingInProgress} ${downloadProvider.recordingStation?.displayName ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                '${downloadProvider.elapsedSeconds}s / ${downloadProvider.targetDurationSeconds}s (${downloadProvider.formattedBytes})',
                                style: const TextStyle(fontSize: 11, color: AppTheme.accentPink),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop_circle_rounded, color: Colors.redAccent, size: 26),
                          onPressed: () => downloadProvider.stopRecording(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: downloadProvider.progressPercentage,
                      backgroundColor: AppTheme.borderOf(context),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentPink),
                      borderRadius: BorderRadius.circular(6),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),

            // Track list or Empty state
            Expanded(
              child: tracks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.audio_file_outlined,
                            size: 64,
                            color: AppTheme.textMutedOf(context),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            tr.noRecordingsYet,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              tr.recordGuidance,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryOf(context)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryOf(context),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => onNavigateToTab?.call(0),
                            icon: const Icon(Icons.radio_rounded, size: 18),
                            label: Text(tr.browseChannels, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                      itemCount: tracks.length,
                      itemBuilder: (ctx, i) {
                        final track = tracks[i];
                        final isPlayingThis = downloadProvider.isPlayingTrack &&
                            downloadProvider.currentPlayingTrack?.id == track.id;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: isPlayingThis
                                ? AppTheme.elevatedOf(context)
                                : AppTheme.cardColorOf(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isPlayingThis
                                  ? AppTheme.accentPink.withValues(alpha: 0.6)
                                  : AppTheme.borderOf(context),
                              width: isPlayingThis ? 1.5 : 1.0,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceOf(context),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.borderOf(context)),
                                  ),
                                  child: const Icon(Icons.music_note_rounded, color: AppTheme.accentPink),
                                ),
                                if (isPlayingThis)
                                  const AudioVisualizer(
                                    isPlaying: true,
                                    barCount: 3,
                                    height: 14,
                                    width: 2.5,
                                    color: AppTheme.accentPink,
                                  ),
                              ],
                            ),
                            title: Text(
                              track.stationName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isPlayingThis ? AppTheme.accentPink : AppTheme.textPrimaryOf(context),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Row(
                                children: [
                                  Text(
                                    '${track.formattedDuration} • ${track.formattedSize}',
                                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryOf(context)),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceOf(context),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'MP3',
                                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.accentPink),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Play / Pause Button
                                IconButton(
                                  icon: Icon(
                                    isPlayingThis ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                                    color: AppTheme.accentPink,
                                    size: 34,
                                  ),
                                  onPressed: () => downloadProvider.playTrack(track),
                                ),
                                // Delete Track Button
                                IconButton(
                                  icon: Icon(Icons.delete_outline_rounded, color: AppTheme.textMutedOf(context), size: 20),
                                  onPressed: () => downloadProvider.deleteTrack(track),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

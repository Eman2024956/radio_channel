import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/radio_station.dart';
import '../../providers/download_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/country_flags.dart';
import '../../utils/app_translations.dart';

class RecordTimeDialog extends StatefulWidget {
  final RadioStation station;

  const RecordTimeDialog({super.key, required this.station});

  static Future<void> show(BuildContext context, RadioStation station) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RecordTimeDialog(station: station),
    );
  }

  @override
  State<RecordTimeDialog> createState() => _RecordTimeDialogState();
}

class _RecordTimeDialogState extends State<RecordTimeDialog> {
  int _selectedDuration = 60; // 60 seconds by default

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final downloadProvider = context.watch<DownloadProvider>();
    final isRecordingThis = downloadProvider.isRecording &&
        downloadProvider.recordingStation?.stationUuid == widget.station.stationUuid;
    final flag = CountryFlags.getFlag(widget.station.countryCode);

    final List<Map<String, dynamic>> durationOptions = [
      {'seconds': 30, 'label': '30s', 'desc': tr.quickClip},
      {'seconds': 60, 'label': '1 min', 'desc': tr.standard},
      {'seconds': 120, 'label': '2 min', 'desc': tr.songTrack},
      {'seconds': 300, 'label': '5 min', 'desc': tr.segment},
      {'seconds': 600, 'label': '10 min', 'desc': tr.fullShow},
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppTheme.borderOf(context), width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMutedOf(context).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentPink.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fiber_manual_record_rounded, color: AppTheme.accentPink, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.recordDownloadMp3,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$flag ${widget.station.displayName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryOf(context)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Active Recording State
          if (isRecordingThis) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentPink.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.fiber_smart_record_rounded, color: AppTheme.accentPink, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            tr.recordingInProgress,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentPink),
                          ),
                        ],
                      ),
                      Text(
                        '${downloadProvider.elapsedSeconds}s / ${downloadProvider.targetDurationSeconds}s',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: downloadProvider.progressPercentage,
                    backgroundColor: AppTheme.borderOf(context),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentPink),
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${downloadProvider.formattedBytes} • ${tr.savedInDownloadsNote}',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryOf(context)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  downloadProvider.stopRecording();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.stop_rounded),
                label: Text(tr.stopAndSaveNow, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ] else ...[
            // Duration selector
            Text(
              tr.selectDuration,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryOf(context),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: durationOptions.map((opt) {
                final isSelected = _selectedDuration == opt['seconds'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDuration = opt['seconds'] as int),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryOf(context).withValues(alpha: 0.15)
                            : AppTheme.surfaceOf(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryOf(context) : AppTheme.borderOf(context),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            opt['label'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppTheme.primaryOf(context) : AppTheme.textPrimaryOf(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            opt['desc'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              color: AppTheme.textMutedOf(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // Note on location & permissions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderOf(context)),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_special_rounded, color: AppTheme.primaryOf(context), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tr.savedInDownloadsNote,
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryOf(context)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Start Recording Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () {
                  downloadProvider.startRecording(widget.station, _selectedDuration);
                },
                icon: const Icon(Icons.fiber_manual_record_rounded, size: 18),
                label: Text(
                  '${tr.startRecording} (${_selectedDuration ~/ 60 > 0 ? '${_selectedDuration ~/ 60}m' : ''}${_selectedDuration % 60 > 0 ? '${_selectedDuration % 60}s' : ''})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

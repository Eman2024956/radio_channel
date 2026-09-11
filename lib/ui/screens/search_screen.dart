import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_filter_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/country_flags.dart';
import '../../utils/app_translations.dart';
import '../widgets/station_list_tile.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/language_toggle_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<SearchFilterProvider>();
    _searchController.text = provider.query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final searchFilter = context.watch<SearchFilterProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Search Input & Filter Button & Language Toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: searchFilter.onQueryChanged,
                      decoration: InputDecoration(
                        hintText: tr.searchStationsHint,
                        prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryOf(context)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: AppTheme.textMutedOf(context), size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  searchFilter.onQueryChanged('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: searchFilter.activeFilterCount > 0
                              ? AppTheme.primaryOf(context)
                              : AppTheme.cardColorOf(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: searchFilter.activeFilterCount > 0
                                ? AppTheme.primaryOf(context)
                                : AppTheme.borderOf(context),
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.tune_rounded,
                            color: searchFilter.activeFilterCount > 0 ? Colors.white : AppTheme.textPrimaryOf(context),
                          ),
                          tooltip: tr.advancedFilters,
                          onPressed: () => FilterBottomSheet.show(context),
                        ),
                      ),
                      if (searchFilter.activeFilterCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.accentPink,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${searchFilter.activeFilterCount}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  const LanguageToggleButton(),
                ],
              ),
            ),

            // Active Filters Chips (Country, Language, Genre, Codec)
            if (searchFilter.activeFilterCount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (searchFilter.selectedCountryCode != null)
                        _buildActiveChip(
                          '${CountryFlags.getFlag(searchFilter.selectedCountryCode)} ${searchFilter.selectedCountry ?? searchFilter.selectedCountryCode}',
                          () => searchFilter.setCountry(null, null),
                        ),
                      if (searchFilter.selectedLanguage != null)
                        _buildActiveChip(
                          '🌐 ${searchFilter.selectedLanguage}',
                          () => searchFilter.setLanguage(null),
                        ),
                      if (searchFilter.selectedGenre != null)
                        _buildActiveChip(
                          '#${searchFilter.selectedGenre}',
                          () => searchFilter.setGenre(null),
                        ),
                      if (searchFilter.selectedCodec != 'ALL')
                        _buildActiveChip(
                          'Codec: ${searchFilter.selectedCodec}',
                          () => searchFilter.setCodec('ALL'),
                        ),
                      if (searchFilter.minBitrate > 0)
                        _buildActiveChip(
                          '>= ${searchFilter.minBitrate} kbps',
                          () => searchFilter.setMinBitrate(0),
                        ),
                      TextButton(
                        onPressed: () => searchFilter.resetFilters(),
                        child: Text(tr.clearAll, style: const TextStyle(color: AppTheme.accentPink, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),

            // Quick Codec and Language Shortcut Strip
            Container(
              height: 36,
              margin: const EdgeInsets.only(top: 2, bottom: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...['ALL', 'MP3', 'AAC', 'OGG'].map((codec) {
                    final isSelected = searchFilter.selectedCodec == codec;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(codec),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryOf(context),
                        backgroundColor: AppTheme.cardColorOf(context),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 11,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryOf(context) : AppTheme.borderOf(context),
                        ),
                        onSelected: (_) => searchFilter.setCodec(codec),
                      ),
                    );
                  }),
                  const VerticalDivider(width: 14),
                  ...CountryFlags.popularLanguages.skip(1).take(5).map((l) {
                    final code = l['code']!;
                    final isSelected = searchFilter.selectedLanguage?.toLowerCase() == code.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(l['name']!),
                        selected: isSelected,
                        selectedColor: AppTheme.secondaryPurple,
                        backgroundColor: AppTheme.cardColorOf(context),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 11,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppTheme.secondaryPurple : AppTheme.borderOf(context),
                        ),
                        onSelected: (_) => searchFilter.setLanguage(isSelected ? null : code),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Results Counter & Order Display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                children: [
                  Text(
                    searchFilter.isLoading
                        ? tr.searchingChannels
                        : tr.foundStations(searchFilter.results.length),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    initialValue: searchFilter.orderBy,
                    onSelected: (val) {
                      searchFilter.setOrderBy(val, val == 'name' ? false : true);
                    },
                    color: AppTheme.cardColorOf(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sort_rounded, size: 16, color: AppTheme.primaryOf(context)),
                        const SizedBox(width: 4),
                        Text(
                          _getSortName(searchFilter.orderBy, tr),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryOf(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    itemBuilder: (ctx) => [
                      PopupMenuItem(value: 'clickcount', child: Text(tr.sortPopular)),
                      PopupMenuItem(value: 'votes', child: Text(tr.sortTopVoted)),
                      PopupMenuItem(value: 'bitrate', child: Text(tr.sortHighQuality)),
                      PopupMenuItem(value: 'name', child: Text(tr.sortName)),
                      PopupMenuItem(value: 'random', child: Text(tr.sortRandom)),
                    ],
                  ),
                ],
              ),
            ),

            // Station Results List
            Expanded(
              child: searchFilter.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryOf(context)),
                    )
                  : searchFilter.results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textMutedOf(context)),
                              const SizedBox(height: 12),
                              Text(
                                tr.noStationsFound,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                tr.tryChangingSearch,
                                style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryOf(context)),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.cardColorOf(context),
                                  foregroundColor: AppTheme.primaryOf(context),
                                  side: BorderSide(color: AppTheme.borderOf(context)),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  searchFilter.onQueryChanged('');
                                  searchFilter.resetFilters();
                                },
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: Text(tr.resetFilters),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 90),
                          itemCount: searchFilter.results.length,
                          itemBuilder: (ctx, i) {
                            return StationListTile(station: searchFilter.results[i]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveChip(String label, VoidCallback onDeleted) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textPrimaryOf(context))),
        backgroundColor: AppTheme.cardColorOf(context),
        side: BorderSide(color: AppTheme.primaryOf(context)),
        deleteIcon: Icon(Icons.close, size: 14, color: AppTheme.primaryOf(context)),
        onDeleted: onDeleted,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  String _getSortName(String order, AppTranslations tr) {
    switch (order) {
      case 'clickcount':
        return tr.sortPopular;
      case 'votes':
        return tr.sortTopVoted;
      case 'bitrate':
        return tr.sortHighQuality;
      case 'name':
        return tr.sortName;
      case 'random':
        return tr.sortRandom;
      default:
        return tr.sortBy;
    }
  }
}

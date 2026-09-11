import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_filter_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/country_flags.dart';
import '../../utils/app_translations.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const FilterBottomSheet(),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final TextEditingController _countrySearchCtrl = TextEditingController();
  final TextEditingController _langSearchCtrl = TextEditingController();

  String _countrySearch = '';
  String _langSearch = '';

  @override
  void dispose() {
    _countrySearchCtrl.dispose();
    _langSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final searchFilter = context.watch<SearchFilterProvider>();

    final filteredCountries = searchFilter.countries.where((c) {
      if (_countrySearch.isEmpty) return true;
      return c.name.toLowerCase().contains(_countrySearch.toLowerCase()) ||
          c.isoCode.toLowerCase().contains(_countrySearch.toLowerCase());
    }).take(40).toList();

    final filteredLanguages = searchFilter.languages.where((l) {
      if (_langSearch.isEmpty) return true;
      return l.name.toLowerCase().contains(_langSearch.toLowerCase());
    }).take(30).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppTheme.borderOf(context), width: 1.5)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMutedOf(context).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  tr.advancedFilters,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (searchFilter.activeFilterCount > 0)
                  TextButton.icon(
                    onPressed: () {
                      searchFilter.resetFilters();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: AppTheme.accentPink),
                    label: Text(
                      tr.clearAll,
                      style: const TextStyle(color: AppTheme.accentPink, fontSize: 13),
                    ),
                  ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppTheme.textSecondaryOf(context)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(color: AppTheme.borderOf(context), height: 1),

          // Content scrollable
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. Codec Selection
                _buildSectionTitle(tr.audioCodec),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['ALL', 'MP3', 'AAC', 'OGG'].map((codec) {
                    final isSelected = searchFilter.selectedCodec == codec;
                    return ChoiceChip(
                      label: Text(codec),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryOf(context),
                      backgroundColor: AppTheme.surfaceOf(context),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryOf(context) : AppTheme.borderOf(context),
                      ),
                      onSelected: (_) => searchFilter.setCodec(codec),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // 2. Sort Order Selection
                _buildSectionTitle(tr.sortBy),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    {'id': 'clickcount', 'label': tr.sortPopular},
                    {'id': 'votes', 'label': tr.sortTopVoted},
                    {'id': 'bitrate', 'label': tr.sortHighQuality},
                    {'id': 'name', 'label': tr.sortName},
                    {'id': 'random', 'label': tr.sortRandom},
                  ].map((item) {
                    final isSelected = searchFilter.orderBy == item['id'];
                    return ChoiceChip(
                      label: Text(item['label']!),
                      selected: isSelected,
                      selectedColor: AppTheme.secondaryPurple,
                      backgroundColor: AppTheme.surfaceOf(context),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.secondaryPurple : AppTheme.borderOf(context),
                      ),
                      onSelected: (_) => searchFilter.setOrderBy(
                        item['id']!,
                        item['id'] == 'name' ? false : true,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // 3. Minimum Bitrate
                _buildSectionTitle('${tr.minBitrate}: ${searchFilter.minBitrate > 0 ? '${searchFilter.minBitrate} kbps' : tr.any}'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [0, 64, 128, 192, 256, 320].map((b) {
                    final isSelected = searchFilter.minBitrate == b;
                    return ChoiceChip(
                      label: Text(b == 0 ? tr.any : '$b kbps'),
                      selected: isSelected,
                      selectedColor: AppTheme.accentAmber,
                      backgroundColor: AppTheme.surfaceOf(context),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : AppTheme.textSecondaryOf(context),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.accentAmber : AppTheme.borderOf(context),
                      ),
                      onSelected: (_) => searchFilter.setMinBitrate(b),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // 4. Country Filter
                _buildSectionTitle(
                  '${tr.countryFilter} ${searchFilter.selectedCountry != null ? '(${searchFilter.selectedCountry})' : ''}',
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _countrySearchCtrl,
                  onChanged: (v) => setState(() => _countrySearch = v),
                  decoration: InputDecoration(
                    hintText: tr.searchCountriesHint,
                    prefixIcon: Icon(Icons.search, size: 20, color: AppTheme.textMutedOf(context)),
                    suffixIcon: _countrySearch.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _countrySearchCtrl.clear();
                              setState(() => _countrySearch = '');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: filteredCountries.isEmpty
                      ? Center(
                          child: Text(tr.noMatchingCountries, style: TextStyle(color: AppTheme.textMutedOf(context))),
                        )
                      : ListView.builder(
                          itemCount: filteredCountries.length + 1,
                          itemBuilder: (ctx, i) {
                            if (i == 0) {
                              final isSelected = searchFilter.selectedCountryCode == null;
                              return ListTile(
                                dense: true,
                                title: Text(tr.allCountries),
                                trailing: isSelected ? Icon(Icons.check, color: AppTheme.primaryOf(context)) : null,
                                onTap: () => searchFilter.setCountry(null, null),
                              );
                            }
                            final country = filteredCountries[i - 1];
                            final isSelected = searchFilter.selectedCountryCode?.toLowerCase() == country.isoCode.toLowerCase();
                            final flag = CountryFlags.getFlag(country.isoCode);
                            return ListTile(
                              dense: true,
                              leading: Text(flag, style: const TextStyle(fontSize: 20)),
                              title: Text(country.name),
                              subtitle: Text('${country.stationCount} ${tr.stationsCount}', style: TextStyle(fontSize: 11, color: AppTheme.textMutedOf(context))),
                              trailing: isSelected ? Icon(Icons.check, color: AppTheme.primaryOf(context)) : null,
                              onTap: () => searchFilter.setCountry(country.name, country.isoCode),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 22),

                // 5. Language Filter
                _buildSectionTitle(
                  '${tr.languageFilter} ${searchFilter.selectedLanguage != null ? '(${searchFilter.selectedLanguage})' : ''}',
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _langSearchCtrl,
                  onChanged: (v) => setState(() => _langSearch = v),
                  decoration: InputDecoration(
                    hintText: '...',
                    prefixIcon: Icon(Icons.translate_rounded, size: 20, color: AppTheme.textMutedOf(context)),
                    suffixIcon: _langSearch.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _langSearchCtrl.clear();
                              setState(() => _langSearch = '');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 140,
                  child: filteredLanguages.isEmpty
                      ? Center(
                          child: Text('No matching languages', style: TextStyle(color: AppTheme.textMutedOf(context))),
                        )
                      : ListView.builder(
                          itemCount: filteredLanguages.length + 1,
                          itemBuilder: (ctx, i) {
                            if (i == 0) {
                              final isSelected = searchFilter.selectedLanguage == null;
                              return ListTile(
                                dense: true,
                                title: Text(tr.allLanguages),
                                trailing: isSelected ? Icon(Icons.check, color: AppTheme.primaryOf(context)) : null,
                                onTap: () => searchFilter.setLanguage(null),
                              );
                            }
                            final lang = filteredLanguages[i - 1];
                            final isSelected = searchFilter.selectedLanguage?.toLowerCase() == lang.name.toLowerCase();
                            return ListTile(
                              dense: true,
                              title: Text(lang.name),
                              subtitle: Text('${lang.stationCount} ${tr.stationsCount}', style: TextStyle(fontSize: 11, color: AppTheme.textMutedOf(context))),
                              trailing: isSelected ? Icon(Icons.check, color: AppTheme.primaryOf(context)) : null,
                              onTap: () => searchFilter.setLanguage(lang.name),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 22),

                // 6. Popular Genres / Tags
                _buildSectionTitle(
                  '${tr.genreFilter} ${searchFilter.selectedGenre != null ? '(${searchFilter.selectedGenre})' : ''}',
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(tr.exploreByGenre),
                      selected: searchFilter.selectedGenre == null,
                      selectedColor: AppTheme.primaryOf(context),
                      backgroundColor: AppTheme.surfaceOf(context),
                      labelStyle: TextStyle(
                        color: searchFilter.selectedGenre == null ? Colors.white : AppTheme.textSecondaryOf(context),
                        fontWeight: searchFilter.selectedGenre == null ? FontWeight.bold : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: searchFilter.selectedGenre == null ? AppTheme.primaryOf(context) : AppTheme.borderOf(context),
                      ),
                      onSelected: (_) => searchFilter.setGenre(null),
                    ),
                    ...searchFilter.tags.take(30).map((tag) {
                      final isSelected = searchFilter.selectedGenre?.toLowerCase() == tag.name.toLowerCase();
                      return ChoiceChip(
                        label: Text('${tag.name} (${tag.stationCount})'),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryOf(context),
                        backgroundColor: AppTheme.surfaceOf(context),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondaryOf(context),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryOf(context) : AppTheme.borderOf(context),
                        ),
                        onSelected: (_) => searchFilter.setGenre(isSelected ? null : tag.name),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceOf(context),
              border: Border(top: BorderSide(color: AppTheme.borderOf(context))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOf(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '${tr.applyFilters} (${searchFilter.results.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}

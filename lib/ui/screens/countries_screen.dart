import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/country.dart';
import '../../providers/search_filter_provider.dart';
import '../../providers/radio_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/country_flags.dart';
import '../../utils/app_translations.dart';
import '../widgets/language_toggle_button.dart';

class CountriesScreen extends StatefulWidget {
  final Function(int tabIndex)? onNavigateToTab;

  const CountriesScreen({super.key, this.onNavigateToTab});

  @override
  State<CountriesScreen> createState() => _CountriesScreenState();
}

class _CountriesScreenState extends State<CountriesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  int _selectedRegionIndex = 0; // 0: All, 1: Arab World, 2: Europe, 3: Americas, 4: Asia

  static const List<String> arabCountryCodes = [
    'IQ', 'SA', 'EG', 'AE', 'MA', 'DZ', 'JO', 'LB', 'TN', 'KW', 'QA', 'OM', 'BH', 'YE', 'SY', 'SD', 'LY'
  ];

  static const List<String> europeCountryCodes = [
    'GB', 'FR', 'DE', 'ES', 'IT', 'NL', 'RU', 'CH', 'SE', 'PL', 'BE', 'AT', 'PT', 'GR', 'IE'
  ];

  static const List<String> americasCountryCodes = [
    'US', 'CA', 'BR', 'MX', 'AR', 'CO', 'CL', 'PE'
  ];

  static const List<String> asiaCountryCodes = [
    'TR', 'JP', 'IN', 'KR', 'CN', 'ID', 'PH', 'TH', 'VN', 'PK', 'IR'
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CountryItem> _filterCountries(List<CountryItem> all) {
    return all.where((c) {
      if (_search.isNotEmpty) {
        final matchesName = c.name.toLowerCase().contains(_search.toLowerCase());
        final matchesCode = c.isoCode.toLowerCase().contains(_search.toLowerCase());
        if (!matchesName && !matchesCode) return false;
      }

      final code = c.isoCode.toUpperCase();
      switch (_selectedRegionIndex) {
        case 1:
          return arabCountryCodes.contains(code);
        case 2:
          return europeCountryCodes.contains(code);
        case 3:
          return americasCountryCodes.contains(code);
        case 4:
          return asiaCountryCodes.contains(code);
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final searchFilter = context.watch<SearchFilterProvider>();
    final radioProvider = context.watch<RadioProvider>();
    final countries = _filterCountries(searchFilter.countries);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOf(context).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.public_rounded, color: AppTheme.primaryOf(context), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr.countryCategories,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tr.countryCategoriesSubtitle,
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

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: tr.searchCountriesHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Region Categories Filter Strip
            Container(
              height: 38,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildRegionChip(0, tr.allNations),
                  _buildRegionChip(1, tr.arabWorld),
                  _buildRegionChip(2, tr.europe),
                  _buildRegionChip(3, tr.americas),
                  _buildRegionChip(4, tr.asia),
                ],
              ),
            ),

            // Countries Grid with Best Component Cards
            Expanded(
              child: countries.isEmpty
                  ? Center(
                      child: Text(
                        tr.noMatchingCountries,
                        style: TextStyle(color: AppTheme.textMutedOf(context)),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.35,
                      ),
                      itemCount: countries.length,
                      itemBuilder: (ctx, i) {
                        final country = countries[i];
                        final flag = CountryFlags.getFlag(country.isoCode);

                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardColorOf(context),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.borderOf(context)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                searchFilter.setCountry(country.name, country.isoCode);
                                radioProvider.setQuickCountry(country.isoCode);
                                widget.onNavigateToTab?.call(2); // Jump to search tab
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(flag, style: const TextStyle(fontSize: 30)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryOf(context).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${country.stationCount}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryOf(context),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          country.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${country.stationCount} ${tr.stationsCount}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppTheme.textMutedOf(context),
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
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionChip(int index, String label) {
    final isSelected = _selectedRegionIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
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
        onSelected: (_) => setState(() => _selectedRegionIndex = index),
      ),
    );
  }
}

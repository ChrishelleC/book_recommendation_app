import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<String> _selectedGenres = [];
  double _minRating = 0.0;
  bool _hideReading = false;
  bool _hideFinished = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _selectedGenres = prefs.getStringList('filter_genres') ?? [];
      _minRating = prefs.getDouble('filter_min_rating') ?? 0.0;
      _hideReading = prefs.getBool('filter_hide_reading') ?? false;
      _hideFinished = prefs.getBool('filter_hide_finished') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveFilters() async {
    setState(() {
      _isLoading = true;
    });
    
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setStringList('filter_genres', _selectedGenres);
    await prefs.setDouble('filter_min_rating', _minRating);
    await prefs.setBool('filter_hide_reading', _hideReading);
    await prefs.setBool('filter_hide_finished', _hideFinished);
    
    setState(() {
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters saved'),
        duration: Duration(seconds: 2),
      ),
    );
    
    Navigator.pop(context);
  }

  Future<void> _resetFilters() async {
    setState(() {
      _selectedGenres = [];
      _minRating = 0.0;
      _hideReading = false;
      _hideFinished = false;
    });
    
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove('filter_genres');
    await prefs.remove('filter_min_rating');
    await prefs.remove('filter_hide_reading');
    await prefs.remove('filter_hide_finished');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters reset'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Books'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Genre',
                    style: subheadingStyle,
                  ),
                  const SizedBox(height: smallPadding),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: genres.map((genre) {
                      final isSelected = _selectedGenres.contains(genre);
                      return FilterChip(
                        label: Text(genre),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedGenres.add(genre);
                            } else {
                              _selectedGenres.remove(genre);
                            }
                          });
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: primaryColor.withOpacity(0.2),
                        checkmarkColor: primaryColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: largePadding),
                  const Text(
                    'Minimum Rating',
                    style: subheadingStyle,
                  ),
                  const SizedBox(height: smallPadding),
                  Row(
                    children: [
                      const Icon(Icons.star_border, color: Colors.amber),
                      Expanded(
                        child: Slider(
                          value: _minRating,
                          min: 0.0,
                          max: 5.0,
                          divisions: 10,
                          label: _minRating.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() {
                              _minRating = value;
                            });
                          },
                          activeColor: Colors.amber,
                        ),
                      ),
                      const Icon(Icons.star, color: Colors.amber),
                    ],
                  ),
                  Text(
                    'Show books with rating of ${_minRating.toStringAsFixed(1)} or higher',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: largePadding),
                  const Text(
                    'Reading List Filters',
                    style: subheadingStyle,
                  ),
                  const SizedBox(height: smallPadding),
                  SwitchListTile(
                    title: const Text('Hide books I\'m currently reading'),
                    value: _hideReading,
                    onChanged: (value) {
                      setState(() {
                        _hideReading = value;
                      });
                    },
                    activeColor: primaryColor,
                  ),
                  SwitchListTile(
                    title: const Text('Hide books I\'ve finished'),
                    value: _hideFinished,
                    onChanged: (value) {
                      setState(() {
                        _hideFinished = value;
                      });
                    },
                    activeColor: primaryColor,
                  ),
                  const SizedBox(height: largePadding),
                  CustomButton(
                    text: 'Apply Filters',
                    onPressed: _saveFilters,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: defaultPadding),
                  Center(
                    child: TextButton(
                      onPressed: _resetFilters,
                      child: const Text('Reset to Default'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/book_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/reading_insights_widget.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _selectedGenres = [];
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isAuthenticated && userProvider.currentUser != null) {
      _nameController.text = userProvider.currentUser!.displayName;
      
      if (userProvider.currentUser!.preferredGenres != null) {
        setState(() {
          _selectedGenres = List.from(userProvider.currentUser!.preferredGenres);
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _savePreferences() async {
    if (!_isEditing) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.isAuthenticated && userProvider.currentUser != null) {
      final updatedUser = userProvider.currentUser!.copyWith(
        displayName: _nameController.text.trim(),
        preferredGenres: _selectedGenres,
      );
      
      await userProvider.updateUserProfile(updatedUser);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      
      setState(() {
        _isEditing = false;
      });
      
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      final readBookIds = userProvider.finishedList.map((item) => item.bookId).toList();
      bookProvider.fetchRecommendedBooks(_selectedGenres, readBookIds, userProvider.currentUser!.id);
    }
  }

  Widget _buildPreferencesTab(UserProvider userProvider) {
    if (userProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (userProvider.currentUser == null) {
      return const Center(
        child: Text('User data not available'),
      );
    }
    
    final user = userProvider.currentUser!;
    
    final String displayInitial = user.displayName.isNotEmpty 
        ? user.displayName.substring(0, 1).toUpperCase() 
        : '?';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor,
                  child: Text(
                    displayInitial,
                    style: const TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: smallPadding),
                _isEditing 
                ? TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    user.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: largePadding),
          const Text(
            'Preferred Genres',
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
                onSelected: _isEditing
                    ? (selected) {
                        setState(() {
                          if (selected) {
                            _selectedGenres.add(genre);
                          } else {
                            _selectedGenres.remove(genre);
                          }
                        });
                      }
                    : null,
                backgroundColor: Colors.grey[200],
                selectedColor: primaryColor.withOpacity(0.2),
                checkmarkColor: primaryColor,
              );
            }).toList(),
          ),
          const SizedBox(height: largePadding),
          CustomButton(
            text: 'Sign Out',
            onPressed: () async {
              await userProvider.signOut();
              Navigator.pushReplacementNamed(context, Routes.home);
            },
            isOutlined: true,
            color: Colors.red,
            icon: Icons.exit_to_app,
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityTab() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Appearance',
                style: subheadingStyle,
              ),
              const SizedBox(height: smallPadding),
              ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    themeProvider.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                  activeColor: primaryColor,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: defaultPadding),
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    themeProvider.resetToDefaults();
                  },
                  child: const Text('Reset to Defaults'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final isAuthenticated = userProvider.isAuthenticated;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              if (isAuthenticated && _tabController.index == 0 && !_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
              if (isAuthenticated && _tabController.index == 0 && _isEditing)
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _savePreferences,
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Preferences'),
                Tab(text: 'Reading Insights'),
                Tab(text: 'Accessibility'),
              ],
            ),
          ),
          body: !isAuthenticated
              ? _buildNotAuthenticatedView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPreferencesTab(userProvider),
                    const ReadingInsightsWidget(),
                    _buildAccessibilityTab(),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildNotAuthenticatedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Please log in to view your profile',
            style: subheadingStyle,
          ),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.login);
            },
            child: const Text('Log In'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.register);
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
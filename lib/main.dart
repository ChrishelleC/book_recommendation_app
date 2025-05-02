import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/routes.dart';
import 'providers/book_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/discussion_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DiscussionProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Book Recommendation App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: Routes.home,
            routes: Routes.routes,
          );
        },
      ),
    );
  }
}
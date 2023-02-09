import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey)
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  WordPair current = WordPair.random();
  List<WordPair> favorites = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = const Favorites();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  selectedIndex: selectedIndex,
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: Icon(Icons.home_filled),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites')
                    ),
                  ],
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                )
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                )
              ),
            ],
          ),
          
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    WordPair pair = appState.current;
    bool isFavorite = appState.favorites.contains(pair);
    String favoriteLabel = 'Like';
    IconData favoriteIcon = Icons.favorite;

    if (isFavorite) {
      favoriteLabel = 'Unlike';
      favoriteIcon = Icons.heart_broken;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BigCard(pair: pair),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: Icon(favoriteIcon),
                  label: Text(favoriteLabel)
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: const Text('Next')
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    List<WordPair> favorites = appState.favorites;

    if (favorites.isEmpty) {
      return const Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: false,
      children: <ListTile>[
        ListTile(
          leading: const Icon(
            Icons.favorite,
            color: Colors.red,
          ),
          title: Text(
            'You have ${favorites.length} favorites.',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16
            ),
          ),
        ),
        for (var favorite in favorites)
          ListTile(
            title: Text(favorite.asLowerCase),
          )
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle textStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26.0, 15.0, 26.0, 20.0),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: MergeSemantics(
            child: Wrap(
              children: <Text>[
                Text(
                  pair.first,
                  style: textStyle.copyWith(
                    fontWeight: FontWeight.w200
                  ),
                  semanticsLabel: pair.asPascalCase,
                ),
                Text(
                  pair.second,
                  style: textStyle.copyWith(
                    fontWeight: FontWeight.w700
                  ),
                  semanticsLabel: pair.asPascalCase,
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}
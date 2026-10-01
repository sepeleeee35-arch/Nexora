import 'package:flutter/material.dart';

void main() => runApp(const NexoraApp());

class NexoraApp extends StatelessWidget {
  const NexoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0D14),
        useMaterial3: true,
      ),
      home: const NexoraHome(),
    );
  }
}

class NexoraHome extends StatefulWidget {
  const NexoraHome({super.key});
  @override
  State<NexoraHome> createState() => _NexoraHomeState();
}

class _NexoraHomeState extends State<NexoraHome> {
  int index = 0;
  static const pageNames = ['Home', 'Games', 'Music', 'Social', 'Market'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nexora • ${pageNames[index]}'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _Page(index: index, key: ValueKey(index)),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Games',
          ),
          NavigationDestination(
            icon: Icon(Icons.music_note_outlined),
            selectedIcon: Icon(Icons.music_note),
            label: 'Music',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Social',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Market',
          ),
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  final int index;
  const _Page({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    if (index == 0) return const _Home();
    const data = [
      (
        'Games',
        'Mini games, online rooms, and leaderboards.',
        Icons.sports_esports_rounded
      ),
      ('Music', 'Library, playlists, and player.', Icons.music_note_rounded),
      (
        'Social',
        'Profiles, feed, chat, and notifications.',
        Icons.people_alt_rounded
      ),
      (
        'Marketplace',
        'Products, cart, orders, and wallet.',
        Icons.storefront_rounded
      ),
    ];
    final item = data[index - 1];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.$3,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              item.$1,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              item.$2,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: () {}, child: const Text('Open')),
          ],
        ),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Welcome to Nexora',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Your games, music, social space, and marketplace in one app.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        const _Card(
          icon: Icons.sports_esports_rounded,
          title: 'Mini Games',
          subtitle: 'Play offline or join online rooms.',
        ),
        const _Card(
          icon: Icons.music_note_rounded,
          title: 'Music',
          subtitle: 'Manage your library and playlists.',
        ),
        const _Card(
          icon: Icons.people_alt_rounded,
          title: 'Social',
          subtitle: 'Profile, feed, and chat.',
        ),
        const _Card(
          icon: Icons.storefront_rounded,
          title: 'Marketplace',
          subtitle: 'Browse products and manage orders.',
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Card({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    );
  }
}

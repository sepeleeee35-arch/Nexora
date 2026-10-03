// Nexora production redeploy: game start/level/audio verification
// ignore_for_file: unused_element, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_interpolation_to_compose_strings, camel_case_types
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'google_auth_button.dart' if (dart.library.io) 'google_auth_button_stub.dart';
import 'music/music_page.dart';
import 'games/game_hub.dart';
import 'music/music_service.dart';
import 'tools/nexora_tools_page.dart';

void main() => runApp(const NexoraApp());

class NexoraApp extends StatelessWidget {
  const NexoraApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Nexora',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF080A10),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B5CF6), brightness: Brightness.dark),
      cardTheme: CardThemeData(
        color: const Color(0xFF111522),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    home: const NexoraAuthGate(),
  );
}

class NexoraAuthGate extends StatefulWidget {
  const NexoraAuthGate({super.key});
  @override State<NexoraAuthGate> createState() => _NexoraAuthGateState();
}

class _NexoraAuthGateState extends State<NexoraAuthGate> {
  final GoogleSignIn _google = GoogleSignIn.instance;
  GoogleSignInAccount? _user;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSub;
  bool _initializing = true;
  bool _busy = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _initializeGoogle();
  }

  Future<void> _initializeGoogle() async {
    try {
      await _google.initialize(
        clientId: const String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: ''),
        serverClientId: const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID', defaultValue: ''),
      );
      _authSub = _google.authenticationEvents.listen(
        (event) {
          if (!mounted) return;
          if (event is GoogleSignInAuthenticationEventSignIn) {
            setState(() {
              _user = event.user;
              _error = '';
            });
            nexoraActiveAccountId = event.user.id;
          } else if (event is GoogleSignInAuthenticationEventSignOut) {
            setState(() => _user = null);
            nexoraActiveAccountId = null;
          }
        },
        onError: (Object error) {
          if (mounted) setState(() => _error = 'Google login: $error');
        },
      );
      final existing = await _google.attemptLightweightAuthentication();
      if (!mounted) return;
      if (existing != null) {
        _user = existing;
        nexoraActiveAccountId = existing.id;
      }
    } catch (e) {
      if (mounted) _error = 'Google Sign-In belum terkonfigurasi: $e';
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _signIn() async {
    if (!_google.supportsAuthenticate()) return;
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final account = await _google.authenticate();
      if (!mounted) return;
      setState(() => _user = account);
      nexoraActiveAccountId = account.id;
    } on GoogleSignInException catch (e) {
      if (mounted) setState(() => _error = 'Google login: ${e.description ?? e.code.name}');
    } catch (e) {
      if (mounted) setState(() => _error = 'Google login gagal: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hexagon_rounded, size: 64),
              SizedBox(height: 16),
              Text('NEXORA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              SizedBox(height: 12),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }
    if (_user != null) return NexoraShell(account: _user!);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 78, height: 78,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF4F46E5)]),
                        ),
                        child: const Icon(Icons.hexagon_rounded, size: 48),
                      ),
                      const SizedBox(height: 18),
                      const Text('Nexora', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 7),
                      const Text(
                        'Login dengan akun Google untuk masuk ke Nexora dan menyimpan progres game berdasarkan akun.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, height: 1.4),
                      ),
                      const SizedBox(height: 22),
                      if (_google.supportsAuthenticate())
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _busy ? null : _signIn,
                            icon: const Icon(Icons.login_rounded),
                            label: Text(_busy ? 'Menghubungkan...' : 'Login dengan Google'),
                          ),
                        )
                      else
                        nexoraGoogleButton(),
                      if (_error.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(_error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                      ],
                      const SizedBox(height: 18),
                      const Text(
                        'Tanpa login, halaman utama tidak bisa dibuka.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NexoraShell extends StatefulWidget {
  final GoogleSignInAccount account;
  const NexoraShell({required this.account, super.key});
  @override State<NexoraShell> createState() => _NexoraShellState();
}

class _NexoraShellState extends State<NexoraShell> {
  int tab = 0;
  String? page;
  int coins = 1250;
  int cart = 0;
  int wallpaper = 0;
  String customName = '';
  Uint8List? customAvatar;
  Uint8List? customBackground;
  Uint8List? customProfileWallpaper;
  Color themeBackground = const Color(0xFF080A10);
  Color themePrimary = const Color(0xFF8B5CF6);
  Color themeSurface = const Color(0xFF111522);
  Color themeBorder = const Color(0xFF334155);
  Color themeText = const Color(0xFFF8FAFC);
  double cardOpacity = 1.0;
  double cardBorderWidth = 0.0;
  double cardBorderOpacity = 0.0;
  static const names = ['Home','Games','Music','Tools','Market'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  String get _prefPrefix => 'nexora_' + widget.account.id + '_';

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final avatar = prefs.getString(_prefPrefix + 'avatar');
    final background = prefs.getString(_prefPrefix + 'background');
    final profileWallpaper = prefs.getString(_prefPrefix + 'profileWallpaper');
    if (!mounted) return;
    setState(() {
      customName = prefs.getString(_prefPrefix + 'name') ?? '';
      customAvatar = avatar == null ? null : base64Decode(avatar);
      customBackground = background == null ? null : base64Decode(background);
      customProfileWallpaper = profileWallpaper == null ? null : base64Decode(profileWallpaper);
      wallpaper = prefs.getInt(_prefPrefix + 'wallpaper') ?? 0;
      themeBackground = Color(prefs.getInt(_prefPrefix + 'themeBg') ?? 0xFF080A10);
      themePrimary = Color(prefs.getInt(_prefPrefix + 'themePrimary') ?? 0xFF8B5CF6);
      themeSurface = Color(prefs.getInt(_prefPrefix + 'themeSurface') ?? 0xFF111522);
      themeBorder = Color(prefs.getInt(_prefPrefix + 'themeBorder') ?? 0xFF334155);
      themeText = Color(prefs.getInt(_prefPrefix + 'themeText') ?? 0xFFF8FAFC);
      cardOpacity = prefs.getDouble(_prefPrefix + 'cardOpacity') ?? 1.0;
      cardBorderWidth = prefs.getDouble(_prefPrefix + 'cardBorderWidth') ?? 0.0;
      cardBorderOpacity = prefs.getDouble(_prefPrefix + 'cardBorderOpacity') ?? 0.0;
    });
  }

  Future<void> _saveBytes(String key, Uint8List? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) { await prefs.remove(_prefPrefix + key); }
    else { await prefs.setString(_prefPrefix + key, base64Encode(value)); }
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefPrefix + key, value);
  }

  Future<void> _saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefPrefix + key, value);
  }

  void _setName(String value) {
    setState(() => customName = value.trim());
    unawaited(SharedPreferences.getInstance().then((p) => p.setString(_prefPrefix + 'name', customName)));
  }

  void _setAvatar(Uint8List? value) {
    setState(() => customAvatar = value);
    unawaited(_saveBytes('avatar', value));
  }

  void _setBackground(Uint8List? value) {
    setState(() => customBackground = value);
    unawaited(_saveBytes('background', value));
  }

  void _setProfileWallpaper(Uint8List? value) {
    setState(() => customProfileWallpaper = value);
    unawaited(_saveBytes('profileWallpaper', value));
  }

  void _setWallpaper(int value) {
    setState(() => wallpaper = value);
    unawaited(_saveInt('wallpaper', value));
  }

  void _setColor(String key, Color value) {
    setState(() {
      if (key == 'bg') themeBackground = value;
      if (key == 'primary') themePrimary = value;
      if (key == 'surface') themeSurface = value;
      if (key == 'border') themeBorder = value;
      if (key == 'text') themeText = value;
    });
    unawaited(_saveInt('theme' + key[0].toUpperCase() + key.substring(1), value.value));
  }

  void _setVisual(String key, double value) {
    setState(() {
      if (key == 'cardOpacity') cardOpacity = value;
      if (key == 'cardBorderWidth') cardBorderWidth = value;
      if (key == 'cardBorderOpacity') cardBorderOpacity = value;
    });
    unawaited(_saveDouble(key, value));
  }

  void _resetTheme() {
    setState(() {
      themeBackground = const Color(0xFF080A10);
      themePrimary = const Color(0xFF8B5CF6);
      themeSurface = const Color(0xFF111522);
      themeBorder = const Color(0xFF334155);
      themeText = const Color(0xFFF8FAFC);
      cardOpacity = 1.0;
      cardBorderWidth = 0.0;
      cardBorderOpacity = 0.0;
      customBackground = null;
    });
    unawaited(SharedPreferences.getInstance().then((p) async {
      await p.remove(_prefPrefix + 'background');
      await p.setInt(_prefPrefix + 'themeBg', themeBackground.value);
      await p.setInt(_prefPrefix + 'themePrimary', themePrimary.value);
      await p.setInt(_prefPrefix + 'themeSurface', themeSurface.value);
      await p.setInt(_prefPrefix + 'themeBorder', themeBorder.value);
      await p.setInt(_prefPrefix + 'themeText', themeText.value);
      await p.setDouble(_prefPrefix + 'cardOpacity', cardOpacity);
      await p.setDouble(_prefPrefix + 'cardBorderWidth', cardBorderWidth);
      await p.setDouble(_prefPrefix + 'cardBorderOpacity', cardBorderOpacity);
    }));
  }

  void selectPage(String value) {
    Navigator.pop(context);
    if (value == 'Logout') {
      unawaited(GoogleSignIn.instance.signOut());
      return;
    }
    if (value == 'Home' || value == 'Games' || value == 'Music' || value == 'Tools' || value == 'Market') {
      final nextTab = names.indexOf(value);
      setState(() {
        tab = nextTab < 0 ? 0 : nextTab;
        page = null;
      });
    } else {
      setState(() => page = value);
    }
  }
  void selectTab(int value) => setState(() { tab = value; page = null; });

  @override
  Widget build(BuildContext context) {
    final title = page ?? names[tab];
    Widget body;
    if (page == 'Wallet') {
      body = WalletPage(coins: coins, addCoins: () => setState(() => coins += 250));
    } else if (page == 'Profile') {
      body = ProfilePage(user: widget.account);
    } else if (page == 'Login') {
      body = const GoogleLoginPage();
    } else if (page == 'Notifications') {
      body = const NotificationsPage();
    } else if (page == 'Settings') {
      body = SettingsPage(
        account: widget.account,
        customName: _displayName,
        customAvatar: customAvatar,
        wallpaper: wallpaper,
        background: themeBackground,
        primary: themePrimary,
        surface: themeSurface,
        border: themeBorder,
        text: themeText,
        cardOpacity: cardOpacity,
        cardBorderWidth: cardBorderWidth,
        cardBorderOpacity: cardBorderOpacity,
        customBackground: customBackground,
        customProfileWallpaper: customProfileWallpaper,
        onNameChanged: _setName,
        onAvatarChanged: _setAvatar,
        onWallpaperChanged: _setWallpaper,
        onBackgroundChanged: _setBackground,
        onProfileWallpaperChanged: _setProfileWallpaper,
        onColorChanged: _setColor,
        onVisualChanged: _setVisual,
        onResetTheme: _resetTheme,
      );
    } else if (page == 'About') {
      body = const AboutPage();
    } else {
      body = switch (tab) {
        1 => const NexoraGameHub(),
        2 => const MusicPage(),
        3 => const NexoraToolsPage(),
        4 => MarketPage(coins: coins, cart: cart, buy: null),
        _ => HomePage(
          account: widget.account,
          displayName: _displayName,
          customAvatar: customAvatar,
          customProfileWallpaper: customProfileWallpaper,
          coins: coins,
          wallpaper: wallpaper,
          openTab: selectTab,
          openPage: (v) => setState(() => page = v),
        ),
      };
      if (tab == 4) {
        body = MarketPage(
          coins: coins,
          cart: cart,
          buy: (price) {
            if (coins < price) { return; }
            setState(() { coins -= price; cart++; });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item masuk ke pesanan demo.')),
            );
          },
        );
      }
    }

    final appTheme = Theme.of(context).copyWith(
      scaffoldBackgroundColor: themeBackground,
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: themePrimary,
        surface: themeSurface,
        outline: themeBorder,
        onSurface: themeText,
      ),
      textTheme: Theme.of(context).textTheme.apply(bodyColor: themeText, displayColor: themeText),
      cardTheme: CardThemeData(
        color: themeSurface.withValues(alpha: cardOpacity),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: themeBorder.withValues(alpha: cardBorderOpacity),
            width: cardBorderWidth,
          ),
        ),
      ),
    );
    return Theme(
      data: appTheme,
      child: Scaffold(
      drawer: NexoraDrawer(
        coins: coins,
        account: widget.account,
        displayName: _displayName,
        customAvatar: customAvatar,
        onSelect: selectPage,
      ),
      appBar: AppBar(
        titleSpacing: 18,
        title: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              gradient: const LinearGradient(colors: [Color(0xFF8B5CF6),Color(0xFF4F46E5)]),
            ),
            child: const Icon(Icons.hexagon_rounded, size: 21),
          ),
          const SizedBox(width: 10),
          Text('Nexora • $title', style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(onPressed: () => setState(() => page = 'Wallet'), icon: const Icon(Icons.monetization_on_outlined)),
          IconButton(onPressed: () => setState(() => page = 'Notifications'), icon: const Icon(Icons.notifications_none_rounded)),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: themeBackground,
          image: customBackground == null ? null : DecorationImage(image: MemoryImage(customBackground!), fit: BoxFit.cover),
        ),
        child: AnimatedSwitcher(duration: const Duration(milliseconds: 180), child: KeyedSubtree(key: ValueKey(page ?? tab), child: body)),
      ),
      bottomNavigationBar: page == null ? NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: selectTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.sports_esports_outlined), selectedIcon: Icon(Icons.sports_esports_rounded), label: 'Games'),
          NavigationDestination(icon: Icon(Icons.music_note_outlined), selectedIcon: Icon(Icons.music_note_rounded), label: 'Music'),
          NavigationDestination(icon: Icon(Icons.build_outlined), selectedIcon: Icon(Icons.build_rounded), label: 'Tools'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront_rounded), label: 'Market'),
        ],
      ) : null,
    ),
    );
  }
  String get _displayName {
    final custom = customName.trim();
    if (custom.isNotEmpty) return custom;
    final google = widget.account.displayName?.trim();
    if (google != null && google.isNotEmpty) return google;
    return widget.account.email.split('@').first;
  }
}

class NexoraDrawer extends StatelessWidget {
  final int coins;
  final GoogleSignInAccount account;
  final String displayName;
  final Uint8List? customAvatar;
  final ValueChanged<String> onSelect;
  const NexoraDrawer({
    required this.coins,
    required this.account,
    required this.displayName,
    required this.customAvatar,
    required this.onSelect,
    super.key,
  });
  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: const Color(0xFF0C0F18),
    child: SafeArea(child: ListView(padding: const EdgeInsets.symmetric(vertical: 12), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20,10,20,18),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(17), gradient: const LinearGradient(colors: [Color(0xFF8B5CF6),Color(0xFF4F46E5)])),
            child: const Icon(Icons.hexagon_rounded, size: 31),
          ),
          const SizedBox(width: 13),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('NEXORA', style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900,letterSpacing: 1.5)),
            Text('Game • Music • Tools • Market'),
          ]),
        ]),
      ),
      Card(child: ListTile(
        leading: NexoraAvatar(account: account, customAvatar: customAvatar, radius: 24),
        title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(account.email),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => onSelect('Settings'),
      )),
      const _Header('MAIN'),
      _Item(Icons.home_rounded,'Home',()=>onSelect('Home')),
      _Item(Icons.sports_esports_rounded,'Games',()=>onSelect('Games')),
      _Item(Icons.music_note_rounded,'Music',()=>onSelect('Music')),
      _Item(Icons.build_rounded,'Tools',()=>onSelect('Tools')),
      _Item(Icons.storefront_rounded,'Marketplace',()=>onSelect('Market')),
      const _Header('ACCOUNT'),
      _Item(Icons.account_balance_wallet_rounded,'Wallet & Coins',()=>onSelect('Wallet')),
      _Item(Icons.person_rounded,'Profile',()=>onSelect('Profile')),
      _Item(Icons.verified_rounded,'Google Account',()=>onSelect('Profile')),
      _Item(Icons.logout_rounded,'Logout',()=>onSelect('Logout')),
      _Item(Icons.notifications_rounded,'Notifications',()=>onSelect('Notifications')),
      const _Header('APP'),
      _Item(Icons.settings_rounded,'Settings',()=>onSelect('Settings')),
      _Item(Icons.info_rounded,'About Nexora',()=>onSelect('About')),
    ])),
  );
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20,18,20,7),
    child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.primary,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1.4)),
  );
}
class _Item extends StatelessWidget {
  final IconData icon; final String text; final VoidCallback tap;
  const _Item(this.icon,this.text,this.tap);
  @override Widget build(BuildContext context) => ListTile(
    leading: Icon(icon), title: Text(text), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), onTap: tap,
  );
}

class _H extends StatelessWidget {
  final String label;
  final String value;

  const _H(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF151827),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _Score extends StatelessWidget {
  final String label;
  final String value;

  const _Score(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF171B2A),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white60,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final GoogleSignInAccount account;
  final int coins;
  final int wallpaper;
  final String displayName;
  final Uint8List? customAvatar;
  final Uint8List? customProfileWallpaper;
  final ValueChanged<int> openTab;
  final ValueChanged<String> openPage;

  const HomePage({
    required this.account,
    required this.coins,
    required this.wallpaper,
    required this.displayName,
    required this.customAvatar,
    required this.customProfileWallpaper,
    required this.openTab,
    required this.openPage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = _nexoraWallpaperGradient(wallpaper);

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            height: 265,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: customProfileWallpaper == null ? gradient : null,
                image: customProfileWallpaper == null ? null : DecorationImage(
                  image: MemoryImage(customProfileWallpaper!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(.20), BlendMode.darken),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.28),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -45,
                    top: -55,
                    child: _GlowOrb(size: 180, color: Colors.white.withOpacity(.13)),
                  ),
                  Positioned(
                    left: -55,
                    bottom: -85,
                    child: _GlowOrb(size: 190, color: Colors.white.withOpacity(.08)),
                  ),
                  Positioned(
                    right: 18,
                    bottom: 18,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 86,
                      color: Colors.white.withOpacity(.07),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => openPage('Settings'),
                              child: NexoraAvatar(account: account, customAvatar: customAvatar, radius: 29),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => openPage('Settings'),
                                behavior: HitTestBehavior.opaque,
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'SELAMAT DATANG KEMBALI',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withOpacity(.12)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                                  SizedBox(width: 5),
                                  Text(
                                    'ONLINE',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 17),
                        Row(
                          children: [
                            Expanded(
                              child: _ProfileMiniStat(
                                icon: Icons.monetization_on_rounded,
                                label: 'COINS',
                                value: _compactNumber(coins),
                              ),
                            ),
                            const SizedBox(width: 9),
                            const Expanded(
                              child: _ProfileMiniStat(
                                icon: Icons.bolt_rounded,
                                label: 'LEVEL',
                                value: '1',
                              ),
                            ),
                            const SizedBox(width: 9),
                            const Expanded(
                              child: _ProfileMiniStat(
                                icon: Icons.local_fire_department_rounded,
                                label: 'STREAK',
                                value: '0 HARI',
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 22),
        const _Title('Quick Access'),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.55,
          children: [
            _Quick(Icons.sports_esports_rounded, 'Game Hub', 'Play now', () => openTab(1)),
            _Quick(Icons.music_note_rounded, 'Music', 'Library', () => openTab(2)),
            _Quick(Icons.build_rounded, 'Tools', 'Utilities', () => openTab(3)),
            _Quick(Icons.storefront_rounded, 'Market', 'Browse', () => openTab(4)),
          ],
        ),
        const SizedBox(height: 22),
        const _Title('Featured'),
        const SizedBox(height: 10),
        Container(
          height: 150,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF162A45), Color(0xFF321B52)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NEXORA ARCADE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
              const SizedBox(height: 5),
              const Text('Tap Rush', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
              const Text('Kejar skor tertinggi dalam waktu terbatas.'),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReactionRushPage()),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Play'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _Title('Your Account', 'Profile', () => openPage('Profile')),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: NexoraAvatar(account: account, customAvatar: customAvatar, radius: 22),
                title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(account.email + ' • Google Account'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => openPage('Settings'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet_rounded),
                title: const Text('Wallet'),
                subtitle: Text('$coins coins tersedia'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => openPage('Wallet'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _Title('Recent'),
        const _Recent(Icons.sports_esports_rounded, 'Tap Rush', 'Mini game tersedia sekarang'),
        const _Recent(Icons.music_note_rounded, 'Nexora Music', 'Player dan library'),
        const _Recent(Icons.build_rounded, 'Nexora Tools', 'Media & utility tools'),
      ],
    );
  }
}

class NexoraGoogleAvatar extends StatelessWidget {
  final GoogleSignInAccount account;
  final double radius;

  const NexoraGoogleAvatar({
    required this.account,
    required this.radius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final photo = account.photoUrl;
    if (photo != null && photo.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photo),
      );
    }
    return CircleAvatar(
      radius: radius,
      child: Icon(Icons.person_rounded, size: radius),
    );
  }
}

class NexoraAvatar extends StatelessWidget {
  final GoogleSignInAccount account;
  final Uint8List? customAvatar;
  final double radius;
  const NexoraAvatar({required this.account, required this.customAvatar, required this.radius, super.key});
  @override
  Widget build(BuildContext context) {
    if (customAvatar != null) return CircleAvatar(radius: radius, backgroundImage: MemoryImage(customAvatar!));
    final photo = account.photoUrl;
    if (photo != null && photo.isNotEmpty) return CircleAvatar(radius: radius, backgroundImage: NetworkImage(photo));
    return CircleAvatar(radius: radius, child: Icon(Icons.person_rounded, size: radius));
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
    ),
  );
}

class _ProfileMiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileMiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(.18),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: Colors.white.withOpacity(.10)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: Colors.white70),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white60),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );
}

const List<List<Color>> _nexoraWallpapers = [
  [Color(0xFF075985), Color(0xFF1D4ED8), Color(0xFF312E81)],
  [Color(0xFF581C87), Color(0xFF7C3AED), Color(0xFF1E1B4B)],
  [Color(0xFF064E3B), Color(0xFF0F766E), Color(0xFF164E63)],
  [Color(0xFF7C2D12), Color(0xFFB45309), Color(0xFF431407)],
];

LinearGradient _nexoraWallpaperGradient(int index) {
  final colors = _nexoraWallpapers[index % _nexoraWallpapers.length];
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: colors,
  );
}

String _compactNumber(int value) {
  if (value >= 1000000) return (value / 1000000).toStringAsFixed(1) + 'M';
  if (value >= 1000) return (value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1) + 'K';
  return value.toString();
}

class _Title extends StatelessWidget {
  final String text; final String action; final VoidCallback? tap;
  const _Title(this.text,[this.action='',this.tap]);
  @override Widget build(BuildContext context)=>Row(children:[
    Expanded(child:Text(text,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900))),
    if(action.isNotEmpty) TextButton(onPressed:tap,child:Text(action)),
  ]);
}
class _Stat extends StatelessWidget {
  final IconData icon; final String label,value;
  const _Stat(this.icon,this.label,this.value);
  @override Widget build(BuildContext context)=>Container(
    padding:const EdgeInsets.all(13),
    decoration:BoxDecoration(color:Colors.white.withValues(alpha:.07),borderRadius:BorderRadius.circular(15)),
    child:Row(children:[Icon(icon,size:20),const SizedBox(width:8),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontSize:11)),Text(value,style:const TextStyle(fontWeight:FontWeight.w800))])]),
  );
}
class _Quick extends StatelessWidget {
  final IconData icon; final String title,sub; final VoidCallback tap;
  const _Quick(this.icon,this.title,this.sub,this.tap);
  @override Widget build(BuildContext context)=>Card(child:InkWell(
    onTap:tap,borderRadius:BorderRadius.circular(18),
    child:Padding(padding:const EdgeInsets.all(13),child:Row(children:[
      CircleAvatar(child:Icon(icon)),const SizedBox(width:10),
      Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(title,style:const TextStyle(fontWeight:FontWeight.w800)),Text(sub,style:Theme.of(context).textTheme.bodySmall)
      ]))
    ])),
  ));
}
class _Recent extends StatelessWidget {
  final IconData icon; final String title,sub;
  const _Recent(this.icon,this.title,this.sub);
  @override Widget build(BuildContext context)=>Card(child:ListTile(leading:CircleAvatar(child:Icon(icon)),title:Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(sub),trailing:const Icon(Icons.chevron_right_rounded)));
}



class MusicPage extends StatelessWidget {
  const MusicPage({super.key});
  @override
  Widget build(BuildContext context) => NexoraMusicPage(
    service: NexoraMultiMusicService(),
  );
}

class ReactionRushPage extends StatefulWidget {
  const ReactionRushPage({super.key});
  @override
  State<ReactionRushPage> createState() => _ReactionState();
}

class _ReactionState extends State<ReactionRushPage> {
  final rng = Random();
  Timer? timer;
  bool waiting = false;
  bool ready = false;
  int score = 0;
  String text = 'Tekan START';

  void start() {
    timer?.cancel();
    setState(() {
      waiting = true;
      ready = false;
      text = 'Tunggu...';
    });
    timer = Timer(
      Duration(milliseconds: 700 + rng.nextInt(1800)),
      () {
        if (!mounted) return;
        setState(() {
          waiting = false;
          ready = true;
          text = 'TAP!';
        });
      },
    );
  }

  void tap() {
    if (waiting) {
      timer?.cancel();
      setState(() {
        waiting = false;
        ready = false;
        text = 'Terlalu cepat!';
      });
    } else if (ready) {
      setState(() {
        score++;
        ready = false;
        text = 'Bagus!';
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reaction Rush')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _Score('Score', '$score')),
                const SizedBox(width: 10),
                const Expanded(child: _Score('Mode', 'Reflex')),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: tap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ready
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                    child: Center(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: start,
                child: const Text('START'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorClashPage extends StatefulWidget {
  const ColorClashPage({super.key});
  @override
  State<ColorClashPage> createState() => _ColorClashState();
}

class _ColorClashState extends State<ColorClashPage> {
  final rng = Random();
  int score = 0;
  int target = 0;
  final colors = <Color>[
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    target = rng.nextInt(colors.length);
  }

  void next() {
    setState(() {
      target = rng.nextInt(colors.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Color Clash')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _Score('Score', '$score'),
            const SizedBox(height: 22),
            Text(
              'Pilih warna target',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[target],
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  for (int i = 0; i < colors.length; i++)
                    FilledButton(
                      onPressed: () {
                        if (i == target) {
                          setState(() => score++);
                        }
                        next();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colors[i],
                      ),
                      child: const SizedBox(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NumberSprintPage extends StatefulWidget {
  const NumberSprintPage({super.key});
  @override
  State<NumberSprintPage> createState() => _NumberSprintState();
}

class _NumberSprintState extends State<NumberSprintPage> {
  final rng = Random();
  int a = 2;
  int b = 3;
  int answer = 5;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _nextQuestion();
  }

  void _nextQuestion() {
    a = 1 + rng.nextInt(9);
    b = 1 + rng.nextInt(9);
    answer = a + b;
  }

  @override
  Widget build(BuildContext context) {
    final opts = [answer, answer + 1, answer - 1, answer + 2]..shuffle(rng);
    return Scaffold(
      appBar: AppBar(title: const Text('Number Sprint')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _Score('Score', '$score'),
            const SizedBox(height: 30),
            Text(
              '$a + $b = ?',
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 25),
            for (final o in opts)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (o == answer) {
                        score++;
                      }
                      setState(_nextQuestion);
                    },
                    child: Text(
                      '$o',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DodgeZonePage extends StatefulWidget {
  const DodgeZonePage({super.key});
  @override
  State<DodgeZonePage> createState() => _DodgeState();
}

class _DodgeState extends State<DodgeZonePage> {
  double x = .5;
  int score = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(milliseconds: 700),
      (_) {
        if (mounted) {
          setState(() => score++);
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dodge Zone')),
      body: Column(
        children: [
          _Score('Survival', '$score'),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final playerLeft = (constraints.maxWidth - 56) * x;
                return GestureDetector(
                  onHorizontalDragUpdate: (d) {
                    setState(() {
                      x = (x + d.delta.dx / constraints.maxWidth)
                          .clamp(.08, .92);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0xFF111522),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 20,
                          left: playerLeft,
                          child: const CircleAvatar(
                            radius: 28,
                            child: Icon(Icons.shield_rounded),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Geser kiri/kanan untuk bertahan',
                            textAlign: TextAlign.center,
                          ),
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
    );
  }
}

class ToolsPage extends StatefulWidget{const ToolsPage({super.key});@override State<ToolsPage> createState()=>_ToolsState();}
class _ToolsState extends State<ToolsPage>{
  String input='',output='';
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.fromLTRB(16,16,16,110),children:[
    const Text('Nexora Tools',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900)),const SizedBox(height:4),const Text('Utility cepat untuk HP.'),const SizedBox(height:18),
    _ToolCard(icon:Icons.text_fields_rounded,title:'Text Studio',subtitle:'Rapikan teks atau ubah huruf.',child:Column(children:[
      TextField(onChanged:(v)=>setState(()=>input=v),maxLines:4,decoration:const InputDecoration(hintText:'Tulis atau tempel teks...',filled:true)),const SizedBox(height:10),
      Row(children:[Expanded(child:FilledButton(onPressed:()=>setState(()=>output=input.toUpperCase()),child:const Text('UPPERCASE'))),const SizedBox(width:8),Expanded(child:OutlinedButton(onPressed:()=>setState(()=>output=input.replaceAll(RegExp(r'\s+'),' ').trim()),child:const Text('RAPIKAN')))]),
      if(output.isNotEmpty)Padding(padding:const EdgeInsets.only(top:12),child:SelectableText(output)),
      if(input.isNotEmpty)Align(alignment:Alignment.centerLeft,child:Text('${input.length} karakter')),
    ])),
    _ToolCard(icon:Icons.music_note_rounded,title:'Audio Lab',subtitle:'Status player audio Nexora.',child:const Text('Player musik sudah mendukung play, pause, seek, next, dan previous.')),
    _ToolCard(icon:Icons.video_file_rounded,title:'Video → Audio',subtitle:'Ekstrak audio dari video milikmu.',child:const Text('Engine konversi native FFmpeg akan dipasang pada APK; versi web tidak mengirim file pribadimu ke server. Gunakan hanya file yang kamu punya hak untuk ubah.')),
    _ToolCard(icon:Icons.calculate_rounded,title:'Quick Calculator',subtitle:'Hitung dua angka.',child:const _QuickCalc()),
  ]);
}
class _ToolCard extends StatelessWidget{final IconData icon;final String title,subtitle;final Widget child;const _ToolCard({required this.icon,required this.title,required this.subtitle,required this.child});@override Widget build(BuildContext context)=>Card(margin:const EdgeInsets.only(bottom:14),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[CircleAvatar(child:Icon(icon)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),Text(subtitle,style:Theme.of(context).textTheme.bodySmall)]))]),const SizedBox(height:14),child])));}
class _QuickCalc extends StatefulWidget{const _QuickCalc();@override State<_QuickCalc> createState()=>_QuickCalcState();}
class _QuickCalcState extends State<_QuickCalc>{final a=TextEditingController(),b=TextEditingController();String result='—';@override void dispose(){a.dispose();b.dispose();super.dispose();}@override Widget build(BuildContext context)=>Row(children:[Expanded(child:TextField(controller:a,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'A'))),const Padding(padding:EdgeInsets.symmetric(horizontal:8),child:Text('+',style:TextStyle(fontSize:22))),Expanded(child:TextField(controller:b,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'B'))),IconButton(onPressed:(){final x=double.tryParse(a.text)??0;final y=double.tryParse(b.text)??0;setState(()=>result=(x+y).toString());},icon:const Icon(Icons.calculate_rounded)),Text(result,style:const TextStyle(fontWeight:FontWeight.w900))]);}
class SocialPage extends StatefulWidget {
  const SocialPage({super.key});
  @override State<SocialPage> createState()=>_SocialState();
}
class _SocialState extends State<SocialPage>{
  final liked=<int>{};
  final posts=const [('Nexora Team','Selamat datang di Nexora V2!','Update'),('Raka','Baru selesai main Tap Rush. Ada yang mau adu skor?','Gaming'),('Mira','Playlist baru sudah siap untuk malam ini.','Music')];
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    const Text('Community',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const Text('Feed sosial original Nexora.'),
    const SizedBox(height:15),
    Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.person_rounded)),title:const Text('Apa yang kamu pikirkan?'),subtitle:const Text('Buat postingan baru'),trailing:const Icon(Icons.add_circle_outline_rounded),onTap:()=>showDialog(context:context,builder:(_)=>const _Compose()))),
    const SizedBox(height:12),
    for(var i=0;i<posts.length;i++) Card(margin:const EdgeInsets.only(bottom:12),child:Padding(padding:const EdgeInsets.all(15),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[const CircleAvatar(child:Icon(Icons.person_rounded)),const SizedBox(width:10),Expanded(child:Text(posts[i].$1,style:const TextStyle(fontWeight:FontWeight.w800))),Text(posts[i].$3)]),
      const SizedBox(height:13),Text(posts[i].$2),const SizedBox(height:10),const Divider(height:1),
      Row(children:[
        IconButton(onPressed:()=>setState(()=>liked.contains(i)?liked.remove(i):liked.add(i)),icon:Icon(liked.contains(i)?Icons.favorite_rounded:Icons.favorite_border_rounded)),
        Text(liked.contains(i)?'1':'0'),const SizedBox(width:15),const Icon(Icons.chat_bubble_outline_rounded),const SizedBox(width:5),const Text('0'),const Spacer(),IconButton(onPressed:(){},icon:const Icon(Icons.share_outlined)),
      ]),
    ]))),
  ]);
}
class _Compose extends StatelessWidget{
  const _Compose();
  @override Widget build(BuildContext context)=>AlertDialog(title:const Text('New Post'),content:const TextField(maxLines:4,decoration:InputDecoration(hintText:'Tulis sesuatu...',border:OutlineInputBorder())),actions:[
    TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Batal')),
    FilledButton(onPressed:()=>Navigator.pop(context),child:const Text('Post')),
  ]);
}

class MarketPage extends StatelessWidget{
  final int coins,cart; final ValueChanged<int>? buy;
  const MarketPage({required this.coins,required this.cart,required this.buy,super.key});
  static const items=[('Nexora Avatar Pack','Cosmetic pack',250,Icons.person_rounded),('Profile Frame','Cosmetic frame',150,Icons.crop_square_rounded),('Game Badge','Badge profil',300,Icons.workspace_premium_rounded),('Theme Pack','Tema visual',450,Icons.palette_rounded)];
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    Row(children:[const Expanded(child:Text('Marketplace',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900))),Chip(avatar:const Icon(Icons.shopping_cart_rounded,size:17),label:Text(cart.toString()))]),
    Text('Saldo demo: $coins coins'),const SizedBox(height:16),
    for(final item in items) Card(margin:const EdgeInsets.only(bottom:10),child:ListTile(contentPadding:const EdgeInsets.all(13),
      leading:CircleAvatar(radius:27,child:Icon(item.$4)),title:Text(item.$1,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${item.$2} • ${item.$3} coins'),
      trailing:FilledButton(onPressed:coins>=item.$3&&buy!=null?()=>buy!(item.$3):null,child:const Text('Buy')),
    )),
    const Card(child:ListTile(leading:Icon(Icons.info_outline_rounded),title:Text('Marketplace demo'),subtitle:Text('Pembayaran nyata akan memakai backend dan provider resmi pada tahap berikutnya.'))),
  ]);
}

class WalletPage extends StatelessWidget{
  final int coins;final VoidCallback addCoins;
  const WalletPage({required this.coins,required this.addCoins,super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:const LinearGradient(colors:[Color(0xFF4C1D95),Color(0xFF172554)])),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('Nexora Wallet'),const SizedBox(height:8),Text('$coins',style:const TextStyle(fontSize:36,fontWeight:FontWeight.w900)),const Text('coins'),const SizedBox(height:14),
      FilledButton.icon(onPressed:addCoins,icon:const Icon(Icons.add_rounded),label:const Text('Tambah 250 demo coins')),
    ])),
    const SizedBox(height:18),const _Title('Transactions'),const SizedBox(height:8),
    const Card(child:ListTile(leading:CircleAvatar(child:Icon(Icons.card_giftcard_rounded)),title:Text('Welcome bonus'),trailing:Text('+1,250',style:TextStyle(fontWeight:FontWeight.w800)))),
    const Card(child:ListTile(leading:CircleAvatar(child:Icon(Icons.shopping_bag_rounded)),title:Text('Belum ada pembelian'),trailing:Text('—'))),
  ]);
}

class ProfilePage extends StatelessWidget {
  final GoogleSignInAccount user;
  const ProfilePage({required this.user, super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const SizedBox(height: 10),
      Center(
        child: user.photoUrl != null
            ? CircleAvatar(radius: 46, backgroundImage: NetworkImage(user.photoUrl!))
            : const CircleAvatar(radius: 46, child: Icon(Icons.person_rounded, size: 46)),
      ),
      const SizedBox(height: 12),
      Center(child: Text(user.displayName ?? 'Nexora Player', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
      Center(child: Text(user.email)),
      const SizedBox(height: 20),
      Card(child: ListTile(
        leading: const Icon(Icons.verified_rounded),
        title: const Text('Google Account', style: TextStyle(fontWeight: FontWeight.w800)),
        subtitle: const Text('Akun wajib untuk memakai Nexora'),
        trailing: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
      )),
      const SizedBox(height: 18),
      const Row(children: [
        Expanded(child: _PStat('1', 'Level')),
        SizedBox(width: 10),
        Expanded(child: _PStat('0', 'Posts')),
        SizedBox(width: 10),
        Expanded(child: _PStat('0', 'Friends')),
      ]),
      const SizedBox(height: 18),
      const _Title('Account'),
      const Card(child: Column(children: [
        ListTile(leading: Icon(Icons.badge_rounded), title: Text('Rookie'), subtitle: Text('Member Nexora')),
        Divider(height: 1),
        ListTile(leading: Icon(Icons.verified_user_rounded), title: Text('Account security')),
      ])),
    ],
  );
}


class GoogleLoginPage extends StatefulWidget{
  const GoogleLoginPage({super.key});
  @override State<GoogleLoginPage> createState()=>_GoogleLoginState();
}
class _GoogleLoginState extends State<GoogleLoginPage>{
  GoogleSignInAccount? user;
  String status='Login Google siap digunakan setelah OAuth Client ID Nexora dikonfigurasi.';
  bool busy=false;

  Future<void> signIn() async {
    setState(()=>busy=true);
    try {
      final signIn=GoogleSignIn.instance;
      await signIn.initialize(
        clientId: const String.fromEnvironment('GOOGLE_CLIENT_ID',defaultValue:''),
        serverClientId: const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID',defaultValue:''),
      );
      if(!signIn.supportsAuthenticate()){
        setState(()=>status='Platform ini membutuhkan konfigurasi Google OAuth dan tombol web/Android yang sesuai.');
        return;
      }
      final account=await signIn.authenticate();
      if(!mounted)return;
      setState(()=>user=account);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Login berhasil sebagai ${account.email}')));
    } on GoogleSignInException catch(e) {
      if(mounted)setState(()=>status='Google login: ${e.description??e.code.name}');
    } catch(e) {
      if(mounted)setState(()=>status='Google login belum dikonfigurasi: $e');
    } finally {
      if(mounted)setState(()=>busy=false);
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    if(mounted)setState(()=>user=null);
  }

  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(20),children:[
    const SizedBox(height:24),
    const Icon(Icons.account_circle_rounded,size:86),
    const SizedBox(height:12),
    const Center(child:Text('Nexora Account',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900))),
    const SizedBox(height:8),
    Center(child:Text(user==null?'Masuk untuk menyimpan profil, progres game, dan library.':'Akun Google tersambung.',textAlign:TextAlign.center)),
    const SizedBox(height:24),
    if(user!=null) Card(child:ListTile(
      leading:NexoraAvatar(account:user!, customAvatar:null, radius:22),
      title:Text(user!.displayName??'Google Account',style:const TextStyle(fontWeight:FontWeight.w800)),
      subtitle:Text(user!.email),
      trailing:IconButton(onPressed:signOut,icon:const Icon(Icons.logout_rounded)),
    )) else Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(children:[
      const CircleAvatar(radius:28,child:Icon(Icons.g_mobiledata_rounded,size:34)),
      const SizedBox(height:12),
      const Text('Continue with Google',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),
      const SizedBox(height:6),
      Text(status,textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodySmall),
      const SizedBox(height:16),
      SizedBox(width:double.infinity,child:FilledButton.icon(
        onPressed:busy?null:signIn,
        icon:const Icon(Icons.login_rounded),
        label:Text(busy?'Menghubungkan...':'Login dengan Google'),
      )),
    ]))),
    const SizedBox(height:20),
    const _Title('Account benefits'),
    const _Recent(Icons.cloud_sync_rounded,'Cloud profile','Profil dan progres siap disinkronkan.'),
    const _Recent(Icons.emoji_events_rounded,'Game progress','Skor dan pencapaian bisa dikaitkan ke akun.'),
    const _Recent(Icons.library_music_rounded,'Music library','Library dan playlist tetap terkait akun.'),
  ]);
}

class _PStat extends StatelessWidget{final String v,l;const _PStat(this.v,this.l);@override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.symmetric(vertical:15),child:Column(children:[Text(v,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),Text(l)])));}

class NotificationsPage extends StatelessWidget{
  const NotificationsPage({super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:const[
    _Notice(Icons.celebration_rounded,'Welcome to Nexora V2','Dashboard dan Game Hub baru tersedia.'),
    _Notice(Icons.sports_esports_rounded,'Tap Rush tersedia','Coba mini game pertama Nexora.'),
    _Notice(Icons.storefront_rounded,'Marketplace demo','Produk kosmetik demo sudah bisa dicoba.'),
  ]);
}
class _Notice extends StatelessWidget{final IconData icon;final String title,body;const _Notice(this.icon,this.title,this.body);@override Widget build(BuildContext context)=>Card(margin:const EdgeInsets.only(bottom:10),child:ListTile(contentPadding:const EdgeInsets.all(14),leading:CircleAvatar(child:Icon(icon)),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(body)));}

class _NexoraColorPickerDialog extends StatefulWidget {
  final String title;
  final Color initial;
  const _NexoraColorPickerDialog({required this.title,required this.initial});
  @override State<_NexoraColorPickerDialog> createState()=>_NexoraColorPickerState();
}

class _NexoraColorPickerState extends State<_NexoraColorPickerDialog> {
  late HSVColor hsv;
  late TextEditingController hexController;

  @override
  void initState(){
    super.initState();
    hsv=HSVColor.fromColor(widget.initial);
    hexController=TextEditingController(text:_hex(widget.initial));
  }

  String _hex(Color c)=>'#'+c.value.toRadixString(16).padLeft(8,'0').substring(2).toUpperCase();

  void _setColor(Color c){
    setState(() {
      hsv=HSVColor.fromColor(c);
      hexController.text=_hex(c);
      hexController.selection=TextSelection.collapsed(offset:hexController.text.length);
    });
  }

  void _applyHex(){
    var value=hexController.text.trim().replaceFirst('#','');
    if(value.length==6) value='FF'+value;
    if(value.length!=8) return;
    final parsed=int.tryParse(value,radix:16);
    if(parsed==null) return;
    _setColor(Color(parsed));
  }

  void _setHue(Offset p,Size size){setState(()=>hsv=hsv.withHue(((p.dx/size.width).clamp(0.0,1.0)).toDouble()*360));}
  void _setSV(Offset p,Size size){setState(()=>hsv=hsv.withSaturation((p.dx/size.width).clamp(0.0,1.0).toDouble()).withValue((1-p.dy/size.height).clamp(0.0,1.0).toDouble()));}

  @override
  void dispose(){hexController.dispose();super.dispose();}

  @override Widget build(BuildContext context){
    final color=hsv.toColor();
    return AlertDialog(
      title:Text(widget.title,style:const TextStyle(fontWeight:FontWeight.w900)),
      content:SizedBox(width:340,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        SizedBox(height:190,child:LayoutBuilder(builder:(context,c)=>GestureDetector(
          behavior:HitTestBehavior.opaque,
          onTapDown:(d)=>_setSV(d.localPosition,Size(c.maxWidth,190)),
          onPanDown:(d)=>_setSV(d.localPosition,Size(c.maxWidth,190)),
          onPanUpdate:(d)=>_setSV(d.localPosition,Size(c.maxWidth,190)),
          child:CustomPaint(painter:_ColorSVPainter(hsv.hue),child:Stack(children:[
            Positioned(
              left:(hsv.saturation*c.maxWidth-9).clamp(0.0,c.maxWidth-18).toDouble(),
              top:((1-hsv.value)*190-9).clamp(0.0,172).toDouble(),
              child:Container(width:18,height:18,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:Colors.white,width:2),boxShadow:[const BoxShadow(color:Colors.black54,blurRadius:4)])),
            ),
          ])),
        ))),
        const SizedBox(height:14),
        SizedBox(height:26,child:LayoutBuilder(builder:(context,c)=>GestureDetector(
          behavior:HitTestBehavior.opaque,
          onTapDown:(d)=>_setHue(d.localPosition,Size(c.maxWidth,26)),
          onPanDown:(d)=>_setHue(d.localPosition,Size(c.maxWidth,26)),
          onPanUpdate:(d)=>_setHue(d.localPosition,Size(c.maxWidth,26)),
          child:CustomPaint(painter:_HuePainter(),child:Center(child:Container(width:25,height:25,decoration:BoxDecoration(shape:BoxShape.circle,color:color,border:Border.all(color:Colors.white,width:2))))),
        ))),
        const SizedBox(height:15),
        Row(children:[
          Container(width:48,height:48,decoration:BoxDecoration(color:color,borderRadius:BorderRadius.circular(12),border:Border.all(color:Colors.white24))),
          const SizedBox(width:12),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('Pilih dengan sentuhan',style:TextStyle(fontWeight:FontWeight.w800)),
            Text('RGB '+color.red.toString()+', '+color.green.toString()+', '+color.blue.toString(),style:const TextStyle(color:Colors.white60,fontSize:12)),
          ])),
        ]),
        const SizedBox(height:12),
        TextField(
          controller:hexController,
          textCapitalization:TextCapitalization.characters,
          decoration:const InputDecoration(
            labelText:'Kode warna',
            hintText:'#8B5CF6',
            prefixIcon:Icon(Icons.tag_rounded),
            border:OutlineInputBorder(),
          ),
          onSubmitted:(_)=>_applyHex(),
          onChanged:(_){},
        ),
        const SizedBox(height:6),
        Align(alignment:Alignment.centerLeft,child:Text('Bisa pilih dengan picker atau masukkan kode HEX.',style:const TextStyle(color:Colors.white60,fontSize:11))),
      ]))),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Batal')),
        FilledButton(onPressed:()=>{_applyHex(),Navigator.pop(context,hsv.toColor())},child:const Text('Pilih')),
      ],
    );
  }
}

class _ColorSVPainter extends CustomPainter {
  final double hue;
  const _ColorSVPainter(this.hue);
  @override void paint(Canvas canvas,Size size){
    final base=HSVColor.fromAHSV(1,hue,1,1).toColor();
    final rect=Offset.zero&size;
    canvas.drawRect(rect,Paint()..shader=LinearGradient(colors:[Colors.white,base]).createShader(rect));
    canvas.drawRect(rect,Paint()..shader=const LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.transparent,Colors.black]).createShader(rect));
  }
  @override bool shouldRepaint(covariant _ColorSVPainter old)=>old.hue!=hue;
}

class _HuePainter extends CustomPainter {
  @override void paint(Canvas canvas,Size size){
    final colors=List.generate(7,(i)=>HSVColor.fromAHSV(1,i*60.0,1,1).toColor());
    final rect=Offset.zero&size;
    canvas.drawRRect(RRect.fromRectAndRadius(rect,const Radius.circular(14)),Paint()..shader=LinearGradient(colors:colors).createShader(rect));
  }
  @override bool shouldRepaint(covariant _HuePainter old)=>false;
}

class _VisualSlider extends StatelessWidget {
  final String label,display;
  final double value,min,max;
  final ValueChanged<double> onChanged;
  const _VisualSlider({required this.label,required this.value,required this.min,required this.max,required this.display,required this.onChanged});
  @override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[Expanded(child:Text(label,style:const TextStyle(fontWeight:FontWeight.w700,fontSize:12))),Text(display,style:const TextStyle(fontSize:12,color:Colors.white60))]),
    Slider(value:value.clamp(min,max).toDouble(),min:min,max:max,onChanged:onChanged),
  ]);
}

class SettingsPage extends StatefulWidget {
  final GoogleSignInAccount account;
  final String customName;
  final Uint8List? customAvatar;
  final int wallpaper;
  final Color background, primary, surface, border, text;
  final double cardOpacity, cardBorderWidth, cardBorderOpacity;
  final Uint8List? customBackground;
  final Uint8List? customProfileWallpaper;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<Uint8List?> onAvatarChanged;
  final ValueChanged<int> onWallpaperChanged;
  final ValueChanged<Uint8List?> onBackgroundChanged;
  final void Function(String key, Color value) onColorChanged;
  final void Function(String key, double value) onVisualChanged;
  final VoidCallback onResetTheme;
  const SettingsPage({
    required this.account,
    required this.customName,
    required this.customAvatar,
    required this.wallpaper,
    required this.background,
    required this.primary,
    required this.surface,
    required this.border,
    required this.text,
    required this.cardOpacity,
    required this.cardBorderWidth,
    required this.cardBorderOpacity,
    required this.customBackground,
    required this.customProfileWallpaper,
    required this.onNameChanged,
    required this.onAvatarChanged,
    required this.onWallpaperChanged,
    required this.onBackgroundChanged,
    required this.onColorChanged,
    required this.onVisualChanged,
    required this.onResetTheme,
    super.key,
  });
  @override State<SettingsPage> createState()=>_SettingsState();
}
class _SettingsState extends State<SettingsPage> {
  final ImagePicker _picker=ImagePicker();
  bool notifications=true,sound=true,animations=true;
  Future<void> _pickAvatar() async {
    final file=await _picker.pickImage(source:ImageSource.gallery,imageQuality:88,maxWidth:900,maxHeight:900);
    if(file!=null) widget.onAvatarChanged(await file.readAsBytes());
  }
  Future<void> _pickBackground() async {
    final file=await _picker.pickImage(source:ImageSource.gallery,imageQuality:82,maxWidth:1800,maxHeight:1800);
    if(file!=null) widget.onBackgroundChanged(await file.readAsBytes());
  }

  Future<void> _pickProfileWallpaper() async {
    final file=await _picker.pickImage(source:ImageSource.gallery,imageQuality:82,maxWidth:1800,maxHeight:1200);
    if(file!=null) widget.onProfileWallpaperChanged(await file.readAsBytes());
  }
  Future<void> _editName() async {
    final controller=TextEditingController(text:widget.customName);
    final value=await showDialog<String>(context:context,builder:(_)=>AlertDialog(
      title:const Text('Nama Nexora'),
      content:TextField(controller:controller,autofocus:true,maxLength:24,decoration:const InputDecoration(labelText:'Nama tampilan')),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Batal')),
        FilledButton(onPressed:()=>Navigator.pop(context,controller.text.trim()),child:const Text('Simpan')),
      ],
    ));
    if(value!=null&&value.trim().isNotEmpty) widget.onNameChanged(value.trim());
  }
  Future<void> _editColor(String key,String title,Color current) async {
    final value=await showDialog<Color>(
      context:context,
      builder:(_)=>_NexoraColorPickerDialog(title:title,initial:current),
    );
    if(value!=null) widget.onColorChanged(key,value);
  }
  Widget _colorRow(String key,String title,String subtitle,Color color)=>ListTile(
    contentPadding:const EdgeInsets.symmetric(vertical:4,horizontal:6),
    leading:Container(
      width:46,height:46,
      decoration:BoxDecoration(
        color:color,
        borderRadius:BorderRadius.circular(13),
        border:Border.all(color:Colors.white24),
        boxShadow:[BoxShadow(color:color.withValues(alpha:.28),blurRadius:12)],
      ),
    ),
    title:Text(title,style:const TextStyle(fontWeight:FontWeight.w800)),
    subtitle:Text(subtitle,style:const TextStyle(fontSize:11)),
    trailing:IconButton(onPressed:()=>_editColor(key,title,color),icon:const Icon(Icons.palette_outlined)),
    onTap:()=>_editColor(key,title,color),
  );
  @override Widget build(BuildContext context){
    final googleName=widget.account.displayName?.trim();
    final shownName=widget.customName.trim().isNotEmpty?widget.customName:(googleName!=null&&googleName.isNotEmpty?googleName:widget.account.email.split('@').first);
    return ListView(padding:const EdgeInsets.fromLTRB(16,16,16,32),children:[
      const _Title('PENGATURAN AKUN'),
      const SizedBox(height:8),
      Card(child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[
        GestureDetector(onTap:_pickAvatar,child:Stack(children:[
          NexoraAvatar(account:widget.account,customAvatar:widget.customAvatar,radius:40),
          Positioned(right:0,bottom:0,child:CircleAvatar(radius:15,backgroundColor:Theme.of(context).colorScheme.primary,child:const Icon(Icons.camera_alt_rounded,size:15))),
        ])),
        const SizedBox(width:14),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(shownName,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
          const SizedBox(height:3),
          Text(widget.account.email,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.white60,fontSize:12)),
          const SizedBox(height:10),
          Wrap(spacing:8,children:[
            OutlinedButton.icon(onPressed:_editName,icon:const Icon(Icons.edit_rounded,size:16),label:const Text('Ubah nama')),
            if(widget.customName.trim().isNotEmpty) OutlinedButton(onPressed:()=>widget.onNameChanged(''),child:const Text('Nama Google')),
          ]),
        ])),
      ]))),
      const SizedBox(height:18),
      const _Title('CART PROFIL PENGGUNA'),
      const SizedBox(height:5),
      const Text('Wallpaper khusus untuk kartu profil pengguna di Home. Bisa pakai gambar sendiri atau style bawaan.',style:TextStyle(color:Colors.white60,fontSize:12)),
      const SizedBox(height:8),
      Card(child:Padding(padding:const EdgeInsets.all(14),child:SizedBox(height:84,child:ListView.separated(
        scrollDirection:Axis.horizontal,itemCount:_nexoraWallpapers.length,separatorBuilder:(_,__)=>const SizedBox(width:10),
        itemBuilder:(_,index)=>GestureDetector(onTap:()=>widget.onWallpaperChanged(index),child:Container(
          width:116,
          decoration:BoxDecoration(borderRadius:BorderRadius.circular(17),gradient:_nexoraWallpaperGradient(index),border:Border.all(color:widget.wallpaper==index?Colors.white:Colors.white24,width:widget.wallpaper==index?2.5:1)),
          alignment:Alignment.bottomLeft,padding:const EdgeInsets.all(9),
          child:Text('Style '+(index+1).toString(),style:const TextStyle(fontSize:10,fontWeight:FontWeight.w900)),
        )),
      )))),
      const SizedBox(height:10),
      Card(child:ListTile(
        leading:const Icon(Icons.wallpaper_rounded),
        title:const Text('Wallpaper custom kartu profil',style:TextStyle(fontWeight:FontWeight.w900)),
        subtitle:Text(widget.customProfileWallpaper == null ? 'Belum ada wallpaper custom' : 'Wallpaper custom sedang digunakan'),
        trailing:const Icon(Icons.chevron_right_rounded),
        onTap:_pickProfileWallpaper,
      )),
      if(widget.customProfileWallpaper!=null)
        Card(child:ListTile(
          leading:const Icon(Icons.delete_outline_rounded),
          title:const Text('Hapus wallpaper kartu profil'),
          onTap:()=>widget.onProfileWallpaperChanged(null),
        )),
      const SizedBox(height:18),
      const _Title('CUSTOM TEMA NEXORA'),
      const SizedBox(height:5),
      const Text('Custom warna seperti panel tema: ubah 4 warna utama dan gunakan background sendiri.',style:TextStyle(color:Colors.white60,fontSize:12)),
      const SizedBox(height:9),
      Card(child:Column(children:[
        _colorRow('bg','Warna Latar Layar (Background)','Latar belakang aplikasi',widget.background),
        const Divider(height:1),
        _colorRow('primary','Warna Aksen Utama (Primary)','Tombol, highlight, icon aktif',widget.primary),
        const Divider(height:1),
        _colorRow('surface','Warna Kartu & Panel (Surface)','Card, menu, popup',widget.surface),
        const Divider(height:1),
        _colorRow('border','Warna Border & Garis Tepi','Outline dan separator',widget.border),
        const Divider(height:1),
        _colorRow('text','Warna Tulisan','Semua teks yang mengikuti tema',widget.text),
      ])),
      const SizedBox(height:10),
      Card(
        child:Padding(
          padding:const EdgeInsets.fromLTRB(16,12,16,16),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('TRANSPARANSI & KETEBALAN UI',style:TextStyle(fontWeight:FontWeight.w900)),
            const SizedBox(height:4),
            const Text('Atur seberapa terlihat kartu/panel dan ketebalan garisnya. Nilai 0 membuat warna kartu hilang.',style:TextStyle(color:Colors.white60,fontSize:11)),
            const SizedBox(height:12),
            _VisualSlider(label:'Kecerahan / transparansi kartu',value:widget.cardOpacity,min:0,max:1,display:(widget.cardOpacity*100).round().toString()+'%',onChanged:(v)=>widget.onVisualChanged('cardOpacity',v)),
            _VisualSlider(label:'Ketebalan border',value:widget.cardBorderWidth,min:0,max:6,display:widget.cardBorderWidth.toStringAsFixed(1)+' px',onChanged:(v)=>widget.onVisualChanged('cardBorderWidth',v)),
            _VisualSlider(label:'Kecerahan border',value:widget.cardBorderOpacity,min:0,max:1,display:(widget.cardBorderOpacity*100).round().toString()+'%',onChanged:(v)=>widget.onVisualChanged('cardBorderOpacity',v)),
          ]),
        ),
      ),
      const SizedBox(height:10),
      Card(child:Column(children:[
        ListTile(leading:const Icon(Icons.image_rounded),title:const Text('Background sendiri',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:const Text('Pilih gambar dari galeri/perangkat'),trailing:const Icon(Icons.chevron_right_rounded),onTap:_pickBackground),
        if(widget.customBackground!=null) ListTile(leading:const Icon(Icons.delete_outline_rounded),title:const Text('Hapus background custom'),onTap:()=>widget.onBackgroundChanged(null)),
      ])),
      const SizedBox(height:10),
      Card(child:ListTile(leading:const Icon(Icons.restore_rounded),title:const Text('Reset ke warna asli Nexora'),subtitle:const Text('#080A10 • #8B5CF6 • #111522 • #334155'),onTap:widget.onResetTheme)),
      const SizedBox(height:18),
      const _Title('PREFERENCES'),
      const SizedBox(height:8),
      Card(child:Column(children:[
        SwitchListTile(value:notifications,onChanged:(v)=>setState(()=>notifications=v),title:const Text('Notifications'),subtitle:const Text('Notifikasi Nexora')),
        const Divider(height:1),
        SwitchListTile(value:sound,onChanged:(v)=>setState(()=>sound=v),title:const Text('Sound'),subtitle:const Text('Suara aplikasi dan game')),
        const Divider(height:1),
        SwitchListTile(value:animations,onChanged:(v)=>setState(()=>animations=v),title:const Text('Animations'),subtitle:const Text('Animasi aplikasi')),
      ])),
    ]);
  }
}


class AboutPage extends StatelessWidget{
  const AboutPage({super.key});
  @override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(28),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    const Icon(Icons.hexagon_rounded,size:82),const SizedBox(height:16),const Text('Nexora',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900)),const Text('Original mobile hub • V2'),const SizedBox(height:18),
    const Text('Game, music, community, dan marketplace dalam satu aplikasi original Nexora.',textAlign:TextAlign.center),
  ])));
}

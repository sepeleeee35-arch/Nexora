import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    home: const NexoraShell(),
  );
}

class NexoraShell extends StatefulWidget {
  const NexoraShell({super.key});
  @override State<NexoraShell> createState() => _NexoraShellState();
}

class _NexoraShellState extends State<NexoraShell> {
  int tab = 0;
  String? page;
  int coins = 1250;
  int cart = 0;
  static const names = ['Home','Games','Music','Tools','Market'];

  void selectPage(String value) {
    Navigator.pop(context);
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
      body = const ProfilePage();
    } else if (page == 'Login') {
      body = const GoogleLoginPage();
    } else if (page == 'Notifications') {
      body = const NotificationsPage();
    } else if (page == 'Settings') {
      body = const SettingsPage();
    } else if (page == 'About') {
      body = const AboutPage();
    } else {
      body = switch (tab) {
        1 => const GamesPage(),
        2 => const MusicPage(),
        3 => const ToolsPage(),
        4 => MarketPage(coins: coins, cart: cart, buy: null),
        _ => HomePage(
          coins: coins,
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

    return Scaffold(
      drawer: NexoraDrawer(coins: coins, onSelect: selectPage),
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
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 180), child: KeyedSubtree(key: ValueKey(page ?? tab), child: body)),
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
    );
  }
}

class NexoraDrawer extends StatelessWidget {
  final int coins;
  final ValueChanged<String> onSelect;
  const NexoraDrawer({required this.coins, required this.onSelect, super.key});
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
        leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
        title: const Text('Nexora Player', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$coins coins'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => onSelect('Profile'),
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
      _Item(Icons.login_rounded,'Login with Google',()=>onSelect('Login')),
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
  final int coins; final ValueChanged<int> openTab; final ValueChanged<String> openPage;
  const HomePage({required this.coins,required this.openTab,required this.openPage,super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [Color(0xFF35206D),Color(0xFF151B38),Color(0xFF10131F)]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Expanded(child: Text('Welcome back!',style:TextStyle(fontSize:26,fontWeight:FontWeight.w900))),
          CircleAvatar(child: Icon(Icons.person_rounded)),
        ]),
        const SizedBox(height:8),
        const Text('Game, music, community, dan marketplace dalam satu aplikasi.'),
        const SizedBox(height:18),
        Row(children: [
          Expanded(child:_Stat(Icons.monetization_on_rounded,'Coins',coins.toString())),
          const SizedBox(width:10),
          const Expanded(child:_Stat(Icons.emoji_events_rounded,'Rank','Rookie')),
        ]),
      ]),
    ),
    const SizedBox(height:22),
    const _Title('Quick Access'),
    const SizedBox(height:10),
    GridView.count(
      crossAxisCount:2, shrinkWrap:true, physics:const NeverScrollableScrollPhysics(),
      crossAxisSpacing:10, mainAxisSpacing:10, childAspectRatio:1.55,
      children:[
        _Quick(Icons.sports_esports_rounded,'Game Hub','Play now',()=>openTab(1)),
        _Quick(Icons.music_note_rounded,'Music','Library',()=>openTab(2)),
        _Quick(Icons.build_rounded,'Tools','Utilities',()=>openTab(3)),
        _Quick(Icons.storefront_rounded,'Market','Browse',()=>openTab(4)),
      ],
    ),
    const SizedBox(height:22),
    const _Title('Featured'),
    const SizedBox(height:10),
    Container(
      height:150, padding:const EdgeInsets.all(20),
      decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),gradient:const LinearGradient(colors:[Color(0xFF162A45),Color(0xFF321B52)])),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('NEXORA ARCADE',style:TextStyle(fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1.5)),
        const SizedBox(height:5), const Text('Tap Rush',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900)),
        const Text('Kejar skor tertinggi dalam waktu terbatas.'),
        const Spacer(),
        FilledButton.icon(
          onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const ArcadeGamePage(ArcadeGame('Tap Rush', 'tap')))),
          icon:const Icon(Icons.play_arrow_rounded),label:const Text('Play'),
        ),
      ]),
    ),
    const SizedBox(height:22),
    _Title('Your Account','Profile',()=>openPage('Profile')),
    const SizedBox(height:10),
    Card(child:Column(children:[
      ListTile(leading:const CircleAvatar(child:Icon(Icons.person_rounded)),title:const Text('Nexora Player',style:TextStyle(fontWeight:FontWeight.bold)),subtitle:const Text('Rookie • Level 1'),trailing:const Icon(Icons.chevron_right_rounded),onTap:()=>openPage('Profile')),
      const Divider(height:1),
      ListTile(leading:const Icon(Icons.account_balance_wallet_rounded),title:const Text('Wallet'),subtitle:Text('$coins coins tersedia'),trailing:const Icon(Icons.chevron_right_rounded),onTap:()=>openPage('Wallet')),
    ])),
    const SizedBox(height:18),
    const _Title('Recent'),
    const _Recent(Icons.sports_esports_rounded,'Tap Rush','Mini game tersedia sekarang'),
    const _Recent(Icons.music_note_rounded,'Nexora Music','Player dan library'),
    const _Recent(Icons.build_rounded,'Nexora Tools','Media & utility tools'),
  ]);
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

class ArcadeGame{final String title,kind;const ArcadeGame(this.title,this.kind);}const _games=<ArcadeGame>[ArcadeGame('Geometry Rush','dodge'),ArcadeGame('Happy Filled Glass','puzzle'),ArcadeGame('Apple Worm','maze'),ArcadeGame('Impostor','target'),ArcadeGame('Mr. Shoot','target'),ArcadeGame('Save the Doge','puzzle'),ArcadeGame('Trap Path','dodge'),ArcadeGame('Archers Random','target'),ArcadeGame('Brainrot Merge','merge'),ArcadeGame('Fruits Match 2','match'),ArcadeGame('Head Soccer','tap'),ArcadeGame('Sheep and Sheep','match'),ArcadeGame('Tic Tac Toe','ttt'),ArcadeGame('Knife Hit','timing'),ArcadeGame('Color Maze','maze'),ArcadeGame('Pipe Way','puzzle'),ArcadeGame('Ludo','dice'),ArcadeGame('Coloring Book','color'),ArcadeGame('Master Fall Down','target'),ArcadeGame('Route Digger','maze'),ArcadeGame('Cap Sort','sort'),ArcadeGame('Tanks Battle','target'),ArcadeGame('Color by Number','color'),ArcadeGame('Draw Parking','parking'),ArcadeGame('Turn Light','lights'),ArcadeGame('Blast','blast'),ArcadeGame('Solitaire Association','memory'),ArcadeGame('Skip Card','highlow'),ArcadeGame('Crazy Fishing','timing'),ArcadeGame('Word Search Hidden','word'),ArcadeGame('House Painter','paint'),ArcadeGame('Zombie Tower Defence','defense'),ArcadeGame('Tower Boom','timing'),ArcadeGame('Find Number','number'),ArcadeGame('4 Colors','cards'),ArcadeGame('Golf Day','tap'),ArcadeGame('Jigsaw Puzzle','memory'),ArcadeGame('Pool 8 Pro','pool'),ArcadeGame('Nuts and Bolts','sort'),ArcadeGame('Indianara','dodge'),ArcadeGame('Merge Fruits','merge'),ArcadeGame('City Builder','builder'),ArcadeGame('Tiny Crash Fighters','dodge'),ArcadeGame('Spill Wine','puzzle'),ArcadeGame('Pool Shoot','pool'),ArcadeGame('Sudoku','number'),ArcadeGame('Merge Shooter','target'),ArcadeGame('Math','math'),ArcadeGame('Slider Puzzle','slider'),ArcadeGame('Zumba Pop Marble','match'),ArcadeGame('Solitaire Spider','cards'),ArcadeGame('Collect Em All','match'),ArcadeGame('Shooting Balls','target'),ArcadeGame('Chess','ttt'),ArcadeGame('Pull the Pin','pin'),ArcadeGame('Water Sort','sort'),ArcadeGame('Pinball Rush','timing'),ArcadeGame('Solitaire Classic','cards'),ArcadeGame('Brick Breaker','brick'),ArcadeGame('Word Connect','word'),ArcadeGame('Rope Bowling','timing')];
String _cat(String k){if(k=='ttt'||k=='dice')return'BOARD';if(k=='cards'||k=='highlow')return'CARD';if(k=='target')return'ACTION';if(k=='dodge'||k=='timing')return'ARCADE';return'PUZZLE';}
IconData _ico(String k){switch(k){case'dodge':return Icons.speed_rounded;case'target':return Icons.gps_fixed_rounded;case'merge':case'2048':return Icons.add_box_rounded;case'memory':return Icons.grid_view_rounded;case'word':return Icons.abc_rounded;case'brick':return Icons.view_module_rounded;case'maze':return Icons.route_rounded;case'sort':return Icons.view_column_rounded;case'cards':return Icons.style_rounded;case'timing':return Icons.timer_rounded;case'ttt':return Icons.grid_3x3_rounded;case'pool':return Icons.circle_rounded;case'lights':return Icons.lightbulb_rounded;case'bubble':return Icons.bubble_chart_rounded;case'defense':return Icons.shield_rounded;default:return Icons.extension_rounded;}}
class GamesPage extends StatefulWidget{const GamesPage({super.key});@override State<GamesPage> createState()=>_GamesState();}
class _GamesState extends State<GamesPage> {
  String query = '';

  void openGame(ArcadeGame game) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArcadeGamePage(game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final games = _games
        .where((game) =>
            game.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 110),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFF6D28D9), Color(0xFF111827)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.sports_esports_rounded, size: 34),
                  const Spacer(),
                  Text(
                    '\${_games.length} GAMES',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'NEXORA ARCADE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                'Main. Temukan. Ulangi.',
                style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                '\${_games.length} mini-game original. Banyak genre, satu tempat.',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _games.isEmpty
                    ? null
                    : () => openGame(
                          _games[Random().nextInt(_games.length)],
                        ),
                icon: const Icon(Icons.shuffle_rounded),
                label: const Text('Random Play'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: 'Cari game...',
            filled: true,
            fillColor: const Color(0xFF111522),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'All Games',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
            ),
            Text('\${games.length}'),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: games.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: .73,
          ),
          itemBuilder: (context, index) {
            final game = games[index];
            final color = Colors.primaries[index % Colors.primaries.length];

            return Material(
              color: const Color(0xFF171321),
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                onTap: () => openGame(game),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: .55),
                        const Color(0xFF171321),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: color.withValues(alpha: .35),
                          ),
                          child: Stack(
                            children: [
                              Center(child: Icon(_ico(game.kind), size: 58)),
                              const Positioned(
                                top: 9,
                                right: 9,
                                child: Icon(
                                  Icons.play_circle_fill_rounded,
                                  size: 28,
                                ),
                              ),
                              Positioned(
                                left: 9,
                                bottom: 9,
                                child: Text(
                                  _cat(game.kind),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        game.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Original Nexora • \${_cat(game.kind)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded, size: 15),
                          SizedBox(width: 3),
                          Text(
                            'PLAY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ArcadeGamePage extends StatefulWidget{final ArcadeGame game;const ArcadeGamePage(this.game,{super.key});@override State<ArcadeGamePage> createState()=>_ArcadeState();}
class _ArcadeState extends State<ArcadeGamePage> {
  final Random random = Random();
  Timer? timer;
  int score = 0;
  int time = 30;
  int target = 0;
  bool playing = false;
  List<int> board = <int>[];
  List<bool> opened = <bool>[];

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    timer?.cancel();
    score = 0;
    time = 30;
    target = random.nextInt(25);
    playing = false;
    board = List<int>.generate(25, (_) => random.nextInt(5));
    opened = List<bool>.filled(16, false);
    if (mounted) setState(() {});
  }

  void startGame() {
    timer?.cancel();
    score = 0;
    time = 30;
    target = random.nextInt(25);
    playing = true;
    board = List<int>.generate(25, (_) => random.nextInt(5));
    opened = List<bool>.filled(16, false);
    setState(() {});

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (time <= 1) {
        timer?.cancel();
        setState(() {
          time = 0;
          playing = false;
        });
      } else {
        setState(() => time--);
      }
    });
  }

  void finishGame() {
    timer?.cancel();
    if (mounted) setState(() => playing = false);
  }

  void tapCell(int index) {
    if (!playing) return;
    final kind = widget.game.kind;

    if (kind == 'tap' || kind == 'timing' || kind == 'target') {
      if (index == target) {
        score += 20;
        target = random.nextInt(25);
      } else {
        score = max(0, score - 2);
      }
    } else if (kind == 'memory' || kind == 'match' || kind == 'cards') {
      if (index < opened.length && !opened[index]) {
        opened[index] = true;
        score += 10;
        if (opened.every((value) => value)) finishGame();
      }
    } else if (kind == '2048' || kind == 'merge') {
      final row = index ~/ 5;
      final col = index % 5;
      final neighbor =
          col < 4 ? index + 1 : (row > 0 ? index - 5 : index - 1);

      if (neighbor >= 0 &&
          neighbor < board.length &&
          board[neighbor] == board[index]) {
        board[neighbor]++;
        board[index] = 0;
        score += 20;
      } else {
        board[index] = (board[index] + 1) % 9;
      }
    } else if (kind == 'ttt') {
      if (index >= 9 || board[index] != 0) return;
      board[index] = 1;
      final empty = <int>[
        for (int i = 0; i < 9; i++)
          if (board[i] == 0) i,
      ];
      if (empty.isNotEmpty) {
        board[empty[random.nextInt(empty.length)]] = 2;
      }
      score += 5;
    } else if (kind == 'lights') {
      final positions = <int>[
        index,
        index - 1,
        index + 1,
        index - 5,
        index + 5,
      ];
      for (final position in positions) {
        if (position >= 0 && position < board.length) {
          board[position] = board[position] == 0 ? 1 : 0;
        }
      }
      score += 5;
    } else {
      board[index] = (board[index] + 1) % 9;
      score += 10;
      if (score >= 180) finishGame();
    }

    setState(() {});
  }

  Widget gameGrid(int columns) {
    final count = columns * columns;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final kind = widget.game.kind;
        String label = '•';

        if (kind == '2048' || kind == 'merge') {
          label = board[index] == 0 ? '' : '\${board[index] * 2}';
        } else if (kind == 'target' || kind == 'timing' || kind == 'tap') {
          label = index == target ? 'TARGET' : '';
        } else if (kind == 'memory' || kind == 'match' || kind == 'cards') {
          label = index < opened.length && opened[index] ? '✓' : '?';
        } else if (kind == 'ttt') {
          label = index < 9 && board[index] > 0
              ? (board[index] == 1 ? 'X' : 'O')
              : '';
        } else if (kind == 'lights') {
          label = board[index] == 1 ? 'ON' : '';
        }

        final color = Colors.primaries[index % Colors.primaries.length];

        return GestureDetector(
          onTap: () => tapCell(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: .55),
                  const Color(0xFF171B2A),
                ],
              ),
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
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
    final kind = widget.game.kind;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.title),
        actions: [
          IconButton(
            onPressed: reset,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _H('SCORE', score.toString())),
                const SizedBox(width: 8),
                Expanded(child: _H('TIME', '\${time}s')),
                const SizedBox(width: 8),
                Expanded(child: _H('MODE', _cat(kind))),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(27),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B1530), Color(0xFF0C1019)],
                  ),
                ),
                child: playing
                    ? gameGrid(kind == 'ttt' ? 3 : 5)
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _ico(kind),
                              size: 70,
                              color: Colors.deepPurpleAccent,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              time == 0 ? 'ROUND OVER' : 'READY TO PLAY',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              kind == '2048' || kind == 'merge'
                                  ? 'Merge matching tiles.'
                                  : kind == 'memory' || kind == 'match'
                                      ? 'Reveal the tiles and score points.'
                                      : 'Tap, solve, and chase your best score.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: playing ? null : startGame,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(playing ? 'PLAYING' : 'START GAME'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});
  @override State<MusicPage> createState()=>_MusicState();
}
class _MusicState extends State<MusicPage>{
  final AudioPlayer player=AudioPlayer();
  int selected=0;bool playing=false;bool shuffle=false;bool repeat=false;String query='';
  Duration position=Duration.zero,duration=Duration.zero;
  final liked=<String>{};
  final tracks=const [
    ('Nexora Intro','Nexora Studio',440.0,Color(0xFF7C3AED)),('Afterlight','Nexora Studio',330.0,Color(0xFF2563EB)),
    ('Night Drive','Nexora Studio',220.0,Color(0xFF0891B2)),('Pixel Rain','Nexora Studio',523.0,Color(0xFFDB2777)),
    ('Safe Horizon','Nexora Studio',294.0,Color(0xFF059669)),('Midnight Bloom','Nexora Studio',196.0,Color(0xFFD97706)),
    ('Digital Sunrise','Nexora Studio',392.0,Color(0xFFDC2626)),('Neon Memory','Nexora Studio',262.0,Color(0xFF4F46E5)),
  ];
  @override void initState(){super.initState();player.onPlayerStateChanged.listen((s){if(mounted)setState(()=>playing=s==PlayerState.playing);});player.onPositionChanged.listen((p){if(mounted)setState(()=>position=p);});player.onDurationChanged.listen((d){if(mounted)setState(()=>duration=d);});player.onPlayerComplete.listen((_)=>_completed());}
  void _completed(){if(repeat){playSelected();return;}selectTrack(shuffle?Random().nextInt(tracks.length):(selected+1)%tracks.length);}
  Uint8List _wav(double base){const sr=22050,seconds=12,channels=1,bits=16;final count=sr*seconds,dataBytes=count*2;final data=ByteData(44+dataBytes);void w32(int o,int v)=>data.setUint32(o,v,Endian.little);void w16(int o,int v)=>data.setUint16(o,v,Endian.little);void ascii(int o,String s){for(int i=0;i<s.length;i++){data.setUint8(o+i,s.codeUnitAt(i));}}ascii(0,'RIFF');w32(4,36+dataBytes);ascii(8,'WAVE');ascii(12,'fmt ');w32(16,16);w16(20,1);w16(22,channels);w32(24,sr);w32(28,sr*channels*bits~/8);w16(32,channels*bits~/8);w16(34,bits);ascii(36,'data');w32(40,dataBytes);for(int i=0;i<count;i++){final t=i/sr,fadeIn=min(1.0,t*8),fadeOut=min(1.0,(seconds-t)*4),env=fadeIn*fadeOut;final beat=(sin(2*pi*2.0*t)>0.88)?1.0:0.0;final melody=base*(1+0.035*sin(2*pi*.22*t));var sw=.20*sin(2*pi*melody*t)+.10*sin(2*pi*melody*1.5*t)+.055*sin(2*pi*melody*2*t)+beat*.07*sin(2*pi*(base/2)*t);data.setInt16(44+i*2,(sw*env*27000).clamp(-32768,32767).toInt(),Endian.little);}return data.buffer.asUint8List();}
  Future<void> playSelected() async{await player.play(BytesSource(_wav(tracks[selected].$3),mimeType:'audio/wav'));}
  Future<void> selectTrack(int i) async{await player.stop();if(!mounted)return;setState(() { selected=i; position=Duration.zero; });await playSelected();}
  void toggleLike(){setState(()=>liked.contains(tracks[selected].$1)?liked.remove(tracks[selected].$1):liked.add(tracks[selected].$1));}
  @override void dispose(){player.dispose();super.dispose();}
  @override Widget build(BuildContext context){final filtered=tracks.where((t)=>t.$1.toLowerCase().contains(query.toLowerCase())||t.$2.toLowerCase().contains(query.toLowerCase())).toList();final t=tracks[selected],maxMs=max(1,duration.inMilliseconds),value=min(position.inMilliseconds.toDouble(),maxMs.toDouble());return ListView(padding:const EdgeInsets.fromLTRB(16,16,16,110),children:[
    Row(children:[const Expanded(child:Text('Nexora Music',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900))),Chip(label: Text('${tracks.length} TRACKS'))]),const SizedBox(height:4),const Text('Player • Search • Queue • Repeat • Shuffle • Library'),const SizedBox(height:14),
    TextField(onChanged:(v)=>setState(()=>query=v),decoration:InputDecoration(prefixIcon:const Icon(Icons.search_rounded),hintText:'Cari lagu atau artis...',filled:true,border:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:BorderSide.none))),const SizedBox(height:18),
    Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(borderRadius:BorderRadius.circular(28),gradient:LinearGradient(colors:[t.$4,const Color(0xFF111522)])),child:Column(children:[
      Container(width:172,height:172,decoration:BoxDecoration(borderRadius:BorderRadius.circular(30),gradient:LinearGradient(colors:[t.$4.withValues(alpha:.9),Colors.black38])),child:const Icon(Icons.album_rounded,size:82)),const SizedBox(height:16),
      Text(t.$1,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900),textAlign:TextAlign.center),Text(t.$2),const SizedBox(height:5),Text(liked.contains(t.$1)?'Liked • Original Nexora':'Original Nexora',style:Theme.of(context).textTheme.bodySmall),
      Slider(value:value,min:0,max:maxMs.toDouble(),onChanged:(v)=>player.seek(Duration(milliseconds:v.toInt()))),Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(_fmt(position)),Text(_fmt(duration))]),
      Row(mainAxisAlignment:MainAxisAlignment.center,children:[IconButton(onPressed:()=>selectTrack((selected-1+tracks.length)%tracks.length),icon:const Icon(Icons.skip_previous_rounded,size:32)),FilledButton(onPressed:playing?()=>player.pause():playSelected,style:FilledButton.styleFrom(shape:const CircleBorder(),padding:const EdgeInsets.all(18)),child:Icon(playing?Icons.pause_rounded:Icons.play_arrow_rounded,size:30)),IconButton(onPressed:()=>selectTrack((selected+1)%tracks.length),icon:const Icon(Icons.skip_next_rounded,size:32))]),
      Row(mainAxisAlignment:MainAxisAlignment.center,children:[IconButton(onPressed:()=>setState(()=>shuffle=!shuffle),color:shuffle?Theme.of(context).colorScheme.primary:null,icon:const Icon(Icons.shuffle_rounded)),IconButton(onPressed:toggleLike,color:liked.contains(t.$1)?Theme.of(context).colorScheme.primary:null,icon:Icon(liked.contains(t.$1)?Icons.favorite_rounded:Icons.favorite_border_rounded)),IconButton(onPressed:()=>setState(()=>repeat=!repeat),color:repeat?Theme.of(context).colorScheme.primary:null,icon:const Icon(Icons.repeat_rounded))]),
    ])),const SizedBox(height:22),const _Title('Made for you'),const SizedBox(height:10),
    SizedBox(height:112,child:ListView(scrollDirection:Axis.horizontal,children:[_MusicCard('Daily Mix','Original Nexora',Icons.auto_awesome_rounded),_MusicCard('Game Focus','Arcade energy',Icons.sports_esports_rounded),_MusicCard('Late Night','Chill original',Icons.nightlight_rounded),_MusicCard('Liked Songs','Your favorites',Icons.favorite_rounded)])),const SizedBox(height:22),
    const _Title('Library'),const SizedBox(height:10),for(final tr in filtered)Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(leading:CircleAvatar(backgroundColor:tr.$4,child:const Icon(Icons.music_note_rounded)),title:Text(tr.$1,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(tr.$2),trailing:Icon(tr.$1==t.$1&&playing?Icons.pause_circle_filled:Icons.play_circle_outline_rounded),onTap:()=>selectTrack(tracks.indexOf(tr)))),
    const Card(child:ListTile(leading:Icon(Icons.info_outline_rounded),title:Text('Katalog Nexora'),subtitle:Text('Track bawaan ini adalah audio original/sintetis untuk demo player. Katalog lagu pihak lain membutuhkan lisensi atau integrasi resmi.'))),
  ]);}
  String _fmt(Duration d)=>'${d.inMinutes}:${(d.inSeconds%60).toString().padLeft(2,'0')}';
}
class _MusicCard extends StatelessWidget{final String title,sub;final IconData icon;const _MusicCard(this.title,this.sub,this.icon);@override Widget build(BuildContext context)=>Container(width:175,margin:const EdgeInsets.only(right:10),padding:const EdgeInsets.all(14),decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),color:const Color(0xFF111522)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[CircleAvatar(child:Icon(icon)),const Spacer(),Text(title,style:const TextStyle(fontWeight:FontWeight.w900)),Text(sub,style:const TextStyle(fontSize:11))]));}
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

class ProfilePage extends StatefulWidget{
  const ProfilePage({super.key});
  @override State<ProfilePage> createState()=>_ProfileState();
}
class _ProfileState extends State<ProfilePage>{
  GoogleSignInAccount? user;
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    const SizedBox(height:10),
    Center(child:user?.photoUrl!=null?CircleAvatar(radius:46,backgroundImage:NetworkImage(user!.photoUrl!)):const CircleAvatar(radius:46,child:Icon(Icons.person_rounded,size:46))),
    const SizedBox(height:12),
    Center(child:Text(user?.displayName??'Nexora Player',style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900))),
    Center(child:Text(user?.email??'@nexora_player')),
    const SizedBox(height:14),
    Center(child:FilledButton.icon(
      onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const GoogleLoginPage())),
      icon:const Icon(Icons.account_circle_rounded),label:Text(user==null?'Login dengan Google':'Kelola akun Google'),
    )),
    const SizedBox(height:20),
    const Row(children:[Expanded(child:_PStat('1','Level')),SizedBox(width:10),Expanded(child:_PStat('0','Posts')),SizedBox(width:10),Expanded(child:_PStat('0','Friends'))]),
    const SizedBox(height:18),const _Title('Account'),const Card(child:Column(children:[
      ListTile(leading:Icon(Icons.badge_rounded),title:Text('Rookie'),subtitle:Text('Member Nexora'),trailing:Icon(Icons.chevron_right_rounded)),
      Divider(height:1),ListTile(leading:Icon(Icons.verified_user_rounded),title:Text('Account security'),trailing:Icon(Icons.chevron_right_rounded)),
    ])),
  ]);
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
      leading:GoogleUserCircleAvatar(identity:user!),
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

class SettingsPage extends StatefulWidget{const SettingsPage({super.key});@override State<SettingsPage> createState()=>_SettingsState();}
class _SettingsState extends State<SettingsPage>{
  bool notifications=true,sound=true,animations=true;
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    const _Title('Preferences'),const SizedBox(height:8),Card(child:Column(children:[
      SwitchListTile(value:notifications,onChanged:(v)=>setState(()=>notifications=v),title:const Text('Notifications'),subtitle:const Text('Notifikasi Nexora')),
      const Divider(height:1),
      SwitchListTile(value:sound,onChanged:(v)=>setState(()=>sound=v),title:const Text('Sound'),subtitle:const Text('Suara aplikasi dan game')),
      const Divider(height:1),
      SwitchListTile(value:animations,onChanged:(v)=>setState(()=>animations=v),title:const Text('Animations'),subtitle:const Text('Animasi antarmuka')),
    ])),
    const SizedBox(height:18),const _Title('Security'),const Card(child:Column(children:[
      ListTile(leading:Icon(Icons.lock_rounded),title:Text('Password & Login'),trailing:Icon(Icons.chevron_right_rounded)),
      Divider(height:1),ListTile(leading:Icon(Icons.privacy_tip_rounded),title:Text('Privacy'),trailing:Icon(Icons.chevron_right_rounded)),
    ])),
  ]);
}
class AboutPage extends StatelessWidget{
  const AboutPage({super.key});
  @override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(28),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    const Icon(Icons.hexagon_rounded,size:82),const SizedBox(height:16),const Text('Nexora',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900)),const Text('Original mobile hub • V2'),const SizedBox(height:18),
    const Text('Game, music, community, dan marketplace dalam satu aplikasi original Nexora.',textAlign:TextAlign.center),
  ])));
}

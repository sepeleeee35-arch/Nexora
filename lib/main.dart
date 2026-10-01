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


class ArcadeGame {
  final String title;
  final String kind;
  final IconData icon;
  const ArcadeGame(this.title, this.kind, this.icon);
}

const _games = <ArcadeGame>[
  ArcadeGame('Neon Jump', 'jump', Icons.flash_on_rounded),
  ArcadeGame('Worm Arena', 'worm', Icons.circle_rounded),
  ArcadeGame('Nexora Chess', 'chess', Icons.grid_4x4_rounded),
  ArcadeGame('Road Rush', 'road', Icons.directions_car_rounded),
  ArcadeGame('Brick Smash', 'brick', Icons.view_module_rounded),
  ArcadeGame('Flap Orbit', 'flap', Icons.flutter_dash_rounded),
  ArcadeGame('Maze Escape', 'maze', Icons.route_rounded),
  ArcadeGame('Nexora 2048', '2048', Icons.add_box_rounded),
];

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});
  @override State<GamesPage> createState() => _GamesState();
}
class _GamesState extends State<GamesPage> {
  String query = '';
  Widget page(ArcadeGame g) {
    switch (g.kind) {
      case 'jump': return const NeonJumpPage();
      case 'worm': return const WormArenaPage();
      case 'chess': return const NexoraChessPage();
      case 'road': return const RoadRushPage();
      case 'brick': return const BrickSmashPage();
      case 'flap': return const FlapOrbitPage();
      case 'maze': return const MazeEscapePage();
      default: return const Mini2048Page();
    }
  }
  @override Widget build(BuildContext context) {
    final list = _games.where((g) => g.title.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(14,14,14,110),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(colors: [Color(0xFF6D28D9),Color(0xFF111827)]),
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.sports_esports_rounded, size: 34),
            SizedBox(height: 10),
            Text('NEXORA MINI GAMES', style: TextStyle(fontSize: 11,fontWeight: FontWeight.w900,letterSpacing: 1.5)),
            SizedBox(height: 4),
            Text('Main langsung.', style: TextStyle(fontSize: 28,fontWeight: FontWeight.w900)),
            SizedBox(height: 5),
            Text('Offline. Tanpa akun, koin, toko, leaderboard, atau fitur tambahan.'),
          ]),
        ),
        const SizedBox(height: 14),
        TextField(
          onChanged: (v) => setState(() => query = v),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: 'Cari game...',
            filled: true, fillColor: const Color(0xFF111522),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18),borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,crossAxisSpacing: 10,mainAxisSpacing: 10,childAspectRatio: .92,
          ),
          itemBuilder: (_,i) {
            final g=list[i];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.push(context,MaterialPageRoute(builder: (_) => page(g))),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withOpacity(.45),const Color(0xFF151827)]),
                      ),
                      child: Icon(g.icon,size:48),
                    )),
                    const SizedBox(height: 9),
                    Text(g.title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w900)),
                    const SizedBox(height:3),
                    const Text('OFFLINE',style:TextStyle(fontSize:9,fontWeight:FontWeight.w900,color:Colors.white54)),
                  ]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MiniScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback restart;
  const _MiniScaffold({required this.title,required this.child,required this.restart});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title,style:const TextStyle(fontWeight:FontWeight.w900)),
      actions:[IconButton(onPressed:restart,tooltip:'Restart',icon:const Icon(Icons.refresh_rounded))],
    ),
    body:child,
  );
}
class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);
  @override Widget build(BuildContext context)=>Container(
    padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),
    decoration:BoxDecoration(color:Colors.black54,borderRadius:BorderRadius.circular(12)),
    child:Text(text,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1)),
  );
}
class _Over extends StatelessWidget {
  final String title;
  final VoidCallback restart;
  const _Over({required this.title,required this.restart});
  @override Widget build(BuildContext context)=>Center(child:Container(
    padding:const EdgeInsets.all(24),margin:const EdgeInsets.all(24),
    decoration:BoxDecoration(color:const Color(0xFF111522),borderRadius:BorderRadius.circular(24),border:Border.all(color:Colors.white12)),
    child:Column(mainAxisSize:MainAxisSize.min,children:[
      Text(title,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900)),
      const SizedBox(height:16),
      FilledButton.icon(onPressed:restart,icon:const Icon(Icons.refresh_rounded),label:const Text('Main Lagi')),
    ]),
  ));
}

class NeonJumpPage extends StatefulWidget {
  const NeonJumpPage({super.key});
  @override State<NeonJumpPage> createState()=>_NeonJumpState();
}
class _NeonJumpState extends State<NeonJumpPage>{
  Timer? timer; double x=80,y=480,vy=0,camera=0; bool dead=false;
  final platforms=const [
    Rect.fromLTWH(0,520,380,24),Rect.fromLTWH(450,445,230,24),
    Rect.fromLTWH(760,365,220,24),Rect.fromLTWH(1050,470,250,24),
    Rect.fromLTWH(1370,390,220,24),Rect.fromLTWH(1660,315,260,24),
    Rect.fromLTWH(1990,430,300,24),
  ];
  final spikes=const [
    Rect.fromLTWH(350,496,30,24),Rect.fromLTWH(680,421,30,24),
    Rect.fromLTWH(1300,446,30,24),Rect.fromLTWH(1590,366,30,24),
  ];
  @override void initState(){super.initState();restart();}
  void restart(){
    timer?.cancel();
    setState((){x=80;y=486;vy=0;camera=0;dead=false;});
    timer=Timer.periodic(const Duration(milliseconds:16),(_)=>tick());
  }
  void jump(){if(dead){restart();return;}if(y>=450)vy=-10.5;}
  void tick(){
    if(!mounted||dead)return;
    setState((){
      x+=3.7;vy+=.45;y+=vy;
      final feet=y+34;
      for(final p in platforms){
        if(x+28>p.left&&x<p.right&&feet>=p.top&&feet<=p.bottom+18&&vy>0){y=p.top-34;vy=-10.2;}
      }
      camera=max(0,x-110);
      if(y>640||spikes.any((s)=>Rect.fromLTWH(x,y,30,34).overlaps(s))||x>2250){dead=true;timer?.cancel();}
    });
  }
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_MiniScaffold(
    title:'Neon Jump',restart:restart,
    child:GestureDetector(onTap:jump,child:Stack(children:[
      Positioned.fill(child:CustomPaint(painter:_NeonPainter(x,y,camera,platforms,spikes))),
      const Positioned(top:14,left:16,child:_Badge('TAP = JUMP')),
      if(dead)const SizedBox.shrink(),
      if(dead)Positioned.fill(child:_Over(title:'LEVEL END',restart:restart)),
    ])),
  );
}
class _NeonPainter extends CustomPainter{
  final double x,y,camera;final List<Rect> platforms,spikes;
  _NeonPainter(this.x,this.y,this.camera,this.platforms,this.spikes);
  @override void paint(Canvas c,Size s){
    c.drawRect(Offset.zero,Offset(s.width,s.height),Paint()..color=const Color(0xFF070A14));
    final grid=Paint()..color=const Color(0xFF171D32);
    for(double gx=-(camera%40);gx<s.width;gx+=40)c.drawLine(Offset(gx,0),Offset(gx,s.height),grid);
    for(double gy=0;gy<s.height;gy+=40)c.drawLine(Offset(0,gy),Offset(s.width,gy),grid);
    for(final r in platforms)c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(r.left-camera,r.top,r.width,r.height),const Radius.circular(7)),Paint()..color=const Color(0xFF7C3AED));
    for(final r in spikes){final p=Path()..moveTo(r.left-camera,r.bottom)..lineTo(r.center.dx-camera,r.top)..lineTo(r.right-camera,r.bottom)..close();c.drawPath(p,Paint()..color=const Color(0xFFEF4444));}
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-camera,y,34,34),const Radius.circular(8)),Paint()..color=const Color(0xFF22D3EE));
  }
  @override bool shouldRepaint(covariant _NeonPainter old)=>true;
}

class WormArenaPage extends StatefulWidget{const WormArenaPage({super.key});@override State<WormArenaPage> createState()=>_WormState();}
class _WormState extends State<WormArenaPage>{
  static const rows=18,cols=11;final rng=Random();Timer?timer;
  List<Point<int>> worm=[];Point<int> food=const Point(6,9),dir=const Point(0,-1),next=const Point(0,-1);bool dead=false;int score=0;
  @override void initState(){super.initState();restart();}
  void restart(){timer?.cancel();setState((){worm=[const Point(5,9),const Point(5,10),const Point(5,11)];dir=const Point(0,-1);next=const Point(0,-1);score=0;dead=false;placeFood();});timer=Timer.periodic(const Duration(milliseconds:135),(_)=>tick());}
  void placeFood(){Point<int> p;do{p=Point(rng.nextInt(cols),rng.nextInt(rows));}while(worm.contains(p));food=p;}
  void setDir(Point<int>d){if(d.x+dir.x==0&&d.y+dir.y==0)return;next=d;}
  void tick(){if(!mounted||dead)return;setState((){dir=next;final h=worm.first;final n=Point(h.x+dir.x,h.y+dir.y);if(n.x<0||n.x>=cols||n.y<0||n.y>=rows||worm.contains(n)){dead=true;timer?.cancel();return;}worm=[n,...worm];if(n==food){score++;placeFood();}else{worm.removeLast();}});}
  @override void dispose(){timer?.cancel();super.dispose();}
  Widget key(IconData i,Point<int>d)=>IconButton.filled(onPressed:()=>setDir(d),icon:Icon(i));
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Worm Arena',restart:restart,child:Column(children:[
    Padding(padding:const EdgeInsets.all(12),child:Row(children:[_Badge('FOOD '+score.toString()),const Spacer(),if(dead)const Text('GAME OVER',style:TextStyle(color:Colors.redAccent,fontWeight:FontWeight.w900))])),
    Expanded(child:Center(child:AspectRatio(aspectRatio:cols/rows,child:Container(margin:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFF101522),borderRadius:BorderRadius.circular(18)),child:CustomPaint(painter:_WormPainter(worm,food)))))),
    Row(mainAxisAlignment:MainAxisAlignment.center,children:[key(Icons.arrow_back_rounded,const Point(-1,0)),Column(children:[key(Icons.arrow_upward_rounded,const Point(0,-1)),key(Icons.arrow_downward_rounded,const Point(0,1))]),key(Icons.arrow_forward_rounded,const Point(1,0))]),
    const SizedBox(height:10),
  ]));
}
class _WormPainter extends CustomPainter{
  final List<Point<int>> worm;final Point<int> food;_WormPainter(this.worm,this.food);
  @override void paint(Canvas c,Size s){final cell=min(s.width/11,s.height/18),ox=(s.width-cell*11)/2,oy=(s.height-cell*18)/2;c.drawCircle(Offset(ox+food.x*cell+cell/2,oy+food.y*cell+cell/2),cell*.28,Paint()..color=const Color(0xFFEF4444));for(int i=worm.length-1;i>=0;i--){final p=worm[i];c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(ox+p.x*cell+2,oy+p.y*cell+2,cell-4,cell-4),const Radius.circular(7)),Paint()..color=i==0?const Color(0xFF22D3EE):const Color(0xFF8B5CF6));}}
  @override bool shouldRepaint(covariant _WormPainter old)=>true;
}

class NexoraChessPage extends StatefulWidget{const NexoraChessPage({super.key});@override State<NexoraChessPage> createState()=>_ChessState();}
class _ChessState extends State<NexoraChessPage>{
  final rng=Random();late List<String>b;int?sel;bool turn=true,busy=false,over=false;String msg='WHITE TURN';
  bool white(String p)=>'KQRBNP'.contains(p);
  bool inside(int r,int c)=>r>=0&&r<8&&c>=0&&c<8;
  @override void initState(){super.initState();restart();}
  void restart(){b=['r','n','b','q','k','b','n','r','p','p','p','p','p','p','p','p',...List.filled(32,''),'P','P','P','P','P','P','P','P','R','N','B','Q','K','B','N','R'];sel=null;turn=true;busy=false;over=false;msg='WHITE TURN';setState((){});}
  bool enemy(String p,bool w)=>p.isNotEmpty&&white(p)!=w;
  bool clear(int a,int z){final ar=a~/8,ac=a%8,br=z~/8,bc=z%8,dr=(br-ar).sign,dc=(bc-ac).sign;var r=ar+dr,c=ac+dc;while(r!=br||c!=bc){if(b[r*8+c].isNotEmpty)return false;r+=dr;c+=dc;}return true;}
  bool attacks(int a,int z,bool w){final p=b[a],ar=a~/8,ac=a%8,br=z~/8,bc=z%8,dr=br-ar,dc=bc-ac;switch(p.toUpperCase()){case'P':return dr==(w?-1:1)&&dc.abs()==1;case'N':return(dr.abs()==2&&dc.abs()==1)||(dr.abs()==1&&dc.abs()==2);case'K':return dr.abs()<=1&&dc.abs()<=1&&(dr!=0||dc!=0);case'B':return dr.abs()==dc.abs()&&clear(a,z);case'R':return(dr==0||dc==0)&&clear(a,z);case'Q':return(dr==0||dc==0||dr.abs()==dc.abs())&&clear(a,z);}return false;}
  bool check(bool w){final k=b.indexOf(w?'K':'k');if(k<0)return true;for(int i=0;i<64;i++)if(b[i].isNotEmpty&&white(b[i])!=w&&attacks(i,k,!w))return true;return false;}
  List<int> pseudo(int a,bool w){final p=b[a],r=a~/8,c=a%8,out=<int>[];void add(int rr,int cc){if(!inside(rr,cc))return;final i=rr*8+cc;if(b[i].isEmpty||enemy(b[i],w))out.add(i);}if(p.toUpperCase()=='P'){final d=w?-1:1,st=w?6:1;if(inside(r+d,c)&&b[(r+d)*8+c].isEmpty){out.add((r+d)*8+c);if(r==st&&b[(r+2*d)*8+c].isEmpty)out.add((r+2*d)*8+c);}for(final dc in[-1,1])if(inside(r+d,c+dc)&&enemy(b[(r+d)*8+c+dc],w))out.add((r+d)*8+c+dc);}else if(p.toUpperCase()=='N'){for(final d in[[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]])add(r+d[0],c+d[1]);}else if(p.toUpperCase()=='K'){for(int rr=-1;rr<=1;rr++)for(int cc=-1;cc<=1;cc++)if(rr!=0||cc!=0)add(r+rr,c+cc);}else{final ds=<List<int>>[];if(p.toUpperCase()=='B'||p.toUpperCase()=='Q')ds.addAll([[-1,-1],[-1,1],[1,-1],[1,1]]);if(p.toUpperCase()=='R'||p.toUpperCase()=='Q')ds.addAll([[-1,0],[1,0],[0,-1],[0,1]]);for(final d in ds){var rr=r+d[0],cc=c+d[1];while(inside(rr,cc)){final i=rr*8+cc;if(b[i].isEmpty)out.add(i);else{if(enemy(b[i],w))out.add(i);break;}rr+=d[0];cc+=d[1];}}}return out;}
  List<int> legal(int a,bool w){final out=<int>[];for(final z in pseudo(a,w)){final p=b[a],old=b[z];b[z]=p;b[a]='';if(p=='P'&&z~/8==0)b[z]='Q';if(p=='p'&&z~/8==7)b[z]='q';if(!check(w))out.add(z);b[a]=p;b[z]=old;}return out;}
  List<List<int>> all(bool w){final out=<List<int>>[];for(int i=0;i<64;i++)if(b[i].isNotEmpty&&white(b[i])==w)for(final z in legal(i,w))out.add([i,z]);return out;}
  void tap(int i){if(over||busy||!turn)return;if(sel==null){if(b[i].isNotEmpty&&white(b[i]))setState(()=>sel=i);return;}if(legal(sel!,true).contains(i)){move(sel!,i,true);}else if(b[i].isNotEmpty&&white(b[i]))setState(()=>sel=i);else setState(()=>sel=null);}
  void move(int a,int z,bool w){setState((){final p=b[a];b[z]=p;b[a]='';if(p=='P'&&z~/8==0)b[z]='Q';sel=null;turn=!turn;msg='BOT TURN';});end();if(!over&&!turn){busy=true;Future.delayed(const Duration(milliseconds:300),bot);}}
  void bot(){if(!mounted||over)return;final m=all(false);if(m.isEmpty){setState(()=>busy=false);end();return;}final q=m[rng.nextInt(m.length)],p=b[q[0]];setState((){b[q[1]]=p;b[q[0]]='';if(p=='p'&&q[1]~/8==7)b[q[1]]='q';turn=true;busy=false;msg='WHITE TURN';});end();}
  void end(){final m=all(turn);if(m.isEmpty){setState((){over=true;msg=check(turn)?'CHECKMATE':'STALEMATE';});}}
  String glyph(String p){const m={'K':'♔','Q':'♕','R':'♖','B':'♗','N':'♘','P':'♙','k':'♚','q':'♛','r':'♜','b':'♝','n':'♞','p':'♟'};return m[p]??'';}
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Nexora Chess',restart:restart,child:Column(children:[
    Padding(padding:const EdgeInsets.all(10),child:Row(children:[Text(msg,style:const TextStyle(fontWeight:FontWeight.w900)),const Spacer(),const Text('OFFLINE BOT',style:TextStyle(color:Colors.white54,fontSize:10))])),
    Expanded(child:Center(child:AspectRatio(aspectRatio:1,child:GridView.builder(itemCount:64,physics:const NeverScrollableScrollPhysics(),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:8),itemBuilder:(_,i){final r=i~/8,c=i%8,light=(r+c).isEven;return GestureDetector(onTap:()=>tap(i),child:Container(color:sel==i?const Color(0xFF22D3EE):(light?const Color(0xFFD6D3D1):const Color(0xFF57534E)),child:Center(child:Text(glyph(b[i]),style:TextStyle(fontSize:27,color:white(b[i])?Colors.white:Colors.black87)))));})))),
    if(over)Padding(padding:const EdgeInsets.all(10),child:Text(msg,style:const TextStyle(fontWeight:FontWeight.w900))),
  ]));
}

class RoadRushPage extends StatefulWidget{const RoadRushPage({super.key});@override State<RoadRushPage> createState()=>_RoadState();}
class _Car{double lane,y;_Car(this.lane,this.y);}
class _RoadState extends State<RoadRushPage>{
  Timer?timer;final rng=Random();double lane=1;List<_Car>cars=[];int score=0;bool dead=false;
  @override void initState(){super.initState();restart();}
  void restart(){timer?.cancel();setState((){lane=1;cars=[];score=0;dead=false;});timer=Timer.periodic(const Duration(milliseconds:35),(_)=>tick());}
  void tick(){if(!mounted||dead)return;setState((){for(final c in cars)c.y+=.012;cars.removeWhere((c)=>c.y>1.1);if(rng.nextDouble()<.035)cars.add(_Car(rng.nextInt(3).toDouble(),-.1));score++;if(cars.any((c)=>(c.lane-lane).abs()<.25&&c.y>.78&&c.y<.94)){dead=true;timer?.cancel();}});}
  void move(double d){setState(()=>lane=(lane+d).clamp(0,2));}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Road Rush',restart:restart,child:GestureDetector(onHorizontalDragEnd:(d)=>move(d.primaryVelocity!>0?1:-1),child:Stack(children:[
    Positioned.fill(child:CustomPaint(painter:_RoadPainter(lane,cars))),
    Positioned(top:14,left:16,child:_Badge('TIME '+(score~/20).toString())),
    Positioned(bottom:18,left:0,right:0,child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[IconButton.filled(onPressed:()=>move(-1),icon:const Icon(Icons.chevron_left)),const SizedBox(width:80),IconButton.filled(onPressed:()=>move(1),icon:const Icon(Icons.chevron_right))])),
    if(dead)Positioned.fill(child:_Over(title:'CRASH',restart:restart)),
  ])));
}
class _RoadPainter extends CustomPainter{
  final double lane;final List<_Car>cars;_RoadPainter(this.lane,this.cars);
  @override void paint(Canvas c,Size s){c.drawRect(Offset.zero,Offset(s.width,s.height),Paint()..color=const Color(0xFF102016));final road=Rect.fromLTWH(s.width*.1,0,s.width*.8,s.height);c.drawRect(road,Paint()..color=const Color(0xFF242833));final dash=Paint()..color=Colors.white24..strokeWidth=4;for(int l=1;l<3;l++){final x=road.left+road.width*l/3;for(double y=-30;y<s.height;y+=55)c.drawLine(Offset(x,y),Offset(x,y+25),dash);}final px=road.left+road.width*(lane+.5)/3;c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(px-25,s.height*.84,50,70),const Radius.circular(12)),Paint()..color=const Color(0xFF22D3EE));for(final car in cars){final x=road.left+road.width*(car.lane+.5)/3;c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-23,car.y*s.height,46,66),const Radius.circular(11)),Paint()..color=const Color(0xFFEF4444));}}
  @override bool shouldRepaint(covariant _RoadPainter old)=>true;
}

class BrickSmashPage extends StatefulWidget{const BrickSmashPage({super.key});@override State<BrickSmashPage> createState()=>_BrickState();}
class _BrickState extends State<BrickSmashPage>{
  Timer?timer;double bx=.5,by=.75,vx=.006,vy=-.009,paddle=.5;List<bool>bricks=List.filled(30,true);bool dead=false;
  @override void initState(){super.initState();restart();}
  void restart(){timer?.cancel();setState((){bx=.5;by=.75;vx=.006;vy=-.009;paddle=.5;bricks=List.filled(30,true);dead=false;});timer=Timer.periodic(const Duration(milliseconds:16),(_)=>tick());}
  void tick(){if(!mounted||dead)return;setState((){bx+=vx;by+=vy;if(bx<.03||bx>.97)vx=-vx;if(by<.03)vy=vy.abs();if(by>.82&&by<.94&&(bx-paddle).abs()<.15)vy=-vy.abs();for(int i=0;i<30;i++)if(bricks[i]){final col=i%5,row=i~/5,l=.05+col*.19,t=.1+row*.06;if(bx>l&&bx<l+.16&&by>t&&by<t+.045){bricks[i]=false;vy=-vy;break;}}if(by>1.05||bricks.every((v)=>!v)){dead=true;timer?.cancel();}});}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Brick Smash',restart:restart,child:GestureDetector(onHorizontalDragUpdate:(d)=>setState(()=>paddle=(paddle+d.delta.dx/MediaQuery.sizeOf(context).width).clamp(.12,.88)),child:Stack(children:[
    Positioned.fill(child:CustomPaint(painter:_BrickPainter(bx,by,paddle,bricks))),
    if(dead)Positioned.fill(child:_Over(title:bricks.every((v)=>!v)?'CLEAR':'GAME OVER',restart:restart)),
  ])));
}
class _BrickPainter extends CustomPainter{
  final double x,y,p;final List<bool>b;_BrickPainter(this.x,this.y,this.p,this.b);
  @override void paint(Canvas c,Size s){c.drawRect(Offset.zero,Offset(s.width,s.height),Paint()..color=const Color(0xFF080B14));for(int i=0;i<30;i++)if(b[i]){final col=i%5,row=i~/5;c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*(.05+col*.19),s.height*(.08+row*.055),s.width*.17,s.height*.04),const Radius.circular(6)),Paint()..color=const Color(0xFF8B5CF6));}c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*(p-.12),s.height*.92,s.width*.24,12),const Radius.circular(10)),Paint()..color=Colors.white);c.drawCircle(Offset(x*s.width,y*s.height),9,Paint()..color=const Color(0xFF22D3EE));}
  @override bool shouldRepaint(covariant _BrickPainter old)=>true;
}

class FlapOrbitPage extends StatefulWidget{const FlapOrbitPage({super.key});@override State<FlapOrbitPage> createState()=>_FlapState();}
class _FlapState extends State<FlapOrbitPage>{
  Timer?timer;final rng=Random();double y=.5,vy=0,px=1.1,g=.5;int score=0;bool dead=false;
  @override void initState(){super.initState();restart();}
  void restart(){timer?.cancel();setState((){y=.5;vy=0;px=1.1;g=.5;score=0;dead=false;});timer=Timer.periodic(const Duration(milliseconds:16),(_)=>tick());}
  void flap(){if(dead){restart();return;}setState(()=>vy=-.011);}
  void tick(){if(!mounted||dead)return;setState((){vy+=.00055;y+=vy;px-=.006;if(px<-.15){px=1.1;g=.3+rng.nextDouble()*.4;score++;}if(y<.02||y>.98||(px<.62&&px>.36&&(y<g-.16||y>g+.16))){dead=true;timer?.cancel();}});}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Flap Orbit',restart:restart,child:GestureDetector(onTap:flap,child:Stack(children:[
    Positioned.fill(child:CustomPaint(painter:_FlapPainter(y,px,g))),
    const Positioned(top:14,left:16,child:_Badge('TAP TO FLY')),
    if(dead)Positioned.fill(child:_Over(title:'GAME OVER',restart:restart)),
  ])));
}
class _FlapPainter extends CustomPainter{
  final double y,x,g;_FlapPainter(this.y,this.x,this.g);
  @override void paint(Canvas c,Size s){c.drawRect(Offset.zero,Offset(s.width,s.height),Paint()..color=const Color(0xFF08131A));final p=Paint()..color=const Color(0xFF16A34A);c.drawRect(Rect.fromLTWH(x*s.width,0,s.width*.12,s.height*(g-.16)),p);c.drawRect(Rect.fromLTWH(x*s.width,s.height*(g+.16),s.width*.12,s.height),p);c.drawCircle(Offset(s.width*.5,y*s.height),18,Paint()..color=const Color(0xFFFBBF24));}
  @override bool shouldRepaint(covariant _FlapPainter old)=>true;
}

class MazeEscapePage extends StatefulWidget{const MazeEscapePage({super.key});@override State<MazeEscapePage> createState()=>_MazeState();}
class _MazeState extends State<MazeEscapePage>{
  static const map=['1111111111','1000000001','1011111101','1010000101','1010110101','1000100101','1110101101','1000100001','1011111101','1000000001','1111111111'];
  int r=1,c=1,moves=0;bool win=false;
  void restart(){setState((){r=1;c=1;moves=0;win=false;});}
  void go(int dr,int dc){if(win)return;final nr=r+dr,nc=c+dc;if(map[nr][nc]=='0')setState((){r=nr;c=nc;moves++;if(r==9&&c==8)win=true;});}
  Widget key(IconData i,int dr,int dc)=>IconButton.filled(onPressed:()=>go(dr,dc),icon:Icon(i));
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Maze Escape',restart:restart,child:Column(children:[
    Padding(padding:const EdgeInsets.all(10),child:Row(children:[_Badge('MOVES '+moves.toString()),const Spacer(),if(win)const Text('ESCAPED',style:TextStyle(color:Colors.greenAccent,fontWeight:FontWeight.w900))])),
    Expanded(child:Center(child:AspectRatio(aspectRatio:10/11,child:CustomPaint(painter:_MazePainter(map,r,c))))),
    Row(mainAxisAlignment:MainAxisAlignment.center,children:[key(Icons.arrow_back,0,-1),Column(children:[key(Icons.arrow_upward,-1,0),key(Icons.arrow_downward,1,0)]),key(Icons.arrow_forward,0,1)]),
    const SizedBox(height:10),
  ]));
}
class _MazePainter extends CustomPainter{
  final List<String>m;final int r,c;_MazePainter(this.m,this.r,this.c);
  @override void paint(Canvas p,Size s){final cell=min(s.width/10,s.height/11);for(int y=0;y<11;y++)for(int x=0;x<10;x++)p.drawRect(Rect.fromLTWH(x*cell,y*cell,cell,cell),Paint()..color=m[y][x]=='1'?const Color(0xFF312E81):const Color(0xFF111827));p.drawCircle(Offset(c*cell+cell/2,r*cell+cell/2),cell*.3,Paint()..color=const Color(0xFF22D3EE));p.drawCircle(Offset(8*cell+cell/2,9*cell+cell/2),cell*.23,Paint()..color=const Color(0xFF22C55E));}
  @override bool shouldRepaint(covariant _MazePainter old)=>true;
}

class Mini2048Page extends StatefulWidget{const Mini2048Page({super.key});@override State<Mini2048Page> createState()=>_2048State();}
class _2048State extends State<Mini2048Page>{
  final rng=Random();List<int>b=List.filled(16,0);int score=0;
  @override void initState(){super.initState();restart();}
  void restart(){setState((){b=List.filled(16,0);score=0;add();add();});}
  void add(){final e=[for(int i=0;i<16;i++)if(b[i]==0)i];if(e.isNotEmpty)b[e[rng.nextInt(e.length)]]=rng.nextDouble()<.9?2:4;}
  List<int> merge(List<int>a){final v=a.where((x)=>x>0).toList();for(int i=0;i<v.length-1;i++)if(v[i]==v[i+1]){v[i]*=2;score+=v[i];v.removeAt(i+1);}while(v.length<4)v.add(0);return v;}
  void move(int dr,int dc){final old=List<int>.from(b);if(dr==0){for(int r=0;r<4;r++){final a=[for(int c=0;c<4;c++)b[r*4+c]];final q=merge(dc<0?a:a.reversed.toList());final z=dc<0?q:q.reversed.toList();for(int c=0;c<4;c++)b[r*4+c]=z[c];}}else{for(int c=0;c<4;c++){final a=[for(int r=0;r<4;r++)b[r*4+c]];final q=merge(dr<0?a:a.reversed.toList());final z=dr<0?q:q.reversed.toList();for(int r=0;r<4;r++)b[r*4+c]=z[r];}}if(old.toString()!=b.toString())setState(add);}
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Nexora 2048',restart:restart,child:GestureDetector(
    onHorizontalDragEnd:(d){final v=d.primaryVelocity??0;move(0,v>0?1:-1);},
    onVerticalDragEnd:(d){final v=d.primaryVelocity??0;move(v>0?1:-1,0);},
    child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
      Row(children:[_Badge('SCORE '+score.toString()),const Spacer(),const Text('SWIPE',style:TextStyle(color:Colors.white54,fontWeight:FontWeight.w900))]),
      const SizedBox(height:14),
      Expanded(child:Center(child:AspectRatio(aspectRatio:1,child:GridView.builder(itemCount:16,physics:const NeverScrollableScrollPhysics(),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:4,crossAxisSpacing:8,mainAxisSpacing:8),itemBuilder:(_,i)=>Container(decoration:BoxDecoration(color:b[i]==0?const Color(0xFF1A1E2A):const Color(0xFF6D28D9),borderRadius:BorderRadius.circular(12)),child:Center(child:Text(b[i]==0?'':b[i].toString(),style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900)))))))),
    ])),
  ));
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

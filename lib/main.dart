// Nexora production redeploy: game start/level/audio verification
// ignore_for_file: unused_element, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_interpolation_to_compose_strings, camel_case_types
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
          onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const NeonJumpPage())),
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

class GamePreview extends StatelessWidget{
  final String kind;
  const GamePreview({required this.kind,super.key});
  @override Widget build(BuildContext context)=>CustomPaint(painter:_GamePreviewPainter(kind),child:const SizedBox.expand());
}
class _GamePreviewPainter extends CustomPainter{
  final String kind;
  _GamePreviewPainter(this.kind);
  @override void paint(Canvas c,Size s){
    final p=Paint()..isAntiAlias=true;
    p.color=const Color(0xFF0B1020);c.drawRect(Offset.zero&s,p);
    void rr(Rect r,Color color,{double radius=8}){p.color=color;c.drawRRect(RRect.fromRectAndRadius(r,Radius.circular(radius)),p);}
    if(kind=='jump'){
      rr(Rect.fromLTWH(10,s.height*.72,s.width*.42,9),const Color(0xFF8B5CF6));
      rr(Rect.fromLTWH(s.width*.58,s.height*.48,s.width*.30,9),const Color(0xFF8B5CF6));
      p.color=const Color(0xFF22D3EE);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*.25,s.height*.42,18,18),const Radius.circular(4)),p);
      p.color=const Color(0xFFEF4444);final spike=Path()..moveTo(s.width*.43,s.height*.72)..lineTo(s.width*.48,s.height*.58)..lineTo(s.width*.53,s.height*.72)..close();c.drawPath(spike,p);
    }else if(kind=='worm'){
      p.color=const Color(0xFF8B5CF6);for(int i=0;i<4;i++)c.drawCircle(Offset(s.width*.42-i*15,s.height*.56),8,p);
      p.color=const Color(0xFF22D3EE);c.drawCircle(Offset(s.width*.42,s.height*.56),9,p);
      p.color=const Color(0xFFEF4444);c.drawCircle(Offset(s.width*.70,s.height*.35),7,p);
    }else if(kind=='chess'){
      final cell=min(s.width,s.height)/8;
      for(int r=0;r<8;r++)for(int q=0;q<8;q++){p.color=(r+q).isEven?const Color(0xFFD6D3D1):const Color(0xFF57534E);c.drawRect(Rect.fromLTWH(q*cell,r*cell,cell,cell),p);}
      const glyphs=['♜','♞','♝','♛','♚','♝','♞','♜'];
      for(int i=0;i<8;i++){final tp=TextPainter(text:TextSpan(text:glyphs[i],style:const TextStyle(fontSize:16,color:Colors.black87)),textDirection:TextDirection.ltr)..layout();tp.paint(c,Offset(i*cell+(cell-tp.width)/2,3));}
    }else if(kind=='road'){
      p.color=const Color(0xFF252936);c.drawRect(Rect.fromLTWH(s.width*.18,0,s.width*.64,s.height),p);
      p.color=Colors.white24;p.strokeWidth=3;for(int i=1;i<3;i++)for(double y=0;y<s.height;y+=22)c.drawLine(Offset(s.width*(.18+.64*i/3),y),Offset(s.width*(.18+.64*i/3),y+10),p);
      rr(Rect.fromLTWH(s.width*.44,s.height*.66,30,45),const Color(0xFF22D3EE),radius:6);rr(Rect.fromLTWH(s.width*.62,s.height*.22,28,42),const Color(0xFFEF4444),radius:6);
    }else if(kind=='brick'){
      for(int r=0;r<3;r++)for(int q=0;q<5;q++)rr(Rect.fromLTWH(8+q*(s.width-16)/5,10+r*19,(s.width-22)/5,14),const Color(0xFF8B5CF6),radius:4);
      rr(Rect.fromLTWH(s.width*.35,s.height*.78,s.width*.30,8),Colors.white,radius:4);p.color=const Color(0xFF22D3EE);c.drawCircle(Offset(s.width*.5,s.height*.68),7,p);
    }else if(kind=='flap'){
      p.color=const Color(0xFFFBBF24);c.drawCircle(Offset(s.width*.34,s.height*.50),11,p);
      rr(Rect.fromLTWH(s.width*.68,0,35,s.height*.34),const Color(0xFF16A34A),radius:4);
      rr(Rect.fromLTWH(s.width*.68,s.height*.66,35,s.height*.34),const Color(0xFF16A34A),radius:4);
    }else if(kind=='maze'){
      p.color=const Color(0xFF312E81);for(int r=0;r<6;r++)for(int q=0;q<8;q++)if((r+q)%3!=1)c.drawRect(Rect.fromLTWH(q*s.width/8,r*s.height/6,s.width/8-2,s.height/6-2),p);
      p.color=const Color(0xFF22D3EE);c.drawCircle(Offset(s.width*.18,s.height*.18),7,p);p.color=const Color(0xFF22C55E);c.drawCircle(Offset(s.width*.82,s.height*.82),7,p);
    }else{
      for(int i=0;i<4;i++){final vals=['2','4','8','2048'];final x=8+i*((s.width-24)/4);rr(Rect.fromLTWH(x,s.height*.35,(s.width-32)/4,34),const Color(0xFF6D28D9),radius:6);final tp=TextPainter(text:TextSpan(text:vals[i],style:TextStyle(fontSize:i==3?10:14,fontWeight:FontWeight.w900,color:Colors.white)),textDirection:TextDirection.ltr)..layout();tp.paint(c,Offset(x+((s.width-32)/4-tp.width)/2,s.height*.35+9));}
    }
  }
  @override bool shouldRepaint(covariant _GamePreviewPainter old)=>old.kind!=kind;
}

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
                      child: GamePreview(kind:g.kind),
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


class _GameAudio {
  final AudioPlayer player=AudioPlayer();
  Future<void> start(double base,{double volume=.16}) async {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setVolume(volume);
    await player.play(BytesSource(_gameWav(base),mimeType:'audio/wav'));
  }
  Future<void> stop() async {await player.stop();}
  Future<void> dispose() async {await player.dispose();}
}
Uint8List _gameWav(double base,{int seconds=6}){
  const sr=22050;final count=sr*seconds,bytes=count*2;final d=ByteData(44+bytes);
  void w32(int o,int v)=>d.setUint32(o,v,Endian.little);void w16(int o,int v)=>d.setUint16(o,v,Endian.little);
  void txt(int o,String v){for(var i=0;i<v.length;i++)d.setUint8(o+i,v.codeUnitAt(i));}
  txt(0,'RIFF');w32(4,36+bytes);txt(8,'WAVE');txt(12,'fmt ');w32(16,16);w16(20,1);w16(22,1);w32(24,sr);w32(28,sr*2);w16(32,2);w16(34,16);txt(36,'data');w32(40,bytes);
  for(var i=0;i<count;i++){final t=i/sr;final f=base*[1,1.25,1.5,1.875][(t*2).floor()%4];final env=min(1.0,t*8)*min(1.0,(seconds-t)*5);final v=(.17*sin(2*pi*f*t)+.08*sin(2*pi*f*2*t)+.05*sin(2*pi*base/2*t))*env;d.setInt16(44+i*2,(v*26000).clamp(-32768,32767).toInt(),Endian.little);}
  return d.buffer.asUint8List();
}
class _GameStart extends StatelessWidget{
  final String title,description,extra;final VoidCallback onStart;
  const _GameStart({required this.title,required this.description,required this.extra,required this.onStart});
  @override Widget build(BuildContext context)=>Center(child:Container(margin:const EdgeInsets.all(22),padding:const EdgeInsets.all(24),decoration:BoxDecoration(color:const Color(0xFF111522),borderRadius:BorderRadius.circular(26),border:Border.all(color:Colors.white12)),child:Column(mainAxisSize:MainAxisSize.min,children:[
    const Icon(Icons.sports_esports_rounded,size:54),const SizedBox(height:14),Text(title,textAlign:TextAlign.center,style:const TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const SizedBox(height:8),Text(description,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white70,height:1.45)),const SizedBox(height:12),Text(extra,textAlign:TextAlign.center,style:TextStyle(color:Theme.of(context).colorScheme.primary,fontWeight:FontWeight.w800)),const SizedBox(height:22),
    SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:onStart,icon:const Icon(Icons.play_arrow_rounded),label:const Text('START GAME'),style:FilledButton.styleFrom(padding:const EdgeInsets.symmetric(vertical:15)))),
  ])));
}
class _GamePauseButton extends StatelessWidget{
  final bool paused;final VoidCallback onTap;const _GamePauseButton({required this.paused,required this.onTap});
  @override Widget build(BuildContext context)=>IconButton.filledTonal(onPressed:onTap,tooltip:paused?'Resume':'Pause',icon:Icon(paused?Icons.play_arrow_rounded:Icons.pause_rounded));
}

class NeonJumpPage extends StatefulWidget{const NeonJumpPage({super.key});@override State<NeonJumpPage> createState()=>_NeonJumpState();}
class _NeonJumpState extends State<NeonJumpPage>{
  Timer?timer;final audio=_GameAudio();int level=1,score=0;double x=80,y=486,vy=0,camera=0;bool started=false,dead=false,paused=false;
  final levels=<List<Rect>>[
    [const Rect.fromLTWH(0,520,420,24),const Rect.fromLTWH(490,455,250,24),const Rect.fromLTWH(810,385,230,24),const Rect.fromLTWH(1120,470,250,24),const Rect.fromLTWH(1450,390,250,24),const Rect.fromLTWH(1780,325,280,24),const Rect.fromLTWH(2140,430,330,24)],
    [const Rect.fromLTWH(0,520,360,24),const Rect.fromLTWH(430,470,190,24),const Rect.fromLTWH(700,405,190,24),const Rect.fromLTWH(970,340,190,24),const Rect.fromLTWH(1240,430,190,24),const Rect.fromLTWH(1510,350,220,24),const Rect.fromLTWH(1810,280,230,24),const Rect.fromLTWH(2120,420,320,24)],
    [const Rect.fromLTWH(0,520,330,24),const Rect.fromLTWH(400,420,170,24),const Rect.fromLTWH(650,500,170,24),const Rect.fromLTWH(900,350,170,24),const Rect.fromLTWH(1160,445,170,24),const Rect.fromLTWH(1420,330,190,24),const Rect.fromLTWH(1700,430,190,24),const Rect.fromLTWH(1980,300,200,24),const Rect.fromLTWH(2270,430,260,24)],
    [const Rect.fromLTWH(0,520,300,24),const Rect.fromLTWH(370,450,150,24),const Rect.fromLTWH(600,360,150,24),const Rect.fromLTWH(830,460,150,24),const Rect.fromLTWH(1060,330,150,24),const Rect.fromLTWH(1290,410,150,24),const Rect.fromLTWH(1520,300,150,24),const Rect.fromLTWH(1750,390,150,24),const Rect.fromLTWH(1980,280,170,24),const Rect.fromLTWH(2230,430,270,24)],
    [const Rect.fromLTWH(0,520,280,24),const Rect.fromLTWH(340,420,135,24),const Rect.fromLTWH(550,500,135,24),const Rect.fromLTWH(770,370,135,24),const Rect.fromLTWH(990,450,135,24),const Rect.fromLTWH(1210,320,135,24),const Rect.fromLTWH(1430,400,135,24),const Rect.fromLTWH(1650,290,135,24),const Rect.fromLTWH(1870,370,135,24),const Rect.fromLTWH(2090,260,160,24),const Rect.fromLTWH(2320,430,260,24)]
  ];
  List<Rect>platforms=[],spikes=[];
  @override void initState(){super.initState();_load();}
  void _load(){platforms=levels[level-1];spikes=[for(int i=0;i<platforms.length-1;i++)if(i%2==0)Rect.fromLTWH(platforms[i].right-28,platforms[i].top-24,28,24)];}
  Future<void> startGame() async{timer?.cancel();_load();setState((){started=true;dead=false;paused=false;score=0;x=80;y=486;vy=0;camera=0;});unawaited(audio.start(240+level*25,volume:.20));timer=Timer.periodic(const Duration(milliseconds:16),(_)=>tick());}
  void restart(){timer?.cancel();audio.stop();if(mounted)setState((){started=false;dead=false;paused=false;level=1;score=0;x=80;y=486;vy=0;camera=0;_load();});}
  void jump(){if(!started||paused)return;if(y>=450)vy=-10.5;}
  void tick(){if(!mounted||!started||dead||paused)return;setState((){x+=3.7;vy+=.45;y+=vy;final feet=y+34;for(final p in platforms)if(x+28>p.left&&x<p.right&&feet>=p.top&&feet<=p.bottom+18&&vy>0){y=p.top-34;vy=-10.2;}camera=max(0,x-110);score=(x/10).floor();if(y>640||spikes.any((q)=>Rect.fromLTWH(x,y,30,34).overlaps(q))){dead=true;timer?.cancel();audio.stop();}else if(x>platforms.last.right-50){timer?.cancel();audio.stop();if(level<5){level++;_load();started=false;}else{dead=true;}}});}
  @override void dispose(){timer?.cancel();audio.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Neon Jump',restart:restart,child:Stack(children:[
    Positioned.fill(child:CustomPaint(painter:_NeonPainter(x,y,camera,platforms,spikes))),
    if(!started)Positioned.fill(child:Container(color:Colors.black45,child:_GameStart(title:'Neon Jump • Level '+level.toString(),description:'Auto-run seperti rhythm runner: tap untuk lompat dan hindari spike.',extra:'LEVEL '+level.toString()+' / 5 • Backsound ON saat mulai',onStart:startGame))),
    if(started)Positioned(top:12,left:12,child:Row(children:[_Badge('LEVEL '+level.toString()),const SizedBox(width:8),_Badge('SCORE '+score.toString())])),
    if(started)Positioned(top:12,right:12,child:_GamePauseButton(paused:paused,onTap:(){setState(()=>paused=!paused);})),
    if(started)Positioned.fill(child:GestureDetector(onTap:jump,behavior:HitTestBehavior.opaque)),
    if(dead)Positioned.fill(child:_Over(title:level==5?'ALL LEVELS CLEAR':'LEVEL FAILED',restart:restart)),
  ]));
}
class _NeonPainter extends CustomPainter{
  final double x,y,camera;final List<Rect> platforms,spikes;
  _NeonPainter(this.x,this.y,this.camera,this.platforms,this.spikes);
  @override void paint(Canvas c,Size s){
    c.drawRect(Rect.fromLTWH(0,0,s.width,s.height),Paint()..color=const Color(0xFF070A14));
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
  static const rows=18,cols=11;final rng=Random();Timer?timer;List<Point<int>>worm=[];Point<int>food=const Point(6,9),dir=const Point(0,-1),next=const Point(0,-1);bool started=false,dead=false,paused=false;int score=0,level=1;
  @override void initState(){super.initState();_reset();}
  void _reset(){worm=[const Point(5,9),const Point(5,10),const Point(5,11)];_placeFood();}
  void _placeFood(){Point<int>p;do{p=Point(rng.nextInt(cols),rng.nextInt(rows));}while(worm.contains(p));food=p;}
  void _timer(){timer?.cancel();timer=Timer.periodic(Duration(milliseconds:max(70,145-level*15)),(_)=>tick());}
  void startGame(){setState((){started=true;dead=false;paused=false;score=0;level=1;dir=const Point(0,-1);next=const Point(0,-1);_reset();});_timer();}
  void restart(){timer?.cancel();if(mounted)setState((){started=false;dead=false;paused=false;score=0;level=1;_reset();});}
  void setDir(Point<int>d){if(!started||paused||dead)return;if(d.x+dir.x==0&&d.y+dir.y==0)return;next=d;}
  void tick(){if(!mounted||!started||dead||paused)return;setState((){dir=next;final h=worm.first,n=Point(h.x+dir.x,h.y+dir.y);if(n.x<0||n.x>=cols||n.y<0||n.y>=rows||worm.contains(n)){dead=true;timer?.cancel();return;}worm=[n,...worm];if(n==food){score++;level=min(5,1+score~/5);_placeFood();_timer();}else{worm.removeLast();}});}
  @override void dispose(){timer?.cancel();super.dispose();}
  Widget key(IconData i,Point<int>d)=>IconButton.filled(onPressed:()=>setDir(d),icon:Icon(i));
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Worm Arena',restart:restart,child:Stack(children:[
    Column(children:[
      if(!started)Expanded(child:_GameStart(title:'Worm Arena',description:'Kumpulkan food, tubuh makin panjang, dan hindari tabrakan.',extra:'LEVEL naik tiap 5 FOOD • TANPA INTERNET',onStart:startGame)),
      if(started)Padding(padding:const EdgeInsets.all(10),child:Row(children:[_Badge('LEVEL '+level.toString()),const SizedBox(width:8),_Badge('FOOD '+score.toString()),const Spacer(),_GamePauseButton(paused:paused,onTap:(){setState(()=>paused=!paused);})])),
      if(started)Expanded(child:Center(child:AspectRatio(aspectRatio:cols/rows,child:Container(margin:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFF101522),borderRadius:BorderRadius.circular(18)),child:CustomPaint(painter:_WormPainter(worm,food)))))),
      if(started)Row(mainAxisAlignment:MainAxisAlignment.center,children:[key(Icons.arrow_back_rounded,const Point(-1,0)),Column(children:[key(Icons.arrow_upward_rounded,const Point(0,-1)),key(Icons.arrow_downward_rounded,const Point(0,1))]),key(Icons.arrow_forward_rounded,const Point(1,0))]),
      if(started)const SizedBox(height:10),
    ]),
    if(dead)Positioned.fill(child:_Over(title:'GAME OVER',restart:restart)),
  ]));
}
class _WormPainter extends CustomPainter{
  final List<Point<int>> worm;final Point<int> food;_WormPainter(this.worm,this.food);
  @override void paint(Canvas c,Size s){final cell=min(s.width/11,s.height/18),ox=(s.width-cell*11)/2,oy=(s.height-cell*18)/2;c.drawCircle(Offset(ox+food.x*cell+cell/2,oy+food.y*cell+cell/2),cell*.28,Paint()..color=const Color(0xFFEF4444));for(int i=worm.length-1;i>=0;i--){final p=worm[i];c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(ox+p.x*cell+2,oy+p.y*cell+2,cell-4,cell-4),const Radius.circular(7)),Paint()..color=i==0?const Color(0xFF22D3EE):const Color(0xFF8B5CF6));}}
  @override bool shouldRepaint(covariant _WormPainter old)=>true;
}

class NexoraChessPage extends StatefulWidget{
  const NexoraChessPage({super.key});
  @override State<NexoraChessPage> createState()=>_ChessState();
}
class _ChessState extends State<NexoraChessPage>{
  final rng=Random();late List<String>b;int?sel;bool turn=true,busy=false,over=false,started=false;String msg='WHITE TURN';int difficulty=1;
  bool white(String p)=>'KQRBNP'.contains(p);bool inside(int r,int c)=>r>=0&&r<8&&c>=0&&c<8;
  @override void initState(){super.initState();_resetBoard();}
  void _resetBoard(){b=['r','n','b','q','k','b','n','r','p','p','p','p','p','p','p','p',...List.filled(32,''),'P','P','P','P','P','P','P','P','R','N','B','Q','K','B','N','R'];}
  void startGame(){setState((){started=true;over=false;busy=false;turn=true;sel=null;msg='WHITE TURN';_resetBoard();});}
  void restart(){if(mounted)setState((){started=false;over=false;busy=false;sel=null;msg='WHITE TURN';_resetBoard();});}
  bool enemy(String p,bool w)=>p.isNotEmpty&&white(p)!=w;
  bool clear(int a,int z){final ar=a~/8,ac=a%8,br=z~/8,bc=z%8,dr=(br-ar).sign,dc=(bc-ac).sign;var r=ar+dr,c=ac+dc;while(r!=br||c!=bc){if(b[r*8+c].isNotEmpty)return false;r+=dr;c+=dc;}return true;}
  bool attacks(int a,int z,bool w){final p=b[a],ar=a~/8,ac=a%8,br=z~/8,bc=z%8,dr=br-ar,dc=bc-ac;switch(p.toUpperCase()){case'P':return dr==(w?-1:1)&&dc.abs()==1;case'N':return(dr.abs()==2&&dc.abs()==1)||(dr.abs()==1&&dc.abs()==2);case'K':return dr.abs()<=1&&dc.abs()<=1&&(dr!=0||dc!=0);case'B':return dr.abs()==dc.abs()&&clear(a,z);case'R':return(dr==0||dc==0)&&clear(a,z);case'Q':return(dr==0||dc==0||dr.abs()==dc.abs())&&clear(a,z);}return false;}
  bool check(bool w){final k=b.indexOf(w?'K':'k');if(k<0)return true;for(int i=0;i<64;i++)if(b[i].isNotEmpty&&white(b[i])!=w&&attacks(i,k,!w))return true;return false;}
  List<int>pseudo(int a,bool w){final p=b[a],r=a~/8,c=a%8,out=<int>[];void add(int rr,int cc){if(!inside(rr,cc))return;final i=rr*8+cc;if(b[i].isEmpty||enemy(b[i],w))out.add(i);}if(p.toUpperCase()=='P'){final d=w?-1:1,st=w?6:1;if(inside(r+d,c)&&b[(r+d)*8+c].isEmpty){out.add((r+d)*8+c);if(r==st&&b[(r+2*d)*8+c].isEmpty)out.add((r+2*d)*8+c);}for(final dc in[-1,1])if(inside(r+d,c+dc)&&enemy(b[(r+d)*8+c+dc],w))out.add((r+d)*8+c+dc);}else if(p.toUpperCase()=='N'){for(final d in[[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]])add(r+d[0],c+d[1]);}else if(p.toUpperCase()=='K'){for(int rr=-1;rr<=1;rr++)for(int cc=-1;cc<=1;cc++)if(rr!=0||cc!=0)add(r+rr,c+cc);}else{final ds=<List<int>>[];if(p.toUpperCase()=='B'||p.toUpperCase()=='Q')ds.addAll([[-1,-1],[-1,1],[1,-1],[1,1]]);if(p.toUpperCase()=='R'||p.toUpperCase()=='Q')ds.addAll([[-1,0],[1,0],[0,-1],[0,1]]);for(final d in ds){var rr=r+d[0],cc=c+d[1];while(inside(rr,cc)){final i=rr*8+cc;if(b[i].isEmpty)out.add(i);else{if(enemy(b[i],w))out.add(i);break;}rr+=d[0];cc+=d[1];}}}return out;}
  List<int>legal(int a,bool w){final out=<int>[];for(final z in pseudo(a,w)){final p=b[a],old=b[z];b[z]=p;b[a]='';if(p=='P'&&z~/8==0)b[z]='Q';if(p=='p'&&z~/8==7)b[z]='q';if(!check(w))out.add(z);b[a]=p;b[z]=old;}return out;}
  List<List<int>>all(bool w){final out=<List<int>>[];for(int i=0;i<64;i++)if(b[i].isNotEmpty&&white(b[i])==w)for(final z in legal(i,w))out.add([i,z]);return out;}
  void tap(int i){if(!started||over||busy||!turn)return;if(sel==null){if(b[i].isNotEmpty&&white(b[i]))setState(()=>sel=i);return;}if(legal(sel!,true).contains(i)){move(sel!,i);}else if(b[i].isNotEmpty&&white(b[i]))setState(()=>sel=i);else setState(()=>sel=null);}
  void move(int a,int z){setState((){final p=b[a];b[z]=p;b[a]='';if(p=='P'&&z~/8==0)b[z]='Q';sel=null;turn=false;msg='BOT TURN';});end();if(!over){busy=true;Future.delayed(Duration(milliseconds:difficulty==1?550:difficulty==2?330:180),bot);}}
  int _pieceValue(String p){
    switch(p.toUpperCase()){
      case 'P': return 100;
      case 'N': return 320;
      case 'B': return 330;
      case 'R': return 500;
      case 'Q': return 900;
      case 'K': return 20000;
    }
    return 0;
  }
  int _moveScore(List<int> q){
    final captured=b[q[1]],moving=b[q[0]];
    var score=_pieceValue(captured);
    b[q[1]]=moving;b[q[0]]='';
    if(moving=='p'&&q[1]~/8==7)b[q[1]]='q';
    if(check(true))score+=80;
    final replies=all(true);
    if(replies.isEmpty&&check(true))score+=100000;
    if(replies.isNotEmpty){
      var worst=0;
      for(final r in replies) worst=max(worst,_pieceValue(b[r[1]]));
      score-=worst;
    }
    b[q[0]]=moving;b[q[1]]=captured;
    return score;
  }
  void bot(){
    if(!mounted||over||!started)return;
    final m=all(false);
    if(m.isEmpty){setState(()=>busy=false);end();return;}
    List<int> q;
    if(difficulty==1){
      q=m[rng.nextInt(m.length)];
    }else if(difficulty==2){
      final scored=[for(final move in m)[move,_pieceValue(b[move[1]])]];
      scored.sort((a,z)=>(z[1] as int).compareTo(a[1] as int));
      final top=scored.take(min(4,scored.length)).toList();
      q=top[rng.nextInt(top.length)][0] as List<int>;
    }else{
      q=m.reduce((best,candidate)=>_moveScore(candidate)>_moveScore(best)?candidate:best);
    }
    final p=b[q[0]];
    setState((){
      b[q[1]]=p;b[q[0]]='';
      if(p=='p'&&q[1]~/8==7)b[q[1]]='q';
      turn=true;busy=false;msg='WHITE TURN';
    });
    end();
  }
  void end(){final m=all(turn);if(m.isEmpty&&started)setState((){over=true;msg=check(turn)?'CHECKMATE':'STALEMATE';});}
  String glyph(String p){const m={'K':'♔','Q':'♕','R':'♖','B':'♗','N':'♘','P':'♙','k':'♚','q':'♛','r':'♜','b':'♝','n':'♞','p':'♟'};return m[p]??'';}
  @override Widget build(BuildContext context){
    return _MiniScaffold(
      title:'Nexora Chess',
      restart:restart,
      child:Stack(children:[
        if(!started)
          Center(child:Container(
            margin:const EdgeInsets.all(20),
            padding:const EdgeInsets.all(22),
            decoration:BoxDecoration(color:const Color(0xFF111522),borderRadius:BorderRadius.circular(24)),
            child:Column(mainAxisSize:MainAxisSize.min,children:[
              const Icon(Icons.grid_4x4_rounded,size:54),
              const SizedBox(height:12),
              const Text('Nexora Chess',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),
              const SizedBox(height:8),
              const Text('Catur offline melawan bot. Pilih kesulitan sebelum mulai.',textAlign:TextAlign.center),
              const SizedBox(height:14),
              SegmentedButton<int>(
                segments:const [
                  ButtonSegment(value:1,label:Text('Easy')),
                  ButtonSegment(value:2,label:Text('Normal')),
                  ButtonSegment(value:3,label:Text('Hard')),
                ],
                selected:{difficulty},
                onSelectionChanged:(v)=>setState(()=>difficulty=v.first),
              ),
              const SizedBox(height:16),
              SizedBox(width:double.infinity,child:FilledButton.icon(
                onPressed:startGame,
                icon:const Icon(Icons.play_arrow_rounded),
                label:const Text('START GAME'),
              )),
            ]),
          )),
        if(started)
          Column(children:[
            Padding(
              padding:const EdgeInsets.all(10),
              child:Row(children:[
                Text(msg,style:const TextStyle(fontWeight:FontWeight.w900)),
                const Spacer(),
                Text(
                  difficulty==1?'EASY BOT':difficulty==2?'NORMAL BOT':'HARD BOT',
                  style:const TextStyle(color:Colors.white54,fontSize:10),
                ),
              ]),
            ),
            Expanded(
              child:Center(
                child:AspectRatio(
                  aspectRatio:1,
                  child:GridView.builder(
                    itemCount:64,
                    physics:const NeverScrollableScrollPhysics(),
                    gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:8),
                    itemBuilder:(_,i){
                      final rr=i~/8,cc=i%8,light=(rr+cc).isEven;
                      return GestureDetector(
                        onTap:()=>tap(i),
                        child:Container(
                          color:sel==i?const Color(0xFF22D3EE):(light?const Color(0xFFD6D3D1):const Color(0xFF57534E)),
                          child:Center(
                            child:Text(glyph(b[i]),style:TextStyle(fontSize:27,color:white(b[i])?Colors.white:Colors.black87)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if(over)
              Padding(
                padding:const EdgeInsets.all(10),
                child:FilledButton.icon(onPressed:restart,icon:const Icon(Icons.refresh_rounded),label:Text(msg)),
              ),
          ]),
      ]),
    );
  }
}

class RoadRushPage extends StatefulWidget{const RoadRushPage({super.key});@override State<RoadRushPage> createState()=>_RoadState();}
class _Car{double lane,y;_Car(this.lane,this.y);}
class _RoadState extends State<RoadRushPage>{
  Timer?timer;final rng=Random();final audio=_GameAudio();double lane=1;List<_Car>cars=[];int score=0,level=1;bool started=false,dead=false,paused=false;
  void startGame(){timer?.cancel();setState((){started=true;dead=false;paused=false;score=0;level=1;lane=1;cars=[];});audio.start(150,volume:.13);timer=Timer.periodic(const Duration(milliseconds:35),(_)=>tick());}
  void restart(){timer?.cancel();audio.stop();if(mounted)setState((){started=false;dead=false;paused=false;score=0;level=1;lane=1;cars=[];});}
  void tick(){if(!mounted||!started||dead||paused)return;setState((){for(final c in cars)c.y+=.0105+.0017*level;cars.removeWhere((c)=>c.y>1.1);if(rng.nextDouble()<.026+.006*level)cars.add(_Car(rng.nextInt(3).toDouble(),-.12));score++;level=min(5,1+score~/180);if(cars.any((c)=>(c.lane-lane).abs()<.25&&c.y>.78&&c.y<.94)){dead=true;timer?.cancel();audio.stop();}});}
  void move(double d){if(started&&!paused)setState(()=>lane=(lane+d).clamp(0,2));}
  @override void dispose(){timer?.cancel();audio.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Road Rush',restart:restart,child:Stack(children:[
    Positioned.fill(child:CustomPaint(painter:_RoadPainter(lane,cars))),
    if(!started)Positioned.fill(child:Container(color:Colors.black45,child:_GameStart(title:'Road Rush',description:'Pindah jalur, hindari mobil, dan bertahan selama mungkin.',extra:'LEVEL 1 → 5 • kecepatan dan traffic meningkat',onStart:startGame))),
    if(started)Positioned(top:12,left:12,child:Row(children:[_Badge('LEVEL '+level.toString()),const SizedBox(width:8),_Badge('TIME '+(score~/20).toString()+'s')])),
    if(started)Positioned(top:12,right:12,child:_GamePauseButton(paused:paused,onTap:(){setState(()=>paused=!paused);})),
    if(started)Positioned(bottom:18,left:0,right:0,child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[IconButton.filled(onPressed:()=>move(-1),icon:const Icon(Icons.chevron_left)),const SizedBox(width:90),IconButton.filled(onPressed:()=>move(1),icon:const Icon(Icons.chevron_right))])),
    if(started)Positioned.fill(child:GestureDetector(onHorizontalDragEnd:(d){final v=d.primaryVelocity??0;if(v.abs()>30)move(v>0?1:-1);},behavior:HitTestBehavior.translucent)),
    if(dead)Positioned.fill(child:_Over(title:'CRASH',restart:restart)),
  ]));
}
class _RoadPainter extends CustomPainter{
  final double lane;final List<_Car>cars;_RoadPainter(this.lane,this.cars);
  @override void paint(Canvas c,Size s){c.drawRect(Rect.fromLTWH(0,0,s.width,s.height),Paint()..color=const Color(0xFF102016));final road=Rect.fromLTWH(s.width*.1,0,s.width*.8,s.height);c.drawRect(road,Paint()..color=const Color(0xFF242833));final dash=Paint()..color=Colors.white24..strokeWidth=4;for(int l=1;l<3;l++){final x=road.left+road.width*l/3;for(double y=-30;y<s.height;y+=55)c.drawLine(Offset(x,y),Offset(x,y+25),dash);}final px=road.left+road.width*(lane+.5)/3;c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(px-25,s.height*.84,50,70),const Radius.circular(12)),Paint()..color=const Color(0xFF22D3EE));for(final car in cars){final x=road.left+road.width*(car.lane+.5)/3;c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-23,car.y*s.height,46,66),const Radius.circular(11)),Paint()..color=const Color(0xFFEF4444));}}
  @override bool shouldRepaint(covariant _RoadPainter old)=>true;
}

class BrickSmashPage extends StatefulWidget{const BrickSmashPage({super.key});@override State<BrickSmashPage> createState()=>_BrickState();}
class _BrickState extends State<BrickSmashPage>{
  Timer?timer;final audio=_GameAudio();double bx=.5,by=.75,vx=.006,vy=-.009,paddle=.5;List<bool>bricks=List.filled(30,true);bool started=false,dead=false,paused=false;int level=1;
  void _resetLevel(){bx=.5;by=.75;vx=.006+.001*level;vy=-.009-.0007*level;paddle=.5;bricks=List.generate(30,(i){final row=i~/5;final col=i%5;return level==1?true:level==2?row<4:level==3?(row+col).isEven:level==4?row!=2:col!=2;});}
  void startGame(){timer?.cancel();setState((){started=true;dead=false;paused=false;level=1;_resetLevel();});audio.start(175,volume:.12);timer=Timer.periodic(const Duration(milliseconds:16),(_)=>tick());}
  void restart(){timer?.cancel();audio.stop();if(mounted)setState((){started=false;dead=false;paused=false;level=1;_resetLevel();});}
  void tick(){if(!mounted||!started||dead||paused)return;setState((){bx+=vx;by+=vy;if(bx<.03||bx>.97)vx=-vx;if(by<.03)vy=vy.abs();if(by>.82&&by<.94&&(bx-paddle).abs()<.15)vy=-vy.abs();for(int i=0;i<30;i++)if(bricks[i]){final col=i%5,row=i~/5,l=.05+col*.19,t=.1+row*.06;if(bx>l&&bx<l+.16&&by>t&&by<t+.045){bricks[i]=false;vy=-vy;break;}}if(by>1.05){dead=true;timer?.cancel();audio.stop();}else if(bricks.every((v)=>!v)){if(level<5){level++;_resetLevel();}else{dead=true;timer?.cancel();audio.stop();}}});}
  @override void dispose(){timer?.cancel();audio.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Brick Smash',restart:restart,child:GestureDetector(onHorizontalDragUpdate:(d){if(started&&!paused)setState(()=>paddle=(paddle+d.delta.dx/MediaQuery.sizeOf(context).width).clamp(.12,.88));},behavior:HitTestBehavior.opaque,child:Stack(children:[
    Positioned.fill(child:CustomPaint(painter:_BrickPainter(bx,by,paddle,bricks))),
    if(!started)Positioned.fill(child:Container(color:Colors.black45,child:_GameStart(title:'Brick Smash',description:'Pantulkan bola dan hancurkan semua brick.',extra:'5 LEVEL • pola brick berubah setiap level • backsound ON',onStart:startGame))),
    if(started)Positioned(top:12,left:12,child:_Badge('LEVEL '+level.toString())),
    if(started)Positioned(top:12,right:12,child:_GamePauseButton(paused:paused,onTap:(){setState(()=>paused=!paused);})),
    if(dead)Positioned.fill(child:_Over(title:level==5?'ALL LEVELS CLEAR':'GAME OVER',restart:restart)),
  ])));
}
class _BrickPainter extends CustomPainter{
  final double x,y,p;final List<bool>b;_BrickPainter(this.x,this.y,this.p,this.b);
  @override void paint(Canvas c,Size s){c.drawRect(Rect.fromLTWH(0,0,s.width,s.height),Paint()..color=const Color(0xFF080B14));for(int i=0;i<30;i++)if(b[i]){final col=i%5,row=i~/5;c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*(.05+col*.19),s.height*(.08+row*.055),s.width*.17,s.height*.04),const Radius.circular(6)),Paint()..color=const Color(0xFF8B5CF6));}c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*(p-.12),s.height*.92,s.width*.24,12),const Radius.circular(10)),Paint()..color=Colors.white);c.drawCircle(Offset(x*s.width,y*s.height),9,Paint()..color=const Color(0xFF22D3EE));}
  @override bool shouldRepaint(covariant _BrickPainter old)=>true;
}

class FlapOrbitPage extends StatefulWidget{const FlapOrbitPage({super.key});@override State<FlapOrbitPage> createState()=>_FlapState();}
class _FlapState extends State<FlapOrbitPage>{
  Timer?timer;final rng=Random();final audio=_GameAudio();double y=.5,vy=0,px=1.1,g=.5;int score=0,level=1;bool started=false,dead=false,paused=false;
  void startGame(){timer?.cancel();setState((){started=true;dead=false;paused=false;y=.5;vy=0;px=1.1;g=.5;score=0;level=1;});audio.start(262,volume:.13);timer=Timer.periodic(const Duration(milliseconds:16),(_)=>tick());}
  void restart(){timer?.cancel();audio.stop();if(mounted)setState((){started=false;dead=false;paused=false;y=.5;vy=0;px=1.1;g=.5;score=0;level=1;});}
  void flap(){if(!started||paused)return;setState(()=>vy=-.011);}
  void tick(){if(!mounted||!started||dead||paused)return;setState((){vy+=.00055+.00004*level;y+=vy;px-=.006+.0008*level;if(px<-.15){px=1.1;g=.27+rng.nextDouble()*(.42-.025*level);score++;level=min(5,1+score~/5);}if(y<.02||y>.98||(px<.62&&px>.36&&(y<g-.15||y>g+.15))){dead=true;timer?.cancel();audio.stop();}});}
  @override void dispose(){timer?.cancel();audio.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Flap Orbit',restart:restart,child:GestureDetector(onTap:flap,behavior:HitTestBehavior.opaque,child:Stack(children:[
    Positioned.fill(child:CustomPaint(painter:_FlapPainter(y,px,g))),
    if(!started)Positioned.fill(child:Container(color:Colors.black45,child:_GameStart(title:'Flap Orbit',description:'Tap untuk terbang melewati celah. Semakin tinggi level, semakin cepat.',extra:'LEVEL 1 → 5 • backsound ON',onStart:startGame))),
    if(started)Positioned(top:12,left:12,child:Row(children:[_Badge('LEVEL '+level.toString()),const SizedBox(width:8),_Badge('SCORE '+score.toString())])),
    if(started)Positioned(top:12,right:12,child:_GamePauseButton(paused:paused,onTap:(){setState(()=>paused=!paused);})),
    if(dead)Positioned.fill(child:_Over(title:'GAME OVER',restart:restart)),
  ])));
}
class _FlapPainter extends CustomPainter{
  final double y,x,g;_FlapPainter(this.y,this.x,this.g);
  @override void paint(Canvas c,Size s){c.drawRect(Rect.fromLTWH(0,0,s.width,s.height),Paint()..color=const Color(0xFF08131A));final p=Paint()..color=const Color(0xFF16A34A);c.drawRect(Rect.fromLTWH(x*s.width,0,s.width*.12,s.height*(g-.16)),p);c.drawRect(Rect.fromLTWH(x*s.width,s.height*(g+.16),s.width*.12,s.height),p);c.drawCircle(Offset(s.width*.5,y*s.height),18,Paint()..color=const Color(0xFFFBBF24));}
  @override bool shouldRepaint(covariant _FlapPainter old)=>true;
}

class MazeEscapePage extends StatefulWidget{const MazeEscapePage({super.key});@override State<MazeEscapePage> createState()=>_MazeState();}
class _MazeState extends State<MazeEscapePage>{
  static const maps=<List<String>>[
    ['1111111111','1000000001','1011111101','1010000101','1010110101','1000100101','1110101101','1000100001','1011111101','1000000001','1111111111'],
    ['1111111111','1000000001','1011111101','1010000101','1010110101','1010100101','1010101101','1010000001','1011111101','1000000001','1111111111'],
    ['1111111111','1000000001','1011111101','1010000101','1010110101','1010100101','1010101101','1000100001','1011111101','1000000001','1111111111'],
    ['1111111111','1000000001','1011111101','1010000101','1010110101','1010100101','1010101101','1010000001','1011111101','1000000001','1111111111'],
    ['1111111111','1000000001','1011111101','1010000101','1010110101','1010100101','1010101101','1000100001','1011111101','1000000001','1111111111']
  ];
  int level=1,r=1,c=1,moves=0;bool started=false,win=false;
  void startGame(){setState((){started=true;level=1;r=1;c=1;moves=0;win=false;});}
  void restart(){if(mounted)setState((){started=false;level=1;r=1;c=1;moves=0;win=false;});}
  void go(int dr,int dc){if(!started||win)return;final map=maps[level-1],nr=r+dr,nc=c+dc;if(nr<0||nc<0||nr>=map.length||nc>=map[0].length)return;if(map[nr][nc]=='0')setState((){r=nr;c=nc;moves++;if(r==9&&c==8){if(level<5){level++;r=1;c=1;moves=0;}else{win=true;}}});}
  Widget key(IconData i,int dr,int dc)=>IconButton.filled(onPressed:()=>go(dr,dc),icon:Icon(i));
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Maze Escape',restart:restart,child:Column(children:[
    if(!started)Expanded(child:_GameStart(title:'Maze Escape',description:'Cari jalan keluar. Tiap level punya pola labirin berbeda.',extra:'5 LEVEL • offline • tanpa timer',onStart:startGame)),
    if(started)Padding(padding:const EdgeInsets.all(10),child:Row(children:[_Badge('LEVEL '+level.toString()),const SizedBox(width:8),_Badge('MOVES '+moves.toString()),const Spacer(),if(win)const Text('ESCAPED',style:TextStyle(color:Colors.greenAccent,fontWeight:FontWeight.w900))])),
    if(started)Expanded(child:Center(child:AspectRatio(aspectRatio:10/11,child:CustomPaint(painter:_MazePainter(maps[level-1],r,c))))),
    if(started)Row(mainAxisAlignment:MainAxisAlignment.center,children:[key(Icons.arrow_back,0,-1),Column(children:[key(Icons.arrow_upward,-1,0),key(Icons.arrow_downward,1,0)]),key(Icons.arrow_forward,0,1)]),
    if(started)const SizedBox(height:10),
    if(win)FilledButton.icon(onPressed:restart,icon:const Icon(Icons.refresh_rounded),label:const Text('PLAY AGAIN')),
  ]));
}
class _MazePainter extends CustomPainter{
  final List<String>m;final int r,c;_MazePainter(this.m,this.r,this.c);
  @override void paint(Canvas p,Size s){final cell=min(s.width/10,s.height/11);for(int y=0;y<11;y++)for(int x=0;x<10;x++)p.drawRect(Rect.fromLTWH(x*cell,y*cell,cell,cell),Paint()..color=m[y][x]=='1'?const Color(0xFF312E81):const Color(0xFF111827));p.drawCircle(Offset(c*cell+cell/2,r*cell+cell/2),cell*.3,Paint()..color=const Color(0xFF22D3EE));p.drawCircle(Offset(8*cell+cell/2,9*cell+cell/2),cell*.23,Paint()..color=const Color(0xFF22C55E));}
  @override bool shouldRepaint(covariant _MazePainter old)=>true;
}

class Mini2048Page extends StatefulWidget{const Mini2048Page({super.key});@override State<Mini2048Page> createState()=>_2048State();}
class _2048State extends State<Mini2048Page>{
  final rng=Random();List<int>b=List.filled(16,0);int score=0,best=0;bool started=false,over=false;
  void _add(){final e=[for(int i=0;i<16;i++)if(b[i]==0)i];if(e.isNotEmpty)b[e[rng.nextInt(e.length)]]=rng.nextDouble()<.9?2:4;}
  void startGame(){setState((){started=true;over=false;score=0;b=List.filled(16,0);_add();_add();});}
  void restart(){if(mounted)setState((){started=false;over=false;score=0;b=List.filled(16,0);});}
  List<int>merge(List<int>a){final v=a.where((x)=>x>0).toList();for(int i=0;i<v.length-1;i++)if(v[i]==v[i+1]){v[i]*=2;score+=v[i];best=max(best,score);v.removeAt(i+1);}while(v.length<4)v.add(0);return v;}
  bool _hasMove(){for(int r=0;r<4;r++)for(int c=0;c<4;c++){final v=b[r*4+c];if(c<3&&b[r*4+c+1]==v)return true;if(r<3&&b[(r+1)*4+c]==v)return true;}return false;}
  void move(int dr,int dc){if(!started||over)return;final old=b.toString();if(dr==0){for(int r=0;r<4;r++){final a=[for(int c=0;c<4;c++)b[r*4+c]],q=merge(dc<0?a:a.reversed.toList()),z=dc<0?q:q.reversed.toList();for(int c=0;c<4;c++)b[r*4+c]=z[c];}}else{for(int c=0;c<4;c++){final a=[for(int r=0;r<4;r++)b[r*4+c]],q=merge(dr<0?a:a.reversed.toList()),z=dr<0?q:q.reversed.toList();for(int r=0;r<4;r++)b[r*4+c]=z[r];}}if(old!=b.toString()){_add();setState((){});if(!b.contains(0)&&!_hasMove())setState(()=>over=true);}}
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Nexora 2048',restart:restart,child:GestureDetector(onHorizontalDragEnd:(d){final v=d.primaryVelocity??0;if(v.abs()>30)move(0,v>0?1:-1);},onVerticalDragEnd:(d){final v=d.primaryVelocity??0;if(v.abs()>30)move(v>0?1:-1,0);},behavior:HitTestBehavior.opaque,child:Stack(children:[
    if(!started)Positioned.fill(child:_GameStart(title:'Nexora 2048',description:'Geser ubin dan gabungkan angka. Game tanpa level, fokus ke skor.',extra:'MODE ENDLESS • BEST '+best.toString(),onStart:startGame)),
    if(started)Padding(padding:const EdgeInsets.all(16),child:Column(children:[Row(children:[_Badge('SCORE '+score.toString()),const SizedBox(width:8),_Badge('BEST '+best.toString()),const Spacer()]),const SizedBox(height:14),Expanded(child:Center(child:AspectRatio(aspectRatio:1,child:GridView.builder(itemCount:16,physics:const NeverScrollableScrollPhysics(),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:4,crossAxisSpacing:8,mainAxisSpacing:8),itemBuilder:(_,i)=>Container(decoration:BoxDecoration(color:b[i]==0?const Color(0xFF1A1E2A):const Color(0xFF6D28D9),borderRadius:BorderRadius.circular(12)),child:Center(child:Text(b[i]==0?'':b[i].toString(),style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900)))))))),const Text('SWIPE • target 2048',style:TextStyle(color:Colors.white54,fontWeight:FontWeight.w800))])),
    if(over)Positioned.fill(child:_Over(title:'GAME OVER',restart:restart)),
  ])));
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
  void _completed(){if(!mounted)return;if(repeat){playSelected();return;}selectTrack(shuffle?Random().nextInt(tracks.length):(selected+1)%tracks.length);}
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

// Nexora production redeploy: game start/level/audio verification
// ignore_for_file: unused_element, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_interpolation_to_compose_strings, camel_case_types
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
        1 => const NexoraGameHub(),
        2 => const MusicPage(),
        3 => const NexoraToolsPage(),
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
  final String title, kind, subtitle;
  final IconData icon;
  final int color;
  const ArcadeGame(this.title,this.kind,this.subtitle,this.icon,this.color);
}
const _games=<ArcadeGame>[
  ArcadeGame('Snake','snake','Classic • 1 player',Icons.straighten_rounded,0xFF22D3EE),
  ArcadeGame('2048','2048','Puzzle • Merge tiles',Icons.grid_4x4_rounded,0xFFA78BFA),
  ArcadeGame('Tetris','tetris','Arcade • Stack blocks',Icons.view_module_rounded,0xFFF472B6),
  ArcadeGame('Flappy','flappy','Arcade • Fly & dodge',Icons.flutter_dash_rounded,0xFFFBBF24),
  ArcadeGame('Breakout','breakout','Arcade • Smash bricks',Icons.sports_tennis_rounded,0xFF60A5FA),
  ArcadeGame('Memory','memory','Puzzle • Match pairs',Icons.psychology_rounded,0xFF34D399),
  ArcadeGame('Pong','pong','Classic • 1 vs bot',Icons.sports_tennis_rounded,0xFF38BDF8),
  ArcadeGame('Whack-a-Mole','whack','Arcade • Tap fast',Icons.touch_app_rounded,0xFFF97316),
  ArcadeGame('Minesweeper','mines','Puzzle • Clear field',Icons.warning_amber_rounded,0xFFE879F9),
  ArcadeGame('Simon Says','simon','Memory • Follow lights',Icons.lights_rounded,0xFF4ADE80),
];

class GamesPage extends StatefulWidget{
  const GamesPage({super.key});
  @override State<GamesPage> createState()=>_GamesState();
}
class _GamesState extends State<GamesPage>{
  String query='';
  final favorites=<String>{'Snake','2048'};
  Widget open(ArcadeGame g){
    switch(g.kind){
      case 'snake':return const NexoraSnakePage();
      case '2048':return const Mini2048Page();
      case 'tetris':return const NexoraTetrisPage();
      case 'flappy':return const NexoraFlappyPage();
      case 'breakout':return const NexoraBreakoutPage();
      case 'memory':return const NexoraMemoryPage();
      case 'pong':return const NexoraPongPage();
      case 'whack':return const NexoraWhackPage();
      case 'mines':return const NexoraMinesPage();
      default:return const NexoraSimonPage();
    }
  }
  @override Widget build(BuildContext context){
    final list=_games.where((g)=>g.title.toLowerCase().contains(query.toLowerCase())).toList();
    return Container(color:const Color(0xFF070910),child:ListView(padding:const EdgeInsets.fromLTRB(14,14,14,110),children:[
      Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(borderRadius:BorderRadius.circular(28),gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF4C1D95),Color(0xFF172554),Color(0xFF0B1020)])),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[Container(width:48,height:48,decoration:BoxDecoration(color:Colors.white12,borderRadius:BorderRadius.circular(16)),child:const Icon(Icons.sports_esports_rounded,size:28)),const SizedBox(width:12),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('NEXORA ARCADE',style:TextStyle(fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1.8)),Text('GAME HUB',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900))])),Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.black26,borderRadius:BorderRadius.circular(14)),child:const Column(children:[Text('10',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),Text('GAMES',style:TextStyle(fontSize:8,fontWeight:FontWeight.w900))]))]),
        const SizedBox(height:14),const Text('10 mini game offline dalam satu hub.',style:TextStyle(color:Colors.white70)),
        const SizedBox(height:12),Row(children:[_HubPill(Icons.wifi_off_rounded,'OFFLINE'),const SizedBox(width:7),_HubPill(Icons.bolt_rounded,'QUICK PLAY'),const SizedBox(width:7),_HubPill(Icons.emoji_events_rounded,'HIGH SCORE')]),
      ]),
      const SizedBox(height:14),
      TextField(onChanged:(v)=>setState(()=>query=v),decoration:InputDecoration(prefixIcon:const Icon(Icons.search_rounded),suffixIcon:query.isEmpty?null:IconButton(onPressed:()=>setState(()=>query=''),icon:const Icon(Icons.clear_rounded)),hintText:'Cari game...',filled:true,fillColor:const Color(0xFF111522),border:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:BorderSide.none))),
      const SizedBox(height:16),
      Row(children:[const Expanded(child:Text('All Games',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900))),Text(list.length.toString()+'/10',style:const TextStyle(color:Colors.white54,fontWeight:FontWeight.w800))]),
      const SizedBox(height:10),
      GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:list.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:.80),itemBuilder:(_,i){
        final g=list[i]; final fav=favorites.contains(g.title);
        return Card(clipBehavior:Clip.antiAlias,margin:EdgeInsets.zero,child:InkWell(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>open(g))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Expanded(child:Container(width:double.infinity,decoration:BoxDecoration(gradient:LinearGradient(colors:[Color(g.color).withValues(alpha:.42),const Color(0xFF101522)])),child:Stack(children:[
            Positioned.fill(child:CustomPaint(painter:_ArcadePreview(g.kind,g.color))),
            Positioned(top:5,right:5,child:IconButton(visualDensity:VisualDensity.compact,onPressed:()=>setState(()=>fav?favorites.remove(g.title):favorites.add(g.title)),icon:Icon(fav?Icons.star_rounded:Icons.star_border_rounded,size:19))),
            Positioned(left:9,bottom:8,child:Container(padding:const EdgeInsets.symmetric(horizontal:7,vertical:4),decoration:BoxDecoration(color:Colors.black54,borderRadius:BorderRadius.circular(8)),child:const Text('OFFLINE',style:TextStyle(fontSize:8,fontWeight:FontWeight.w900)))),
          ]))),
          Padding(padding:const EdgeInsets.fromLTRB(11,9,9,11),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(g.title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:3),Text(g.subtitle,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:9,color:Colors.white54))])),const Icon(Icons.play_circle_fill_rounded,size:24)])),
        ]));
      }),
      if(list.isEmpty)const Padding(padding:EdgeInsets.all(35),child:Center(child:Text('Game tidak ditemukan.'))),
    ]));
  }
}
class _HubPill extends StatelessWidget{
  final IconData icon;final String text;
  const _HubPill(this.icon,this.text);
  @override Widget build(BuildContext context)=>Expanded(child:Container(padding:const EdgeInsets.symmetric(vertical:9),decoration:BoxDecoration(color:Colors.white10,borderRadius:BorderRadius.circular(12)),child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,size:14),const SizedBox(width:4),Text(text,style:const TextStyle(fontSize:8,fontWeight:FontWeight.w900))])));
}
class _ArcadePreview extends CustomPainter{
  final String kind;final int color;_ArcadePreview(this.kind,this.color);
  @override void paint(Canvas c,Size s){
    final p=Paint()..isAntiAlias=true..color=Color(color);
    if(kind=='snake'){for(int i=0;i<5;i++)c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*.25+i*15,s.height*.48,18,18),const Radius.circular(5)),p);}
    else if(kind=='2048'){for(int i=0;i<4;i++)c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*.18+i*30,s.height*.4,26,26),const Radius.circular(6)),p);}
    else if(kind=='tetris'){for(int i=0;i<5;i++)c.drawRect(Rect.fromLTWH(s.width*.2+i*18,s.height*.55,17,17),p);for(int i=0;i<3;i++)c.drawRect(Rect.fromLTWH(s.width*.38+i*18,s.height*.38,17,17),p);}
    else if(kind=='flappy'){c.drawCircle(Offset(s.width*.35,s.height*.5),13,p);c.drawRect(Rect.fromLTWH(s.width*.68,0,30,s.height*.32),p);c.drawRect(Rect.fromLTWH(s.width*.68,s.height*.68,30,s.height*.32),p);}
    else if(kind=='breakout'){for(int r=0;r<2;r++)for(int i=0;i<5;i++)c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*.16+i*31,s.height*.28+r*20,27,15),const Radius.circular(4)),p);c.drawCircle(Offset(s.width*.5,s.height*.65),6,Paint()..color=Colors.white);}
    else if(kind=='memory'){for(int r=0;r<2;r++)for(int i=0;i<3;i++)c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*.25+i*32,s.height*.35+r*34,28,30),const Radius.circular(7)),p);}
    else if(kind=='pong'){c.drawRect(Rect.fromLTWH(s.width*.22,s.height*.3,7,60),p);c.drawRect(Rect.fromLTWH(s.width*.76,s.height*.42,7,60),p);c.drawCircle(Offset(s.width*.5,s.height*.55),7,Paint()..color=Colors.white);}
    else if(kind=='whack'){for(int i=0;i<3;i++)c.drawCircle(Offset(s.width*(.3+i*.2),s.height*.52),15,p);}
    else if(kind=='mines'){for(int r=0;r<3;r++)for(int i=0;i<4;i++)c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*.2+i*28,s.height*.25+r*28,24,24),const Radius.circular(5)),p);}
    else{for(int i=0;i<4;i++)c.drawCircle(Offset(s.width*(.3+i*.14),s.height*.5),10,Paint()..color=i.isEven?Color(color):Colors.white24);}
  }
  @override bool shouldRepaint(covariant _ArcadePreview old)=>old.kind!=kind||old.color!=color;
}
class _ArcadeGameScaffold extends StatelessWidget{
  final String title;final Widget child;final VoidCallback restart;
  const _ArcadeGameScaffold({required this.title,required this.child,required this.restart});
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:const Color(0xFF070910),appBar:AppBar(title:Text(title,style:const TextStyle(fontWeight:FontWeight.w900)),actions:[IconButton(onPressed:restart,icon:const Icon(Icons.refresh_rounded))]),body:SafeArea(child:child));
}
class _ArcadeStart extends StatelessWidget{
  final String title,description;final VoidCallback button;
  const _ArcadeStart({required this.title,required this.description,required this.button});
  @override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(24),child:Container(padding:const EdgeInsets.all(26),decoration:BoxDecoration(color:const Color(0xFF111522),borderRadius:BorderRadius.circular(26),border:Border.all(color:Colors.white12)),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.sports_esports_rounded,size:58),const SizedBox(height:14),Text(title,style:const TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const SizedBox(height:8),Text(description,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white70,height:1.4)),const SizedBox(height:22),SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:button,icon:const Icon(Icons.play_arrow_rounded),label:const Text('START GAME')))]))));
}
class _ArcadeBadge extends StatelessWidget{
  final String text;const _ArcadeBadge(this.text);
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:11,vertical:8),decoration:BoxDecoration(color:Colors.white10,borderRadius:BorderRadius.circular(11)),child:Text(text,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w900)));
}
class _ArcadeOverlay extends StatelessWidget{
  final String title;final int score;final VoidCallback restart;
  const _ArcadeOverlay({required this.title,required this.score,required this.restart});
  @override Widget build(BuildContext context)=>Container(color:Colors.black54,alignment:Alignment.center,child:Container(margin:const EdgeInsets.all(28),padding:const EdgeInsets.all(26),decoration:BoxDecoration(color:const Color(0xFF111522),borderRadius:BorderRadius.circular(26)),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.emoji_events_rounded,size:48),const SizedBox(height:10),Text(title,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900)),const SizedBox(height:6),Text('Score '+score.toString(),style:const TextStyle(color:Colors.white60)),const SizedBox(height:18),FilledButton.icon(onPressed:restart,icon:const Icon(Icons.refresh_rounded),label:const Text('MAIN LAGI'))])));
}

class NexoraSnakePage extends StatefulWidget{const NexoraSnakePage({super.key});@override State<NexoraSnakePage> createState()=>_NexoraSnakeState();}
class _NexoraSnakeState extends State<NexoraSnakePage>{
  static const rows=18,cols=12;final rng=Random();Timer?timer;List<Point<int>> snake=[];Point<int>food=const Point(5,5),dir=const Point(1,0),next=const Point(1,0);int score=0;bool run=false,over=false,paused=false;
  @override void initState(){super.initState();resetBoard();}
  void resetBoard(){snake=[const Point(6,9),const Point(5,9),const Point(4,9)];placeFood();}
  void placeFood(){do{food=Point(rng.nextInt(cols),rng.nextInt(rows));}while(snake.contains(food));}
  void start(){timer?.cancel();setState((){resetBoard();score=0;run=true;over=false;paused=false;dir=const Point(1,0);next=const Point(1,0);});timer=Timer.periodic(const Duration(milliseconds:125),(_)=>tick());}
  void tick(){if(!mounted||!run||over||paused)return;setState((){dir=next;final h=snake.first,n=Point(h.x+dir.x,h.y+dir.y);if(n.x<0||n.x>=cols||n.y<0||n.y>=rows||snake.contains(n)){over=true;timer?.cancel();return;}snake=[n,...snake];if(n==food){score++;placeFood();}else{snake.removeLast();}});}
  void move(Point<int>d){if(!run||over)return;if(d.x+dir.x==0&&d.y+dir.y==0)return;next=d;}
  void restart(){timer?.cancel();setState((){run=false;over=false;paused=false;score=0;resetBoard();});}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_ArcadeGameScaffold(title:'Snake',restart:restart,child:Stack(children:[
    Column(children:[
      if(!run)Expanded(child:_ArcadeStart(title:'Snake',description:'Makan titik, tumbuh lebih panjang, jangan tabrak dinding atau tubuh.',button:start)),
      if(run)Padding(padding:const EdgeInsets.all(10),child:Row(children:[_ArcadeBadge('SCORE '+score.toString()),const Spacer(),IconButton.filledTonal(onPressed:()=>setState(()=>paused=!paused),icon:Icon(paused?Icons.play_arrow_rounded:Icons.pause_rounded))])),
      if(run)Expanded(child:Center(child:AspectRatio(aspectRatio:cols/rows,child:CustomPaint(painter:_SnakePainter(snake,food))))),
      if(run)Row(mainAxisAlignment:MainAxisAlignment.center,children:[IconButton.filled(onPressed:()=>move(const Point(-1,0)),icon:const Icon(Icons.arrow_back_rounded)),Column(children:[IconButton.filled(onPressed:()=>move(const Point(0,-1)),icon:const Icon(Icons.arrow_upward_rounded)),IconButton.filled(onPressed:()=>move(const Point(0,1)),icon:const Icon(Icons.arrow_downward_rounded))]),IconButton.filled(onPressed:()=>move(const Point(1,0)),icon:const Icon(Icons.arrow_forward_rounded))]),
      if(run)const SizedBox(height:8),
    ]),if(over)Positioned.fill(child:_ArcadeOverlay(title:'GAME OVER',score:score,restart:restart)),
  ]));
}
class _SnakePainter extends CustomPainter{final List<Point<int>> snake;final Point<int> food;_SnakePainter(this.snake,this.food);@override void paint(Canvas c,Size s){final cell=min(s.width/12,s.height/18),ox=(s.width-cell*12)/2,oy=(s.height-cell*18)/2;c.drawCircle(Offset(ox+food.x*cell+cell/2,oy+food.y*cell+cell/2),cell*.28,Paint()..color=const Color(0xFFF43F5E));for(int i=snake.length-1;i>=0;i--){final p=snake[i];c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(ox+p.x*cell+2,oy+p.y*cell+2,cell-4,cell-4),const Radius.circular(6)),Paint()..color=i==0?const Color(0xFF22D3EE):const Color(0xFF8B5CF6));}}@override bool shouldRepaint(covariant _SnakePainter old)=>true;}

class NexoraTetrisPage extends StatefulWidget{const NexoraTetrisPage({super.key});@override State<NexoraTetrisPage> createState()=>_NexoraTetrisState();}
class _NexoraTetrisState extends State<NexoraTetrisPage>{
  static const rows=18,cols=10;final rng=Random();Timer?timer;List<List<int>> board=[];int x=4,y=0,rot=0,score=0;List<Point<int>> shape=[];bool run=false,over=false,paused=false;
  static const pieces=<List<Point<int>>>[[Point(0,0),Point(1,0),Point(0,1),Point(1,1)],[Point(-1,0),Point(0,0),Point(1,0),Point(2,0)],[Point(-1,0),Point(0,0),Point(0,1),Point(1,1)],[Point(-1,1),Point(0,1),Point(0,0),Point(1,0)]];
  List<Point<int>> cells(){return shape.map((p){var a=p.x,b=p.y;for(int i=0;i<rot%4;i++){final t=a;a=-b;b=t;}return Point(x+a,y+b);}).toList();}
  bool hit(int xx,int yy,int rr){for(final p in shape.map((q){var a=q.x,b=q.y;for(int i=0;i<rr%4;i++){final t=a;a=-b;b=t;}return Point(xx+a,yy+b);})){if(p.x<0||p.x>=cols||p.y>=rows)return true;if(p.y>=0&&board[p.y][p.x]!=0)return true;}return false;}
  void piece(){shape=pieces[rng.nextInt(pieces.length)];x=4;y=0;rot=0;if(hit(x,y,0)){over=true;timer?.cancel();}}
  void lock(){for(final p in cells())if(p.y>=0)board[p.y][p.x]=1;for(int r=rows-1;r>=0;r--)if(board[r].every((v)=>v!=0)){board.removeAt(r);board.insert(0,List.filled(cols,0));score+=100;r++;}piece();}
  void drop(){if(!hit(x,y+1,rot))y++;else lock();}
  void start(){timer?.cancel();board=List.generate(rows,(_)=>List.filled(cols,0));score=0;run=true;over=false;paused=false;piece();setState((){});timer=Timer.periodic(const Duration(milliseconds:420),(_){if(mounted&&!paused&&!over)setState(drop);});}
  void restart(){timer?.cancel();setState((){run=false;over=false;score=0;board=List.generate(rows,(_)=>List.filled(cols,0));});}
  void move(int dx){if(run&&!over&&!paused&&!hit(x+dx,y,rot))setState(()=>x+=dx);}
  void rotate(){if(run&&!over&&!paused&&!hit(x,y,(rot+1)%4))setState(()=>rot=(rot+1)%4);}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_ArcadeGameScaffold(title:'Tetris',restart:restart,child:Stack(children:[Column(children:[
    if(!run)Expanded(child:_ArcadeStart(title:'Tetris',description:'Susun blok dan bersihkan baris sebelum papan penuh.',button:start)),
    if(run)Padding(padding:const EdgeInsets.all(10),child:Row(children:[_ArcadeBadge('SCORE '+score.toString()),const Spacer(),IconButton.filledTonal(onPressed:rotate,icon:const Icon(Icons.rotate_right_rounded)),IconButton.filledTonal(onPressed:()=>setState(()=>paused=!paused),icon:Icon(paused?Icons.play_arrow_rounded:Icons.pause_rounded))])),
    if(run)Expanded(child:Center(child:AspectRatio(aspectRatio:cols/rows,child:CustomPaint(painter:_TetrisPainter(board,cells()))))),
    if(run)Row(mainAxisAlignment:MainAxisAlignment.center,children:[IconButton.filled(onPressed:()=>move(-1),icon:const Icon(Icons.arrow_back_rounded)),IconButton.filled(onPressed:drop,icon:const Icon(Icons.arrow_downward_rounded)),IconButton.filled(onPressed:()=>move(1),icon:const Icon(Icons.arrow_forward_rounded))]),
  ]),if(over)Positioned.fill(child:_ArcadeOverlay(title:'GAME OVER',score:score,restart:restart))]));}
class _TetrisPainter extends CustomPainter{final List<List<int>> b;final List<Point<int>> active;_TetrisPainter(this.b,this.active);@override void paint(Canvas c,Size s){final cell=min(s.width/10,s.height/18),ox=(s.width-cell*10)/2,oy=(s.height-cell*18)/2;for(int y=0;y<18;y++)for(int x=0;x<10;x++)c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(ox+x*cell+1,oy+y*cell+1,cell-2,cell-2),const Radius.circular(4)),Paint()..color=b[y][x]!=0?const Color(0xFFA78BFA):const Color(0xFF111827));for(final p in active)if(p.y>=0)c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(ox+p.x*cell+1,oy+p.y*cell+1,cell-2,cell-2),const Radius.circular(4)),Paint()..color=const Color(0xFF22D3EE));}@override bool shouldRepaint(covariant _TetrisPainter old)=>true;}

class NexoraFlappyPage extends StatefulWidget{const NexoraFlappyPage({super.key});@override State<NexoraFlappyPage> createState()=>_NexoraFlappyState();}
class _NexoraFlappyState extends State<NexoraFlappyPage>{Timer?timer;double bird=.5,vy=0;int score=0;bool run=false,over=false;final rng=Random();List<double> pipes=[];
  void start(){timer?.cancel();setState((){run=true;over=false;score=0;bird=.5;vy=0;pipes=[.9,1.5];});timer=Timer.periodic(const Duration(milliseconds:30),(_)=>tick());}
  void tick(){if(!mounted||!run||over)return;setState((){vy+=.0015;bird+=vy;pipes=[for(final p in pipes)p-.008];if(pipes.first<-.12){pipes.removeAt(0);pipes.add(1.0+rng.nextDouble()*.5);score++;}if(bird<.03||bird>.97)end();});}
  void end(){over=true;timer?.cancel();}
  void flap(){if(!run){start();return;}if(!over)setState(()=>vy=-.018);}
  void restart(){timer?.cancel();setState((){run=false;over=false;score=0;pipes=[];});}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_ArcadeGameScaffold(title:'Flappy',restart:restart,child:Stack(children:[Positioned.fill(child:GestureDetector(onTap:flap,child:CustomPaint(painter:_FlappyPainter(bird,pipes)))),Positioned(top:12,left:12,child:_ArcadeBadge('SCORE '+score.toString())),if(!run)Positioned.fill(child:_ArcadeStart(title:'Flappy',description:'Tap layar untuk terbang dan lewati celah pipa.',button:start)),if(over)Positioned.fill(child:_ArcadeOverlay(title:'GAME OVER',score:score,restart:restart))]));}
class _FlappyPainter extends CustomPainter{final double bird;final List<double> pipes;_FlappyPainter(this.bird,this.pipes);@override void paint(Canvas c,Size s){c.drawRect(Offset.zero&s,Paint()..color=const Color(0xFF08111F));final p=Paint()..color=const Color(0xFF16A34A);for(final x in pipes){c.drawRect(Rect.fromLTWH(x*s.width,0,34,s.height*.32),p);c.drawRect(Rect.fromLTWH(x*s.width,s.height*.68,34,s.height*.32),p);}c.drawCircle(Offset(s.width*.28,bird*s.height),14,Paint()..color=const Color(0xFFFBBF24));}@override bool shouldRepaint(covariant _FlappyPainter old)=>true;}

class NexoraBreakoutPage extends StatefulWidget{const NexoraBreakoutPage({super.key});@override State<NexoraBreakoutPage> createState()=>_BreakoutState();}
class _BreakoutState extends State<NexoraBreakoutPage>{Timer?timer;double px=.5,bx=.5,by=.7,vx=.009,vy=-.009;int score=0;bool run=false,over=false;final bricks=<Point<int>>{};
  void start(){timer?.cancel();bricks.clear();for(int r=0;r<3;r++)for(int c=0;c<7;c++)bricks.add(Point(c,r));setState((){run=true;over=false;score=0;px=.5;bx=.5;by=.7;vx=.009;vy=-.009;});timer=Timer.periodic(const Duration(milliseconds:30),(_)=>tick());}
  void tick(){if(!mounted||!run||over)return;setState((){bx+=vx;by+=vy;if(bx<.02||bx>.98)vx=-vx;if(by<.03)vy=-vy;if(by>.94){if((bx-px).abs()<.17){vy=-vy;by=.91;}else{end();return;}}final col=(bx*7).floor().clamp(0,6),row=((by-.2)*8).floor().clamp(0,2),hit=Point<int>(col,row);if(bricks.remove(hit)){score+=10;vy=-vy;if(bricks.isEmpty)end();}});}
  void end(){over=true;timer?.cancel();}
  void restart(){timer?.cancel();setState((){run=false;over=false;score=0;bricks.clear();});}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_ArcadeGameScaffold(title:'Breakout',restart:restart,child:Stack(children:[GestureDetector(onHorizontalDragUpdate:(d){setState(()=>px=(px+d.delta.dx/300).clamp(.08,.92));},child:CustomPaint(size:Size.infinite,painter:_BreakoutPainter(bx,by,px,bricks))),Positioned(top:12,left:12,child:_ArcadeBadge('SCORE '+score.toString())),if(!run)Positioned.fill(child:_ArcadeStart(title:'Breakout',description:'Geser paddle kiri/kanan dan hancurkan semua brick.',button:start)),if(over)Positioned.fill(child:_ArcadeOverlay(title:bricks.isEmpty?'YOU WIN':'GAME OVER',score:score,restart:restart))]));}
class _BreakoutPainter extends CustomPainter{final double bx,by,px;final Set<Point<int>> bricks;_BreakoutPainter(this.bx,this.by,this.px,this.bricks);@override void paint(Canvas c,Size s){c.drawRect(Offset.zero&s,Paint()..color=const Color(0xFF080C18));for(final b in bricks){final x=s.width*(.12+b.x*.11),y=s.height*.2+b.y*22;c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x,y,s.width*.095,17),const Radius.circular(5)),Paint()..color=const Color(0xFF60A5FA));}c.drawCircle(Offset(bx*s.width,by*s.height),7,Paint()..color=Colors.white);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(px*s.width-s.width*.12,s.height-48,s.width*.24,10),const Radius.circular(5)),Paint()..color=const Color(0xFF22D3EE));}@override bool shouldRepaint(covariant _BreakoutPainter old)=>true;}

class NexoraMemoryPage extends StatefulWidget{const NexoraMemoryPage({super.key});@override State<NexoraMemoryPage> createState()=>_MemoryState();}
class _MemoryState extends State<NexoraMemoryPage>{final base=<String>['★','★','◆','◆','●','●','▲','▲','♥','♥','✦','✦'];final rng=Random();late List<String>cards;final open=<int>{};final matched=<int>{};int moves=0;bool busy=false,started=false;
  void start(){cards=[...base]..shuffle(rng);open.clear();matched.clear();moves=0;busy=false;started=true;setState((){});}
  void tap(int i){if(!started||busy||matched.contains(i)||open.contains(i))return;setState(()=>open.add(i));if(open.length==2){busy=true;final a=open.toList();moves++;Future.delayed(const Duration(milliseconds:450),(){if(!mounted)return;setState((){if(cards[a[0]]==cards[a[1]])matched.addAll(a);open.clear();busy=false;});});}}
  void restart(){setState((){started=false;open.clear();matched.clear();moves=0;busy=false;});}
  @override Widget build(BuildContext context)=>_ArcadeGameScaffold(title:'Memory',restart:restart,child:!started?_ArcadeStart(title:'Memory',description:'Buka dua kartu dan cari semua pasangan yang sama.',button:start):Column(children:[Padding(padding:const EdgeInsets.all(12),child:Row(children:[_ArcadeBadge('MOVES '+moves.toString()),const Spacer(),Text((matched.length~/2).toString()+'/6 PASANG',style:const TextStyle(fontWeight:FontWeight.w900))])),Expanded(child:GridView.builder(padding:const EdgeInsets.all(14),itemCount:12,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:10,mainAxisSpacing:10),itemBuilder:(_,i){final visible=open.contains(i)||matched.contains(i);return GestureDetector(onTap:()=>tap(i),child:Container(decoration:BoxDecoration(color:visible?const Color(0xFF1F2937):const Color(0xFF111827),borderRadius:BorderRadius.circular(16),border:Border.all(color:visible?const Color(0xFF34D399):Colors.white12)),child:Center(child:Text(visible?cards[i]:'?',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900,color:visible?const Color(0xFF34D399):Colors.white54)))));}))]));}

class NexoraPongPage extends StatefulWidget{const NexoraPongPage({super.key});@override State<NexoraPongPage> createState()=>_PongState();}
class _PongState extends State<NexoraPongPage>{Timer?timer;double player=.5,bot=.5,x=.5,y=.5,vx=.009,vy=.008;int score=0,botScore=0;bool run=false,over=false;
  void start(){timer?.cancel();setState((){run=true;over=false;score=0;botScore=0;player=.5;bot=.5;x=.5;y=.5;vx=.009;vy=.008;});timer=Timer.periodic(const Duration(milliseconds:25),(_)=>tick());}
  void tick(){if(!mounted||!run||over)return;setState((){x+=vx;y+=vy;bot+=(y-bot)*.08;if(y<.04||y>.96)vy=-vy;if(x<.05){if((y-player).abs()<.18){vx=-vx;x=.08;}else{botScore++;serve();}}if(x>.95){if((y-bot).abs()<.18){vx=-vx;x=.92;}else{score++;serve();}}if(score>=7||botScore>=7){over=true;timer?.cancel();}});}
  void serve(){x=.5;y=.5;vx=-vx;}
  void restart(){timer?.cancel();setState(()=>run=false);}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_ArcadeGameScaffold(title:'Pong',restart:restart,child:Stack(children:[GestureDetector(onVerticalDragUpdate:(d){setState(()=>player=(player+d.delta.dy/300).clamp(.12,.88));},child:CustomPaint(size:Size.infinite,painter:_PongPainter(player,bot,x,y))),Positioned(top:12,left:12,child:_ArcadeBadge(score.toString()+' : '+botScore.toString())),if(!run)Positioned.fill(child:_ArcadeStart(title:'Pong',description:'Geser vertikal untuk menggerakkan paddle. Pertama ke 7.',button:start)),if(over)Positioned.fill(child:_ArcadeOverlay(title:score>=7?'YOU WIN':'BOT WINS',score:score,restart:restart))]));}
class _PongPainter extends CustomPainter{final double player,bot,x,y;_PongPainter(this.player,this.bot,this.x,this.y);@override void paint(Canvas c,Size s){c.drawRect(Offset.zero&s,Paint()..color=const Color(0xFF07101A));final line=Paint()..color=Colors.white12..strokeWidth=2;for(double y=0;y<s.height;y+=22)c.drawLine(Offset(s.width/2,y),Offset(s.width/2,y+10),line);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(18,player*s.height-45,9,90),const Radius.circular(5)),Paint()..color=const Color(0xFF38BDF8));c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width-27,bot*s.height-45,9,90),const Radius.circular(5)),Paint()..color=const Color(0xFFF472B6));c.drawCircle(Offset(x*s.width,y*s.height),8,Paint()..color=Colors.white);}@override bool shouldRepaint(covariant _PongPainter old)=>true;}

class NexoraWhackPage extends StatefulWidget{const NexoraWhackPage({super.key});@override State<NexoraWhackPage> createState()=>_WhackState();}
class _WhackState extends State<NexoraWhackPage>{Timer?timer;final rng=Random();int active=0,score=0,time=30;bool run=false;int?hit;
  void start(){timer?.cancel();setState((){run=true;score=0;time=30;active=rng.nextInt(9);hit=null;});timer=Timer.periodic(const Duration(seconds:1),(_){if(!mounted)return;setState((){time--;active=rng.nextInt(9);hit=null;if(time<=0){run=false;timer?.cancel();}});});}
  void tap(int i){if(run&&i==active){score++;hit=i;setState((){});}}
  void restart(){timer?.cancel();setState(()=>run=false);}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_ArcadeGameScaffold(title:'Whack-a-Mole',restart:restart,child:!run?_ArcadeStart(title:'Whack-a-Mole',description:'Tap mole secepat mungkin sebelum waktu habis.',button:start):Column(children:[Padding(padding:const EdgeInsets.all(12),child:Row(children:[_ArcadeBadge('TIME '+time.toString()),const Spacer(),_ArcadeBadge('SCORE '+score.toString())])),Expanded(child:GridView.builder(padding:const EdgeInsets.all(20),itemCount:9,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:14,mainAxisSpacing:14),itemBuilder:(_,i)=>GestureDetector(onTap:()=>tap(i),child:Container(decoration:BoxDecoration(color:const Color(0xFF131A28),borderRadius:BorderRadius.circular(22)),child:Icon(i==active?Icons.pets_rounded:Icons.circle_outlined,size:44,color:i==active?const Color(0xFFF97316):Colors.white12)))))]));}

class NexoraMinesPage extends StatefulWidget{const NexoraMinesPage({super.key});@override State<NexoraMinesPage> createState()=>_MinesState();}
class _MinesState extends State<NexoraMinesPage>{static const n=8,mines=10;final rng=Random();late List<bool>mine,open,flag;bool started=false,over=false;int safe=0;
  void start(){mine=List.filled(n*n,false);open=List.filled(n*n,false);flag=List.filled(n*n,false);safe=0;over=false;started=true;int placed=0;while(placed<mines){final i=rng.nextInt(n*n);if(!mine[i]){mine[i]=true;placed++;}}setState((){});}
  int count(int i){final r=i~/n,c=i%n;int z=0;for(int dr=-1;dr<=1;dr++)for(int dc=-1;dc<=1;dc++){final rr=r+dr,cc=c+dc;if(rr>=0&&rr<n&&cc>=0&&cc<n&&mine[rr*n+cc])z++;}return z;}
  void reveal(int i){if(!started||over||open[i]||flag[i])return;if(mine[i]){setState(()=>over=true);return;}if(open[i])return;setState((){open[i]=true;safe++;});if(count(i)==0){final r=i~/n,c=i%n;for(int dr=-1;dr<=1;dr++)for(int dc=-1;dc<=1;dc++){final rr=r+dr,cc=c+dc;if(rr>=0&&rr<n&&cc>=0&&cc<n)reveal(rr*n+cc);}}if(safe>=n*n-mines)setState(()=>over=true);}
  void toggle(int i){if(started&&!over&&!open[i])setState(()=>flag[i]=!flag[i]);}
  void restart()=>setState(()=>started=false);
  @override Widget build(BuildContext context)=>_ArcadeGameScaffold(title:'Minesweeper',restart:restart,child:!started?_ArcadeStart(title:'Minesweeper',description:'Tap untuk buka. Tahan untuk memberi flag pada ranjau.',button:start):Stack(children:[Column(children:[Padding(padding:const EdgeInsets.all(10),child:Row(children:[_ArcadeBadge('MINES '+mines.toString()),const Spacer(),Text(safe.toString()+'/'+(n*n-mines).toString(),style:const TextStyle(fontWeight:FontWeight.w900))])),Expanded(child:GridView.builder(padding:const EdgeInsets.all(12),itemCount:n*n,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:n,crossAxisSpacing:3,mainAxisSpacing:3),itemBuilder:(_,i)=>GestureDetector(onTap:()=>reveal(i),onLongPress:()=>toggle(i),child:Container(decoration:BoxDecoration(color:open[i]?const Color(0xFF202938):const Color(0xFF111827),borderRadius:BorderRadius.circular(5)),child:Center(child:Text(flag[i]?'⚑':open[i]?(mine[i]?'✹':(count(i)==0?'':count(i).toString())):'',style:const TextStyle(fontWeight:FontWeight.w900,color:Color(0xFFA78BFA))))))))]),if(over)Positioned.fill(child:_ArcadeOverlay(title:'ROUND OVER',score:safe,restart:restart))]));}

class NexoraSimonPage extends StatefulWidget{const NexoraSimonPage({super.key});@override State<NexoraSimonPage> createState()=>_SimonState();}
class _SimonState extends State<NexoraSimonPage>{final rng=Random();final seq=<int>[];int showing=-1,input=0,score=0;bool run=false,locked=false,over=false;
  void start(){seq.clear();score=0;over=false;run=true;nextRound();}
  Future<void> nextRound() async{if(!mounted)return;seq.add(rng.nextInt(4));input=0;locked=true;for(final v in seq){if(!mounted)return;setState(()=>showing=v);await Future.delayed(const Duration(milliseconds:400));if(!mounted)return;setState(()=>showing=-1);await Future.delayed(const Duration(milliseconds:120));}if(mounted)setState(()=>locked=false);}
  void tap(int i){if(!run||locked||over)return;if(seq[input]!=i){setState(()=>over=true);return;}setState(()=>input++);if(input==seq.length){score++;nextRound();}}
  void restart()=>setState((){run=false;over=false;locked=false;seq.clear();score=0;showing=-1;});
  @override Widget build(BuildContext context)=>_ArcadeGameScaffold(title:'Simon Says',restart:restart,child:Stack(children:[Column(children:[if(!run)Expanded(child:_ArcadeStart(title:'Simon Says',description:'Hafalkan urutan lampu lalu tekan dengan urutan yang sama.',button:start)),if(run)Padding(padding:const EdgeInsets.all(14),child:Row(children:[_ArcadeBadge('ROUND '+(score+1).toString()),const Spacer(),Text(locked?'WATCH':'YOUR TURN',style:const TextStyle(fontWeight:FontWeight.w900))])),if(run)Expanded(child:GridView.count(shrinkWrap:true,crossAxisCount:2,padding:const EdgeInsets.all(28),crossAxisSpacing:16,mainAxisSpacing:16,children:[for(int i=0;i<4;i++)GestureDetector(onTap:()=>tap(i),child:AnimatedContainer(duration:const Duration(milliseconds:100),decoration:BoxDecoration(color:[const Color(0xFFEF4444),const Color(0xFF22C55E),const Color(0xFF3B82F6),const Color(0xFFEAB308)][i].withValues(alpha:showing==i?1:.28),borderRadius:BorderRadius.circular(28)),child:const Icon(Icons.circle,size:30,color:Colors.white70))))]))]),if(over)Positioned.fill(child:_ArcadeOverlay(title:'WRONG SEQUENCE',score:score,restart:restart))]));}

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

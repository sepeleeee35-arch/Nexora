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
          onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const TapRushPage())),
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

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});
  @override State<GamesPage> createState()=>_GamesState();
}
class _GamesState extends State<GamesPage>{
  String filter='All';
  final categories=const ['All','Arcade','Puzzle','Racing','Runner'];
  final games=const [
    ['Tap Rush','Arcade','PLAYABLE',Icons.touch_app_rounded,Color(0xFF7C3AED)],
    ['Memory Grid','Puzzle','PLAYABLE',Icons.grid_view_rounded,Color(0xFF0891B2)],
    ['Nexora Runner','Runner','PLAYABLE',Icons.directions_run_rounded,Color(0xFF16A34A)],
    ['Neon Circuit','Racing','PLAYABLE',Icons.directions_car_rounded,Color(0xFFF97316)],
    ['Block Forge','Puzzle','PLAYABLE',Icons.extension_rounded,Color(0xFF2563EB)],
    ['Sky Dash','Arcade','PLAYABLE',Icons.flight_rounded,Color(0xFF0D9488)],
    ['Color Clash','Arcade','PLAYABLE',Icons.palette_rounded,Color(0xFFDB2777)],
    ['Reaction Rush','Arcade','PLAYABLE',Icons.flash_on_rounded,Color(0xFFF59E0B)],
    ['Number Sprint','Puzzle','PLAYABLE',Icons.calculate_rounded,Color(0xFF059669)],
    ['Dodge Zone','Runner','PLAYABLE',Icons.shield_rounded,Color(0xFF8B5CF6)],
  ];
  void openGame(String title){
    final Widget game=switch(title){
      'Memory Grid'=>const MemoryGridPage(),
      'Reaction Rush'=>const ReactionRushPage(),
      'Color Clash'=>const ColorClashPage(),
      'Number Sprint'=>const NumberSprintPage(),
      'Dodge Zone'=>const DodgeZonePage(),
      'Nexora Runner'=>const NexoraRunnerPage(),
      'Neon Circuit'=>const NexoraRunnerPage(mode:'Neon Circuit'),
      'Sky Dash'=>const NexoraRunnerPage(mode:'Sky Dash'),
      'Block Forge'=>const BlockForgePage(),
      _=>const TapRushPage(),
    };
    Navigator.push(context,MaterialPageRoute(builder:(_)=>game));
  }
  @override Widget build(BuildContext context){
    final visible=games.where((g)=>filter=='All'||g[1]==filter).toList();
    return ListView(padding:const EdgeInsets.fromLTRB(16,16,16,110),children:[
      Container(
        padding:const EdgeInsets.all(22),
        decoration:BoxDecoration(borderRadius:BorderRadius.circular(28),gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF4C1D95),Color(0xFF111827),Color(0xFF0F172A)])),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[Container(width:52,height:52,decoration:BoxDecoration(color:Colors.white12,borderRadius:BorderRadius.circular(17)),child:const Icon(Icons.sports_esports_rounded,size:28)),const Spacer(),const _Badge('10 GAMES')]),
          const SizedBox(height:20),
          const Text('Nexora Arcade',style:TextStyle(fontSize:29,fontWeight:FontWeight.w900)),
          const SizedBox(height:6),
          const Text('Mini-game original dengan kontrol cepat, skor, combo, dan gameplay yang bisa langsung dimainkan.'),
          const SizedBox(height:16),
          FilledButton.icon(onPressed:()=>openGame('Tap Rush'),icon:const Icon(Icons.play_arrow_rounded),label:const Text('Main sekarang')),
        ]),
      ),
      const SizedBox(height:20),
      SizedBox(height:42,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:categories.length,itemBuilder:(c,i)=>ChoiceChip(label:Text(categories[i]),selected:filter==categories[i],onSelected:(_)=>setState(()=>filter=categories[i])),separatorBuilder:(context,index)=>const SizedBox(width:8))),
      const SizedBox(height:18),
      Row(children:[const Expanded(child:Text('All Games',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900))),Text('${visible.length} game',style:Theme.of(context).textTheme.bodySmall)]),
      const SizedBox(height:10),
      GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:visible.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:.9),itemBuilder:(context,i){
        final g=visible[i];
        return _ArcadeTile(title:g[0] as String,category:g[1] as String,icon:g[3] as IconData,color:g[4] as Color,onTap:()=>openGame(g[0] as String));
      }),
      const SizedBox(height:14),
      Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.emoji_events_rounded)),title:const Text('Leaderboard',style:TextStyle(fontWeight:FontWeight.bold)),subtitle:const Text('Skor terbaik Nexora akan ditampilkan di sini.'),trailing:const Icon(Icons.chevron_right_rounded))),
    ]);
  }
}
class _ArcadeTile extends StatelessWidget{
  final String title,category; final IconData icon; final Color color; final VoidCallback onTap;
  const _ArcadeTile({required this.title,required this.category,required this.icon,required this.color,required this.onTap});
  @override Widget build(BuildContext context)=>Material(
    color:const Color(0xFF111522),borderRadius:BorderRadius.circular(22),
    child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(22),child:Container(
      padding:const EdgeInsets.all(15),
      decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[color.withValues(alpha:.55),const Color(0xFF111522)])),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[Container(width:52,height:52,decoration:BoxDecoration(color:color,borderRadius:BorderRadius.circular(17)),child:Icon(icon,size:27)),const Spacer(),const Icon(Icons.play_circle_fill_rounded,size:28)]),
        const Spacer(),
        Text(category.toUpperCase(),style:const TextStyle(fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1.1)),
        const SizedBox(height:4),Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),
      ]),
    )),
  );
}
class _Game extends StatelessWidget {
  final String title,desc,badge; final IconData icon; final Color color;
  const _Game(this.title,this.desc,this.icon,this.badge,this.color);
  @override Widget build(BuildContext context)=>Card(
    margin:const EdgeInsets.only(bottom:12),
    clipBehavior:Clip.antiAlias,
    child:InkWell(
      onTap: badge=='PLAYABLE' ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => title == 'Memory Grid' ? const MemoryGridPage() : title == 'Reaction Rush' ? const ReactionRushPage() : title == 'Color Clash' ? const ColorClashPage() : title == 'Number Sprint' ? const NumberSprintPage() : title == 'Dodge Zone' ? const DodgeZonePage() : title == 'Nexora Runner' ? const NexoraRunnerPage() : title == 'Neon Circuit' ? const NexoraRunnerPage(mode: 'Neon Circuit') : title == 'Sky Dash' ? const NexoraRunnerPage(mode: 'Sky Dash') : title == 'Block Forge' ? const BlockForgePage() : const TapRushPage())) : null,
      child:Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(gradient:LinearGradient(colors:[color.withValues(alpha:.45),const Color(0xFF111522)])),child:Row(children:[
        Container(width:60,height:60,decoration:BoxDecoration(color:color,borderRadius:BorderRadius.circular(17)),child:Icon(icon,size:30)),
        const SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[Expanded(child:Text(title,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900))),_Badge(badge)]),
          const SizedBox(height:5),Text(desc),
        ])),
        if(badge=='PLAYABLE') const Icon(Icons.play_circle_fill_rounded),
      ])),
    ),
  );
}
class _Badge extends StatelessWidget {
  final String text; const _Badge(this.text);
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:Theme.of(context).colorScheme.primary.withValues(alpha:.18),borderRadius:BorderRadius.circular(20)),child:Text(text,style:TextStyle(fontSize:9,fontWeight:FontWeight.w900,color:Theme.of(context).colorScheme.primary)));
}

class TapRushPage extends StatefulWidget {
  const TapRushPage({super.key});
  @override State<TapRushPage> createState()=>_TapRushState();
}
class _TapRushState extends State<TapRushPage> {
  final rng=Random(); Timer? timer; int score=0, seconds=20; bool playing=false; double x=.5,y=.5;
  void start(){
    timer?.cancel();
    setState((){score=0;seconds=20;playing=true;move();});
    timer=Timer.periodic(const Duration(seconds:1),(_){
      if(!mounted)return;
      if(seconds<=1){timer?.cancel();setState((){seconds=0;playing=false;});}
      else { setState(()=>seconds--); }
    });
  }
  void move(){x=.12+rng.nextDouble()*.76;y=.12+rng.nextDouble()*.66;}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Tap Rush')),
    body:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
      Row(children:[Expanded(child:_Score('Score','$score')),const SizedBox(width:10),Expanded(child:_Score('Time','${seconds}s'))]),
      const SizedBox(height:14),
      Expanded(child:Container(clipBehavior:Clip.antiAlias,decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:const LinearGradient(colors:[Color(0xFF161B2B),Color(0xFF24133E)])),child:LayoutBuilder(builder:(context,c)=>Stack(children:[
        if(playing) Positioned(left:c.maxWidth*x-30,top:c.maxHeight*y-30,child:GestureDetector(
          onTap:()=>setState((){score++;move();}),
          child:Container(width:60,height:60,decoration:BoxDecoration(shape:BoxShape.circle,color:Theme.of(context).colorScheme.primary,boxShadow:[BoxShadow(color:Theme.of(context).colorScheme.primary.withValues(alpha:.45),blurRadius:22,spreadRadius:4)]),child:const Icon(Icons.touch_app_rounded,size:29)),
        )) else Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
          Icon(Icons.touch_app_rounded,size:60,color:Theme.of(context).colorScheme.primary),
          const SizedBox(height:12),
          Text(seconds==0?'Selesai! Skor $score':'Tekan Start untuk bermain',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800)),
        ])),
      ])))),
      const SizedBox(height:14),
      SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:playing?null:start,icon:const Icon(Icons.play_arrow_rounded),label:Text(seconds==0?'Main Lagi':'Start'))),
    ])),
  );
}
class NexoraRunnerPage extends StatefulWidget{final String mode;const NexoraRunnerPage({super.key,this.mode='Nexora Runner'});@override State<NexoraRunnerPage> createState()=>_NexoraRunnerState();}
class _NexoraRunnerState extends State<NexoraRunnerPage>{Timer? timer;final rng=Random();int lane=1,score=0,lives=3,obstacle=1;bool running=false;
void start(){timer?.cancel();setState((){score=0;lives=3;lane=1;obstacle=rng.nextInt(3);running=true;});timer=Timer.periodic(const Duration(milliseconds:650),(_){if(!mounted)return;setState((){if(obstacle==lane){lives--;if(lives<=0){running=false;timer?.cancel();}}else{score++;}obstacle=rng.nextInt(3);});});}
@override void dispose(){timer?.cancel();super.dispose();}
@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.mode)),body:Padding(padding:const EdgeInsets.all(16),child:Column(children:[Row(children:[Expanded(child:_Score('Score',score.toString())),const SizedBox(width:8),Expanded(child:_Score('Lives',lives.toString()))]),const SizedBox(height:14),Expanded(child:GestureDetector(onHorizontalDragUpdate:(d)=>setState(()=>lane=(lane+(d.delta.dx>0?1:-1)).clamp(0,2)),onTap:()=>setState(()=>lane=(lane+1)%3),child:Container(decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:const LinearGradient(colors:[Color(0xFF101827),Color(0xFF23113E)])),child:Stack(children:[Row(children:[for(int i=0;i<3;i++)Expanded(child:Container(margin:const EdgeInsets.symmetric(horizontal:4),color:Colors.white.withValues(alpha:.03)))]),if(running)Align(alignment:Alignment((lane-1)*.7,.75),child:Icon(widget.mode=='Sky Dash'?Icons.flight_takeoff_rounded:Icons.directions_car_filled_rounded,size:58)),if(running)Align(alignment:Alignment((obstacle-1)*.7,-.65),child:const Icon(Icons.warning_rounded,size:52)),if(!running)Center(child:Text(score==0?'Geser atau tap untuk pindah lane':'Game Over • score $score',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)))])))),const SizedBox(height:12),SizedBox(width:double.infinity,child:FilledButton(onPressed:running?null:start,child:Text(running?'RUNNING':'START')))])));}
class BlockForgePage extends StatefulWidget{const BlockForgePage({super.key});@override State<BlockForgePage> createState()=>_BlockForgeState();}
class _BlockForgeState extends State<BlockForgePage>{final rng=Random();late List<int> cells;int score=0;@override void initState(){super.initState();cells=List.generate(9,(_)=>rng.nextInt(4));}void tap(int i){setState((){cells[i]=(cells[i]+1)%5;if(cells[i]==0)score+=10;});}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Block Forge')),body:Padding(padding:const EdgeInsets.all(18),child:Column(children:[_Score('Score',score.toString()),const SizedBox(height:14),const Text('Naikkan level blok sampai pecah.'),const SizedBox(height:18),Expanded(child:GridView.builder(gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:12,mainAxisSpacing:12),itemCount:9,itemBuilder:(c,i)=>InkWell(onTap:()=>tap(i),child:AnimatedContainer(duration:const Duration(milliseconds:160),decoration:BoxDecoration(borderRadius:BorderRadius.circular(20),color:Theme.of(context).colorScheme.primary.withValues(alpha:.18+cells[i]*.12)),child:Center(child:Text(cells[i]==0?'BREAK':cells[i].toString(),style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900)))))))])));}
class _Score extends StatelessWidget {
  final String label,value; const _Score(this.label,this.value);
  @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.symmetric(horizontal:15,vertical:12),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(label),Text(value,style:const TextStyle(fontWeight:FontWeight.w900))])));
}

class MemoryGridPage extends StatefulWidget {
  const MemoryGridPage({super.key});
  @override State<MemoryGridPage> createState() => _MemoryGridState();
}

class _MemoryGridState extends State<MemoryGridPage> {
  final rng = Random();
  final List<int> values = List<int>.generate(12, (i) => i);
  final Set<int> revealed = <int>{};
  int? first;
  int moves = 0;
  int pairs = 0;
  bool locked = false;

  void reset() {
    setState(() {
      values.shuffle(rng);
      revealed.clear();
      first = null;
      moves = 0;
      pairs = 0;
      locked = false;
    });
  }

  Future<void> tap(int index) async {
    if (locked || revealed.contains(index)) return;
    setState(() => revealed.add(index));

    if (first == null) {
      first = index;
      return;
    }

    final second = index;
    final isPair = values[first!] ~/ 2 == values[second] ~/ 2;
    moves++;
    locked = true;

    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    setState(() {
      if (isPair) {
        pairs++;
      } else {
        revealed.remove(first!);
        revealed.remove(second);
      }
      first = null;
      locked = false;
    });

    if (isPair && pairs == 6 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memory Grid selesai!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Memory Grid'),
      actions: [
        IconButton(onPressed: reset, icon: const Icon(Icons.refresh_rounded)),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _Score('Pairs', '$pairs / 6')),
              const SizedBox(width: 10),
              Expanded(child: _Score('Moves', '$moves')),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: values.length,
              itemBuilder: (context, index) {
                final open = revealed.contains(index);
                return GestureDetector(
                  onTap: () => tap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: open
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFF171B2A),
                    ),
                    child: Center(
                      child: Icon(
                        open ? Icons.star_rounded : Icons.help_outline_rounded,
                        size: 30,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          const Text('Buka dua kartu yang memiliki pasangan simbol yang sama.'),
        ],
      ),
    ),
  );
}

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});
  @override State<MusicPage> createState()=>_MusicState();
}
class _MusicState extends State<MusicPage>{
  final AudioPlayer player=AudioPlayer();
  int selected=0; bool playing=false; String query='';
  Duration position=Duration.zero; Duration duration=const Duration(seconds:7);
  final tracks=const [
    ('Nexora Intro','Nexora Studio',440.0,Color(0xFF7C3AED)),
    ('Afterlight','Nexora Studio',330.0,Color(0xFF2563EB)),
    ('Night Drive','Nexora Studio',220.0,Color(0xFF0891B2)),
    ('Pixel Rain','Nexora Studio',523.0,Color(0xFFDB2777)),
    ('Safe Horizon','Nexora Studio',294.0,Color(0xFF059669)),
    ('Midnight Bloom','Nexora Studio',196.0,Color(0xFFD97706)),
  ];
  @override void initState(){super.initState();
    player.onPlayerStateChanged.listen((s){if(mounted)setState(()=>playing=s==PlayerState.playing);});
    player.onPositionChanged.listen((p){if(mounted)setState(()=>position=p);});
    player.onDurationChanged.listen((d){if(mounted)setState(()=>duration=d);});
  }
  Uint8List _wav(double base){
    const sr=22050, seconds=8, channels=1, bits=16;
    final count=sr*seconds;
    final dataBytes=count*2;
    final data=ByteData(44+dataBytes);
    void w32(int o,int v)=>data.setUint32(o,v,Endian.little);
    void w16(int o,int v)=>data.setUint16(o,v,Endian.little);
    void ascii(int o,String s){for(int i=0;i<s.length;i++)data.setUint8(o+i,s.codeUnitAt(i));}
    ascii(0,'RIFF'); w32(4,36+dataBytes); ascii(8,'WAVE');
    ascii(12,'fmt '); w32(16,16); w16(20,1); w16(22,channels);
    w32(24,sr); w32(28,sr*channels*bits~/8); w16(32,channels*bits~/8); w16(34,bits);
    ascii(36,'data'); w32(40,dataBytes);
    for(int i=0;i<count;i++){
      final t=i/sr;
      final fadeIn=min(1.0,t*12);
      final fadeOut=min(1.0,(seconds-t)*5);
      final env=fadeIn*fadeOut;
      final pulse=(sin(2*pi*1.25*t)>0.72)?1.0:0.0;
      final melody=base*(1+0.06*sin(2*pi*0.33*t));
      var s=0.24*sin(2*pi*melody*t);
      s+=0.12*sin(2*pi*melody*1.5*t);
      s+=0.07*sin(2*pi*melody*2*t);
      s+=0.045*sin(2*pi*(base/2)*t);
      s+=pulse*0.08*sin(2*pi*55*t);
      final sample=(s*env*26000).clamp(-32768,32767).toInt();
      data.setInt16(44+i*2,sample,Endian.little);
    }
    return data.buffer.asUint8List();
  }
  Future<void> playSelected() async{await player.play(BytesSource(_wav(tracks[selected].$3),mimeType:'audio/wav'));}
  Future<void> selectTrack(int i) async{setState(()=>selected=i);await playSelected();}
  @override void dispose(){player.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final filtered=tracks.where((t)=>t.$1.toLowerCase().contains(query.toLowerCase())||t.$2.toLowerCase().contains(query.toLowerCase())).toList();
    final t=tracks[selected]; final maxMs=max(1,duration.inMilliseconds); final value=min(position.inMilliseconds.toDouble(),maxMs.toDouble());
    return ListView(padding:const EdgeInsets.fromLTRB(16,16,16,110),children:[
      Row(children:[const Expanded(child:Text('Nexora Music',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900))),Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:Theme.of(context).colorScheme.primary.withValues(alpha:.15),borderRadius:BorderRadius.circular(20)),child:const Text('ORIGINAL',style:TextStyle(fontSize:10,fontWeight:FontWeight.w900)))]),
      const SizedBox(height:4),const Text('Player audio aktif • Library • Playlist • Made for you'),const SizedBox(height:14),
      TextField(onChanged:(v)=>setState(()=>query=v),decoration:InputDecoration(prefixIcon:const Icon(Icons.search_rounded),hintText:'Cari lagu atau artis...',filled:true,border:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:BorderSide.none))),
      const SizedBox(height:18),
      Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(borderRadius:BorderRadius.circular(28),gradient:LinearGradient(colors:[t.$4,const Color(0xFF111522)])),child:Column(children:[
        Container(width:150,height:150,decoration:BoxDecoration(borderRadius:BorderRadius.circular(28),color:Colors.black26),child:const Icon(Icons.album_rounded,size:76)),
        const SizedBox(height:18),Text(t.$1,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900),textAlign:TextAlign.center),Text(t.$2),
        Slider(value:value,min:0,max:maxMs.toDouble(),onChanged:(v)=>player.seek(Duration(milliseconds:v.toInt()))),
        Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(_fmt(position)),Text(_fmt(duration))]),
        Row(mainAxisAlignment:MainAxisAlignment.center,children:[IconButton(onPressed:()=>selectTrack((selected-1+tracks.length)%tracks.length),icon:const Icon(Icons.skip_previous_rounded,size:32)),FilledButton(onPressed:playing?()=>player.pause():playSelected,style:FilledButton.styleFrom(shape:const CircleBorder(),padding:const EdgeInsets.all(18)),child:Icon(playing?Icons.pause_rounded:Icons.play_arrow_rounded,size:30)),IconButton(onPressed:()=>selectTrack((selected+1)%tracks.length),icon:const Icon(Icons.skip_next_rounded,size:32))]),
      ])),
      const SizedBox(height:22),const _Title('Made for you'),const SizedBox(height:10),
      SizedBox(height:105,child:ListView(scrollDirection:Axis.horizontal,children:[_MusicCard('Daily Mix','Original Nexora',Icons.auto_awesome_rounded),_MusicCard('Game Focus','Arcade energy',Icons.sports_esports_rounded),_MusicCard('Late Night','Chill original',Icons.nightlight_rounded)])),
      const SizedBox(height:22),const _Title('Library'),const SizedBox(height:10),
      for(final tr in filtered) Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(leading:CircleAvatar(backgroundColor:tr.$4,child:const Icon(Icons.music_note_rounded)),title:Text(tr.$1,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(tr.$2),trailing:Icon(tr.$1==t.$1&&playing?Icons.pause_circle_filled:Icons.play_circle_outline_rounded),onTap:()=>selectTrack(tracks.indexOf(tr)))),
      Card(child:ListTile(leading:const Icon(Icons.info_outline_rounded),title:const Text('Katalog original'),subtitle:const Text('Track bawaan Nexora dibuat original dan dapat langsung diputar. Lagu berhak cipta pihak lain tidak dibundel tanpa lisensi.'))),
    ]);
  }
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

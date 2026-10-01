import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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
  static const names = ['Home','Games','Music','Social','Market'];

  void selectPage(String value) {
    Navigator.pop(context);
    if (value == 'Home' || value == 'Games' || value == 'Music' || value == 'Social' || value == 'Market') {
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
        3 => const SocialPage(),
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
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people_rounded), label: 'Social'),
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
            Text('Game • Social • Market'),
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
      _Item(Icons.people_rounded,'Social',()=>onSelect('Social')),
      _Item(Icons.storefront_rounded,'Marketplace',()=>onSelect('Market')),
      const _Header('ACCOUNT'),
      _Item(Icons.account_balance_wallet_rounded,'Wallet & Coins',()=>onSelect('Wallet')),
      _Item(Icons.person_rounded,'Profile',()=>onSelect('Profile')),
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
        _Quick(Icons.people_rounded,'Community','Feed',()=>openTab(3)),
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
  @override Widget build(BuildContext context){
    final games=[
      ['Tap Rush','Arcade','PLAYABLE',Icons.touch_app_rounded,Color(0xFF6D28D9)],
      ['Memory Grid','Puzzle','PLAYABLE',Icons.grid_view_rounded,Color(0xFF155E75)],
      ['Nexora Runner','Runner','SOON',Icons.directions_run_rounded,Color(0xFF166534)],
      ['Neon Circuit','Racing','SOON',Icons.directions_car_rounded,Color(0xFF9A3412)],
      ['Block Forge','Puzzle','SOON',Icons.extension_rounded,Color(0xFF1D4ED8)],
      ['Sky Dash','Arcade','SOON',Icons.flight_rounded,Color(0xFF0F766E)],
    ].where((g)=>filter=='All'||g[1]==filter).toList();
    return ListView(padding:const EdgeInsets.all(16),children:[
      const Text('Game Hub',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),
      const SizedBox(height:5),const Text('Katalog game original Nexora. Offline dan online akan ditambahkan bertahap.'),
      const SizedBox(height:16),
      SizedBox(height:42,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:categories.length,itemBuilder:(c,i)=>ChoiceChip(label:Text(categories[i]),selected:filter==categories[i],onSelected:(_)=>setState(()=>filter=categories[i])),separatorBuilder:(_,_)=>const SizedBox(width:8))),
      const SizedBox(height:16),
      Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.emoji_events_rounded)),title:const Text('Leaderboard',style:TextStyle(fontWeight:FontWeight.bold)),subtitle:const Text('Skor terbaik dan ranking pemain Nexora.'),trailing:const Icon(Icons.chevron_right_rounded))),
      const SizedBox(height:10),
      for(final g in games) _Game(g[0] as String,'${g[1]} • game original Nexora',g[3] as IconData,g[2] as String,g[4] as Color),
    ]);
  }
}
class _Game extends StatelessWidget {
  final String title,desc,badge; final IconData icon; final Color color;
  const _Game(this.title,this.desc,this.icon,this.badge,this.color);
  @override Widget build(BuildContext context)=>Card(
    margin:const EdgeInsets.only(bottom:12),
    clipBehavior:Clip.antiAlias,
    child:InkWell(
      onTap:badge=='PLAYABLE'?()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const TapRushPage())):null,
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
class _Score extends StatelessWidget {
  final String label,value; const _Score(this.label,this.value);
  @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.symmetric(horizontal:15,vertical:12),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(label),Text(value,style:const TextStyle(fontWeight:FontWeight.w900))])));
}

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});
  @override State<MusicPage> createState()=>_MusicState();
}
class _MusicState extends State<MusicPage>{
  int selected=0;bool playing=false;bool premium=false;String query='';
  final tracks=const [('Nexora Intro','Nexora Studio'),('Afterlight','Nexora Studio'),('Night Drive','Nexora Studio'),('Safe Horizon','Nexora Studio'),('Pixel Rain','Nexora Studio'),('Midnight Bloom','Nexora Studio')];
  @override Widget build(BuildContext context){final filtered=tracks.where((t)=>t.$1.toLowerCase().contains(query.toLowerCase())).toList();final t=tracks[selected];
    return ListView(padding:const EdgeInsets.all(16),children:[
      Row(children:[const Expanded(child:Text('Nexora Music',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900))),Text(premium?'PREMIUM':'FREE',style:TextStyle(fontSize:10,fontWeight:FontWeight.w900,color:Theme.of(context).colorScheme.primary))]),
      const Text('Home • Explore • Library • Playlists • Player'),
      const SizedBox(height:12),
      TextField(onChanged:(v)=>setState(()=>query=v),decoration:InputDecoration(prefixIcon:const Icon(Icons.search_rounded),hintText:'Cari lagu, album, atau artis...',filled:true,border:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:BorderSide.none))),
      const SizedBox(height:16),
      Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:const LinearGradient(colors:[Color(0xFF312E81),Color(0xFF111827)])),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('NEXORA MUSIC',style:TextStyle(fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1.4)),const SizedBox(height:5),const Text('Your soundtrack',style:TextStyle(fontSize:23,fontWeight:FontWeight.w900)),const SizedBox(height:12),
        Row(children:[const CircleAvatar(radius:38,child:Icon(Icons.album_rounded,size:38)),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t.$1,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900)),Text(t.$2),const SizedBox(height:8),const LinearProgressIndicator(value:.34)]))]),
        Row(mainAxisAlignment:MainAxisAlignment.center,children:[IconButton(onPressed:(){},icon:const Icon(Icons.skip_previous_rounded)),FilledButton(onPressed:()=>setState(()=>playing=!playing),style:FilledButton.styleFrom(shape:const CircleBorder(),padding:const EdgeInsets.all(15)),child:Icon(playing?Icons.pause_rounded:Icons.play_arrow_rounded)),IconButton(onPressed:(){},icon:const Icon(Icons.skip_next_rounded)),IconButton(onPressed:(){},icon:const Icon(Icons.queue_music_rounded))]),
      ])),
      const SizedBox(height:18),const _Title('Made for you'),const SizedBox(height:8),
      SizedBox(height:110,child:ListView(scrollDirection:Axis.horizontal,children:[_MusicCard('Daily Mix','Campuran harian',Icons.auto_awesome_rounded),_MusicCard('Night Drive','Electronic & chill',Icons.nightlight_rounded),_MusicCard('Game Focus','Musik untuk bermain',Icons.sports_esports_rounded)])),
      const SizedBox(height:18),const _Title('Library'),const SizedBox(height:8),
      for(final tr in filtered) Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(leading:const CircleAvatar(child:Icon(Icons.album_rounded)),title:Text(tr.$1,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(tr.$2),trailing:Icon(tr.$1==t.$1&&playing?Icons.pause_circle_filled:Icons.play_circle_outline_rounded),onTap:()=>setState((){selected=tracks.indexOf(tr);playing=true;}))),
      const SizedBox(height:10),
      Card(child:ListTile(leading:const Icon(Icons.workspace_premium_rounded),title:Text(premium?'Nexora Premium aktif':'Nexora Premium'),subtitle:Text(premium?'Mode premium demo aktif.':'Premium akan punya fitur tambahan yang kamu tentukan.'),trailing:FilledButton(onPressed:()=>setState(()=>premium=!premium),child:Text(premium?'ON':'VIEW')))),
    ]);}
}
class _MusicCard extends StatelessWidget{
  final String title,sub;final IconData icon;const _MusicCard(this.title,this.sub,this.icon);
  @override Widget build(BuildContext context)=>Container(width:170,margin:const EdgeInsets.only(right:10),padding:const EdgeInsets.all(14),decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),color:const Color(0xFF111522)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[CircleAvatar(child:Icon(icon)),const Spacer(),Text(title,style:const TextStyle(fontWeight:FontWeight.w900)),Text(sub,style:const TextStyle(fontSize:11))]);
}
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

class ProfilePage extends StatelessWidget{
  const ProfilePage({super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    const SizedBox(height:10),const Center(child:CircleAvatar(radius:46,child:Icon(Icons.person_rounded,size:46))),
    const SizedBox(height:12),const Center(child:Text('Nexora Player',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900))),const Center(child:Text('@nexora_player')),
    const SizedBox(height:14),Center(child:FilledButton.icon(onPressed:(){},icon:const Icon(Icons.edit_rounded),label:const Text('Edit Profile'))),
    const SizedBox(height:20),const Row(children:[Expanded(child:_PStat('1','Level')),SizedBox(width:10),Expanded(child:_PStat('0','Posts')),SizedBox(width:10),Expanded(child:_PStat('0','Friends'))]),
    const SizedBox(height:18),const _Title('Account'),const Card(child:Column(children:[
      ListTile(leading:Icon(Icons.badge_rounded),title:Text('Rookie'),subtitle:Text('Member Nexora'),trailing:Icon(Icons.chevron_right_rounded)),
      Divider(height:1),ListTile(leading:Icon(Icons.verified_user_rounded),title:Text('Account security'),trailing:Icon(Icons.chevron_right_rounded)),
    ])),
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

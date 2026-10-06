// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NexoraWebGame {
  final String title, category, path;
  final IconData icon;
  final Color accent;
  const NexoraWebGame(this.title,this.category,this.path,this.icon,this.accent);
}

const games = <NexoraWebGame>[
  NexoraWebGame('Stack Tower','ARCADE','assets/games/mashukui/stack-tower/index.html',Icons.account_balance_rounded,Color(0xFF8B5CF6)),
  NexoraWebGame('Paddle Duel','ARCADE','assets/games/mashukui/paddle-duel/index.html',Icons.sports_tennis_rounded,Color(0xFF22D3EE)),
  NexoraWebGame('Breakout','ARCADE','assets/games/mashukui/breakout/index.html',Icons.grid_view_rounded,Color(0xFFEF4444)),
  NexoraWebGame('Gem Match','PUZZLE','assets/games/mashukui/gem-match/index.html',Icons.diamond_rounded,Color(0xFFA78BFA)),
  NexoraWebGame('Water Sort','PUZZLE','assets/games/mashukui/water-sort/index.html',Icons.science_rounded,Color(0xFF22D3EE)),
  NexoraWebGame('Sokoban','PUZZLE','assets/games/mashukui/sokoban/index.html',Icons.inventory_2_rounded,Color(0xFFF59E0B)),
  NexoraWebGame('Memory Match','PUZZLE','assets/games/mashukui/memory-match/index.html',Icons.style_rounded,Color(0xFFEC4899)),
  NexoraWebGame('Sudoku','PUZZLE','assets/games/mashukui/sudoku/index.html',Icons.grid_3x3_rounded,Color(0xFF60A5FA)),
  NexoraWebGame('Slide Puzzle','PUZZLE','assets/games/mashukui/slide-puzzle/index.html',Icons.dashboard_customize_rounded,Color(0xFF34D399)),
  NexoraWebGame('Lights Out','PUZZLE','assets/games/mashukui/lights-out/index.html',Icons.lightbulb_rounded,Color(0xFFFBBF24)),
  NexoraWebGame('Air Hockey','ARCADE','assets/games/mashukui/air-hockey/index.html',Icons.sports_hockey_rounded,Color(0xFF06B6D4)),
  NexoraWebGame('Snake','CLASSIC','assets/games/mashukui/snake/index.html',Icons.pest_control_rounded,Color(0xFF4ADE80)),
  NexoraWebGame('Piano Tap','ARCADE','assets/games/mashukui/piano-tap/index.html',Icons.piano_rounded,Color(0xFFE879F9)),
  NexoraWebGame('Block Drop','ARCADE','assets/games/mashukui/block-drop/index.html',Icons.view_module_rounded,Color(0xFFA78BFA)),
  NexoraWebGame('Connect Four','CLASSIC','assets/games/mashukui/connect-four/index.html',Icons.circle_rounded,Color(0xFFF87171)),
  NexoraWebGame('Tic Tac Toe','CLASSIC','assets/games/mashukui/tic-tac-toe/index.html',Icons.close_rounded,Color(0xFF38BDF8)),
  NexoraWebGame('Merge Cats','PUZZLE','assets/games/skymoon/merge-cats/index.html',Icons.pets_rounded,Color(0xFFF472B6)),
  NexoraWebGame('Merge Town','PUZZLE','assets/games/skymoon/merge-town/index.html',Icons.location_city_rounded,Color(0xFFF59E0B)),
  NexoraWebGame('Cat Seesaw','ARCADE','assets/games/skymoon/cat-seesaw/index.html',Icons.balance_rounded,Color(0xFFC084FC)),
];

class NexoraWebArcade extends StatefulWidget {
  const NexoraWebArcade({super.key});
  @override State<NexoraWebArcade> createState()=>_NexoraWebArcadeState();
}
class _NexoraWebArcadeState extends State<NexoraWebArcade> {
  String filter='ALL',query='';
  @override Widget build(BuildContext context) {
    final visible=games.where((g)=>(filter=='ALL'||g.category==filter)&&(query.isEmpty||g.title.toLowerCase().contains(query.toLowerCase()))).toList();
    return Scaffold(
      backgroundColor:const Color(0xFF05070D),
      body:SafeArea(child:ListView(padding:const EdgeInsets.fromLTRB(16,14,16,100),children:[
        Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(borderRadius:BorderRadius.circular(30),gradient:const LinearGradient(colors:[Color(0xFF281052),Color(0xFF0B2037),Color(0xFF090D17)]),border:Border.all(color:Colors.white10)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[Icon(Icons.sports_esports_rounded,color:Color(0xFFA78BFA),size:32),Spacer(),Text('19 GAMES',style:TextStyle(fontSize:9,fontWeight:FontWeight.w900,letterSpacing:1.2,color:Colors.white70))]),
          SizedBox(height:18),Text('NEXORA ARCADE',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,letterSpacing:2,color:Colors.white54)),
          SizedBox(height:4),Text('Play. Beat. Repeat.',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900)),
          SizedBox(height:7),Text('19 curated open-source mini-games • touch-first • offline ready.',style:TextStyle(color:Colors.white60,height:1.35)),
        ])),
        const SizedBox(height:14),
        TextField(onChanged:(v)=>setState(()=>query=v),style:const TextStyle(color:Colors.white),decoration:InputDecoration(prefixIcon:Icon(Icons.search_rounded),hintText:'Search games',filled:true,fillColor:Color(0xFF0D1320),border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(18)),borderSide:BorderSide.none))),
        const SizedBox(height:10),
        SizedBox(height:40,child:ListView(scrollDirection:Axis.horizontal,children:['ALL','ARCADE','PUZZLE','CLASSIC'].map((x)=>Padding(padding:const EdgeInsets.only(right:8),child:ChoiceChip(label:Text(x),selected:filter==x,onSelected:(_)=>setState(()=>filter=x)))).toList())),
        const SizedBox(height:18),
        Text('Arcade library • 19 games',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
        const SizedBox(height:10),
        GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:visible.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:11,mainAxisSpacing:11,childAspectRatio:.77),itemBuilder:(_,i)=>_Card(visible[i])),
        const SizedBox(height:20),
        const Text('MIT license notices are bundled with the game assets.',style:TextStyle(fontSize:11,color:Colors.white38)),
      ])),
    );
  }
}

class _Card extends StatelessWidget {
  final NexoraWebGame game;
  const _Card(this.game);
  @override Widget build(BuildContext context)=>Container(
    decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),color:const Color(0xFF0A0E18),border:Border.all(color:game.accent.withOpacity(.3)),boxShadow:[BoxShadow(color:game.accent.withOpacity(.12),blurRadius:18)]),
    child:ClipRRect(borderRadius:BorderRadius.circular(24),child:Column(children:[
      Expanded(flex:7,child:Stack(children:[
        Positioned.fill(child:DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(colors:[game.accent.withOpacity(.4),const Color(0xFF03050A)],begin:Alignment.topLeft,end:Alignment.bottomRight)))),
        Center(child:Container(width:76,height:76,decoration:BoxDecoration(color:Colors.black26,borderRadius:BorderRadius.circular(24),border:Border.all(color:game.accent.withOpacity(.35))),child:Icon(game.icon,color:game.accent,size:40))),
        Positioned(left:10,top:10,child:Text(game.category,style:const TextStyle(fontSize:8,fontWeight:FontWeight.w900,color:Colors.white70))),
      ])),
      Expanded(flex:5,child:Padding(padding:const EdgeInsets.fromLTRB(12,8,10,9),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(game.title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900)),
        const Spacer(),
        SizedBox(width:double.infinity,height:36,child:FilledButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>_GameScreen(game))),icon:const Icon(Icons.play_arrow_rounded,size:18),label:const Text('PLAY',style:TextStyle(fontSize:10,fontWeight:FontWeight.w900)))),
      ]))),
    ])),
  );
}

class _GameScreen extends StatefulWidget {
  final NexoraWebGame game;
  const _GameScreen(this.game);
  @override State<_GameScreen> createState()=>_GameScreenState();
}
class _GameScreenState extends State<_GameScreen> {
  late final WebViewController controller;
  int progress=0;
  @override void initState(){
    super.initState();
    controller=WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF05070D))
      ..setNavigationDelegate(NavigationDelegate(onProgress:(v){if(mounted)setState(()=>progress=v);}));
    controller.loadFlutterAsset(widget.game.path);
  }
  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:const Color(0xFF05070D),
    appBar:AppBar(title:Text(widget.game.title,style:const TextStyle(fontWeight:FontWeight.w900)),actions:[IconButton(onPressed:()=>controller.reload(),icon:const Icon(Icons.refresh_rounded))]),
    body:Stack(children:[WebViewWidget(controller:controller),if(progress<100)Align(alignment:Alignment.topCenter,child:LinearProgressIndicator(value:progress==0?null:progress/100,minHeight:2,color:widget.game.accent))]),
  );
}

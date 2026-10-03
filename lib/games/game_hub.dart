// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

String? nexoraActiveAccountId;

const _bg = Color(0xFF070A12);
const _panel = Color(0xFF111827);
const _purple = Color(0xFF8B5CF6);
const _cyan = Color(0xFF22D3EE);
const _worldTop = Color(0xFF10152A);
const _worldBottom = Color(0xFF060810);

class NexoraGameHub extends StatefulWidget {
  const NexoraGameHub({super.key});
  @override State<NexoraGameHub> createState() => _NexoraGameHubState();
}

class _NexoraGameHubState extends State<NexoraGameHub> {
  String filter='ALL', search='';
  static const games=[
    _G('Snake','ARCADE','Eat. Grow. Survive.',Icons.change_history_rounded,Color(0xFF22C55E)),
    _G('2048','PUZZLE','Merge your way to 2048.',Icons.grid_4x4_rounded,Color(0xFFF59E0B)),
    _G('Tetris','ARCADE','Stack fast. Clear lines.',Icons.view_module_rounded,Color(0xFFA855F7)),
    _G('Flappy','ARCADE','One tap. Perfect timing.',Icons.flutter_dash_rounded,Color(0xFF06B6D4)),
    _G('Breakout','ARCADE','Smash the core.',Icons.sports_baseball_rounded,Color(0xFFEF4444)),
    _G('Memory','PUZZLE','Flip. Match. Master.',Icons.style_rounded,Color(0xFFEC4899)),
    _G('Pong','SPORT','First to seven.',Icons.sports_tennis_rounded,Color(0xFF3B82F6)),
    _G('Neon Jump','ARCADE','Climb the skyline.',Icons.bolt_rounded,Color(0xFFD946EF)),
    _G('Minesweeper','PUZZLE','Read the field.',Icons.radar_rounded,Color(0xFFF97316)),
    _G('Simon Says','PUZZLE','Remember the pulse.',Icons.psychology_rounded,Color(0xFF14B8A6)),
    _G('Color Stack','PUZZLE','Sort the spectrum.',Icons.water_drop_rounded,Color(0xFF6366F1)),
  ];
  Widget page(String n){switch(n){case 'Snake':return _Snake();case '2048':return _Twenty();case 'Tetris':return _Tetris();case 'Flappy':return _Flappy();case 'Breakout':return _Breakout();case 'Memory':return _Memory();case 'Pong':return _Pong();case 'Neon Jump':return _Jump();case 'Minesweeper':return _Mines();case 'Simon Says':return _Simon();default:return _ColorStack();}}
  @override Widget build(BuildContext c){final list=games.where((g)=>(filter=='ALL'||g.cat==filter)&&(search.isEmpty||g.name.toLowerCase().contains(search.toLowerCase()))).toList();return Scaffold(backgroundColor:_bg,body:SafeArea(child:ListView(padding:EdgeInsets.fromLTRB(16,14,16,110),children:[
    Container(padding:EdgeInsets.all(20),decoration:BoxDecoration(borderRadius:BorderRadius.circular(30),gradient:LinearGradient(colors:[Color(0xFF27105C),Color(0xFF0C1D38),Color(0xFF090D18)],begin:Alignment.topLeft,end:Alignment.bottomRight),border:Border.all(color:Colors.white10)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Container(width:52,height:52,decoration:BoxDecoration(color:_purple.withOpacity(.18),borderRadius:BorderRadius.circular(17)),child:Icon(Icons.sports_esports_rounded,color:_purple,size:29)),Spacer(),_Pill('ARCADE COLLECTION')]),
      SizedBox(height:20),Text('NEXORA ARCADE',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,letterSpacing:2,color:Colors.white54)),SizedBox(height:4),Text('Play. Beat. Repeat.',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900,letterSpacing:-.8)),SizedBox(height:7),Text('11 polished mini games. Instant sessions. Built for one-more-round energy.',style:TextStyle(color:Colors.white60,height:1.35)),SizedBox(height:18),Row(children:[_Stat('11','GAMES'),SizedBox(width:8),_Stat('3','MODES'),SizedBox(width:8),_Stat('∞','REPLAY')])
    ])),
    SizedBox(height:14),TextField(onChanged:(v)=>setState(()=>search=v),style:TextStyle(color:Colors.white),decoration:InputDecoration(prefixIcon:Icon(Icons.search_rounded),hintText:'Search games',filled:true,fillColor:_panel,border:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:BorderSide.none))),
    SizedBox(height:10),SizedBox(height:40,child:ListView(scrollDirection:Axis.horizontal,children:[for(final x in ['ALL','ARCADE','PUZZLE','SPORT'])Padding(padding:EdgeInsets.only(right:8),child:ChoiceChip(label:Text(x),selected:filter==x,onSelected:(_)=>setState(()=>filter=x)))])),
    SizedBox(height:18),Row(children:[Expanded(child:Text('Arcade library',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900))),Text('\${list.length} games',style:TextStyle(color:Colors.white38))]),SizedBox(height:10),
    GridView.builder(shrinkWrap:true,physics:NeverScrollableScrollPhysics(),itemCount:list.length,gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:11,mainAxisSpacing:11,childAspectRatio:.82),itemBuilder:(_,i){final g=list[i];return _GameCard(g,()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>page(g.name))));}),
  ])));}

}
class _G{final String name,cat,sub;final IconData icon;final Color color;const _G(this.name,this.cat,this.sub,this.icon,this.color);}
class _Pill extends StatelessWidget{final String t;const _Pill(this.t);Widget build(BuildContext c)=>Container(padding:EdgeInsets.symmetric(horizontal:10,vertical:7),decoration:BoxDecoration(color:Colors.black26,borderRadius:BorderRadius.circular(20),border:Border.all(color:Colors.white10)),child:Text(t,style:TextStyle(fontSize:9,fontWeight:FontWeight.w900,letterSpacing:1,color:Colors.white70)));}
class _Stat extends StatelessWidget{final String a,b;const _Stat(this.a,this.b);Widget build(BuildContext c)=>Expanded(child:Container(padding:EdgeInsets.symmetric(vertical:10),decoration:BoxDecoration(color:Colors.white.withOpacity(.055),borderRadius:BorderRadius.circular(14)),child:Column(children:[Text(a,style:TextStyle(fontSize:17,fontWeight:FontWeight.w900)),SizedBox(height:2),Text(b,style:TextStyle(fontSize:8,color:Colors.white38,fontWeight:FontWeight.w800,letterSpacing:1))])));}
class _GameCard extends StatelessWidget{final _G g;final VoidCallback play;const _GameCard(this.g,this.play);Widget build(BuildContext c)=>InkWell(onTap:play,borderRadius:BorderRadius.circular(24),child:Container(decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:LinearGradient(colors:[g.color.withOpacity(.20),Color(0xFF111827)],begin:Alignment.topLeft,end:Alignment.bottomRight),border:Border.all(color:g.color.withOpacity(.22))),child:Stack(children:[Positioned(right:-18,top:-18,child:Container(width:95,height:95,decoration:BoxDecoration(shape:BoxShape.circle,color:g.color.withOpacity(.10)))),Padding(padding:EdgeInsets.all(15),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(width:52,height:52,decoration:BoxDecoration(color:g.color.withOpacity(.16),borderRadius:BorderRadius.circular(17)),child:Icon(g.icon,color:g.color,size:27)),Spacer(),Text(g.name,style:TextStyle(fontSize:19,fontWeight:FontWeight.w900)),SizedBox(height:3),Text(g.sub,maxLines:2,style:TextStyle(fontSize:11,color:Colors.white54,height:1.25)),SizedBox(height:11),Row(children:[Text(g.cat,style:TextStyle(fontSize:9,color:g.color,fontWeight:FontWeight.w900,letterSpacing:1)),Spacer(),Container(width:30,height:30,decoration:BoxDecoration(color:Colors.white.withOpacity(.08),shape:BoxShape.circle),child:Icon(Icons.play_arrow_rounded,size:18))])]))])));}

class _Shell extends StatelessWidget{final String title,subtitle;final Widget child;final Color accent;final VoidCallback? onReset;const _Shell({required this.title,required this.subtitle,required this.child,this.accent=_purple,this.onReset});Widget build(BuildContext c)=>Scaffold(backgroundColor:_bg,body:SafeArea(child:Column(children:[Padding(padding:EdgeInsets.fromLTRB(14,10,14,8),child:Row(children:[IconButton(onPressed:()=>Navigator.pop(c),icon:Icon(Icons.arrow_back_rounded)),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),Text(subtitle,style:TextStyle(fontSize:10,color:Colors.white38))])),if(onReset!=null)IconButton(onPressed:onReset,icon:Icon(Icons.refresh_rounded))])),Expanded(child:child)])));}
class _World extends StatelessWidget{final Widget child;final Color a,b;const _World(this.child,{this.a=_worldTop,this.b=_worldBottom});Widget build(BuildContext c)=>Container(decoration:BoxDecoration(gradient:LinearGradient(colors:[a,b],begin:Alignment.topCenter,end:Alignment.bottomCenter)),child:Stack(children:[Positioned.fill(child:CustomPaint(painter:_Stars())),child]));}
class _Stars extends CustomPainter{final r=Random(8);void paint(Canvas c,Size s){final p=Paint();for(int i=0;i<70;i++){p.color=Colors.white.withOpacity(.04+r.nextDouble()*.08);final x=r.nextDouble()*s.width,y=r.nextDouble()*s.height;c.drawCircle(Offset(x,y),r.nextDouble()*1.5,p);}}bool shouldRepaint(c)=>false;}

class _Snake extends StatefulWidget{const _Snake();State<_Snake> createState()=>_SnakeState();}
class _SnakeState extends State<_Snake>{final r=Random();List<Point<int>> body=[];Point<int> food=Point(7,7),dir=Point(1,0);Timer? timer;int score=0;bool live=false,over=false;@override void initState(){super.initState();reset();}void reset(){timer?.cancel();body=[Point(6,8),Point(5,8),Point(4,8)];dir=Point(1,0);food=Point(r.nextInt(16),r.nextInt(22));score=0;live=false;over=false;}void start(){if(live)return;setState(()=>live=true);timer=Timer.periodic(Duration(milliseconds:max(70,145-score*2)),(_){if(!mounted)return;final h=Point(body.first.x+dir.x,body.first.y+dir.y);if(h.x<0||h.x>=16||h.y<0||h.y>=22||body.contains(h)){timer?.cancel();setState(() { live=false; over=true; });return;}setState((){body.insert(0,h);if(h==food){score+=10;do{food=Point(r.nextInt(16),r.nextInt(22));}while(body.contains(food));}else body.removeLast();});});}void turn(Point<int> d){if(dir.x+d.x==0&&dir.y+d.y==0)return;dir=d;start();}Widget build(BuildContext c)=>_Shell(title:'Snake',subtitle:'Cyber Jungle • score $score',accent:Color(0xFF22C55E),onReset:(){setState(reset);},child:GestureDetector(onVerticalDragUpdate:(d)=>d.delta.dy.abs()>d.delta.dx.abs()?turn(Point(0,d.delta.dy>0?1:-1)):null,onHorizontalDragUpdate:(d)=>d.delta.dx.abs()>d.delta.dy.abs()?turn(Point(d.delta.dx>0?1:-1,0)):null,child:_World(Column(children:[Expanded(child:AspectRatio(aspectRatio:16/22,child:Container(margin:EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.black26,borderRadius:BorderRadius.circular(22),border:Border.all(color:Color(0xFF22C55E).withOpacity(.25))),child:CustomPaint(painter:_SnakePainter(body,food))))),if(!live)Padding(padding:EdgeInsets.all(18),child:Column(children:[Text(over?'RUN OVER':'READY?',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900)),SizedBox(height:7),Text('Swipe to move • tap Start to enter the jungle',style:TextStyle(color:Colors.white54)),SizedBox(height:12),FilledButton(onPressed:start,child:Text(over?'PLAY AGAIN':'START RUN'))]))]))));}
}
class _SnakePainter extends CustomPainter{final List<Point<int>> b;final Point<int> f;_SnakePainter(this.b,this.f);void paint(Canvas c,Size s){final cell=s.width/16;final p=Paint();p.color=Colors.white.withOpacity(.025);for(int x=0;x<16;x++)for(int y=0;y<22;y++)c.drawRect(Rect.fromLTWH(x*cell,y*cell,cell-1,cell-1),p);p.color=Color(0xFFFB7185);c.drawCircle(Offset((f.x+.5)*cell,(f.y+.5)*cell),cell*.27,p);for(int i=b.length-1;i>=0;i--){p.color=i==0?Color(0xFF86EFAC):Color(0xFF22C55E).withOpacity(max(.35,1-i*.025));final q=b[i];c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(q.x*cell+2,q.y*cell+2,cell-4,cell-4),Radius.circular(cell*.25)),p);}}bool shouldRepaint(c)=>true;}

class _ArcadeGame extends StatefulWidget {
  final String title, hint; final Color accent; final IconData icon;
  const _ArcadeGame({required this.title, required this.hint, required this.accent, required this.icon});
  @override State<_ArcadeGame> createState()=>_ArcadeGameState();
}
class _ArcadeGameState extends State<_ArcadeGame> {
  int score=0; bool running=false;
  void action(){setState((){running=true;score++;});}
  @override Widget build(BuildContext c)=>_Shell(title:widget.title,subtitle:'Nexora Arcade • score $score',accent:widget.accent,onReset:()=>setState((){score=0;running=false;}),child:_World(
    Center(child:Padding(padding:EdgeInsets.all(24),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      Container(width:120,height:120,decoration:BoxDecoration(color:widget.accent.withOpacity(.12),shape:BoxShape.circle,border:Border.all(color:widget.accent.withOpacity(.35))),child:Icon(widget.icon,size:58,color:widget.accent)),
      SizedBox(height:24),Text(widget.title,style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),
      SizedBox(height:8),Text(widget.hint,textAlign:TextAlign.center,style:TextStyle(color:Colors.white54,height:1.4)),
      SizedBox(height:24),FilledButton.icon(onPressed:action,icon:Icon(running?Icons.bolt_rounded:Icons.play_arrow_rounded),label:Text(running?'PLAY AGAIN':'START GAME')),
      SizedBox(height:12),Text('Score: $score',style:TextStyle(color:Colors.white38,fontWeight:FontWeight.w700)),
    ]))));
}
class _Twenty extends StatelessWidget { const _Twenty(); @override Widget build(BuildContext c)=>_ArcadeGame(title:'2048',hint:'Swipe to merge matching tiles and build the highest number.',accent:Color(0xFFF59E0B),icon:Icons.grid_4x4_rounded); }
class _Tetris extends StatelessWidget { const _Tetris(); @override Widget build(BuildContext c)=>_ArcadeGame(title:'Tetris',hint:'Move, rotate and stack blocks to clear lines.',accent:_purple,icon:Icons.view_module_rounded); }
class _Flappy extends StatelessWidget { const _Flappy(); @override Widget build(BuildContext c)=>_ArcadeGame(title:'Flappy',hint:'Tap to fly through the neon gates without hitting them.',accent:_cyan,icon:Icons.flutter_dash_rounded); }
class _Breakout extends StatelessWidget { const _Breakout(); @override Widget build(BuildContext c)=>_ArcadeGame(title:'Breakout',hint:'Move the paddle and smash every block.',accent:Color(0xFFEF4444),icon:Icons.sports_baseball_rounded); }
class _Memory extends StatelessWidget { const _Memory(); @override Widget build(BuildContext c)=>_ArcadeGame(title:'Memory',hint:'Flip cards, remember positions and match every pair.',accent:Color(0xFFEC4899),icon:Icons.style_rounded); }
class _Pong extends StatelessWidget { const _Pong(); @override Widget build(BuildContext c)=>_ArcadeGame(title:'Pong',hint:'Control your paddle and return the ball.',accent:Color(0xFF3B82F6),icon:Icons.sports_tennis_rounded); }
class _Jump extends StatelessWidget { const _Jump(); @override Widget build(BuildContext c)=>_ArcadeGame(title:'Neon Jump',hint:'Jump between platforms and climb as high as possible.',accent:Color(0xFFD946EF),icon:Icons.bolt_rounded); }
class _Mines extends StatelessWidget { const _Mines(); @override Widget build(BuildContext c)=>_ArcadeGame(title:'Minesweeper',hint:'Reveal safe cells, read the numbers and avoid mines.',accent:Color(0xFFF97316),icon:Icons.radar_rounded); }
class _Simon extends StatelessWidget { const _Simon(); @override Widget build(BuildContext c)=>_ArcadeGame(title:'Simon Says',hint:'Watch the pulse sequence and repeat it from memory.',accent:Color(0xFF14B8A6),icon:Icons.psychology_rounded); }
class _ColorStack extends StatelessWidget { const _ColorStack(); @override Widget build(BuildContext c)=>_ArcadeGame(title:'Color Stack',hint:'Sort matching colors into complete stacks.',accent:Color(0xFF6366F1),icon:Icons.water_drop_rounded); }

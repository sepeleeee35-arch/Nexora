import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

String? nexoraActiveAccountId;

enum NexoraDifficulty { easy, normal, hard, pro, impossible }
NexoraDifficulty nexoraDifficulty = NexoraDifficulty.normal;
String difficultyName(NexoraDifficulty d) => switch (d) {
  NexoraDifficulty.easy => 'EASY', NexoraDifficulty.normal => 'NORMAL', NexoraDifficulty.hard => 'HARD', NexoraDifficulty.pro => 'PRO', NexoraDifficulty.impossible => 'IMPOSSIBLE',
};
String difficultyHint(NexoraDifficulty d) => switch (d) {
  NexoraDifficulty.easy => 'Relaxed pace • forgiving gameplay', NexoraDifficulty.normal => 'Balanced challenge • classic feel', NexoraDifficulty.hard => 'Faster • tighter timing • fewer mistakes', NexoraDifficulty.pro => 'Expert pace • serious precision required', NexoraDifficulty.impossible => 'Extreme mode • brutally unforgiving',
};

const bg = Color(0xFF05070D);
const int nexoraMaxLevel = 1000000000;
int nexoraLevel(int value) => value.clamp(1, nexoraMaxLevel).toInt();
const panel = Color(0xFF0D1320);
const purple = Color(0xFF8B5CF6);
bool nexoraHapticEnabled = true;
bool nexoraSoundEnabled = true;
String nexoraControlMode = 'BUTTONS';
int nexoraSelectedLevel = 1;

class NexoraGameHub extends StatefulWidget {
  const NexoraGameHub({super.key});
  @override
  State<NexoraGameHub> createState() => _NexoraGameHubState();
}

class _NexoraGameHubState extends State<NexoraGameHub> {
  String filter = 'ALL';
  String query = '';

  final games = const [
    _GameInfo('2048', 'PUZZLE', 'Merge • chain • survive', Icons.grid_4x4_rounded, Color(0xFFF59E0B)),
    _GameInfo('Tetris', 'ARCADE', 'Drop • rotate • clear', Icons.view_module_rounded, Color(0xFFA78BFA)),
    _GameInfo('Flappy', 'ARCADE', 'Tap • dodge • score', Icons.flutter_dash_rounded, Color(0xFF22D3EE)),
    _GameInfo('Breakout', 'ARCADE', 'Smash • combo • clear', Icons.sports_baseball_rounded, Color(0xFFEF4444)),
    _GameInfo('Memory', 'PUZZLE', 'Flip • match • master', Icons.style_rounded, Color(0xFFEC4899)),
    _GameInfo('Dino Run Ultra', 'ARCADE', 'Run • jump • survive', Icons.directions_run_rounded, Color(0xFF00FF88)),
    _GameInfo('Brick Breaker Ultimate', 'ARCADE', 'Smash • combo • clear', Icons.view_stream_rounded, Color(0xFFFF9500)),
    _GameInfo('Watermelon Merge Pro', 'PUZZLE', 'Drop • merge • grow', Icons.local_florist_rounded, Color(0xFF22D3EE)),
  ];

  Widget openGame(String name) {
    if (name == 'Flappy') return const _Flappy();
    return _GameMenu(
      game: name,
      onStart: (level, control, haptic, sound) {
        nexoraSelectedLevel = level;
        nexoraControlMode = control;
        nexoraHapticEnabled = haptic;
        nexoraSoundEnabled = sound;
        Widget game;
        switch (name) {
          case '2048': game = const _Twenty(); break;
          case 'Tetris': game = const _Tetris(); break;
          case 'Breakout': game = const _Breakout(); break;
          case 'Memory': game = const _Memory(); break;
          case 'Dino Run Ultra': game = const _DinoRunUltra(); break;
          case 'Brick Breaker Ultimate': game = const _BrickBreakerUltimate(); break;
          case 'Watermelon Merge Pro': game = const _WatermelonMergePro(); break;
          default: game = const _Twenty();
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => game));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = games.where((g) {
      final categoryOk = filter == 'ALL' || g.category == filter;
      final queryOk = query.isEmpty || g.name.toLowerCase().contains(query.toLowerCase());
      return categoryOk && queryOk;
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF24104F), Color(0xFF0B2037), Color(0xFF090D17)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(color: purple.withOpacity(.18), borderRadius: BorderRadius.circular(17)),
                      child: const Icon(Icons.sports_esports_rounded, color: purple, size: 28),
                    ),
                    const Spacer(),
                    _Badge('ARCADE COLLECTION'),
                  ]),
                  const SizedBox(height: 20),
                  const Text('NEXORA ARCADE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white54)),
                  const SizedBox(height: 4),
                  const Text('Play. Beat. Repeat.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -.8)),
                  const SizedBox(height: 7),
                  const Text('Eight mini-games • game-specific controls • touch-first gameplay.', style: TextStyle(color: Colors.white60, height: 1.35)),
                  const SizedBox(height: 18),
                  Row(children: const [
                    _MiniStat('5', 'GAMES'),
                    SizedBox(width: 8),
                    _MiniStat('∞', 'REPLAY'),
                    SizedBox(width: 8),
                    _MiniStat('1', 'PLAYER'),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              onChanged: (v) => setState(() => query = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Search games',
                filled: true,
                fillColor: panel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['ALL', 'ARCADE', 'PUZZLE'].map((x) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(x),
                    selected: filter == x,
                    onSelected: (_) => setState(() => filter = x),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 18),
            Row(children: [
              const Expanded(child: Text('Arcade library', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
              Text('${visible.length} games', style: const TextStyle(color: Colors.white38)),
            ]),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visible.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 11, mainAxisSpacing: 11, childAspectRatio: .78,
              ),
              itemBuilder: (_, i) {
                final game = visible[i];
                return _GameCard(game, () => Navigator.push(context, MaterialPageRoute(builder: (_) => openGame(game.name))));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GameInfo {
  final String name, category, subtitle;
  final IconData icon;
  final Color color;
  const _GameInfo(this.name, this.category, this.subtitle, this.icon, this.color);
}

_GameInfo _gameInfoForName(String name) => switch (name) {
  '2048' => const _GameInfo('2048', 'PUZZLE', 'Merge • chain • survive', Icons.grid_4x4_rounded, Color(0xFFF59E0B)),
  'Tetris' => const _GameInfo('Tetris', 'ARCADE', 'Drop • rotate • clear', Icons.view_module_rounded, Color(0xFFA78BFA)),
  'Flappy' => const _GameInfo('Flappy', 'ARCADE', 'Tap • dodge • score', Icons.flutter_dash_rounded, Color(0xFF22D3EE)),
  'Breakout' => const _GameInfo('Breakout', 'ARCADE', 'Smash • combo • clear', Icons.sports_baseball_rounded, Color(0xFFEF4444)),
  'Dino Run Ultra' => const _GameInfo('Dino Run Ultra', 'ARCADE', 'Run • jump • survive', Icons.directions_run_rounded, Color(0xFF00FF88)),
  'Brick Breaker Ultimate' => const _GameInfo('Brick Breaker Ultimate', 'ARCADE', 'Smash • combo • clear', Icons.view_stream_rounded, Color(0xFFFF9500)),
  'Watermelon Merge Pro' => const _GameInfo('Watermelon Merge Pro', 'PUZZLE', 'Drop • merge • grow', Icons.local_florist_rounded, Color(0xFF22D3EE)),
  _ => const _GameInfo('Memory', 'PUZZLE', 'Flip • match • master', Icons.style_rounded, Color(0xFFEC4899)),
};

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
    child: Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.white70)),
  );
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  const _MiniStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.055), borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.w800, letterSpacing: 1)),
      ]),
    ),
  );
}

class _GameCard extends StatelessWidget {
  final _GameInfo game;
  final VoidCallback onPlay;
  const _GameCard(this.game, this.onPlay);
  @override Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),color:const Color(0xFF0A0E18),border:Border.all(color:game.color.withOpacity(.28)),boxShadow:[BoxShadow(color:game.color.withOpacity(.14),blurRadius:22,offset:const Offset(0,9))]),
    child:ClipRRect(borderRadius:BorderRadius.circular(24),child:Column(children:[
      Expanded(flex:7,child:Stack(children:[
        Positioned.fill(child:CustomPaint(painter:_GameCardArt(game.name,game.color))),
        Positioned.fill(child:DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(colors:[Colors.transparent,Colors.black.withOpacity(.08),Colors.black.withOpacity(.62)],begin:Alignment.topCenter,end:Alignment.bottomCenter)))),
        Positioned(left:12,top:12,child:_MiniBadge(game.category)),
      ])),
      Expanded(flex:5,child:Padding(padding:const EdgeInsets.fromLTRB(12,8,10,9),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(game.name,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900)),
        const SizedBox(height:2),
        Text(game.subtitle,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:9,color:Colors.white.withOpacity(.45))),
        const Spacer(),
        Row(children:[
          Expanded(child:OutlinedButton.icon(style:OutlinedButton.styleFrom(minimumSize:const Size(0,35),padding:const EdgeInsets.symmetric(horizontal:8),side:BorderSide(color:game.color.withOpacity(.35)),foregroundColor:game.color),onPressed:onPlay,icon:const Icon(Icons.play_arrow_rounded,size:17),label:const Text('PLAY',style:TextStyle(fontSize:10,fontWeight:FontWeight.w900)))),
          const SizedBox(width:7),
          SizedBox(width:39,height:35,child:IconButton(tooltip:'CARA BERMAIN',onPressed:()=>_showGuide(context),icon:Icon(Icons.menu_book_rounded,color:game.color,size:19))),
        ]),
      ]))),
    ])));
  void _showGuide(BuildContext context)=>Navigator.push(context,MaterialPageRoute(builder:(_)=>_VisualGameGuide(game:game)));
}

class _MiniBadge extends StatelessWidget {
  final String text; const _MiniBadge(this.text);
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:6),decoration:BoxDecoration(color:Colors.black.withOpacity(.34),borderRadius:BorderRadius.circular(12),border:Border.all(color:Colors.white12)),child:Text(text,style:const TextStyle(fontSize:8,fontWeight:FontWeight.w900,letterSpacing:.8,color:Colors.white70)));
}

class _GameCardArt extends CustomPainter {
  final String name;
  final Color accent;
  const _GameCardArt(this.name, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    final r = Rect.fromLTWH(0, 0, size.width, size.height);
    final backgrounds = <String,List<Color>>{
      '2048':[const Color(0xFF321B08),const Color(0xFF130B1F)],
      'Tetris':[const Color(0xFF24144B),const Color(0xFF09152B)],
      'Flappy':[const Color(0xFF2087B8),const Color(0xFF0C3951)],
      'Breakout':[const Color(0xFF45111B),const Color(0xFF140713)],
      'Memory':[const Color(0xFF4A123A),const Color(0xFF16091C)],
    };
    final colors=backgrounds[name]??[const Color(0xFF111827),const Color(0xFF070914)];
    p.shader=LinearGradient(colors:colors,begin:Alignment.topLeft,end:Alignment.bottomRight).createShader(r);
    canvas.drawRect(r,p);
    p.shader=null;

    if(name=='2048') _draw2048(canvas,size,p);
    else if(name=='Tetris') _drawTetris(canvas,size,p);
    else if(name=='Flappy') _drawFlappy(canvas,size,p);
    else if(name=='Breakout') _drawBreakout(canvas,size,p);
    else _drawMemory(canvas,size,p);

    p.color=accent.withOpacity(.13);
    canvas.drawCircle(Offset(size.width*.86,size.height*.12),size.width*.22,p);
  }

  void _draw2048(Canvas c,Size s,Paint p){
    final board=Rect.fromLTWH(s.width*.16,s.height*.15,s.width*.68,s.height*.68);
    p.color=Colors.black.withOpacity(.28);c.drawRRect(RRect.fromRectAndRadius(board,const Radius.circular(15)),p);
    const vals=[2,4,8,16,32,64,128,256,512];
    for(var i=0;i<16;i++){final x=i%4,y=i~/4;final v=i<vals.length?vals[i]:0;final cell=board.width/4;
      p.color=v==0?Colors.white.withOpacity(.035):Color.lerp(const Color(0xFFF59E0B),const Color(0xFF8B5CF6),min(1.0,log(v)/log(512)))!;
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(board.left+x*cell+3,board.top+y*cell+3,cell-6,cell-6),const Radius.circular(7)),p);
      if(v>0){final tp=TextPainter(text:TextSpan(text:'$v',style:TextStyle(color:Colors.white.withOpacity(.9),fontSize:v>=128?8:10,fontWeight:FontWeight.w900)),textDirection:TextDirection.ltr)..layout();tp.paint(c,Offset(board.left+x*cell+(cell-tp.width)/2,board.top+y*cell+(cell-tp.height)/2));}
    }
  }
  void _drawTetris(Canvas c,Size s,Paint p){
    final cell=min(s.width/11,s.height/11);
    final ox=(s.width-cell*10)/2,oy=s.height*.14;
    for(var y=0;y<9;y++)for(var x=0;x<10;x++){p.color=Colors.white.withOpacity(.035);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(ox+x*cell+1,oy+y*cell+1,cell-2,cell-2),const Radius.circular(3)),p);}
    const blocks=[[3,0,Color(0xFF22D3EE)],[4,0,Color(0xFF22D3EE)],[5,0,Color(0xFF22D3EE)],[5,1,Color(0xFFFACC15)],[5,2,Color(0xFFFACC15)],[4,2,Color(0xFFFACC15)],[3,2,Color(0xFFA78BFA)],[3,3,Color(0xFFA78BFA)],[4,3,Color(0xFFA78BFA)],[5,3,Color(0xFFA78BFA)],[6,3,Color(0xFFA78BFA)],[6,4,Color(0xFF4ADE80)],[7,4,Color(0xFF4ADE80)],[7,5,Color(0xFF4ADE80)],[8,5,Color(0xFF4ADE80)]];
    for(final b in blocks){p.color=b[2] as Color;c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(ox+(b[0] as int)*cell+2,oy+(b[1] as int)*cell+2,cell-4,cell-4),const Radius.circular(4)),p);}
  }  void _drawFlappy(Canvas c,Size s,Paint p){
    p.color=Colors.white.withOpacity(.14);for(var i=0;i<4;i++)c.drawOval(Rect.fromLTWH(i*s.width*.28-20,s.height*(.18+i*.12),70,18),p);
    final px=s.width*.63,top=s.height*.17,bottom=s.height*.62;
    p.color=const Color(0xFF58C95A);c.drawRect(Rect.fromLTWH(px,0,34,top),p);c.drawRect(Rect.fromLTWH(px,bottom,34,s.height*.82-bottom),p);
    p.color=const Color(0xFF8BE06A);c.drawRect(Rect.fromLTWH(px-4,top-8,42,9),p);c.drawRect(Rect.fromLTWH(px-4,bottom,42,9),p);
    p.color=const Color(0xFFFFE45C);c.drawCircle(Offset(s.width*.34,s.height*.48),17,p);p.color=Colors.white;c.drawCircle(Offset(s.width*.39,s.height*.44),4,p);p.color=Colors.black;c.drawCircle(Offset(s.width*.4,s.height*.44),2,p);p.color=const Color(0xFFF97316);c.drawOval(Rect.fromCenter(center:Offset(s.width*.34+16,s.height*.48),width:18,height:7),p);
    p.color=const Color(0xFFD5C56A);c.drawRect(Rect.fromLTWH(0,s.height*.88,s.width,s.height*.12),p);
  }
  void _drawBreakout(Canvas c,Size s,Paint p){
    const cs=[Color(0xFFF87171),Color(0xFFFB923C),Color(0xFFFACC15),Color(0xFF4ADE80),Color(0xFF22D3EE)];
    for(var y=0;y<5;y++)for(var x=0;x<7;x++){p.color=cs[y];final rr=Rect.fromLTWH(s.width*.10+x*s.width*.115,s.height*.15+y*s.height*.09,s.width*.095,s.height*.065);c.drawRRect(RRect.fromRectAndRadius(rr,const Radius.circular(5)),p);}
    p.color=Colors.white;c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*.30,s.height*.78,s.width*.40,9),const Radius.circular(5)),p);p.color=const Color(0xFFFFD5D5);c.drawCircle(Offset(s.width*.53,s.height*.70),6,p);
  }
  void _drawMemory(Canvas c,Size s,Paint p){
    final w=s.width*.15,h=s.height*.20;for(var y=0;y<3;y++)for(var x=0;x<4;x++){final show=(x+y)%3==0;final rr=Rect.fromLTWH(s.width*.18+x*s.width*.17,s.height*.18+y*s.height*.23,w,h);p.color=show?accent.withOpacity(.25):Colors.white.withOpacity(.07);c.drawRRect(RRect.fromRectAndRadius(rr,const Radius.circular(8)),p);if(show){p.color=accent;c.drawCircle(rr.center,7,p);}else{p.color=Colors.white24;c.drawCircle(rr.center,5,p);}}
  }
  @override bool shouldRepaint(covariant _GameCardArt old)=>false;
}

class _GameMenu extends StatefulWidget {
  final String game;
  final void Function(int level,String control,bool haptic,bool sound) onStart;
  const _GameMenu({required this.game,required this.onStart});
  @override State<_GameMenu> createState()=>_GameMenuState();
}
class _GameMenuState extends State<_GameMenu>{
  bool haptic=true,sound=true;late String control;int selectedLevel=1;
  bool get hasLevels=>widget.game!='Flappy';
  List<String> get controls=>switch(widget.game){ 'Tetris'=>const['BUTTONS'],'Breakout'=>const['DRAG'],'2048'=>const['SWIPE'],'Memory'=>const['TOUCH'],_=>const['TAP']};
  Color get accent=>switch(widget.game){'2048'=>const Color(0xFFF59E0B),'Tetris'=>const Color(0xFFA78BFA),'Breakout'=>const Color(0xFFEF4444),_=>const Color(0xFFEC4899)};
  String get tagline=>switch(widget.game){'2048'=>'MERGE & SURVIVE','Tetris'=>'DROP & CLEAR','Breakout'=>'SMASH & COMBO',_=>'MATCH & MASTER'};
  @override void initState(){super.initState();control=controls.first;}
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:bg,body:SafeArea(child:ListView(padding:const EdgeInsets.fromLTRB(20,12,20,30),children:[
    Row(children:[IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.arrow_back_rounded)),const Spacer(),Text(widget.game.toUpperCase(),style:const TextStyle(fontWeight:FontWeight.w900,letterSpacing:1.5,color:Colors.white54))]),
    Container(height:185,decoration:BoxDecoration(borderRadius:BorderRadius.circular(28),border:Border.all(color:accent.withOpacity(.4)),boxShadow:[BoxShadow(color:accent.withOpacity(.12),blurRadius:28)]),child:ClipRRect(borderRadius:BorderRadius.circular(28),child:Stack(children:[
      Positioned.fill(child:CustomPaint(painter:_GameCardArt(widget.game,accent))),
      Positioned(left:18,bottom:16,child:Text(tagline,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900))),
    ]))),
    const SizedBox(height:18),
    const Text('LEVEL',style:TextStyle(fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1.5,color:Colors.white38)),
    const SizedBox(height:7),
    InkWell(borderRadius:BorderRadius.circular(18),onTap:hasLevels?()=>_showLevels(context):null,child:Container(padding:const EdgeInsets.symmetric(horizontal:15,vertical:14),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:Colors.white10)),child:Row(children:[
      Icon(Icons.flag_rounded,color:accent),const SizedBox(width:11),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(hasLevels?'LEVEL $selectedLevel':'INSTANT PLAY',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:15)),
        const SizedBox(height:3),Text(hasLevels?'Pilih level yang ingin dimainkan.':'Game langsung dimulai tanpa level selector.',style:const TextStyle(color:Colors.white38,fontSize:10)),
      ])),
      if(hasLevels)const Icon(Icons.chevron_right_rounded,color:Colors.white38),
    ]))),
    const SizedBox(height:16),
    const Text('SETTINGS',style:TextStyle(fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1.5,color:Colors.white38)),
    const SizedBox(height:7),
    Container(decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:Colors.white10)),child:Column(children:[
      ListTile(dense:true,leading:const Icon(Icons.gamepad_rounded),title:const Text('CONTROL',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900)),trailing:Text(control,style:TextStyle(color:accent,fontSize:11,fontWeight:FontWeight.w900))),
      const Divider(height:1,color:Colors.white10),
      SwitchListTile(dense:true,title:const Text('HAPTIC',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900)),value:haptic,onChanged:(v)=>setState(()=>haptic=v)),
      SwitchListTile(dense:true,title:const Text('SOUND',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900)),value:sound,onChanged:(v)=>setState(()=>sound=v)),
    ])),
    const SizedBox(height:12),
    OutlinedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => _VisualGameGuide(game: _gameInfoForName(widget.game))),
        );
      },
      icon: const Icon(Icons.menu_book_rounded),
      label: const Text('CARA BERMAIN'),
    ),
    const SizedBox(height:10),
    SizedBox(height:56,child:FilledButton.icon(onPressed:()=>widget.onStart(selectedLevel,control,haptic,sound),icon:const Icon(Icons.play_arrow_rounded),label:Text(selectedLevel>1?'START LEVEL $selectedLevel':'START',style:const TextStyle(fontWeight:FontWeight.w900,letterSpacing:1)))),
  ])));
  void _showLevels(BuildContext context){
    final input=TextEditingController(text:'$selectedLevel');
    showModalBottomSheet(context:context,isScrollControlled:true,backgroundColor:const Color(0xFF0A0F1A),shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(26))),builder:(sheet)=>StatefulBuilder(builder:(context,setSheet)=>SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(16,14,16,20),child:Column(mainAxisSize:MainAxisSize.min,children:[
      Container(width:42,height:4,decoration:BoxDecoration(color:Colors.white24,borderRadius:BorderRadius.circular(8))),const SizedBox(height:12),
      const Text('SELECT LEVEL',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:8),
      Row(children:[Expanded(child:TextField(controller:input,keyboardType:TextInputType.number,decoration:const InputDecoration(prefixText:'LEVEL ',hintText:'1 - 1,000,000,000'))),const SizedBox(width:8),FilledButton(onPressed:(){final n=int.tryParse(input.text.replaceAll(',','').trim());if(n!=null&&n>=1&&n<=nexoraMaxLevel){setState(()=>selectedLevel=n);Navigator.pop(sheet);}},child:const Text('GO'))]),
      const SizedBox(height:12),
      SizedBox(height:235,child:GridView.builder(gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:5,mainAxisSpacing:8,crossAxisSpacing:8,childAspectRatio:1.25),itemCount:50,itemBuilder:(_,i){final n=i+1;return OutlinedButton(style:OutlinedButton.styleFrom(padding:EdgeInsets.zero,foregroundColor:n==selectedLevel?accent:Colors.white70,side:BorderSide(color:n==selectedLevel?accent:Colors.white10)),onPressed:(){setState(()=>selectedLevel=n);Navigator.pop(sheet);},child:Text('$n',style:const TextStyle(fontWeight:FontWeight.w900)));})),
      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('1 — 50',style:TextStyle(color:Colors.white38,fontSize:11)),Text('1 — 1B',style:TextStyle(color:accent,fontSize:11,fontWeight:FontWeight.w900))]),
    ])))));
  }
}

class _VisualGameGuide extends StatefulWidget{
  final _GameInfo game;const _VisualGameGuide({required this.game});
  @override State<_VisualGameGuide> createState()=>_VisualGameGuideState();
}
class _VisualGameGuideState extends State<_VisualGameGuide>{
  final PageController page=PageController();int index=0;
  List<Map<String,String>> get steps=>switch(widget.game.name){
    'Tetris'=>[
      {'title':'GERAKKAN','text':'Gunakan tombol kiri dan kanan untuk memindahkan balok dengan presisi.','key':'MOVE'},
      {'title':'PUTAR','text':'Tekan ROTATE untuk mengubah arah balok.','key':'ROTATE'},
      {'title':'TURUNKAN','text':'Gunakan ↓ untuk soft drop atau HARD DROP untuk langsung menjatuhkan balok.','key':'DROP'},
      {'title':'CLEAR BARIS','text':'Penuhi satu baris untuk menghapusnya dan mendapatkan score.','key':'CLEAR'}],
    '2048'=>[
      {'title':'GESER','text':'Geser papan ke empat arah untuk menggerakkan tile.','key':'SWIPE'},
      {'title':'GABUNGKAN','text':'Tile dengan angka sama bergabung menjadi angka yang lebih besar.','key':'MERGE'},
      {'title':'ATUR PAPAN','text':'Jaga ruang kosong dan rencanakan beberapa langkah ke depan.','key':'PLAN'}],
    'Breakout'=>[
      {'title':'GERAKKAN PADDLE','text':'Geser paddle untuk mengarahkan pantulan bola.','key':'PADDLE'},
      {'title':'HANCURKAN BRICK','text':'Pantulkan bola ke brick sampai habis.','key':'BRICK'},
      {'title':'POWER-UP','text':'Ambil power-up untuk mendapatkan bantuan sementara.','key':'POWER'}],
    'Memory'=>[
      {'title':'BUKA KARTU','text':'Tap dua kartu untuk melihat simbolnya.','key':'FLIP'},
      {'title':'CARI PASANGAN','text':'Temukan dua kartu dengan simbol yang sama.','key':'MATCH'},
      {'title':'SELESAIKAN','text':'Temukan semua pasangan untuk menyelesaikan level.','key':'WIN'}],
    _=>[
      {'title':'TAP','text':'Tap layar untuk membuat karakter terbang naik.','key':'TAP'},
      {'title':'LEWATI RINTANGAN','text':'Atur ritme tap agar melewati celah.','key':'PIPE'},
      {'title':'KEJAR SCORE','text':'Bertahan sejauh mungkin untuk score tinggi.','key':'SCORE'}]};
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:bg,appBar:AppBar(title:Text('CARA BERMAIN • '+widget.game.name),backgroundColor:bg),body:Column(children:[
    Expanded(child:PageView.builder(controller:page,itemCount:steps.length,onPageChanged:(i)=>setState(()=>index=i),itemBuilder:(_,i)=>Padding(padding:const EdgeInsets.fromLTRB(20,12,20,18),child:Column(children:[
      Expanded(child:Container(width:double.infinity,decoration:BoxDecoration(borderRadius:BorderRadius.circular(28),border:Border.all(color:widget.game.color.withOpacity(.35)),gradient:LinearGradient(colors:[widget.game.color.withOpacity(.16),Colors.white.withOpacity(.025)],begin:Alignment.topLeft,end:Alignment.bottomRight)),child:Center(child:_GuideIllustration(game:widget.game.name,step:steps[i]['key']!)))),
      const SizedBox(height:20),Text(steps[i]['title']!,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),const SizedBox(height:8),Text(steps[i]['text']!,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white60,height:1.45,fontSize:13)),
    ])))),
    Row(mainAxisAlignment:MainAxisAlignment.center,children:List.generate(steps.length,(i)=>AnimatedContainer(duration:const Duration(milliseconds:180),margin:const EdgeInsets.all(3),width:i==index?22:6,height:6,decoration:BoxDecoration(color:i==index?widget.game.color:Colors.white24,borderRadius:BorderRadius.circular(9))))),
    Padding(padding:const EdgeInsets.fromLTRB(20,12,20,18),child:Row(children:[
      if(index>0)Expanded(child:OutlinedButton(onPressed:()=>page.previousPage(duration:const Duration(milliseconds:180),curve:Curves.easeOut),child:const Text('KEMBALI'))),
      if(index>0)const SizedBox(width:8),
      Expanded(child:FilledButton(onPressed:()=>index<steps.length-1?page.nextPage(duration:const Duration(milliseconds:180),curve:Curves.easeOut):Navigator.pop(context),child:Text(index<steps.length-1?'LANJUT':'SELESAI'))),
    ])),
  ]));
}
class _GuideIllustration extends StatelessWidget{
  final String game,step;const _GuideIllustration({required this.game,required this.step});
  @override Widget build(BuildContext context){final c=switch(game){'Tetris'=>const Color(0xFFA78BFA),'2048'=>const Color(0xFFF59E0B),'Breakout'=>const Color(0xFFEF4444),'Memory'=>const Color(0xFFEC4899),_=>const Color(0xFF22D3EE)};final icon=switch(step){'MOVE'=>Icons.swap_horiz_rounded,'ROTATE'=>Icons.rotate_right_rounded,'DROP'=>Icons.vertical_align_bottom_rounded,'CLEAR'=>Icons.view_agenda_rounded,'SWIPE'=>Icons.swipe_rounded,'MERGE'=>Icons.merge_type_rounded,'PLAN'=>Icons.grid_view_rounded,'PADDLE'=>Icons.horizontal_rule_rounded,'BRICK'=>Icons.grid_on_rounded,'POWER'=>Icons.bolt_rounded,'FLIP'=>Icons.style_rounded,'MATCH'=>Icons.compare_arrows_rounded,'WIN'=>Icons.emoji_events_rounded,'TAP'=>Icons.touch_app_rounded,'PIPE'=>Icons.alt_route_rounded,_=>Icons.star_rounded};return Column(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:92,color:c),const SizedBox(height:22),Container(width:190,height:70,decoration:BoxDecoration(color:Colors.black.withOpacity(.28),borderRadius:BorderRadius.circular(18),border:Border.all(color:c.withOpacity(.28))),child:Center(child:Text(step,style:TextStyle(color:c,fontWeight:FontWeight.w900,letterSpacing:2))))]);}
}

class _GameIntro extends StatefulWidget {
  final _GameInfo info; final ValueChanged<NexoraDifficulty> onStart;
  const _GameIntro({required this.info, required this.onStart});
  @override State<_GameIntro> createState() => _GameIntroState();
}

class _GameIntroState extends State<_GameIntro> {
  NexoraDifficulty selected = NexoraDifficulty.normal;

  String shortHow(String name) => switch (name) {
    '2048' => 'Geser semua tile. Tile bernilai sama akan menyatu menjadi angka lebih besar. Jaga ruang kosong dan kejar 2048.',
    'Tetris' => 'Geser, putar, HOLD, lalu hard drop. Susun balok tanpa celah dan hapus garis untuk terus bertahan.',
    'Flappy' => 'Ketuk layar untuk mengepak. Atur ritme agar melewati celah pipa. Jangan menyentuh pipa atau tanah.',
    'Breakout' => 'Geser paddle untuk memantulkan bola. Hancurkan semua brick, ambil power-up, dan pertahankan combo.',
    _ => 'Buka dua kartu, ingat posisinya, lalu cari pasangan yang sama. Streak tinggi memberi skor lebih besar.',
  };

  String _guide(String game) => switch (game) {
    '2048' => '1. Geser layar ke atas, bawah, kiri, atau kanan untuk menggerakkan semua tile.\\n\\n2. Dua angka yang sama akan bergabung saat bertemu. Contoh: 2 + 2 menjadi 4.\\n\\n3. Setiap merge memberi skor. Target utama adalah membuat tile 2048.\\n\\n4. Jangan isi papan sampai tidak ada gerakan. Simpan ruang kosong dan rencanakan beberapa langkah ke depan.\\n\\nCONTROL\\n• Swipe kiri/kanan/atas/bawah\\n• UNDO untuk membatalkan langkah terakhir\\n• RETRY untuk memulai ulang\\n\\nSYSTEM\\nSkor menaikkan level secara bertahap. Mode lebih tinggi membuat permainan lebih menuntut.',
    'Tetris' => '1. Balok jatuh dari atas dan harus disusun di grid 10×20.\\n\\n2. Geser untuk memindahkan balok, tap untuk memutar, dan double-tap untuk hard drop.\\n\\n3. HOLD menyimpan satu balok agar bisa dipakai nanti. NEXT menunjukkan balok berikutnya.\\n\\n4. Isi satu baris penuh untuk menghapusnya. Semakin banyak baris yang dibersihkan, kecepatan jatuh meningkat.\\n\\nCONTROL\\n• Drag horizontal = kiri/kanan\\n• Tap = rotate\\n• Double-tap = hard drop\\n• HOLD = simpan/tukar balok\\n\\nSYSTEM\\nMenggunakan 7-bag agar distribusi tetromino lebih adil. Ghost piece menunjukkan posisi pendaratan.',
    'Flappy' => '1. Ketuk layar untuk membuat burung mengepak ke atas. Setelah itu gravitasi menariknya kembali.\\n\\n2. Atur timing ketukan untuk melewati celah setiap pipa.\\n\\n3. Setiap pipa yang berhasil dilewati menambah skor dan setiap beberapa poin level naik.\\n\\n4. Menyentuh pipa, tanah, atau batas atas mengakhiri ronde.\\n\\nCONTROL\\n• Tap di mana saja = flap\\n• Tap saat GAME OVER = main lagi\\n\\nSYSTEM\\nKecepatan, gravitasi, dan ukuran celah mengikuti mode. Celah juga perlahan makin ketat saat skor bertambah.',
    'Breakout' => '1. Geser paddle di bagian bawah untuk menjaga bola tetap hidup.\\n\\n2. Bola menghancurkan brick dari bawah/atas. Brick kuat membutuhkan lebih dari satu hit.\\n\\n3. Pantulan di bagian berbeda dari paddle mengubah arah bola sehingga kamu bisa mengontrol sudut serangan.\\n\\n4. Ambil power-up yang jatuh: W memperlebar paddle, × menambah bola, S memperlambat bola, F memberi efek serangan tambahan.\\n\\nCONTROL\\n• Drag kiri/kanan = paddle\\n• Tap = launch\\n\\nSYSTEM\\nAda 3 nyawa, combo, brick ber-HP, power-up, dan level berulang. Bola yang hilang mengurangi nyawa.',
    _ => '1. Semua kartu tertutup. Buka satu kartu untuk melihat simbolnya.\\n\\n2. Buka kartu kedua. Jika simbol sama, pasangan tetap terbuka dan streak bertambah.\\n\\n3. Jika salah, kedua kartu tertutup kembali. Hafalkan posisi agar gerakan berikutnya lebih cepat.\\n\\n4. Selesaikan seluruh papan untuk naik level. Pada level lebih tinggi jumlah pasangan dapat bertambah.\\n\\nCONTROL\\n• Tap kartu = buka kartu\\n• Tidak ada batas waktu paksa\\n\\nSYSTEM\\nMatch memberi skor dan streak. Salah menebak memutus streak. Kesulitan menentukan jumlah pasangan dan tekanan permainan.',
  };

  void _showGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0F1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => SafeArea(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: .72,
          minChildSize: .45,
          maxChildSize: .94,
          builder: (_, scroll) => SingleChildScrollView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 18),
              Row(children: [
                Icon(Icons.menu_book_rounded, color: widget.info.color),
                const SizedBox(width: 9),
                const Text('CARA BERMAIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 14),
              Text(_guide(widget.info.name), style: const TextStyle(color: Colors.white70, height: 1.55, fontSize: 13)),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('TUTUP'))),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: bg,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          Row(children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
            const Spacer(),
            _Badge('READY TO PLAY'),
          ]),
          const SizedBox(height: 10),
          Container(
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: widget.info.color.withOpacity(.42)),
              boxShadow: [BoxShadow(color: widget.info.color.withOpacity(.12), blurRadius: 28)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(children: [
                Positioned.fill(child: CustomPaint(painter: _GameCardArt(widget.info.name, widget.info.color))),
                Positioned(left: 18, bottom: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.info.category, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.6, color: Colors.white60)),
                  const SizedBox(height: 3),
                  Text(widget.info.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                ])),

                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: _showGuide,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.62),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: widget.info.color.withOpacity(.55)),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.22), blurRadius: 12)],
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.help_outline_rounded, color: widget.info.color, size: 17),
                          const SizedBox(width: 6),
                          const Text('CARA BERMAIN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .8)),
                        ]),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          Text(shortHow(widget.info.name), style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 14)),
          const SizedBox(height: 18),
          Row(children: [
            const Text('MODE', style: TextStyle(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
            const SizedBox(width: 10),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.06), borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<NexoraDifficulty>(
                  value: selected,
                  dropdownColor: const Color(0xFF101624),
                  icon: const Icon(Icons.expand_more_rounded, size: 18, color: Colors.white54),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                  items: NexoraDifficulty.values.map((d) => DropdownMenuItem(value: d, child: Text(difficultyName(d)))).toList(),
                  onChanged: (d) => setState(() => selected = d ?? selected),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(difficultyHint(selected), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: Colors.white38))),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: () => widget.onStart(selected),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('START GAME', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .7)),
            ),
          ),
        ],
      ),
    ),
  );
}

class _GamePage extends StatelessWidget {
  final String title, subtitle;
  final Color accent;
  final Widget child;
  final VoidCallback? reset;
  const _GamePage({required this.title, required this.subtitle, required this.accent, required this.child, this.reset});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: bg,
    body: SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 7),
          child: Row(children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.white38)),
            ])),
            if (reset != null) IconButton(onPressed: reset, icon: const Icon(Icons.refresh_rounded)),
          ]),
        ),
        Expanded(child: child),
      ]),
    ),
  );
}

class _World extends StatelessWidget {
  final Widget child;
  final Color top, bottom;
  const _World({required this.child, this.top = const Color(0xFF10152A), this.bottom = const Color(0xFF060811)});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(gradient: LinearGradient(colors: [top, bottom], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
    child: Stack(children: [const Positioned.fill(child: CustomPaint(painter: _Stars())), child]),
  );
}

class _Stars extends CustomPainter {
  const _Stars();
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(77);
    final paint = Paint();
    for (var i = 0; i < 70; i++) {
      paint.color = Colors.white.withOpacity(.025 + random.nextDouble() * .07);
      canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), random.nextDouble() * 1.5, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScoreBar extends StatelessWidget {
  final String left, right;
  final Color accent;
  const _ScoreBar(this.left, this.right, this.accent);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.055), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
    child: Row(children: [
      Text(left, style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .7)),
      const Spacer(),
      Text(right, style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: .7)),
    ]),
  );
}

class _Twenty extends StatefulWidget {
  const _Twenty(); @override State<_Twenty> createState()=>_TwentyState();
}
class _TwentyState extends State<_Twenty>{
  final random=Random(); List<int> board=List.filled(16,0),previous=List.filled(16,0);
  int score=0,best=0,previousScore=0,pulse=0,level=1; bool gameOver=false,won=false,keepPlaying=false;
  @override void initState(){super.initState();_reset();}
  void _reset(){board=List.filled(16,0);previous=List.filled(16,0);score=0;previousScore=0;level=1;gameOver=false;won=false;keepPlaying=false;pulse++;_spawn();_spawn();}
  void _spawn(){final e=<int>[for(var i=0;i<16;i++)if(board[i]==0)i];if(e.isNotEmpty){final d=nexoraDifficulty.index;board[e[random.nextInt(e.length)]]=random.nextDouble()<(0.94-d*.07)?2:4;if(d>=3&&random.nextDouble()<.10&&e.length>1){final rest=<int>[for(final i in e)if(board[i]==0)i];if(rest.isNotEmpty)board[rest[random.nextInt(rest.length)]]=2;}}}
  List<int> _merge(List<int> line){final v=line.where((x)=>x!=0).toList(),o=<int>[];var i=0;while(i<v.length){if(i+1<v.length&&v[i]==v[i+1]){final m=v[i]*2;o.add(m);score+=m;i+=2;}else{o.add(v[i]);i++;}}while(o.length<4)o.add(0);return o;}
  bool _can(){if(board.contains(0))return true;for(var y=0;y<4;y++)for(var x=0;x<4;x++){final v=board[y*4+x];if(x<3&&board[y*4+x+1]==v)return true;if(y<3&&board[(y+1)*4+x]==v)return true;}return false;}
  void _move(int dx,int dy){if(gameOver||(won&&!keepPlaying))return;final old=List<int>.from(board),oldScore=score,next=List<int>.filled(16,0);for(var line=0;line<4;line++){final vals=<int>[];for(var pos=0;pos<4;pos++){final x=dx!=0?(dx>0?3-pos:pos):line,y=dy!=0?(dy>0?3-pos:pos):line;vals.add(board[y*4+x]);}final m=_merge(vals);for(var pos=0;pos<4;pos++){final x=dx!=0?(dx>0?3-pos:pos):line,y=dy!=0?(dy>0?3-pos:pos):line;next[y*4+x]=m[pos];}}if(next.toString()==old.toString())return;previous=old;previousScore=oldScore;board=next;_spawn();pulse++;best=max(best,score);level=nexoraLevel(1+score~/500);if(board.contains(2048))won=true;if(!_can())gameOver=true;setState((){});}
  Color _tile(int v){if(v==0)return Colors.white.withOpacity(.045);final t=min(1.0,log(max(2,v))/log(8192));return Color.lerp(const Color(0xFFF59E0B),const Color(0xFF7C3AED),t)!;}
  @override Widget build(BuildContext context)=>_GamePage(title:'2048',subtitle:'${difficultyName(nexoraDifficulty)} • Classic merge puzzle • swipe every direction',accent:const Color(0xFFF59E0B),reset:()=>setState(_reset),child:GestureDetector(
    behavior:HitTestBehavior.opaque,onHorizontalDragEnd:(d){final v=d.primaryVelocity??0;if(v!=0)_move(v>0?1:-1,0);},onVerticalDragEnd:(d){final v=d.primaryVelocity??0;if(v!=0)_move(0,v>0?1:-1);},
    child:_World(top:const Color(0xFF24170A),bottom:const Color(0xFF080A13),child:Column(children:[
      _ScoreBar('SCORE $score','LVL $level • BEST $best',const Color(0xFFF59E0B)),Expanded(child:Center(child:AspectRatio(aspectRatio:1,child:Container(
        margin:const EdgeInsets.all(16),padding:const EdgeInsets.all(9),decoration:BoxDecoration(color:Colors.black38,borderRadius:BorderRadius.circular(25),border:Border.all(color:const Color(0xFFF59E0B).withOpacity(.22))),
        child:GridView.count(key:ValueKey(pulse),crossAxisCount:4,physics:const NeverScrollableScrollPhysics(),crossAxisSpacing:8,mainAxisSpacing:8,children:board.map((v)=>AnimatedContainer(duration:const Duration(milliseconds:120),curve:Curves.easeOutBack,
          decoration:BoxDecoration(color:_tile(v),borderRadius:BorderRadius.circular(15),boxShadow:v>0?[BoxShadow(color:_tile(v).withOpacity(.16),blurRadius:9)]:const[]),child:Center(child:Text(v==0?'':'$v',style:TextStyle(fontSize:v>=1024?18:v>=128?23:28,fontWeight:FontWeight.w900)))),
        ).toList()),
      )))),Padding(padding:const EdgeInsets.fromLTRB(18,0,18,16),child:Row(children:[
        Expanded(child:Text(gameOver?'NO MORE MOVES':won&&!keepPlaying?'2048 REACHED!':'SWIPE ANYWHERE',textAlign:TextAlign.center,style:const TextStyle(color:Colors.white38,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1))),
        IconButton(onPressed:previous.every((v)=>v==0)?null:()=>setState((){board=List<int>.from(previous);score=previousScore;gameOver=false;won=false;keepPlaying=false;previous=List.filled(16,0);pulse++;}),icon:const Icon(Icons.undo_rounded)),
        if(won&&!gameOver&&!keepPlaying)FilledButton(onPressed:()=>setState(()=>keepPlaying=true),child:const Text('KEEP')),
        if(gameOver)FilledButton.icon(onPressed:()=>setState(_reset),icon:const Icon(Icons.refresh_rounded,size:17),label:const Text('RETRY')),
      ]))]))));}

class _Tetris extends StatefulWidget{const _Tetris();@override State<_Tetris> createState()=>_TetrisState();}
class _TetrisState extends State<_Tetris>{
 final random=Random(),board=List<int>.filled(200,0);List<int> bag=[];
 final shapes=const[[[1,1,1,1]],[[1,1],[1,1]],[[0,1,0],[1,1,1]],[[1,0,0],[1,1,1]],[[0,0,1],[1,1,1]],[[0,1,1],[1,1,0]],[[1,1,0],[0,1,1]]];
 final colors=const[Colors.transparent,Color(0xFF22D3EE),Color(0xFFFACC15),Color(0xFFA78BFA),Color(0xFF60A5FA),Color(0xFFFB923C),Color(0xFF4ADE80),Color(0xFFF87171)];
 Timer? timer;late int current,next,activeKind;List<List<int>> shape=const[[1]];List<List<int>>? held;int row=0,col=3,score=0,lines=0;bool running=false,over=false,canHold=true;
 @override void initState(){super.initState();_reset();}
 void _reset(){timer?.cancel();for(var i=0;i<200;i++)board[i]=0;bag=[];current=_nextPiece();next=_nextPiece();held=null;score=0;lines=0;running=false;over=false;canHold=true;_load();}
 int _nextPiece(){if(bag.isEmpty){bag=List<int>.generate(7,(i)=>i)..shuffle(random);}return bag.removeLast();}
 void _load(){activeKind=current;shape=shapes[activeKind].map((r)=>List<int>.from(r)).toList();row=0;col=3;current=next;next=_nextPiece();canHold=true;}
 bool _can(int r,int c,List<List<int>>s){for(var y=0;y<s.length;y++)for(var x=0;x<s[y].length;x++){if(s[y][x]==0)continue;final xx=c+x,yy=r+y;if(xx<0||xx>=10||yy>=20)return false;if(yy>=0&&board[yy*10+xx]!=0)return false;}return true;}
 void _start(){if(running||over)return;running=true;_clock();setState((){});}
 void _clock(){timer?.cancel();final base=max(70,720-((nexoraSelectedLevel-1)*5));final speedStage=lines~/10;timer=Timer.periodic(Duration(milliseconds:max(45,base-speedStage*38)),(_)=>_tick());}
 void _tick(){if(!mounted||!running)return;if(_can(row+1,col,shape)){row++;setState((){});}else{_lock();}}
 void _move(int d){if(!running)_start();if(_can(row,col+d,shape)){col+=d;setState((){});}}
 void _soft(){if(!running)_start();if(_can(row+1,col,shape)){row++;score++;setState((){});}else{_lock();}}
 void _hard(){if(!running)_start();var n=0;while(_can(row+1,col,shape)){row++;n++;}score+=n*2;_lock();}
 void _rotate(){if(!running)_start();final h=shape.length,w=shape[0].length,r=List.generate(w,(_)=>List<int>.filled(h,0));for(var y=0;y<h;y++)for(var x=0;x<w;x++)r[x][h-1-y]=shape[y][x];for(final k in[0,-1,1,-2,2])if(_can(row,col+k,r)){shape=r;col+=k;setState((){});return;}}
 int _kind(List<List<int>>s){final k=s.expand((r)=>r).join();for(var i=0;i<7;i++)if(shapes[i].expand((r)=>r).join()==k)return i;return activeKind;}
 void _hold(){if(!running||!canHold)return;canHold=false;final old=activeKind;if(held==null){held=shapes[old].map((r)=>List<int>.from(r)).toList();_load();canHold=false;}else{final t=held!;held=shapes[old].map((r)=>List<int>.from(r)).toList();shape=t.map((r)=>List<int>.from(r)).toList();activeKind=_kind(shape);row=0;col=3;}setState((){});}
 int _ghost(){var r=row;while(_can(r+1,col,shape))r++;return r;}
 void _lock(){for(var y=0;y<shape.length;y++)for(var x=0;x<shape[y].length;x++)if(shape[y][x]!=0&&row+y>=0&&row+y<20&&col+x>=0&&col+x<10)board[(row+y)*10+col+x]=activeKind+1;var clear=0;for(var y=19;y>=0;y--){var full=true;for(var x=0;x<10;x++)if(board[y*10+x]==0){full=false;break;}if(full){for(var yy=y;yy>0;yy--)for(var x=0;x<10;x++)board[yy*10+x]=board[(yy-1)*10+x];for(var x=0;x<10;x++)board[x]=0;clear++;y++;}}if(clear>0){lines+=clear;score+=[0,100,300,500,800][clear]*(1+lines~/10);_clock();}_load();if(!_can(row,col,shape)){running=false;over=true;timer?.cancel();}setState((){});}
 Widget ctl(IconData icon,VoidCallback fn)=>SizedBox(width:46,height:50,child:FilledButton(style:FilledButton.styleFrom(backgroundColor:const Color(0xFF171A2B),foregroundColor:Colors.white,side:BorderSide(color:const Color(0xFFA78BFA).withOpacity(.28)),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14))),onPressed:fn,child:Icon(icon,size:22)));
 Widget mini(List<List<int>>?s,Color c)=>SizedBox(width:58,height:44,child:CustomPaint(painter:_MiniPiecePainter(s,c)));
 @override void dispose(){timer?.cancel();super.dispose();}
 @override Widget build(BuildContext context)=>_GamePage(title:'Tetris',subtitle:'LEVEL $nexoraSelectedLevel • BUTTON CONTROL • 10×20',accent:const Color(0xFFA78BFA),reset:()=>setState(_reset),child:_World(top:const Color(0xFF17112A),bottom:const Color(0xFF070914),child:Column(children:[
  _ScoreBar('SCORE $score','LINES $lines',const Color(0xFFA78BFA)),
  Expanded(child:Row(children:[
   Expanded(child:Center(child:AspectRatio(aspectRatio:.50,child:Container(margin:const EdgeInsets.only(left:10,right:4),padding:const EdgeInsets.all(5),decoration:BoxDecoration(color:Colors.black38,borderRadius:BorderRadius.circular(20),border:Border.all(color:const Color(0xFFA78BFA).withOpacity(.22))),child:CustomPaint(painter:_TetrisPainter(board,shape,row,col,_ghost(),colors[activeKind+1]),child:const SizedBox.expand()))))),
   SizedBox(width:102,child:Padding(padding:const EdgeInsets.only(right:7),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    const Text('NEXT',style:TextStyle(fontSize:9,color:Colors.white38,fontWeight:FontWeight.w900)),mini(shapes[next],colors[next+1]),const SizedBox(height:6),
    const Text('HOLD',style:TextStyle(fontSize:9,color:Colors.white38,fontWeight:FontWeight.w900)),mini(held,held==null?Colors.white12:colors[_kind(held!)+1]),const SizedBox(height:8),
    Row(mainAxisAlignment:MainAxisAlignment.center,children:[ctl(Icons.arrow_back_rounded,()=>_move(-1)),const SizedBox(width:4),ctl(Icons.arrow_forward_rounded,()=>_move(1))]),
    const SizedBox(height:5),Row(mainAxisAlignment:MainAxisAlignment.center,children:[ctl(Icons.rotate_right_rounded,_rotate),const SizedBox(width:4),ctl(Icons.keyboard_double_arrow_down_rounded,_hard)]),
    const SizedBox(height:5),Row(mainAxisAlignment:MainAxisAlignment.center,children:[ctl(Icons.keyboard_arrow_down_rounded,_soft),const SizedBox(width:4),ctl(Icons.back_hand_rounded,_hold)]),
    const SizedBox(height:7),SizedBox(width:94,height:40,child:FilledButton(onPressed:over?()=>setState(_reset):_start,child:Text(over?'AGAIN':running?'RUNNING':'START',style:const TextStyle(fontSize:9,fontWeight:FontWeight.w900)))),
   ])),
  ])),
 ])));
}
const List<Color> _tetrisColors = [
  Colors.transparent,
  Color(0xFF22D3EE),
  Color(0xFFFACC15),
  Color(0xFFA78BFA),
  Color(0xFF60A5FA),
  Color(0xFFFB923C),
  Color(0xFF4ADE80),
  Color(0xFFF87171),
];

class _MiniPiecePainter extends CustomPainter {
  final List<List<int>>? shape;
  final Color color;
  const _MiniPiecePainter(this.shape, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (shape == null || shape!.isEmpty) return;
    final h = shape!.length;
    final w = shape!.map((r) => r.length).reduce(max);
    final cell = min(size.width / w, size.height / h) * .72;
    final ox = (size.width - w * cell) / 2;
    final oy = (size.height - h * cell) / 2;
    final p = Paint()..color = color;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < shape![y].length; x++) {
        if (shape![y][x] == 0) continue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(ox + x * cell + 1, oy + y * cell + 1, cell - 2, cell - 2),
            const Radius.circular(4),
          ),
          p,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniPiecePainter old) => old.shape != shape || old.color != color;
}

class _TetrisPainter extends CustomPainter{
 final List<int> board;final List<List<int>> shape;final int row,col,ghost;final Color active;
 const _TetrisPainter(this.board,this.shape,this.row,this.col,this.ghost,this.active);
 @override void paint(Canvas canvas,Size size){
  final cell=size.width/10,p=Paint();
  for(var y=0;y<20;y++)for(var x=0;x<10;x++){
   p.color=Colors.white.withOpacity(.025);
   canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x*cell+1,y*cell+1,cell-2,cell-2),const Radius.circular(4)),p);
   final v=board[y*10+x];
   if(v>0){
    p.color=_tetrisColors[v.clamp(0,_tetrisColors.length-1).toInt()];
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x*cell+2,y*cell+2,cell-4,cell-4),const Radius.circular(5)),p);
   }
  }
  p.color=active.withOpacity(.16);
  for(var y=0;y<shape.length;y++)for(var x=0;x<shape[y].length;x++)if(shape[y][x]!=0){
   final yy=ghost+y,xx=col+x;
   if(yy>=0&&yy<20&&xx>=0&&xx<10)canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(xx*cell+4,yy*cell+4,cell-8,cell-8),const Radius.circular(4)),p);
  }
  p.color=active;
  for(var y=0;y<shape.length;y++)for(var x=0;x<shape[y].length;x++)if(shape[y][x]!=0){
   final yy=row+y,xx=col+x;
   if(yy>=0&&yy<20&&xx>=0&&xx<10)canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(xx*cell+2,yy*cell+2,cell-4,cell-4),const Radius.circular(5)),p);
  }
 }
 @override bool shouldRepaint(covariant _TetrisPainter old)=>true;
}
class _Flappy extends StatefulWidget{const _Flappy();@override State<_Flappy> createState()=>_FlappyState();}
class _FlappyState extends State<_Flappy>{
 Timer? timer;double birdY=.45,velocity=0,pipeX=1.15,gap=.48;int score=0,best=0,level=1;bool running=false,over=false;final random=Random();
 void _reset(){timer?.cancel();birdY=.45;velocity=0;pipeX=1.15;gap=.48;score=0;level=1;running=false;over=false;}
 void _flap(){if(!running){if(over)_reset();running=true;timer=Timer.periodic(const Duration(milliseconds:25),(_)=>_tick());}velocity=-.028;setState((){});}
 void _tick(){if(!mounted||!running)return;birdY+=velocity;const gravity=[.00125,.00155,.00185,.00215,.00255];const pipeSpeed=[.0072,.0098,.0125,.015,.0185];const gapBase=[.20,.18,.16,.145,.125];final d=nexoraDifficulty.index;velocity+=gravity[d];pipeX-=pipeSpeed[d];if(pipeX<-.18){pipeX=1.08;final dynamicGap=max(.09,gapBase[d]-min(score,900)*.00002);gap=(.5-dynamicGap)+random.nextDouble()*(dynamicGap*2);score++;level=nexoraLevel(1+score~/10);best=max(best,score);}final hit=birdY<.055||birdY>.90||(pipeX<.25&&pipeX>-.02&&(birdY<gap-gapBase[d]||birdY>gap+gapBase[d]));if(hit){running=false;over=true;timer?.cancel();}setState((){});}
 @override void dispose(){timer?.cancel();super.dispose();}
 @override Widget build(BuildContext context)=>_GamePage(title:'Flappy',subtitle:'${difficultyName(nexoraDifficulty)} • Tap flight • dodge the pipes',accent:const Color(0xFF22D3EE),reset:()=>setState(_reset),child:GestureDetector(behavior:HitTestBehavior.opaque,onTap:_flap,child:_World(top:const Color(0xFF49B9E9),bottom:const Color(0xFFB8E9D4),child:Stack(children:[
  Positioned.fill(child:CustomPaint(painter:_FlappyPainter(birdY,pipeX,gap,score))),Positioned(top:14,left:0,right:0,child:Column(children:[Text('$score',style:const TextStyle(fontSize:50,fontWeight:FontWeight.w900,shadows:[Shadow(blurRadius:5)])),Text('LVL $level  •  BEST $best',style:const TextStyle(fontSize:9,color:Colors.white70,fontWeight:FontWeight.w900,letterSpacing:2))])),
  if(!running)Center(child:Container(padding:const EdgeInsets.fromLTRB(26,21,26,19),decoration:BoxDecoration(color:Colors.black.withOpacity(.32),borderRadius:BorderRadius.circular(24),border:Border.all(color:Colors.white.withOpacity(.32))),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.flutter_dash_rounded,color:Color(0xFFFFE45C),size:54),const SizedBox(height:7),Text(over?'GAME OVER':'READY?',style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900)),const SizedBox(height:5),Text(over?'TAP TO FLY AGAIN':'TAP TO FLAP',style:const TextStyle(color:Colors.white70,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1))]))),
 ]))));}
class _FlappyPainter extends CustomPainter{
 final double birdY,pipeX,gap;final int score;const _FlappyPainter(this.birdY,this.pipeX,this.gap,this.score);
 @override void paint(Canvas canvas,Size size){final p=Paint();p.color=Colors.white.withOpacity(.26);for(var i=0;i<6;i++){final x=((i*150.0)-(score%10)*9)%(size.width+180)-90,y=70.0+(i%3)*92;canvas.drawOval(Rect.fromLTWH(x,y,100,24),p);canvas.drawOval(Rect.fromLTWH(x+22,y-12,54,34),p);}final px=pipeX*size.width,top=(gap-.16)*size.height,bottom=(gap+.16)*size.height;p.color=const Color(0xFF55B947);canvas.drawRect(Rect.fromLTWH(px,0,58,max(0,top)),p);canvas.drawRect(Rect.fromLTWH(px,bottom,58,max(0,size.height*.90-bottom)),p);p.color=const Color(0xFF82D95B);canvas.drawRect(Rect.fromLTWH(px-5,max(0,top-12),68,12),p);canvas.drawRect(Rect.fromLTWH(px-5,bottom,68,12),p);p.color=const Color(0xFF7BCB4D);canvas.drawRect(Rect.fromLTWH(0,size.height*.90,size.width,size.height*.10),p);p.color=const Color(0xFFD9C56A);canvas.drawRect(Rect.fromLTWH(0,size.height*.925,size.width,size.height*.075),p);final by=birdY*size.height;p.color=const Color(0xFFFFE45C);canvas.drawCircle(Offset(size.width*.19,by),18,p);p.color=const Color(0xFFFFC928);canvas.drawOval(Rect.fromCenter(center:Offset(size.width*.16,by+4),width:20,height:12),p);p.color=Colors.white;canvas.drawCircle(Offset(size.width*.205,by-5),5,p);p.color=Colors.black;canvas.drawCircle(Offset(size.width*.207,by-5),2.2,p);p.color=const Color(0xFFF97316);canvas.drawOval(Rect.fromCenter(center:Offset(size.width*.19+17,by+1),width:18,height:8),p);}
 @override bool shouldRepaint(covariant _FlappyPainter old)=>true;
}

class _Breakout extends StatefulWidget{const _Breakout();@override State<_Breakout> createState()=>_BreakoutState();}
class _BreakoutState extends State<_Breakout>{
 final random=Random();Timer? timer;List<int> bricks=[],hp=[];List<_PowerDrop> drops=[];List<_Ball> balls=[];double paddle=.5;int score=0,lives=3,level=1,combo=0;bool running=false,over=false;
 @override void initState(){super.initState();_reset();}
 void _reset(){timer?.cancel();score=0;lives=3;level=1;combo=0;paddle=.5;running=false;over=false;_makeLevel();}
 void _makeLevel(){final d=nexoraDifficulty.index;bricks=List<int>.filled(54,1);hp=List<int>.generate(54,(i)=>i<9||(d>=2&&i<18)||(d>=4&&i%3==0)?(d>=2?2:1):1);drops=[];final base=[.0068,.0085,.0105,.013,.017][d];final speed=base*(1+min(level-1,500)*.002);balls=[_Ball(.5,.82,speed,-speed*1.45)];}
 void _start(){if(running||over)return;running=true;_clock();setState((){});}void _clock(){timer?.cancel();timer=Timer.periodic(const Duration(milliseconds:16),(_)=>_tick());}
 void _drop(double x,double y){if(random.nextDouble()>.20)return;const t=['wide','multi','slow','fire'];drops.add(_PowerDrop(x,y,t[random.nextInt(t.length)]));}
 void _tick(){if(!mounted||!running)return;final out=<_Ball>[];for(final b in balls){b.x+=b.vx;b.y+=b.vy;if(b.x<.018||b.x>.982){b.vx=-b.vx;b.x=b.x.clamp(.018,.982).toDouble();}if(b.y<.055){b.vy=b.vy.abs();b.y=.055;}if(b.vy>0&&b.y>.84&&b.y<.94&&(b.x-paddle).abs()<[.22,.18,.15,.12,.095][nexoraDifficulty.index]){final h=(b.x-paddle)/[.22,.18,.15,.12,.095][nexoraDifficulty.index];b.vx=(b.vx+h*.010).clamp(-.019,.019).toDouble();b.vy=-max(b.vy.abs(),.0065);combo++;}final col=(b.x*9).floor().clamp(0,8).toInt(),row=((b.y-.08)/.060).floor().clamp(0,5).toInt(),idx=row*9+col;if(b.y>.07&&b.y<.46&&bricks[idx]!=0){hp[idx]--;if(hp[idx]<=0){bricks[idx]=0;score+=10+combo*2;combo++;_drop(b.x,b.y);}else{score+=4;}b.vy=-b.vy;}if(b.y<1.02)out.add(b);}balls=out;if(balls.isEmpty){lives--;combo=0;if(lives<=0){running=false;over=true;timer?.cancel();}else{final base=[.0068,.0085,.0105,.013,.017][nexoraDifficulty.index];final speed=base*(1+min(level-1,500)*.002);balls=[_Ball(.5,.82,speed*(random.nextBool()?1:-1),-speed*1.45)];}}for(final d in drops)d.y+=.006;final caught=<_PowerDrop>[];drops.removeWhere((d){final hit=d.y>.84&&d.y<.95&&(d.x-paddle).abs()<.16;if(hit)caught.add(d);return hit||d.y>1.02;});for(final d in caught)_power(d.type);if(bricks.every((v)=>v==0)){level=nexoraLevel(level+1);_makeLevel();_clock();}setState((){});}
 void _power(String t){if(t=='wide'){paddle=paddle.clamp(.16,.84).toDouble();}else if(t=='multi'&&balls.isNotEmpty&&balls.length<3){final b=balls.first;balls.add(_Ball(b.x,b.y,-b.vx,b.vy));balls.add(_Ball(b.x,b.y,b.vx*.65,b.vy));}else if(t=='slow'){for(final b in balls){b.vx*=.72;b.vy*=.72;}}else{score+=100;for(var i=0;i<bricks.length;i++)if(bricks[i]!=0&&random.nextDouble()<.14)bricks[i]=0;}}
 @override void dispose(){timer?.cancel();super.dispose();}
 @override Widget build(BuildContext context)=>_GamePage(title:'Breakout',subtitle:'${difficultyName(nexoraDifficulty)} • Brick breaker • power-ups • 3 stages',accent:const Color(0xFFEF4444),reset:()=>setState(_reset),child:GestureDetector(behavior:HitTestBehavior.opaque,onTap:_start,onHorizontalDragUpdate:(d){paddle=(paddle+d.delta.dx/MediaQuery.sizeOf(context).width).clamp(.10,.90).toDouble();setState((){});},child:_World(top:const Color(0xFF210A14),bottom:const Color(0xFF070914),child:Stack(children:[
  Positioned.fill(child:CustomPaint(painter:_BreakoutPainter(bricks,hp,balls,drops,paddle))),Positioned(top:14,left:16,right:16,child:Row(children:[Text('SCORE $score',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12)),const Spacer(),Text('LV $level  •  ♥ $lives',style:const TextStyle(color:Color(0xFFFCA5A5),fontWeight:FontWeight.w900,fontSize:12))])),
  if(!running)Center(child:Container(padding:const EdgeInsets.symmetric(horizontal:22,vertical:16),decoration:BoxDecoration(color:Colors.black54,borderRadius:BorderRadius.circular(22),border:Border.all(color:Colors.white12)),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.sports_baseball_rounded,color:Color(0xFFFF6B6B),size:48),const SizedBox(height:5),Text(over?(lives<=0?'GAME OVER':'ARCADE CLEAR'):'TAP TO LAUNCH',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(over?'PLAY AGAIN':'DRAG THE PADDLE',style:const TextStyle(color:Colors.white54,fontSize:9,fontWeight:FontWeight.w900,letterSpacing:1))]))),
 ]))));}
class _Ball{double x,y,vx,vy;_Ball(this.x,this.y,this.vx,this.vy);}
class _PowerDrop{double x,y;final String type;_PowerDrop(this.x,this.y,this.type);}
class _BreakoutPainter extends CustomPainter{
 final List<int> bricks,hp;final List<_Ball> balls;final List<_PowerDrop> drops;final double paddle;const _BreakoutPainter(this.bricks,this.hp,this.balls,this.drops,this.paddle);
 @override void paint(Canvas canvas,Size size){final p=Paint();const cs=[Color(0xFFF87171),Color(0xFFFB923C),Color(0xFFFACC15),Color(0xFF4ADE80),Color(0xFF22D3EE),Color(0xFFA78BFA)];for(var r=0;r<6;r++)for(var col=0;col<9;col++){final i=r*9+col;if(bricks[i]==0)continue;final rect=Rect.fromLTWH(col*size.width/9+4,58+r*30,size.width/9-8,23);p.color=hp[i]>1?cs[r].withOpacity(.55):cs[r];canvas.drawRRect(RRect.fromRectAndRadius(rect,const Radius.circular(7)),p);p.color=Colors.white.withOpacity(.18);canvas.drawRect(Rect.fromLTWH(rect.left+3,rect.top+3,rect.width-6,4),p);}p.color=Colors.white;canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH((paddle-[.22,.18,.15,.12,.095][nexoraDifficulty.index])*size.width,size.height*.91,[.44,.36,.30,.24,.19][nexoraDifficulty.index]*size.width,13),const Radius.circular(8)),p);for(final b in balls){p.color=const Color(0xFFFFD5D5);canvas.drawCircle(Offset(b.x*size.width,b.y*size.height),7,p);}for(final d in drops){final x=d.x*size.width,y=d.y*size.height;p.color=d.type=='multi'?const Color(0xFF22D3EE):d.type=='wide'?const Color(0xFF4ADE80):d.type=='slow'?const Color(0xFFA78BFA):const Color(0xFFFF6B35);canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(x,y),width:24,height:24),const Radius.circular(7)),p);final label=d.type=='multi'?'×':d.type=='wide'?'W':d.type=='slow'?'S':'F';TextPainter(text:TextSpan(text:label,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w900,color:Colors.black54)),textDirection:TextDirection.ltr)..layout()..paint(canvas,Offset(x-5,y-8));}}
 @override bool shouldRepaint(covariant _BreakoutPainter old)=>true;
}

class _Memory extends StatefulWidget {
  const _Memory();
  @override State<_Memory> createState() => _MemoryState();
}
class _MemoryState extends State<_Memory> {
  final random = Random();
  final icons = const [
    Icons.bolt_rounded, Icons.star_rounded, Icons.hexagon_rounded, Icons.favorite_rounded,
    Icons.diamond_rounded, Icons.bubble_chart_rounded, Icons.rocket_launch_rounded, Icons.local_fire_department_rounded,
    Icons.brightness_7_rounded, Icons.ac_unit_rounded, Icons.music_note_rounded, Icons.flash_on_rounded,
    Icons.public_rounded, Icons.emoji_events_rounded, Icons.pets_rounded, Icons.sailing_rounded,
    Icons.auto_awesome_rounded, Icons.sports_esports_rounded,
  ];
  final colors = const [
    Color(0xFF22D3EE), Color(0xFFF59E0B), Color(0xFFA78BFA), Color(0xFFEC4899),
    Color(0xFF34D399), Color(0xFFFB7185), Color(0xFF60A5FA), Color(0xFFF97316),
    Color(0xFF38BDF8), Color(0xFF67E8F9), Color(0xFFC084FC), Color(0xFFF472B6),
    Color(0xFF2DD4BF), Color(0xFFFBBF24), Color(0xFF818CF8), Color(0xFFFB7185),
    Color(0xFFA3E635), Color(0xFFE879F9),
  ];
  late List<int> cards;
  final open = <int>[];
  final matched = <int>{};
  int moves = 0, streak = 0, bestStreak = 0, level = 1, score = 0;
  bool locked = false;

  @override void initState() { super.initState(); _reset(); }
  void _reset() {
    final pairCounts=[6,8,10,12,18];final pairs=pairCounts[nexoraDifficulty.index];cards=<int>[for(var i=0;i<pairs;i++)...[i,i]]..shuffle(random);
    open.clear(); matched.clear();
    moves = 0; streak = 0;
              bestStreak = 0; level = 1; score = 0; locked = false;
  }
  void _newRound() {
    final base=[6,8,10,12,18][nexoraDifficulty.index];
    final extra=min(4, (level-1)~/3);
    final pairs=min(18, base+extra);
    cards=<int>[for(var i=0;i<pairs;i++)...[i,i]]..shuffle(random);
    open.clear(); matched.clear(); moves=0; streak=0; locked=false;
  }
  void _tap(int index) {
    if (locked || open.contains(index) || matched.contains(index)) return;
    setState(() {
      open.add(index);
      if (open.length == 2) {
        locked = true;
        moves++;
        final first = open[0], second = open[1];
        Future.delayed(const Duration(milliseconds: 520), () {
          if (!mounted) return;
          setState(() {
            if (cards[first] == cards[second]) {
              matched.addAll([first, second]);
              streak++;
              bestStreak = max(bestStreak, streak);
            } else {
              streak = 0;
            }
            open.clear();
            if (matched.length == cards.length) {
              level = nexoraLevel(level + 1);
              Future.delayed(const Duration(milliseconds: 650), () {
                if (!mounted || locked) return;
                setState(() => _newRound());
              });
            }
            locked = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => _GamePage(
    title: 'Memory', subtitle: '${difficultyName(nexoraDifficulty)} • Match Lab • build your streak', accent: const Color(0xFFEC4899),
    reset: () => setState(_reset),
    child: _World(
      top: const Color(0xFF180B1C), bottom: const Color(0xFF070914),
      child: Column(children: [
        _ScoreBar('LVL $level • SCORE $score', 'MOVES $moves • STREAK $streak', const Color(0xFFEC4899)),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: cards.length > 24 ? .82 : 1.0),
          itemBuilder: (_, i) {
            final show = open.contains(i) || matched.contains(i);
            final color = colors[cards[i]];
            return GestureDetector(
              onTap: () => _tap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: show ? color.withOpacity(.12) : Colors.white.withOpacity(.055),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: show ? color.withOpacity(.72) : Colors.white.withOpacity(.08)),
                  boxShadow: show ? [BoxShadow(color: color.withOpacity(.16), blurRadius: 14)] : const [],
                ),
                child: Center(child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: show
                    ? Icon(icons[cards[i]], key: ValueKey('card-${cards[i]}'), color: color, size: 32)
                    : const Icon(Icons.question_mark_rounded, key: ValueKey('hidden'), color: Colors.white24, size: 24),
                )),
              ),
            );
          },
        )),
        if (matched.length == cards.length)
          Padding(padding: const EdgeInsets.fromLTRB(18, 0, 18, 16), child: FilledButton(onPressed: () => setState(_reset), child: const Text('PLAY AGAIN'))),
      ]),
    ),
  );
}
// Bonus arcade games based on the supplied Game Hub concept.
class _DinoRunUltra extends StatefulWidget{const _DinoRunUltra();@override State<_DinoRunUltra> createState()=>_DinoRunUltraState();}
class _DinoRunUltraState extends State<_DinoRunUltra>{
 Timer? timer;double y=0,v=0,speed=6,distance=0;bool running=false,dead=false;final obstacles=<Rect>[];final random=Random();int score=0,best=0;
 @override void initState(){super.initState();_reset();} void _reset(){timer?.cancel();y=0;v=0;distance=0;score=0;running=false;dead=false;obstacles.clear();best=0;}
 void _start(){if(running)return;setState(()=>running=true);timer=Timer.periodic(const Duration(milliseconds:16),(_){if(mounted)_tick();});}
 void _jump(){if(!running){_start();return;}if(y==0)setState(()=>v=-15);}
 void _tick(){if(!running)return;setState((){v+=.8;y+=v;if(y>0){y=0;v=0;}distance+=speed*.08;score=distance.floor();if(obstacles.isEmpty||obstacles.last.left<320&&random.nextDouble()<.018)obstacles.add(Rect.fromLTWH(430.0,118.0-random.nextInt(12).toDouble(),22.0+random.nextInt(12).toDouble(),42.0));for(var i=0;i<obstacles.length;i++)obstacles[i]=obstacles[i].translate(-speed,0);obstacles.removeWhere((o)=>o.right<0);if(obstacles.any((o)=>o.overlaps(Rect.fromLTWH(48,122+y,34,42)))){dead=true;running=false;timer?.cancel();best=max(best,score);}});}
 @override void dispose(){timer?.cancel();super.dispose();}
 @override Widget build(BuildContext context)=>_GamePage(title:'Dino Run Ultra',subtitle:'LEVEL $nexoraSelectedLevel • RUN • JUMP • SURVIVE',accent:const Color(0xFF00FF88),reset:()=>setState(_reset),child:_World(top:const Color(0xFF071A13),bottom:const Color(0xFF030609),child:Column(children:[
  _ScoreBar('SCORE $score','BEST $best',const Color(0xFF00FF88)),Expanded(child:GestureDetector(onTap:_jump,child:CustomPaint(painter:_DinoPainter(y,obstacles,distance),child:const SizedBox.expand()))),
  Padding(padding:const EdgeInsets.fromLTRB(18,8,18,18),child:Row(children:[Expanded(child:FilledButton(onPressed:dead?()=>setState(_reset):_start,child:Text(dead?'PLAY AGAIN':running?'RUNNING':'START'))),const SizedBox(width:10),IconButton.filled(onPressed:_jump,icon:const Icon(Icons.keyboard_arrow_up_rounded))])),
 ])));
}
class _DinoPainter extends CustomPainter{
 final double y,distance;final List<Rect> obstacles;const _DinoPainter(this.y,this.obstacles,this.distance);
 @override void paint(Canvas c,Size s){final bg=Paint()..shader=const LinearGradient(colors:[Color(0xFF09231A),Color(0xFF030609)],begin:Alignment.topCenter,end:Alignment.bottomCenter).createShader(Offset.zero&s);c.drawRect(Offset.zero&s,bg);final glow=Paint()..color=const Color(0xFF00FF88).withOpacity(.15);for(var i=0;i<18;i++)c.drawCircle(Offset((i*73-(distance*9)%73),35+(i%4)*22),i%2+1,glow);c.drawRect(Rect.fromLTWH(0,164,s.width,2),Paint()..color=const Color(0xFF00FF88).withOpacity(.35));c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(48,122+y,34,42),const Radius.circular(8)),Paint()..color=const Color(0xFF00FF88));c.drawCircle(const Offset(72,132),3,Paint()..color=Colors.black);for(final o in obstacles)c.drawRRect(RRect.fromRectAndRadius(o,const Radius.circular(5)),Paint()..color=const Color(0xFFFF2B2B));}
 @override bool shouldRepaint(covariant _DinoPainter old)=>true;
}
class _BrickBreakerUltimate extends StatefulWidget{const _BrickBreakerUltimate();@override State<_BrickBreakerUltimate> createState()=>_BrickBreakerUltimateState();}
class _BrickBreakerUltimateState extends State<_BrickBreakerUltimate>{
 Timer? timer;double paddle=.5,bx=.5,by=.78,dx=.006,dy=-.008;int score=0,lives=3,level=1,combo=0;bool running=false,dead=false;late List<List<bool>> bricks;
 @override void initState(){super.initState();_reset();} void _reset(){timer?.cancel();paddle=.5;bx=.5;by=.78;dx=.006;dy=-.008;score=0;lives=3;level=nexoraSelectedLevel.clamp(1,50).toInt();combo=0;running=false;dead=false;bricks=List.generate(min(8,3+level~/4),(r)=>List.generate(8,(_)=>true));}
 void _start(){if(running)return;setState(()=>running=true);timer=Timer.periodic(const Duration(milliseconds:16),(_){if(mounted)_tick();});}
 void _tick(){if(!running)return;setState((){bx+=dx;by+=dy;if(bx<.03||bx>.97){dx=-dx;bx=bx.clamp(.03,.97).toDouble();}if(by<.04)dy=dy.abs();if(by>.94){lives--;if(lives<=0){dead=true;running=false;timer?.cancel();}else{bx=paddle;by=.78;dy=-.008;dx=.006;}}if(by>.84&&by<.91&&bx>paddle-.12&&bx<paddle+.12&&dy>0){dy=-dy.abs();dx=((bx-paddle)*.035).clamp(-.018,.018).toDouble();}for(var r=0;r<bricks.length;r++)for(var k=0;k<8;k++)if(bricks[r][k]){final left=.08+k*.105,top=.08+r*.065;if(bx>left&&bx<left+.085&&by>top&&by<top+.05){bricks[r][k]=false;dy=-dy;score+=10+combo*2;combo++;break;}}if(bricks.every((r)=>r.every((b)=>!b))){level++;bricks=List.generate(min(10,3+level~/3),(r)=>List.generate(8,(_)=>true));bx=paddle;by=.78;dy=-.008;combo=0;}});}
 @override void dispose(){timer?.cancel();super.dispose();}
 @override Widget build(BuildContext context)=>_GamePage(title:'Brick Breaker Ultimate',subtitle:'LEVEL $level • COMBO $combo • $lives LIVES',accent:const Color(0xFFFF9500),reset:()=>setState(_reset),child:_World(top:const Color(0xFF241107),bottom:const Color(0xFF080609),child:Column(children:[
  _ScoreBar('SCORE $score','LIVES $lives',const Color(0xFFFF9500)),Expanded(child:GestureDetector(onHorizontalDragUpdate:(d){setState(()=>paddle=(paddle+d.delta.dx/350).clamp(.12,.88).toDouble());},child:CustomPaint(painter:_BrickPainter(bricks,bx,by,paddle),child:const SizedBox.expand()))),
  Padding(padding:const EdgeInsets.fromLTRB(18,8,18,18),child:FilledButton(onPressed:dead?()=>setState(_reset):_start,child:Text(dead?'PLAY AGAIN':running?'RUNNING':'START'))),
 ])));
}
class _BrickPainter extends CustomPainter{
 final List<List<bool>> bricks;final double bx,by,paddle;const _BrickPainter(this.bricks,this.bx,this.by,this.paddle);
 @override void paint(Canvas c,Size s){final bg=Paint()..shader=const LinearGradient(colors:[Color(0xFF0B0B12),Color(0xFF030306)],begin:Alignment.topCenter,end:Alignment.bottomCenter).createShader(Offset.zero&s);c.drawRect(Offset.zero&s,bg);final colors=[const Color(0xFFFF2B2B),const Color(0xFFFF9500),const Color(0xFFFFC800),const Color(0xFF00FF88),const Color(0xFF00C8FF),const Color(0xFFA855F7)];for(var r=0;r<bricks.length;r++)for(var k=0;k<8;k++)if(bricks[r][k]){final rect=Rect.fromLTWH(s.width*(.08+k*.105),s.height*(.08+r*.065),s.width*.085,s.height*.05);c.drawRRect(RRect.fromRectAndRadius(rect,const Radius.circular(6)),Paint()..color=colors[r%colors.length]);}c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*(paddle-.12),s.height*.9,s.width*.24,s.height*.028),const Radius.circular(8)),Paint()..color=const Color(0xFFFF9500));c.drawCircle(Offset(s.width*bx,s.height*by),8,Paint()..color=Colors.white);}
 @override bool shouldRepaint(covariant _BrickPainter old)=>true;
}
class _WatermelonMergePro extends StatefulWidget{const _WatermelonMergePro();@override State<_WatermelonMergePro> createState()=>_WatermelonMergeProState();}
class _WatermelonMergeProState extends State<_WatermelonMergePro>{
 final random=Random();final fruits=< _MergeFruit>[];Timer? timer;int score=0;bool running=false,dead=false;double dropX=.5;int current=0,next=1;
 @override void initState(){super.initState();_reset();} void _reset(){timer?.cancel();fruits.clear();score=0;running=false;dead=false;dropX=.5;current=random.nextInt(4);next=random.nextInt(4);}
 void _start(){if(running)return;setState(()=>running=true);timer=Timer.periodic(const Duration(milliseconds:16),(_){if(mounted)_tick();});}
 void _drop(){if(!running)return;setState((){fruits.add(_MergeFruit(dropX,.08,current));current=next;next=random.nextInt(4);});}
 void _tick(){if(!running)return;setState((){for(final f in fruits){f.vy+=.00055;f.y+=f.vy;if(f.y+f.r>.94){f.y=.94-f.r;f.vy*=-.28;}}for(var i=0;i<fruits.length;i++)for(var j=i+1;j<fruits.length;j++){final a=fruits[i],b=fruits[j];if(a.type==b.type&&(a.x-b.x).abs()<a.r+b.r&&(a.y-b.y).abs()<a.r+b.r){a.dead=true;b.dead=true;fruits.add(_MergeFruit((a.x+b.x)/2,(a.y+b.y)/2,a.type+1));score+=(a.type+2)*5;}}fruits.removeWhere((f)=>f.dead);if(fruits.any((f)=>f.y-f.r<.12)&&fruits.length>12){dead=true;running=false;timer?.cancel();}});}
 @override void dispose(){timer?.cancel();super.dispose();}
 @override Widget build(BuildContext context)=>_GamePage(title:'Watermelon Merge Pro',subtitle:'LEVEL $nexoraSelectedLevel • DROP • MERGE • GROW',accent:const Color(0xFF22D3EE),reset:()=>setState(_reset),child:_World(top:const Color(0xFF071A18),bottom:const Color(0xFF030609),child:Column(children:[
  _ScoreBar('SCORE $score','NEXT',const Color(0xFF22D3EE)),Expanded(child:GestureDetector(onHorizontalDragUpdate:(d){setState(()=>dropX=(dropX+d.delta.dx/350).clamp(.08,.92).toDouble());},onHorizontalDragEnd:(_)=>_drop(),child:CustomPaint(painter:_MergePainter(fruits,dropX,current),child:const SizedBox.expand()))),
  Padding(padding:const EdgeInsets.fromLTRB(18,8,18,18),child:FilledButton(onPressed:dead?()=>setState(_reset):_start,child:Text(dead?'PLAY AGAIN':running?'RUNNING':'START'))),
 ])));
}
class _MergeFruit{double x,y,vy=0;int type;bool dead=false;final double r;_MergeFruit(this.x,this.y,this.type):r=.035+type*.008;}
class _MergePainter extends CustomPainter{
 final List<_MergeFruit> fruits;final double dropX;final int current;const _MergePainter(this.fruits,this.dropX,this.current);
 @override void paint(Canvas c,Size s){final bg=Paint()..shader=const RadialGradient(colors:[Color(0xFF0B241B),Color(0xFF030609)]).createShader(Offset.zero&s);c.drawRect(Offset.zero&s,bg);c.drawRect(Rect.fromLTWH(0,s.height*.12,s.width,1.5),Paint()..color=const Color(0xFFFF2B2B).withOpacity(.45));final colors=[const Color(0xFFA855F7),const Color(0xFFFF2B2B),const Color(0xFFFF9500),const Color(0xFF22D3EE),const Color(0xFF00FF88)];for(final f in fruits)c.drawCircle(Offset(f.x*s.width,f.y*s.height),f.r*s.width,Paint()..color=colors[min(f.type,4)]);c.drawCircle(Offset(dropX*s.width,s.height*.08),(.035+current*.008)*s.width,Paint()..color=Colors.white70);}
 @override bool shouldRepaint(covariant _MergePainter old)=>true;
}

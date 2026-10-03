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
    _G('2048','PUZZLE','Merge tiles • beat your best.',Icons.grid_4x4_rounded,Color(0xFFF59E0B)),
    _G('Tetris','ARCADE','Stack blocks • clear lines.',Icons.view_module_rounded,_purple),
    _G('Flappy','ARCADE','Tap • fly • survive.',Icons.flutter_dash_rounded,_cyan),
    _G('Breakout','ARCADE','Smash blocks • save lives.',Icons.sports_baseball_rounded,Color(0xFFEF4444)),
    _G('Memory','PUZZLE','Flip • match • remember.',Icons.style_rounded,Color(0xFFEC4899)),
  ];
  Widget page(String n){switch(n){case 'Snake':return _Snake();case '2048':return _Twenty();case 'Tetris':return _Tetris();case 'Flappy':return _Flappy();case 'Breakout':return _Breakout();case 'Memory':return _Memory();case 'Pong':return _Pong();case 'Neon Jump':return _Jump();case 'Minesweeper':return _Mines();case 'Simon Says':return _Simon();default:return _ColorStack();}}
  @override Widget build(BuildContext c){final list=games.where((g)=>(filter=='ALL'||g.cat==filter)&&(search.isEmpty||g.name.toLowerCase().contains(search.toLowerCase()))).toList();return Scaffold(backgroundColor:_bg,body:SafeArea(child:ListView(padding:EdgeInsets.fromLTRB(16,14,16,110),children:[
    Container(padding:EdgeInsets.all(20),decoration:BoxDecoration(borderRadius:BorderRadius.circular(30),gradient:LinearGradient(colors:[Color(0xFF27105C),Color(0xFF0C1D38),Color(0xFF090D18)],begin:Alignment.topLeft,end:Alignment.bottomRight),border:Border.all(color:Colors.white10)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Container(width:52,height:52,decoration:BoxDecoration(color:_purple.withOpacity(.18),borderRadius:BorderRadius.circular(17)),child:Icon(Icons.sports_esports_rounded,color:_purple,size:29)),Spacer(),_Pill('ARCADE COLLECTION')]),
      SizedBox(height:20),Text('NEXORA ARCADE',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,letterSpacing:2,color:Colors.white54)),SizedBox(height:4),Text('Play. Beat. Repeat.',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900,letterSpacing:-.8)),SizedBox(height:7),Text('5 polished mini games. Fast sessions. Built for one-more-round energy.',style:TextStyle(color:Colors.white60,height:1.35)),SizedBox(height:18),Row(children:[_Stat('5','GAMES'),SizedBox(width:8),_Stat('2','MODES'),SizedBox(width:8),_Stat('∞','REPLAY')])
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
class _SnakePainter extends CustomPainter{final List<Point<int>> b;final Point<int> f;_SnakePainter(this.b,this.f);void paint(Canvas c,Size s){final cell=s.width/16;final p=Paint();p.color=Colors.white.withOpacity(.025);for(int x=0;x<16;x++)for(int y=0;y<22;y++)c.drawRect(Rect.fromLTWH(x*cell,y*cell,cell-1,cell-1),p);p.color=Color(0xFFFB7185);c.drawCircle(Offset((f.x+.5)*cell,(f.y+.5)*cell),cell*.27,p);for(int i=b.length-1;i>=0;i--){p.color=i==0?Color(0xFF86EFAC):Color(0xFF22C55E).withOpacity(max(.35,1-i*.025));final q=b[i];c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(q.x*cell+2,q.y*cell+2,cell-4,cell-4),Radius.circular(cell*.25)),p);}}bool shouldRepaint(c)=>true;}



class _GameTopBar extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  const _GameTopBar(this.label, this.value, this.accent);
  @override
  Widget build(BuildContext c) => Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.055),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(.07)),
    ),
    child: Row(children: [
      Container(width: 42, height: 42,
        decoration: BoxDecoration(color: accent.withOpacity(.14), borderRadius: BorderRadius.circular(13)),
        child: Icon(Icons.bolt_rounded, color: accent, size: 22)),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
        child: const Text('NEXORA', style: TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 1))),
    ]),
  );
}

class _Twenty extends StatefulWidget {
  const _Twenty();
  @override State<_Twenty> createState() => _TwentyState();
}
class _TwentyState extends State<_Twenty> {
  final r = Random();
  List<int> board = List.filled(16, 0);
  List<int> undoBoard = List.filled(16, 0);
  int score = 0, best = 0, undoScore = 0;
  bool over = false, won = false;
  @override void initState(){super.initState(); reset();}
  void reset(){board=List.filled(16,0);undoBoard=List.filled(16,0);score=0;undoScore=0;over=false;won=false;_spawn();_spawn();}
  void undo(){if(undoBoard.every((v)=>v==0))return;setState((){board=List<int>.from(undoBoard);score=undoScore;undoBoard=List.filled(16,0);over=false;});}
  void _spawn(){
    final empty=[for(int i=0;i<16;i++)if(board[i]==0)i];
    if(empty.isEmpty)return;
    board[empty[r.nextInt(empty.length)]]=r.nextDouble()<.9?2:4;
  }
  List<int> _line(List<int> a){
    final v=a.where((x)=>x!=0).toList(), out=<int>[];
    for(int i=0;i<v.length;i++){
      if(i+1<v.length&&v[i]==v[i+1]){final n=v[i]*2;out.add(n);score+=n;i++;if(n>=2048)won=true;}
      else out.add(v[i]);
    }
    while(out.length<4)out.add(0);
    return out;
  }
  void move(int dx,int dy){
    if(over)return;
    final before=List<int>.from(board); final beforeScore=score;
    final n=List<int>.filled(16,0);
    for(int k=0;k<4;k++){
      final a=<int>[];
      for(int q=0;q<4;q++){
        final x=dx!=0?(dx>0?3-q:q):k;
        final y=dy!=0?(dy>0?3-q:q):k;
        a.add(board[y*4+x]);
      }
      final z=_line(a);
      for(int q=0;q<4;q++){
        final x=dx!=0?(dx>0?3-q:q):k;
        final y=dy!=0?(dy>0?3-q:q):k;
        n[y*4+x]=z[q];
      }
    }
    if(n.toString()!=before.toString()){undoBoard=before;undoScore=beforeScore;board=n;_spawn();best=max(best,score);if(!_canMove(board))over=true;}
    setState((){});
  }
  bool _canMove(List<int>b){
    if(b.contains(0))return true;
    for(int y=0;y<4;y++)for(int x=0;x<4;x++){
      final v=b[y*4+x];
      if(x<3&&b[y*4+x+1]==v)return true;
      if(y<3&&b[(y+1)*4+x]==v)return true;
    }
    return false;
  }
  Color tile(int v){
    if(v==0)return Colors.white.withOpacity(.045);
    final t=min(1.0,log(max(2,v))/log(4096));
    return Color.lerp(const Color(0xFFF59E0B),const Color(0xFF8B5CF6),t)!;
  }
  @override Widget build(BuildContext c)=>_Shell(
    title:'2048',subtitle:'Merge Rush • plan every move',accent:const Color(0xFFF59E0B),
    onReset:()=>setState(reset),
    child:GestureDetector(
      onHorizontalDragEnd:(d)=>move((d.primaryVelocity??0)>0?1:-1,0),
      onVerticalDragEnd:(d)=>move(0,(d.primaryVelocity??0)>0?1:-1),
      child:_World(a:const Color(0xFF20140A),b:const Color(0xFF080A13),
        child:Column(children:[
          _GameTopBar('SCORE  $score','BEST  $best',const Color(0xFFF59E0B)),
          Expanded(child:Center(child:AspectRatio(aspectRatio:1,child:Container(
            margin:const EdgeInsets.all(18),padding:const EdgeInsets.all(9),
            decoration:BoxDecoration(color:Colors.black.withOpacity(.28),borderRadius:BorderRadius.circular(26),
              border:Border.all(color:const Color(0xFFF59E0B).withOpacity(.16)),
              boxShadow:[BoxShadow(color:const Color(0xFFF59E0B).withOpacity(.08),blurRadius:30)]),
            child:GridView.count(crossAxisCount:4,physics:const NeverScrollableScrollPhysics(),crossAxisSpacing:8,mainAxisSpacing:8,
              children:[for(final v in board)AnimatedContainer(duration:const Duration(milliseconds:120),
                decoration:BoxDecoration(color:tile(v),borderRadius:BorderRadius.circular(15),
                  boxShadow:v==0?[]:[BoxShadow(color:tile(v).withOpacity(.18),blurRadius:9)]),
                child:Center(child:Text(v==0?'':v.toString(),style:TextStyle(fontSize:v>=1024?21:26,fontWeight:FontWeight.w900,color:v>=128?Colors.white:Colors.white.withOpacity(.94)))))]),
          )))),
          Padding(padding:const EdgeInsets.fromLTRB(18,0,18,16),child:Row(children:[
            Expanded(child:Row(children:[Expanded(child:Text(won?'2048 REACHED!':over?'NO MORE MOVES':'SWIPE ANY DIRECTION',textAlign:TextAlign.center,
              style:TextStyle(color:won?const Color(0xFF86EFAC):Colors.white38,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1))),
            if(over)FilledButton(onPressed:()=>setState(reset),child:const Text('RETRY')),if(!over)IconButton(onPressed:undo,icon:const Icon(Icons.undo_rounded)),
          ])),
        ])),
      ),
    ),
  );
}

class _Tetromino {
  final List<List<int>> cells;
  final Color color;
  const _Tetromino(this.cells,this.color);
}
class _Tetris extends StatefulWidget {
  const _Tetris();
  @override State<_Tetris> createState()=>_TetrisState();
}
class _TetrisState extends State<_Tetris>{
  final r=Random();
  final board=List<int>.filled(200,0);
  final defs=[
    _Tetromino([[1,1,1,1]],Color(0xFF22D3EE)),
    _Tetromino([[1,1],[1,1]],Color(0xFFFACC15)),
    _Tetromino([[0,1,0],[1,1,1]],Color(0xFFA78BFA)),
    _Tetromino([[1,0,0],[1,1,1]],Color(0xFF60A5FA)),
    _Tetromino([[0,0,1],[1,1,1]],Color(0xFFFB923C)),
    _Tetromino([[0,1,1],[1,1,0]],Color(0xFF4ADE80)),
    _Tetromino([[1,1,0],[0,1,1]],Color(0xFFF87171)),
  ];
  late int current,next;
  late List<List<int>> shape;
  Color color=Colors.white;
  Timer? timer;
  int row=0,col=3,score=0,lines=0,level=1;
  bool running=false,over=false;
  @override void initState(){super.initState();reset();}
  void reset(){timer?.cancel();for(int i=0;i<200;i++)board[i]=0;score=0;lines=0;level=1;running=false;over=false;current=r.nextInt(defs.length);next=r.nextInt(defs.length);_loadPiece();}
  void _loadPiece(){activeKind=current;shape=defs[activeKind].cells.map((e)=>List<int>.from(e)).toList();color=defs[activeKind].color;row=0;col=3;current=next;next=r.nextInt(defs.length);}
  bool can(int nr,int nc,List<List<int>> s){
    for(int y=0;y<s.length;y++)for(int x=0;x<s[y].length;x++)if(s[y][x]!=0){
      final xx=nc+x,yy=nr+y;if(xx<0||xx>=10||yy>=20||(yy>=0&&board[yy*10+xx]!=0))return false;
    } return true;
  }
  void rotate(){
    final h=shape.length,w=shape[0].length;final out=List.generate(w,(_)=>List<int>.filled(h,0));
    for(int y=0;y<h;y++)for(int x=0;x<w;x++)out[x][h-1-y]=shape[y][x];
    if(can(row,col,out)){shape=out;setState((){});}
  }
  void start(){if(running||over)return;running=true;_clock();setState((){});}
  void _clock(){timer?.cancel();timer=Timer.periodic(Duration(milliseconds:max(110,520-level*42)),(_)=>tick());}
  void tick(){if(!mounted)return;if(can(row+1,col,shape)){row++;setState((){});return;}lock();}
  void softDrop(){if(!running){start();return;}if(can(row+1,col,shape)){row++;score++;setState((){});}else lock();}
  void lock(){
    for(int y=0;y<shape.length;y++)for(int x=0;x<shape[y].length;x++)if(shape[y][x]!=0){
      final yy=row+y,xx=col+x;if(yy>=0)board[yy*10+xx]=activeKind+1;
    }
    int cleared=0;
    for(int y=19;y>=0;y--){if(List.generate(10,(x)=>board[y*10+x]).every((v)=>v!=0)){
      for(int yy=y;yy>0;yy--)for(int x=0;x<10;x++)board[yy*10+x]=board[(yy-1)*10+x];
      for(int x=0;x<10;x++)board[x]=0;cleared++;y++;
    }}
    if(cleared>0){lines+=cleared;score+=cleared*cleared*100*level;level=1+(lines~/10);_clock();}
    _loadPiece();
    if(!can(row,col,shape)){running=false;over=true;timer?.cancel();}
    setState((){});
  }
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext c)=>_Shell(title:'Tetris',subtitle:'Drop Zone • level $level',accent:const Color(0xFFA78BFA),onReset:()=>setState(reset),child:
    GestureDetector(
      onHorizontalDragUpdate:(d){if(!running)return;if(d.delta.dx>2&&can(row,col+1,shape))col++;if(d.delta.dx<-2&&can(row,col-1,shape))col--;setState((){});},
      onVerticalDragUpdate:(d){if(d.delta.dy>7)softDrop();},
      onTap:rotate,
      child:_World(a:const Color(0xFF17112A),b:const Color(0xFF070914),child:Column(children:[
        Padding(padding:const EdgeInsets.fromLTRB(16,8,16,10),child:Row(children:[
          Expanded(child:_GameTopBar('SCORE  $score','LINES  $lines',const Color(0xFFA78BFA))),
          const SizedBox(width:0),
        ])),
        Expanded(child:Center(child:AspectRatio(aspectRatio:.52,child:Container(
          margin:const EdgeInsets.symmetric(horizontal:22,vertical:4),padding:const EdgeInsets.all(5),
          decoration:BoxDecoration(color:Colors.black.withOpacity(.32),borderRadius:BorderRadius.circular(20),border:Border.all(color:const Color(0xFFA78BFA).withOpacity(.22))),
          child:CustomPaint(painter:_TetrisPainter(board,shape,row,col,color,defs[next].color)),
        )))),
        Padding(padding:const EdgeInsets.fromLTRB(18,5,18,14),child:Row(children:[
          Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:10),decoration:BoxDecoration(color:Colors.white.withOpacity(.05),borderRadius:BorderRadius.circular(14)),
            child:Text('NEXT',style:const TextStyle(fontSize:9,color:Colors.white38,fontWeight:FontWeight.w900))),
          const Spacer(),
          FilledButton(onPressed:over?()=>setState(reset):start,child:Text(over?'PLAY AGAIN':(running?'DROP':'START'))),
        ])),
      ])),
    ));
}
class _TetrisPainter extends CustomPainter{
  final List<int>b;final List<List<int>>s;final int row,col;final Color color,next;
  _TetrisPainter(this.b,this.s,this.row,this.col,this.color,this.next);
  @override void paint(Canvas c,Size z){
    final cell=z.width/10,p=Paint()..style=PaintingStyle.fill;
    for(int y=0;y<20;y++)for(int x=0;x<10;x++){
      p.color=Colors.white.withOpacity(.025);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x*cell+1,y*cell+1,cell-2,cell-2),const Radius.circular(4)),p);
      final v=b[y*10+x];if(v>0){p.color=_blockColor(v);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x*cell+2,y*cell+2,cell-4,cell-4),const Radius.circular(5)),p);}
    }
    p.color=color;
    for(int y=0;y<s.length;y++)for(int x=0;x<s[y].length;x++)if(s[y][x]!=0){
      final xx=col+x,yy=row+y;if(yy>=0)c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(xx*cell+2,yy*cell+2,cell-4,cell-4),const Radius.circular(5)),p);
    }
  }
  Color _blockColor(int v)=>[Colors.transparent,const Color(0xFF22D3EE),const Color(0xFFFACC15),const Color(0xFFA78BFA),const Color(0xFF60A5FA),const Color(0xFFFB923C),const Color(0xFF4ADE80),const Color(0xFFF87171)][v];
  @override bool shouldRepaint(c)=>true;
}

class _Flappy extends StatefulWidget{const _Flappy();@override State<_Flappy> createState()=>_FlappyState();}
class _FlappyState extends State<_Flappy>{
  double y=.45,vy=0,pipeX=1.08,gap=.48;Timer?timer;int score=0,best=0;bool running=false,over=false;final r=Random();
  void flap(){if(!running){if(over)reset();running=true;timer=Timer.periodic(const Duration(milliseconds:28),tick);}vy=-.030;setState((){});}
  void tick(Timer t){y+=vy;vy+=.00165;pipeX-=.0105;
    if(pipeX<-.18){pipeX=1.05;gap=.27+r.nextDouble()*.45;score++;best=max(best,score);}
    if(y<.035||y>.965||(pipeX<.21&&pipeX>.01&&(y<gap-.18||y>gap+.18))){running=false;over=true;t.cancel();}
    if(mounted)setState((){});
  }
  void reset(){timer?.cancel();y=.45;vy=0;pipeX=1.08;gap=.48;score=0;running=false;over=false;}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext c)=>_Shell(title:'Flappy',subtitle:'Sky Dash • tap to fly',accent:const Color(0xFF22D3EE),onReset:()=>setState(reset),child:
    GestureDetector(onTap:flap,child:_World(a:const Color(0xFF071C35),b:const Color(0xFF0C4A4E),child:Stack(children:[
      CustomPaint(size:Size.infinite,painter:_FlappyPainter(y,pipeX,gap,score)),
      Positioned(top:16,left:0,right:0,child:Column(children:[
        Text('$score',style:const TextStyle(fontSize:44,fontWeight:FontWeight.w900,shadows:[Shadow(blurRadius:16)])),
        Text('BEST $best',style:const TextStyle(fontSize:10,color:Colors.white54,fontWeight:FontWeight.w900,letterSpacing:2)),
      ])),
      if(!running)Center(child:Container(padding:const EdgeInsets.fromLTRB(24,20,24,18),decoration:BoxDecoration(color:Colors.black.withOpacity(.35),borderRadius:BorderRadius.circular(24),border:Border.all(color:Colors.white12)),child:Column(mainAxisSize:MainAxisSize.min,children:[
        Icon(Icons.flutter_dash_rounded,color:const Color(0xFFFDE047),size:54),const SizedBox(height:8),
        Text(over?'TRY AGAIN':'SKY DASH',style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900)),
        const SizedBox(height:6),const Text('TAP • FLY • PASS THE GATES',style:TextStyle(color:Colors.white54,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1)),
      ])),
    ])));
}
class _FlappyPainter extends CustomPainter{
  final double y,x,g;final int score;_FlappyPainter(this.y,this.x,this.g,this.score);
  @override void paint(Canvas c,Size s){
    final p=Paint();
    p.color=Colors.white.withOpacity(.07);
    for(int i=0;i<9;i++){final xx=(i*103+score*17)%s.width;c.drawCircle(Offset(xx,70+(i*61)%s.height),2,p);}
    p.color=const Color(0xFF164E63);for(int i=0;i<5;i++)c.drawCircle(Offset(i*s.width/4,s.height*.88),s.width*.20,p);
    final px=x*s.width,top=(g-.18)*s.height,bottom=(g+.18)*s.height;
    p.color=const Color(0xFF0EA5E9);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(px,0,54,top),const Radius.circular(12)),p);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(px,bottom,54,s.height-bottom),const Radius.circular(12)),p);
    p.color=const Color(0xFF67E8F9);c.drawRect(Rect.fromLTWH(px-4,max(0,top-10),62,10),p);c.drawRect(Rect.fromLTWH(px-4,bottom,62,10),p);
    final by=y*s.height;p.color=const Color(0xFFFDE047);c.drawCircle(Offset(s.width*.19,by),18,p);
    p.color=Colors.white;c.drawCircle(Offset(s.width*.20,by-5),4,p);p.color=Colors.black;c.drawCircle(Offset(s.width*.20,by-5),2,p);
    p.color=const Color(0xFFF59E0B);c.drawOval(Rect.fromCenter(center:Offset(s.width*.19+17,by+4),width:18,height:8),p);
  }
  @override bool shouldRepaint(c)=>true;
}

class _Breakout extends StatefulWidget{const _Breakout();@override State<_Breakout> createState()=>_BreakoutState();}
class _BreakoutState extends State<_Breakout>{
  double bx=.5,by=.78,vx=.009,vy=-.014,paddle=.5,powerX=-1,powerY=-1;Timer?timer;int score=0,lives=3,combo=0;bool running=false,over=false;
  final blocks=List<int>.filled(48,1);
  void start(){if(running||over)return;running=true;timer=Timer.periodic(const Duration(milliseconds:20),tick);setState((){});}
  void tick(Timer t){
    bx+=vx;by+=vy;
    if(bx<.025||bx>.975){vx=-vx;bx=bx.clamp(.025,.975);}
    if(by<.05){vy=vy.abs();by=.05;}
    if(by>.88&&by<.96&&(bx-paddle).abs()<.15&&vy>0){vy=-vy.abs();combo++;}
    final col=(bx*8).floor().clamp(0,7),row=((by-.09)/.055).floor().clamp(0,5),i=row*8+col;
    if(by>.08&&by<.43&&blocks[i]>0){blocks[i]=0;score+=10+combo*2;combo++;vy=-vy;if(Random().nextDouble()<.12){powerX=bx;powerY=by;}}
    if(powerY>=0){powerY+=.008;if(powerY>.90){powerY=-1;}else if((powerX-paddle).abs()<.16&&powerY>.84){lives=min(5,lives+1);powerY=-1;}}
    if(by>1.03){lives--;combo=0;bx=.5;by=.78;vx=(vx.sign==0?1:vx.sign)*.009;vy=-.014;if(lives<=0){over=true;running=false;t.cancel();}}
    if(blocks.every((v)=>v==0)){over=true;running=false;t.cancel();}
    if(mounted)setState((){});
  }
  void reset(){timer?.cancel();for(int i=0;i<48;i++)blocks[i]=1;bx=.5;by=.78;vx=.009;vy=-.014;paddle=.5;score=0;lives=3;combo=0;running=false;over=false;}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext c)=>_Shell(title:'Breakout',subtitle:'Brick Rush • combo x$combo',accent:const Color(0xFFEF4444),onReset:()=>setState(reset),child:
    GestureDetector(onTap:start,onHorizontalDragUpdate:(d){paddle=(paddle+d.delta.dx/MediaQuery.sizeOf(c).width).clamp(.12,.88);setState((){});},
      child:_World(a:const Color(0xFF1A0A12),b:const Color(0xFF070914),child:Stack(children:[
        CustomPaint(size:Size.infinite,painter:_BreakoutPainter(blocks,bx,by,paddle,powerX,powerY)),
        Positioned(top:16,left:16,right:16,child:Row(children:[
          Text('SCORE $score',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12)),
          const Spacer(),Text('♥ $lives',style:const TextStyle(color:Color(0xFFFCA5A5),fontWeight:FontWeight.w900)),
        ])),
        if(!running)Center(child:Text(over?(lives==0?'GAME OVER':'CLEARED!'):'DRAG • TAP START',style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900,letterSpacing:1))),
      ])));
}
class _BreakoutPainter extends CustomPainter{
  final List<int>b;final double x,y,paddle,powerX,powerY;_BreakoutPainter(this.b,this.x,this.y,this.paddle,this.powerX,this.powerY);
  @override void paint(Canvas c,Size s){
    final p=Paint();final colors=[const Color(0xFFF87171),const Color(0xFFFB923C),const Color(0xFFFACC15),const Color(0xFF4ADE80),const Color(0xFF22D3EE),const Color(0xFFA78BFA)];
    for(int r=0;r<6;r++)for(int col=0;col<8;col++)if(b[r*8+col]>0){
      p.color=colors[r];final rect=Rect.fromLTWH(col*s.width/8+4,55+r*31,s.width/8-8,24);
      c.drawRRect(RRect.fromRectAndRadius(rect,const Radius.circular(7)),p);
      p.color=Colors.white.withOpacity(.18);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rect.left+3,rect.top+3,rect.width-6,5),const Radius.circular(3)),p);
    }
    p.color=Colors.white.withOpacity(.92);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH((paddle-.13)*s.width,s.height*.91,.26*s.width,13),const Radius.circular(8)),p);
    p.color=const Color(0xFFFCA5A5);c.drawCircle(Offset(x*s.width,y*s.height),8,p);
    if(powerY>=0){p.color=const Color(0xFF4ADE80);c.drawCircle(Offset(powerX*s.width,powerY*s.height),11,p);p.color=Colors.black54;c.drawCircle(Offset(powerX*s.width,powerY*s.height),4,p);}
  }
  @override bool shouldRepaint(c)=>true;
}

class _Memory extends StatefulWidget{const _Memory();@override State<_Memory> createState()=>_MemoryState();}
class _MemoryState extends State<_Memory>{
  final r=Random();late List<int>cards;List<int>open=[];Set<int>matched={};int moves=0,streak=0,bestStreak=0;bool locked=false;
  final icons=[Icons.bolt_rounded,Icons.star_rounded,Icons.hexagon_rounded,Icons.favorite_rounded,Icons.diamond_rounded,Icons.bubble_chart_rounded,Icons.rocket_launch_rounded,Icons.local_fire_department_rounded];
  final colors=[const Color(0xFF22D3EE),const Color(0xFFF59E0B),const Color(0xFFA78BFA),const Color(0xFFEC4899),const Color(0xFF34D399),const Color(0xFFFB7185),const Color(0xFF60A5FA),const Color(0xFFF97316)];
  @override void initState(){super.initState();reset();}
  void reset(){cards=[for(int i=0;i<8;i++)... [i,i]]..shuffle(r);open=[];matched={};moves=0;streak=0;bestStreak=0;locked=false;}
  void tap(int i){
    if(locked||open.contains(i)||matched.contains(i))return;
    setState((){open.add(i);if(open.length==2){
      locked=true;moves++;final a=open[0],b=open[1];
      Future.delayed(const Duration(milliseconds:550),(){if(!mounted)return;setState((){
        if(cards[a]==cards[b]){matched.addAll([a,b]);streak++;bestStreak=max(bestStreak,streak);}
        else streak=0;open=[];locked=false;
      });});
    }});
  }
  @override Widget build(BuildContext c)=>_Shell(title:'Memory',subtitle:'Match Lab • remember the pattern',accent:const Color(0xFFEC4899),onReset:()=>setState(reset),child:
    _World(a:const Color(0xFF180B1C),b:const Color(0xFF070914),child:Column(children:[
      _GameTopBar('MOVES  $moves','STREAK  $streak',const Color(0xFFEC4899)),
      Expanded(child:GridView.builder(
        padding:const EdgeInsets.fromLTRB(18,4,18,18),itemCount:cards.length,
        gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:4,crossAxisSpacing:10,mainAxisSpacing:10),
        itemBuilder:(_,i){
          final show=open.contains(i)||matched.contains(i),col=colors[cards[i]];
          return GestureDetector(onTap:()=>tap(i),child:AnimatedContainer(duration:const Duration(milliseconds:180),
            decoration:BoxDecoration(
              gradient:show?LinearGradient(colors:[col.withOpacity(.28),col.withOpacity(.08)],begin:Alignment.topLeft,end:Alignment.bottomRight):null,
              color:show?null:Colors.white.withOpacity(.055),borderRadius:BorderRadius.circular(18),
              border:Border.all(color:show?col.withOpacity(.72):Colors.white.withOpacity(.08)),
              boxShadow:show?[BoxShadow(color:col.withOpacity(.16),blurRadius:14)]:[]),
            child:Center(child:AnimatedSwitcher(duration:const Duration(milliseconds:150),child:show?Icon(icons[cards[i]],key:ValueKey(cards[i]),color:col,size:32):const Icon(Icons.question_mark_rounded,key:ValueKey('q'),color:Colors.white24,size:24)))));
        },
      )),
      if(matched.length==cards.length)Padding(padding:const EdgeInsets.fromLTRB(18,0,18,16),child:FilledButton(onPressed:()=>setState(reset),child:const Text('PLAY AGAIN'))),
    ]));
}

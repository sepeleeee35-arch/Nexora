// ignore_for_file: prefer_interpolation_to_compose_strings, curly_braces_in_flow_control_structures, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? nexoraActiveAccountId;

const _hubPurple = Color(0xFF8B5CF6);

class NexoraGameHub extends StatefulWidget {
  const NexoraGameHub({super.key});
  @override
  State<NexoraGameHub> createState() => _NexoraGameHubState();
}

class _NexoraGameHubState extends State<NexoraGameHub> {
  String search = '';
  String filter = 'ALL';

  static const games = <_GameInfo>[
    _GameInfo('Snake', 'ARCADE', Icons.straighten_rounded, Color(0xFF22C55E), 'Grow, eat and survive.'),
    _GameInfo('2048', 'PUZZLE', Icons.grid_4x4_rounded, Color(0xFFF59E0B), 'Merge tiles to reach 2048.'),
    _GameInfo('Tetris', 'ARCADE', Icons.view_module_rounded, Color(0xFF8B5CF6), 'Clear lines with falling blocks.'),
    _GameInfo('Flappy', 'ARCADE', Icons.flutter_dash_rounded, Color(0xFF06B6D4), 'Fly through every gap.'),
    _GameInfo('Breakout', 'ARCADE', Icons.sports_baseball_rounded, Color(0xFFEF4444), 'Break every brick.'),
    _GameInfo('Memory', 'PUZZLE', Icons.style_rounded, Color(0xFFEC4899), 'Find all matching pairs.'),
    _GameInfo('Pong', 'SPORT', Icons.sports_tennis_rounded, Color(0xFF3B82F6), 'Beat the CPU to 7.'),
    _GameInfo('Neon Jump', 'ARCADE', Icons.bolt_rounded, Color(0xFFA855F7), 'Jump, dodge and chase a high score.'),
    _GameInfo('Minesweeper', 'PUZZLE', Icons.warning_amber_rounded, Color(0xFFF97316), 'Open safe cells.'),
    _GameInfo('Simon Says', 'PUZZLE', Icons.psychology_rounded, Color(0xFF14B8A6), 'Remember the color sequence.'),
    _GameInfo('Color Stack', 'PUZZLE', Icons.water_drop_rounded, Color(0xFF7C3AED), 'Sortir cairan warna dalam botol.'),
  ];

  Widget _gamePage(String name) {
    switch (name) {
      case 'Snake': return const _SnakeGame();
      case '2048': return const _TwentyFortyEightGame();
      case 'Tetris': return const _TetrisGame();
      case 'Flappy': return const _FlappyGame();
      case 'Breakout': return const _BreakoutGame();
      case 'Memory': return const _MemoryGame();
      case 'Pong': return const _PongGame();
      case 'Color Stack': return const _ColorStackGame();
      case 'Neon Jump': return const NeonJumpPage();
      case 'Minesweeper': return const _MinesGame();
      default: return const _SimonGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = search.trim().toLowerCase();
    final filtered = games.where((game) {
      final categoryOk = filter == 'ALL' || game.category == filter;
      final queryOk = q.isEmpty || game.name.toLowerCase().contains(q);
      return categoryOk && queryOk;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 110),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4C1D95), Color(0xFF172554), Color(0xFF07111F)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.sports_esports_rounded, size: 28),
                ),
                const Spacer(),
                const _HubTag('11 GAMES'),
              ]),
              const SizedBox(height: 16),
              const Text('NEXORA GAME HUB', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.8, color: Colors.white70)),
              const SizedBox(height: 5),
              const Text('Play. Beat. Repeat.', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              const Text('11 mini game original Nexora. Offline dan langsung dimainkan.', style: TextStyle(color: Colors.white70, height: 1.35)),
              const SizedBox(height: 17),
              Row(children: [
                _HubStat('ARCADE', '5'), const SizedBox(width: 8),
                _HubStat('PUZZLE', '5'), const SizedBox(width: 8),
                _HubStat('SPORT', '1'),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          onChanged: (value) => setState(() => search = value),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: 'Cari game...',
            filled: true,
            fillColor: const Color(0xFF111522),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final category in const ['ALL', 'ARCADE', 'PUZZLE', 'SPORT'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: filter == category,
                    onSelected: (_) => setState(() => filter = category),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          const Expanded(child: Text('All Games', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
          Text(filtered.length.toString() + ' tersedia', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            final game = filtered[index];
            return _HubGameCard(
              info: game,
              onPlay: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => _gamePage(game.name)),
              ),
            );
          },
        ),
      const SizedBox(height: 24),
      const Text('NEXORA ORIGINALS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      const Text('Game lama yang dikembalikan ke Nexora.', style: TextStyle(color: Colors.white54)),
      const SizedBox(height: 10),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.8,
        children: [
          _OriginalCard('Worm Arena','Classic cacing',Icons.track_changes_rounded,()=>const WormArenaPage()),
          _OriginalCard('Nexora Chess','Classic chess',Icons.grid_3x3_rounded,()=>const NexoraChessPage()),
          _OriginalCard('Road Rush','Endless driving',Icons.directions_car_rounded,()=>const RoadRushPage()),
          _OriginalCard('Brick Smash','Brick arcade',Icons.view_comfy_alt_rounded,()=>const BrickSmashPage()),
          _OriginalCard('Flap Orbit','Arcade flyer',Icons.flight_takeoff_rounded,()=>const FlapOrbitPage()),
          _OriginalCard('Maze Escape','Find the exit',Icons.route_rounded,()=>const MazeEscapePage()),
          _OriginalCard('Reaction Rush','React fast',Icons.flash_on_rounded,()=>const ReactionRushPage()),
          _OriginalCard('Color Clash','Match colors',Icons.palette_rounded,()=>const ColorClashPage()),
          _OriginalCard('Number Sprint','Number reflex',Icons.numbers_rounded,()=>const NumberSprintPage()),
          _OriginalCard('Dodge Zone','Dodge obstacles',Icons.shield_rounded,()=>const DodgeZonePage()),
        ],
      ),
      ],
    );
  }
}


class _OriginalCard extends StatelessWidget {
  final String title,subtitle;final IconData icon;final Widget Function() page;
  const _OriginalCard(this.title,this.subtitle,this.icon,this.page);
  @override Widget build(BuildContext context)=>Card(
    child:InkWell(onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>page())),borderRadius:BorderRadius.circular(18),
      child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[
        CircleAvatar(child:Icon(icon,size:19)),const SizedBox(width:10),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[
          Text(title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w900)),
          Text(subtitle,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:10,color:Colors.white54)),
        ])),
        const Icon(Icons.play_circle_fill_rounded,size:22),
      ])),
    ),
  );
}

class _GameInfo {
  final String name, category, subtitle;
  final IconData icon;
  final Color color;
  const _GameInfo(this.name, this.category, this.icon, this.color, this.subtitle);
}

class _HubTag extends StatelessWidget {
  final String text;
  const _HubTag(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white12),
    ),
    child: Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
  );
}

class _HubStat extends StatelessWidget {
  final String title, value;
  const _HubStat(this.title, this.value);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 8, color: Colors.white60, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
      ]),
    ),
  );
}

class _HubGameCard extends StatelessWidget {
  final _GameInfo info;
  final VoidCallback onPlay;
  const _HubGameCard({required this.info, required this.onPlay});
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onPlay,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [info.color.withValues(alpha: 0.78), const Color(0xFF111522)],
              ),
            ),
            child: Stack(children: [
              Positioned(right: -16, top: -16, child: Icon(info.icon, size: 96, color: Colors.white.withValues(alpha: 0.08))),
              Center(child: Icon(info.icon, size: 52)),
              Positioned(left: 10, top: 10, child: _HubTag(info.category)),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(info.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(info.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.white60)),
            const SizedBox(height: 9),
            SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: onPlay,
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('PLAY'),
            )),
          ]),
        ),
      ]),
    ),
  );
}

class _GameShell extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback restart;
  const _GameShell({required this.title, required this.child, required this.restart});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      actions: [IconButton(onPressed: restart, tooltip: 'Restart', icon: const Icon(Icons.refresh_rounded))],
    ),
    body: child,
  );
}

class _GameStart extends StatelessWidget {
  final String title, description, details;
  final VoidCallback start;
  const _GameStart({required this.title, required this.description, required this.details, required this.start});
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.all(22),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF111522), borderRadius: BorderRadius.circular(26), border: Border.all(color: Colors.white12)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.sports_esports_rounded, size: 54),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, height: 1.35)),
        const SizedBox(height: 10),
        Text(details, style: const TextStyle(color: _hubPurple, fontWeight: FontWeight.w800)),
        const SizedBox(height: 19),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: start,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('START GAME'),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
        )),
      ]),
    ),
  );
}

class _GameOver extends StatelessWidget {
  final String title;
  final int score;
  final VoidCallback restart;
  const _GameOver({required this.title, required this.score, required this.restart});
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF111522), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.emoji_events_rounded, size: 44),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text('Score ' + score.toString(), style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 15),
        FilledButton.icon(onPressed: restart, icon: const Icon(Icons.refresh_rounded), label: const Text('Main Lagi')),
      ]),
    ),
  );
}

// 1 Snake
class _SnakeGame extends StatefulWidget {
  const _SnakeGame();
  @override State<_SnakeGame> createState()=>_SnakeGameState();
}
class _SnakeGameState extends State<_SnakeGame>{
  static const rows=18,cols=12;
  Timer? _tm; final Random _r=Random();
  List<Point<int>> _snake=[]; Point<int> _food=const Point(5,5);
  Point<int> _dir=const Point(1,0),_next=const Point(1,0);
  int _score=0; bool _run=false,_over=false,_paused=false;

  @override void initState(){super.initState();_resetBoard();}
  void _resetBoard(){_snake=[const Point(6,9),const Point(5,9),const Point(4,9)];_placeFood();}
  void _placeFood(){do{_food=Point(_r.nextInt(cols),_r.nextInt(rows));}while(_snake.contains(_food));}
  void _start(){_tm?.cancel();setState((){_resetBoard();_score=0;_run=true;_over=false;_paused=false;_dir=const Point(1,0);_next=_dir;});_tm=Timer.periodic(const Duration(milliseconds:170),(_)=>_tick());}
  void _tick(){if(!mounted||!_run||_over||_paused)return;setState((){
    _dir=_next;final h=_snake.first;var nx=h.x+_dir.x,ny=h.y+_dir.y;
    // Wrap at the edge: only hitting the snake's own body ends the run.
    if(nx<0)nx=cols-1;if(nx>=cols)nx=0;if(ny<0)ny=rows-1;if(ny>=rows)ny=0;
    final n=Point(nx,ny);final grows=n==_food;
    final body=grows?_snake:_snake.sublist(0,_snake.length-1);
    if(body.contains(n)){_over=true;_tm?.cancel();return;}
    _snake=[n,..._snake];
    if(grows){_score++;_placeFood();}else{_snake.removeLast();}
  });}
  void _move(Point<int>d){if(!_run||_over)return;if(d.x+_dir.x==0&&d.y+_dir.y==0)return;_next=d;}
  void _restart(){_tm?.cancel();setState((){_run=false;_over=false;_paused=false;_score=0;_resetBoard();});}
  @override void dispose(){_tm?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_GameShell(title:'Snake',restart:_restart,child:Stack(children:[
    if(!_run)Positioned.fill(child:_GameStart(title:'Snake',description:'Makan makanan, tumbuh, dan jangan menabrak buntut sendiri. Tepi layar menyambung ke sisi lain.',details:'SLOWER • WRAP AROUND',start:_start)),
    if(_run)Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(14,10,14,6),child:Row(children:[Text('SCORE '+_score.toString(),style:const TextStyle(fontWeight:FontWeight.w900)),const Spacer(),IconButton(onPressed:()=>setState(()=>_paused=!_paused),icon:Icon(_paused?Icons.play_arrow_rounded:Icons.pause_rounded))])),
      Expanded(child:Center(child:AspectRatio(aspectRatio:cols/rows,child:GestureDetector(
        onHorizontalDragEnd:(d){final v=d.primaryVelocity??0;if(v.abs()>20)_move(Point(v>0?1:-1,0));},
        onVerticalDragEnd:(d){final v=d.primaryVelocity??0;if(v.abs()>20)_move(Point(0,v>0?1:-1));},
        child:CustomPaint(painter:_SnakePainter(_snake,_food,rows,cols)),
      )))),
      Padding(padding:const EdgeInsets.only(bottom:12),child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
        IconButton.filledTonal(onPressed:()=>_move(const Point(-1,0)),icon:const Icon(Icons.arrow_back_rounded)),
        const SizedBox(width:12),
        IconButton.filledTonal(onPressed:()=>_move(const Point(0,-1)),icon:const Icon(Icons.arrow_upward_rounded)),
        const SizedBox(width:12),
        IconButton.filledTonal(onPressed:()=>_move(const Point(0,1)),icon:const Icon(Icons.arrow_downward_rounded)),
        const SizedBox(width:12),
        IconButton.filledTonal(onPressed:()=>_move(const Point(1,0)),icon:const Icon(Icons.arrow_forward_rounded)),
      ])),
    ]),
    if(_over)Positioned.fill(child:_GameOver(title:'BODY HIT',score:_score,restart:_restart)),
  ]));
}
class _SnakePainter extends CustomPainter{
  final List<Point<int>> snake;final Point<int> food;final int rows,cols;
  _SnakePainter(this.snake,this.food,this.rows,this.cols);
  @override void paint(Canvas c,Size s){
    c.drawRect(Offset.zero&s,Paint()..color=const Color(0xFF07130D));
    final cw=s.width/cols,ch=s.height/rows;
    final grid=Paint()..color=Colors.white.withValues(alpha:.035)..style=PaintingStyle.stroke;
    for(int x=0;x<=cols;x++)c.drawLine(Offset(x*cw,0),Offset(x*cw,s.height),grid);
    for(int y=0;y<=rows;y++)c.drawLine(Offset(0,y*ch),Offset(s.width,y*ch),grid);
    final fp=Paint()..color=Colors.orangeAccent;
    c.drawCircle(Offset((food.x+.5)*cw,(food.y+.5)*ch),cw*.30,fp);
    for(int i=snake.length-1;i>=0;i--){final p=snake[i];final pp=Paint()..color=i==0?Colors.greenAccent:Colors.green.shade700;
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(p.x*cw+2,p.y*ch+2,cw-4,ch-4),const Radius.circular(6)),pp);}
  }
  @override bool shouldRepaint(covariant _SnakePainter old)=>true;
}

// 2 2048
class _TwentyFortyEightGame extends StatefulWidget { const _TwentyFortyEightGame(); @override State<_TwentyFortyEightGame> createState()=>_TwentyFortyEightState(); }
class _TwentyFortyEightState extends State<_TwentyFortyEightGame>{
  final Random _r=Random();List<int> _b=List<int>.filled(16,0);int _score=0;bool _run=false,_over=false;
  void _add(){final e=[for(var i=0;i<16;i++)if(_b[i]==0)i];if(e.isNotEmpty){_b[e[_r.nextInt(e.length)]]=_r.nextDouble()<.9?2:4;}}
  void _start(){setState((){_b=List<int>.filled(16,0);_score=0;_run=true;_over=false;_add();_add();});}
  List<int> _merge(List<int> a){final v=a.where((x)=>x>0).toList();final o=<int>[];var i=0;while(i<v.length){if(i+1<v.length&&v[i]==v[i+1]){final n=v[i]*2;_score+=n;o.add(n);i+=2;}else{o.add(v[i]);i++;}}while(o.length<4)o.add(0);return o;}
  bool _can(){if(_b.contains(0))return true;for(var y=0;y<4;y++)for(var x=0;x<4;x++){final v=_b[y*4+x];if(x<3&&v==_b[y*4+x+1])return true;if(y<3&&v==_b[(y+1)*4+x])return true;}return false;}
  void _move(int dr,int dc){if(!_run||_over)return;final before=_b.toString();if(dr==0){for(var y=0;y<4;y++){final a=[for(var x=0;x<4;x++)_b[y*4+x]],m=_merge(dc<0?a:a.reversed.toList()),o=dc<0?m:m.reversed.toList();for(var x=0;x<4;x++)_b[y*4+x]=o[x];}}else{for(var x=0;x<4;x++){final a=[for(var y=0;y<4;y++)_b[y*4+x]],m=_merge(dr<0?a:a.reversed.toList()),o=dr<0?m:m.reversed.toList();for(var y=0;y<4;y++)_b[y*4+x]=o[y];}}if(before!=_b.toString()){_add();setState(()=>_over=!_can());}}
  void _restart(){setState((){_run=false;_over=false;_score=0;_b=List<int>.filled(16,0);});}
  @override
  Widget build(BuildContext context) {
    return _GameShell(
      title: '2048',
      restart: _restart,
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v.abs() > 30) _move(0, v > 0 ? 1 : -1);
        },
        onVerticalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v.abs() > 30) _move(v > 0 ? 1 : -1, 0);
        },
        child: Stack(
          children: [
            if (!_run)
              Positioned.fill(
                child: _GameStart(
                  title: '2048',
                  description: 'Geser ubin dan gabungkan angka.',
                  details: 'ENDLESS • PUZZLE',
                  start: _start,
                ),
              ),
            if (_run)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('SCORE ' + _score.toString(), style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: GridView.builder(
                            itemCount: 16,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemBuilder: (_, index) => Container(
                              decoration: BoxDecoration(
                                color: _b[index] == 0 ? const Color(0xFF1A1E2A) : _hubPurple,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  _b[index] == 0 ? '' : _b[index].toString(),
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_over)
              Positioned.fill(
                child: _GameOver(title: 'GAME OVER', score: _score, restart: _restart),
              ),
          ],
        ),
      ),
    );
  }
}

// 3 Tetris
class _TetrisGame extends StatefulWidget { const _TetrisGame(); @override State<_TetrisGame> createState()=>_TetrisGameState(); }
class _TetrisGameState extends State<_TetrisGame>{
  Timer? _tm;final Random _r=Random();List<List<int>> _g=List.generate(20,(_)=>List<int>.filled(10,0));
  List<Point<int>> _p=const [Point(0,0),Point(1,0),Point(0,1),Point(1,1)];int _x=3,_y=0,_rot=0,_score=0,_type=0;bool _run=false,_over=false,_paused=false;
  static const pieces=<List<Point<int>>>[
    [Point(0,0),Point(1,0),Point(2,0),Point(3,0)], // I
    [Point(0,0),Point(1,0),Point(0,1),Point(1,1)], // O
    [Point(0,0),Point(-1,1),Point(0,1),Point(1,1)], // T
    [Point(0,0),Point(0,1),Point(0,2),Point(1,2)], // L
    [Point(1,0),Point(1,1),Point(1,2),Point(0,2)], // J
    [Point(0,1),Point(1,1),Point(1,0),Point(2,0)], // S
    [Point(0,0),Point(1,0),Point(1,1),Point(2,1)], // Z
  ];
  List<Point<int>> _cells([int? xx,int? yy,int? rr]){final x=xx??_x,y=yy??_y,r=rr??_rot;return _p.map((q){var a=q.x,b=q.y;for(int i=0;i<r%4;i++){final t=a;a=-b;b=t;}return Point(x+a,y+b);}).toList();}
  bool _hit(int xx,int yy,int rr){for(final p in _cells(xx,yy,rr)){if(p.x<0||p.x>=10||p.y>=20)return true;if(p.y>=0&&_g[p.y][p.x]!=0)return true;}return false;}
  void _newPiece(){_type=_r.nextInt(pieces.length);_p=pieces[_type];_x=3;_y=0;_rot=0;if(_hit(_x,_y,_rot)){_over=true;_tm?.cancel();}}
  void _lock(){for(final p in _cells()){if(p.y>=0)_g[p.y][p.x]=_type+1;}for(int r=19;r>=0;r--)if(_g[r].every((v)=>v!=0)){_g.removeAt(r);_g.insert(0,List<int>.filled(10,0));_score+=100;r++;}_newPiece();}
  void _drop(){if(!_hit(_x,_y+1,_rot))_y++;else _lock();}
  void _start(){_tm?.cancel();_g=List.generate(20,(_)=>List<int>.filled(10,0));_score=0;_run=true;_over=false;_paused=false;_newPiece();setState((){});_tm=Timer.periodic(const Duration(milliseconds:420),(_){if(mounted&&!_paused&&!_over)setState(_drop);});}
  void _move(int dx){if(_run&&!_over&&!_hit(_x+dx,_y,_rot))setState(()=>_x+=dx);}
  void _rotate(){if(!_run||_over)return;final nr=(_rot+1)%4;if(!_hit(_x,_y,nr))setState(()=>_rot=nr);}
  void _restart(){_tm?.cancel();setState((){_run=false;_over=false;_score=0;_g=List.generate(20,(_)=>List<int>.filled(10,0));});}
  @override void dispose(){_tm?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_GameShell(title:'Tetris',restart:_restart,child:Stack(children:[
    if(!_run)Positioned.fill(child:_GameStart(title:'Tetris',description:'Susun blok dan penuhkan satu baris untuk menghapusnya. Sekarang tersedia 7 jenis blok.',details:'7 BLOCK TYPES • ARCADE',start:_start)),
    if(_run)Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(14,8,14,5),child:Row(children:[Text('SCORE '+_score.toString(),style:const TextStyle(fontWeight:FontWeight.w900)),const Spacer(),IconButton(onPressed:()=>setState(()=>_paused=!_paused),icon:Icon(_paused?Icons.play_arrow_rounded:Icons.pause_rounded))])),
      Expanded(child:Center(child:AspectRatio(aspectRatio:10/20,child:CustomPaint(painter:_TetrisPainter(_g,_cells(),_type))))),
      Padding(padding:const EdgeInsets.fromLTRB(12,8,12,12),child:Wrap(alignment:WrapAlignment.center,spacing:8,children:[
        IconButton.filledTonal(onPressed:()=>_move(-1),icon:const Icon(Icons.chevron_left_rounded)),
        IconButton.filledTonal(onPressed:_rotate,icon:const Icon(Icons.rotate_right_rounded)),
        IconButton.filledTonal(onPressed:()=>_move(1),icon:const Icon(Icons.chevron_right_rounded)),
        IconButton.filledTonal(onPressed:()=>setState(_drop),icon:const Icon(Icons.keyboard_double_arrow_down_rounded)),
      ])),
    ]),
    if(_over)Positioned.fill(child:_GameOver(title:'TOP OUT',score:_score,restart:_restart)),
  ]));
}
class _TetrisPainter extends CustomPainter{
  final List<List<int>> board;final List<Point<int>> active;final int type;
  _TetrisPainter(this.board,this.active,this.type);
  @override void paint(Canvas c,Size s){c.drawRect(Offset.zero&s,Paint()..color=const Color(0xFF0A0D16));final cw=s.width/10,ch=s.height/20;
    for(int y=0;y<20;y++)for(int x=0;x<10;x++){final v=board[y][x];if(v!=0)_cell(c,x,y,cw,ch,_color(v));}
    for(final p in active)if(p.y>=0)_cell(c,p.x,p.y,cw,ch,_color(type+1));
  }
  void _cell(Canvas c,int x,int y,double cw,double ch,Color color){c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x*cw+1,y*ch+1,cw-2,ch-2),const Radius.circular(4)),Paint()..color=color);}
  Color _color(int v)=>[Colors.cyanAccent,Colors.amber,Colors.purpleAccent,Colors.orangeAccent,Colors.blueAccent,Colors.greenAccent,Colors.redAccent][(v-1).clamp(0,6).toInt()];
  @override bool shouldRepaint(covariant _TetrisPainter old)=>true;
}

// 4 Flappy
class _FlappyGame extends StatefulWidget { const _FlappyGame(); @override State<_FlappyGame> createState()=>_FlappyGameState(); }
class _FlappyGameState extends State<_FlappyGame>{
  Timer? _tm;final Random _r=Random();double _bird=.5,_vy=0;int _score=0;bool _run=false,_over=false,_holding=false;List<double> _pipes=[];
  void _start(){_tm?.cancel();setState((){_run=true;_over=false;_holding=false;_score=0;_bird=.5;_vy=0;_pipes=[.9,1.5];});_tm=Timer.periodic(const Duration(milliseconds:30),(_)=>_tick());}
  void _tick(){if(!mounted||!_run||_over)return;setState((){
    if(_holding)_vy=(_vy-.0017).clamp(-.022,.020).toDouble();else _vy=(_vy+.0015).clamp(-.022,.020).toDouble();
    _bird+=_vy;_pipes=[for(final p in _pipes)p-.008];
    if(_pipes.first<-.12){_pipes.removeAt(0);_pipes.add(1.0+_r.nextDouble()*.5);_score++;}
    if(_bird<.03||_bird>.97)_end();
  });}
  void _end(){_over=true;_holding=false;_tm?.cancel();}
  void _press(){if(!_run){_start();return;}if(!_over)setState(()=>_holding=true);}
  void _release(){if(_holding)setState(()=>_holding=false);}
  void _restart(){_tm?.cancel();setState((){_run=false;_over=false;_holding=false;_score=0;_pipes=[];});}
  @override void dispose(){_tm?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_GameShell(title:'Flappy',restart:_restart,child:Stack(children:[
    Positioned.fill(child:GestureDetector(behavior:HitTestBehavior.opaque,onTapDown:(_)=>_press(),onTapUp:(_)=>_release(),onTapCancel:_release,child:CustomPaint(painter:_FlappyPainter(_bird,_pipes)))),
    Positioned(top:12,left:12,child:_GameBadge('SCORE '+_score.toString())),
    if(!_run)Positioned.fill(child:_GameStart(title:'Flappy',description:'Tahan layar untuk terbang naik. Lepas untuk turun dan lewati celah pipa.',details:'HOLD TO FLY • ARCADE',start:_start)),
    if(_run&&!_over)Positioned(bottom:14,left:0,right:0,child:Center(child:_GameBadge(_holding?'FLYING':'RELEASE TO FALL'))),
    if(_over)Positioned.fill(child:_GameOver(title:'PIPE HIT',score:_score,restart:_restart)),
  ]));
}
class _FlappyPainter extends CustomPainter{
  final double bird;final List<double> pipes;_FlappyPainter(this.bird,this.pipes);
  @override void paint(Canvas c,Size s){c.drawRect(Offset.zero&s,Paint()..color=const Color(0xFF07111F));final p=Paint()..color=const Color(0xFF16A34A);
    for(final x in pipes){final gap=.50+((x*17)%0.20)-.10;final left=x*s.width; c.drawRect(Rect.fromLTWH(left,0,38,s.height*(gap-.16)),p);c.drawRect(Rect.fromLTWH(left,s.height*(gap+.16),38,s.height),p);}
    c.drawCircle(Offset(s.width*.30,bird*s.height),16,Paint()..color=Colors.amber);c.drawCircle(Offset(s.width*.35,bird*s.height-4),3,Paint()..color=Colors.black);
  }
  @override bool shouldRepaint(covariant _FlappyPainter old)=>true;
}

// 5 Breakout
class _BreakoutGame extends StatefulWidget { const _BreakoutGame(); @override State<_BreakoutGame> createState()=>_BreakoutGameState(); }
class _BreakoutGameState extends State<_BreakoutGame>{
  Timer? _tm;double _px=.5,_bx=.5,_by=.72,_vx=.009,_vy=-.009;int _score=0;bool _run=false,_over=false;final Set<Point<int>> _bricks={};
  void _start(){_tm?.cancel();_bricks.clear();for(int r=0;r<4;r++)for(int col=0;col<7;col++)_bricks.add(Point(col,r));setState((){_run=true;_over=false;_score=0;_px=.5;_bx=.5;_by=.72;_vx=.009;_vy=-.009;});_tm=Timer.periodic(const Duration(milliseconds:30),(_)=>_tick());}
  void _tick(){if(!mounted||!_run||_over)return;setState((){
    _bx+=_vx;_by+=_vy;
    if(_bx<.025||_bx>.975){_vx=-_vx;_bx=_bx.clamp(.025,.975).toDouble();}
    if(_by<.035)_vy=_vy.abs();
    if(_by>.91){if((_bx-_px).abs()<.18){_vy=-_vy.abs();_by=.89;}else{_end();return;}}
    final col=((_bx-.16)/.096).floor(),row=((_by-.10)/.075).floor();
    final hit=Point<int>(col,row);
    if(col>=0&&col<7&&row>=0&&row<4&&_bricks.remove(hit)){_score+=10;_vy=-_vy;if(_bricks.isEmpty)_end();}
  });}
  void _end(){_over=true;_tm?.cancel();}
  void _restart(){_tm?.cancel();setState((){_run=false;_over=false;_score=0;_bricks.clear();});}
  @override void dispose(){_tm?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_GameShell(title:'Breakout',restart:_restart,child:Stack(children:[
    Positioned.fill(child:GestureDetector(behavior:HitTestBehavior.opaque,onHorizontalDragUpdate:(d)=>setState(()=>_px=(_px+d.delta.dx/260).clamp(.10,.90).toDouble()),child:CustomPaint(painter:_BreakoutPainter(_bx,_by,_px,_bricks)))),
    Positioned(top:12,left:12,child:_GameBadge('SCORE '+_score.toString())),
    if(!_run)Positioned.fill(child:_GameStart(title:'Breakout',description:'Geser jari kiri-kanan untuk menggerakkan paddle. Pantulkan bola dan hancurkan semua brick.',details:'SWIPE LEFT/RIGHT • ARCADE',start:_start)),
    if(_run)Positioned(bottom:12,left:0,right:0,child:Center(child:_GameBadge('GESER KIRI / KANAN'))),
    if(_over)Positioned.fill(child:_GameOver(title:_bricks.isEmpty?'YOU WIN':'BALL LOST',score:_score,restart:_restart)),
  ]));
}
class _BreakoutPainter extends CustomPainter{
  final double bx,by,px;final Set<Point<int>> bricks;_BreakoutPainter(this.bx,this.by,this.px,this.bricks);
  @override void paint(Canvas c,Size s){c.drawRect(Offset.zero&s,Paint()..color=const Color(0xFF0B0F1A));
    for(final b in bricks){final rect=Rect.fromLTWH(s.width*(.16+b.x*.096),s.height*(.10+b.y*.075),s.width*.082,s.height*.055);c.drawRRect(RRect.fromRectAndRadius(rect,const Radius.circular(5)),Paint()..color=[Colors.redAccent,Colors.orangeAccent,Colors.amber,Colors.purpleAccent][b.y]);}
    c.drawCircle(Offset(bx*s.width,by*s.height),7,Paint()..color=Colors.white);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(px*s.width,s.height*.94),width:s.width*.20,height:14),const Radius.circular(8)),Paint()..color=Colors.cyanAccent);
  }
  @override bool shouldRepaint(covariant _BreakoutPainter old)=>true;
}

// 6 Memory
class _MemoryGame extends StatefulWidget { const _MemoryGame(); @override State<_MemoryGame> createState()=>_MemoryGameState(); }
class _MemoryGameState extends State<_MemoryGame>{
  final Random _r=Random();List<int> _cards=[];List<int> _open=[];final Set<int> _matched=<int>{};bool _run=false,_lock=false,_over=false;int _moves=0;
  void _start(){final a=<int>[0,0,1,1,2,2,3,3,4,4,5,5]..shuffle(_r);setState((){_cards=a;_open=[];_matched.clear();_run=true;_lock=false;_over=false;_moves=0;});}
  void _tap(int i){if(!_run||_lock||_open.contains(i)||_matched.contains(i))return;setState(()=>_open=[..._open,i]);if(_open.length!=2)return;_lock=true;_moves++;final a=_open[0],b=_open[1];if(_cards[a]==_cards[b]){Future.delayed(const Duration(milliseconds:300),(){if(!mounted)return;setState((){_matched.addAll([a,b]);_open=[];_lock=false;_over=_matched.length==_cards.length;});});}else{Future.delayed(const Duration(milliseconds:650),(){if(!mounted)return;setState((){_open=[];_lock=false;});});}}
  void _restart(){setState((){_run=false;_lock=false;_over=false;_open=[];_matched.clear();_moves=0;});}
  @override Widget build(BuildContext c)=>_GameShell(title:'Memory',restart:_restart,child:Stack(children:[
    if(!_run)Positioned.fill(child:_GameStart(title:'Memory',description:'Cari semua pasangan kartu yang sama.',details:'12 CARDS • 6 PAIRS',start:_start)),
    if(_run)Padding(padding:const EdgeInsets.all(16),child:Column(children:[Text('MOVES '+_moves.toString(),style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:12),Expanded(child:GridView.builder(itemCount:_cards.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:9,mainAxisSpacing:9),itemBuilder:(_,i){final visible=_open.contains(i)||_matched.contains(i);return InkWell(onTap:()=>_tap(i),borderRadius:BorderRadius.circular(16),child:Container(decoration:BoxDecoration(color:visible?_hubPurple:const Color(0xFF171D2C),borderRadius:BorderRadius.circular(16)),child:Center(child:visible?Text((_cards[i]+1).toString(),style:const TextStyle(fontSize:27,fontWeight:FontWeight.w900)):const Icon(Icons.help_outline_rounded,color:Colors.white38,size:28))));}))])),
    if(_over)Positioned.fill(child:_GameOver(title:'ALL PAIRS FOUND',score:_moves,restart:_restart)),
  ]));
}

// 7 Pong
class _PongGame extends StatefulWidget { const _PongGame(); @override State<_PongGame> createState()=>_PongGameState(); }
class _PongGameState extends State<_PongGame>{
  Timer? _tm;double _player=.5,_bot=.5,_x=.5,_y=.5,_vx=.009,_vy=.008;int _score=0,_botScore=0;String _difficulty='NORMAL';bool _run=false,_over=false;
  double get _botSpeed=>_difficulty=='EASY' ? .045 : _difficulty=='HARD' ? .13 : .085;
  void _start(){_tm?.cancel();setState((){_run=true;_over=false;_score=0;_botScore=0;_player=.5;_bot=.5;_x=.5;_y=.5;_vx=.009;_vy=.008;});_tm=Timer.periodic(const Duration(milliseconds:25),(_)=>_tick());}
  void _tick(){if(!mounted||!_run||_over)return;setState((){
    _x+=_vx;_y+=_vy;_bot+=(_y-_bot)*_botSpeed;
    if(_y<.04||_y>.96){_vy=-_vy;_y=_y.clamp(.04,.96).toDouble();}
    if(_x<.05){if((_y-_player).abs()<.18){_vx=_vx.abs();_x=.08;}else{_botScore++;_serve();}}
    if(_x>.95){if((_y-_bot).abs()<.18){_vx=-_vx.abs();_x=.92;}else{_score++;_serve();}}
    if(_score>=7||_botScore>=7){_over=true;_tm?.cancel();}
  });}
  void _serve(){_x=.5;_y=.5;_vx=-_vx;}
  void _restart(){_tm?.cancel();setState((){_run=false;_over=false;_score=0;_botScore=0;});}
  @override void dispose(){_tm?.cancel();super.dispose();}
  Widget _difficultyPicker(){return Wrap(alignment:WrapAlignment.center,spacing:7,children:[for(final d in const ['EASY','NORMAL','HARD'])ChoiceChip(label:Text(d),selected:_difficulty==d,onSelected:(_){setState(()=>_difficulty=d);})]);}
  @override Widget build(BuildContext context)=>_GameShell(title:'Pong',restart:_restart,child:Stack(children:[
    if(!_run)Positioned.fill(child:SingleChildScrollView(padding:const EdgeInsets.all(22),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      const SizedBox(height:60),const Text('PONG',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900)),const SizedBox(height:8),const Text('Geser paddle kamu secara vertikal. Bot menjaga sisi kanan.',textAlign:TextAlign.center,style:TextStyle(color:Colors.white70)),const SizedBox(height:18),const Text('PILIH BOT',style:TextStyle(fontSize:11,fontWeight:FontWeight.w900)),const SizedBox(height:8),_difficultyPicker(),const SizedBox(height:20),SizedBox(width:220,child:FilledButton.icon(onPressed:_start,icon:const Icon(Icons.play_arrow_rounded),label:const Text('START GAME'))),
    ]))),
    if(_run)Positioned.fill(child:GestureDetector(behavior:HitTestBehavior.opaque,onVerticalDragUpdate:(d)=>setState(()=>_player=(_player+d.delta.dy/300).clamp(.12,.88).toDouble()),child:CustomPaint(painter:_PongPainter(_player,_bot,_x,_y)))),
    if(_run)Positioned(top:12,left:0,right:0,child:Center(child:_GameBadge(_score.toString()+'  :  '+_botScore.toString()+'  •  '+_difficulty))),
    if(_run)Positioned(bottom:12,left:0,right:0,child:Center(child:_GameBadge('GESER ATAS / BAWAH'))),
    if(_over)Positioned.fill(child:_GameOver(title:_score>=7?'YOU WIN':'BOT WINS',score:_score,restart:_restart)),
  ]));
}
class _PongPainter extends CustomPainter{
  final double player,bot,x,y;_PongPainter(this.player,this.bot,this.x,this.y);
  @override void paint(Canvas c,Size s){c.drawRect(Offset.zero&s,Paint()..color=const Color(0xFF080D18));final line=Paint()..color=Colors.white12..strokeWidth=2;for(double y=0;y<s.height;y+=18)c.drawLine(Offset(s.width/2,y),Offset(s.width/2,y+9),line);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*.06,s.height*(player-.10),10,s.height*.20),const Radius.circular(6)),Paint()..color=Colors.cyanAccent);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*.94-10,s.height*(bot-.10),10,s.height*.20),const Radius.circular(6)),Paint()..color=Colors.pinkAccent);
    c.drawCircle(Offset(x*s.width,y*s.height),8,Paint()..color=Colors.white);
  }
  @override bool shouldRepaint(covariant _PongPainter old)=>true;
}

// 8 Whack
// 9 Minesweeper
class _MinesGame extends StatefulWidget { const _MinesGame(); @override State<_MinesGame> createState()=>_MinesGameState(); }
class _MinesGameState extends State<_MinesGame>{
  final Random _r=Random();List<bool> _mines=List<bool>.filled(64,false),_open=List<bool>.filled(64,false),_flags=List<bool>.filled(64,false);int _safe=0;bool _run=false,_over=false,_win=false;
  void _start(){final m=List<bool>.filled(64,false);final ids=List<int>.generate(64,(i)=>i)..shuffle(_r);for(final i in ids.take(10))m[i]=true;setState((){_mines=m;_open=List<bool>.filled(64,false);_flags=List<bool>.filled(64,false);_safe=0;_run=true;_over=false;_win=false;});}
  int _count(int i){final r=i~/8,c=i%8;var n=0;for(var dr=-1;dr<=1;dr++)for(var dc=-1;dc<=1;dc++){final rr=r+dr,cc=c+dc;if(rr>=0&&rr<8&&cc>=0&&cc<8&&_mines[rr*8+cc])n++;}return n;}
  void _reveal(int i){if(!_run||_over||_flags[i]||_open[i])return;if(_mines[i]){setState((){_open[i]=true;_over=true;_run=false;});return;}final q=<int>[i];final seen=<int>{};while(q.isNotEmpty){final x=q.removeLast();if(seen.contains(x)||_open[x]||_flags[x]||_mines[x])continue;seen.add(x);_open[x]=true;_safe++;if(_count(x)==0){final r=x~/8,c=x%8;for(var dr=-1;dr<=1;dr++)for(var dc=-1;dc<=1;dc++){final rr=r+dr,cc=c+dc;if(rr>=0&&rr<8&&cc>=0&&cc<8)q.add(rr*8+cc);}}}final clear=_safe>=54;setState((){_win=clear;_over=clear;_run=!clear;});}
  void _restart(){setState((){_run=false;_over=false;_win=false;_safe=0;_open=List<bool>.filled(64,false);_flags=List<bool>.filled(64,false);});}
  @override Widget build(BuildContext c)=>_GameShell(title:'Minesweeper',restart:_restart,child:Stack(children:[
    if(!_run&&!_over)Positioned.fill(child:_GameStart(title:'Minesweeper',description:'Tap untuk buka. Tahan untuk flag.',details:'8 × 8 • 10 MINES',start:_start)),
    if(_run)Padding(padding:const EdgeInsets.all(14),child:Column(children:[Text('SAFE '+_safe.toString()+' / 54',style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:10),Expanded(child:GridView.builder(itemCount:64,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:8,crossAxisSpacing:4,mainAxisSpacing:4),itemBuilder:(_,i){final n=_count(i);return GestureDetector(onTap:()=>_reveal(i),onLongPress:()=>setState((){if(_run&&!_over&&!_open[i])_flags[i]=!_flags[i];}),child:Container(decoration:BoxDecoration(color:_open[i]?const Color(0xFF20283A):const Color(0xFF111827),borderRadius:BorderRadius.circular(5)),child:Center(child:Text(_open[i]?(_mines[i]?'X':(n==0?'':n.toString())):(_flags[i]?'⚑':'•'),style:const TextStyle(fontWeight:FontWeight.w900)))));}))])),
    if(_over)Positioned.fill(child:_GameOver(title:_win?'BOARD CLEARED':'BOOM',score:_safe,restart:_restart)),
  ]));
}

// 10 Simon Says
class _SimonGame extends StatefulWidget { const _SimonGame(); @override State<_SimonGame> createState()=>_SimonGameState(); }
class _SimonGameState extends State<_SimonGame>{
  final Random _r=Random();final List<Color> _colors=const [Colors.red,Colors.green,Colors.blue,Colors.amber];final List<int> _seq=[];Timer? _tm;int _step=0,_flash=-1,_round=0;bool _run=false,_accept=false,_over=false;
  void _start(){_tm?.cancel();_seq.clear();setState((){_run=true;_accept=false;_over=false;_round=0;_step=0;_flash=-1;});_next();}
  void _next(){_seq.add(_r.nextInt(4));_round=_seq.length;_step=0;_accept=false;_play(0);}
  void _play(int i){if(!mounted)return;if(i>=_seq.length){setState(()=>_accept=true);return;}setState(()=>_flash=_seq[i]);_tm=Timer(const Duration(milliseconds:320),(){if(!mounted)return;setState(()=>_flash=-1);_tm=Timer(const Duration(milliseconds:160),()=>_play(i+1));});}
  void _tap(int i){if(!_run||_over||!_accept)return;if(_seq[_step]!=i){setState((){_over=true;_accept=false;_run=false;});return;}setState(()=>_step++);if(_step>=_seq.length){setState(()=>_accept=false);_tm=Timer(const Duration(milliseconds:450),(){if(mounted&&!_over)_next();});}}
  void _restart(){_tm?.cancel();setState((){_run=false;_accept=false;_over=false;_seq.clear();_round=0;_step=0;_flash=-1;});}
  @override void dispose(){_tm?.cancel();super.dispose();}
  @override Widget build(BuildContext c)=>_GameShell(title:'Simon Says',restart:_restart,child:Stack(children:[
    if(!_run&&!_over)Positioned.fill(child:_GameStart(title:'Simon Says',description:'Ingat urutan warna lalu ulangi.',details:'ENDLESS • MEMORY',start:_start)),
    if(_run)Padding(padding:const EdgeInsets.all(18),child:Column(children:[Text('ROUND '+_round.toString()+'  •  '+(_accept?'YOUR TURN':'WATCH'),style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:18),Expanded(child:GridView.count(crossAxisCount:2,crossAxisSpacing:14,mainAxisSpacing:14,children:[for(var i=0;i<4;i++)GestureDetector(onTap:()=>_tap(i),child:AnimatedContainer(duration:const Duration(milliseconds:110),decoration:BoxDecoration(color:_flash==i?_colors[i]:_colors[i].withValues(alpha:.25),borderRadius:BorderRadius.circular(28),border:Border.all(color:_flash==i?Colors.white:Colors.white10,width:_flash==i?3:1)),child:const Icon(Icons.circle,size:40,color:Colors.white54)))]))])),
    if(_over)Positioned.fill(child:_GameOver(title:'WRONG MOVE',score:max(0,_round-1),restart:_restart)),
  ]));
}





class _MiniScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback restart;
  const _MiniScaffold({required this.title, required this.child, required this.restart});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF070910),
    appBar: AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      actions: [IconButton(onPressed: restart, tooltip: 'Restart', icon: const Icon(Icons.refresh_rounded))],
    ),
    body: SafeArea(child: child),
  );
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
  );
}


class _ColorStackGame extends StatefulWidget {
  const _ColorStackGame();

  @override
  State<_ColorStackGame> createState() => _ColorStackGameState();
}

class _ColorStackGameState extends State<_ColorStackGame> {
  static const _modes = <String>['Easy', 'Normal', 'Hard', 'Pro', 'Impossible'];
  static const _capacity = 4;
  static final _prefs = SharedPreferencesAsync();

  final Random _rng = Random();
  final Map<String, int> _savedLevels = <String, int>{
    'Easy': 1, 'Normal': 1, 'Hard': 1, 'Pro': 1, 'Impossible': 1,
  };

  String _mode = 'Easy';
  int _level = 1;
  List<List<int>> _tubes = <List<int>>[];
  int _colors = 0;
  int? _selected;
  int _moves = 0;
  List<List<List<int>>> _history = <List<List<int>>>[];
  bool _won = false;
  bool _loadingProgress = true;

  static const List<Color> _colorsPaint = <Color>[
    Color(0xFFFF6B35), Color(0xFF22C55E), Color(0xFF06B6D4),
    Color(0xFFEC4899), Color(0xFFFACC15), Color(0xFF3B82F6),
    Color(0xFFA855F7), Color(0xFFEF4444), Color(0xFF14B8A6),
    Color(0xFFF97316), Color(0xFF84CC16), Color(0xFF8B5CF6),
  ];

  int _modeBaseColors(String mode) {
    switch (mode) {
      case 'Normal': return 4;
      case 'Hard': return 5;
      case 'Pro': return 6;
      case 'Impossible': return 7;
      default: return 3;
    }
  }

  int _levelColorCount() {
    final base = _modeBaseColors(_mode);
    final growth = (_level - 1) ~/ 3;
    return min(_colorsPaint.length, base + growth);
  }

  int _scrambleCount() {
    final modeIndex = _modes.indexOf(_mode);
    return 18 + modeIndex * 7 + (_level - 1) * (5 + modeIndex * 2);
  }

  int _emptyTubesFor(String mode) => 2;

  String _progressKey(String mode) {
    final account = nexoraActiveAccountId;
    if (account == null || account.isEmpty) return '';
    final safe = account.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return 'nexora_color_stack_${safe}_$mode';
  }

  Future<void> _loadProgress() async {
    final account = nexoraActiveAccountId;
    if (account == null || account.isEmpty) return;
    for (final mode in _modes) {
      final value = await _prefs.getInt(_progressKey(mode));
      if (value != null && value > 0) _savedLevels[mode] = value;
    }
  }

  Future<void> _saveModeProgress(String mode) async {
    final key = _progressKey(mode);
    if (key.isEmpty) return;
    await _prefs.setInt(key, _savedLevels[mode] ?? 1);
  }

  List<List<int>> _copyTubes(List<List<int>> source) =>
      source.map((tube) => List<int>.from(tube)).toList();

  List<List<int>> _newSolvedBoard() {
    final tubes = <List<int>>[];
    for (int color = 0; color < _colors; color++) {
      tubes.add(<int>[for (int i = 0; i < _capacity; i++) color]);
    }
    for (int i = 0; i < _emptyTubesFor(_mode); i++) tubes.add(<int>[]);
    return tubes;
  }

  List<List<int>> _scrambleCandidate() {
    final tubes = _newSolvedBoard();
    int? lastFrom;
    int? lastTo;

    for (int step = 0; step < _scrambleCount(); step++) {
      final legal = <List<int>>[];
      for (int from = 0; from < tubes.length; from++) {
        if (tubes[from].isEmpty) continue;
        if (tubes[from].length == _capacity &&
            tubes[from].every((v) => v == tubes[from].first)) continue;

        final color = tubes[from].last;
        for (int to = 0; to < tubes.length; to++) {
          if (from == to || tubes[to].length >= _capacity) continue;
          if (lastFrom == to && lastTo == from) continue;
          if (tubes[to].isEmpty || tubes[to].last == color) {
            legal.add(<int>[from, to]);
          }
        }
      }
      if (legal.isEmpty) break;

      final move = legal[_rng.nextInt(legal.length)];
      final from = move[0];
      final to = move[1];
      final color = tubes[from].last;
      int block = 1;
      for (int i = tubes[from].length - 2;
          i >= 0 && tubes[from][i] == color;
          i--) {
        block++;
      }
      final amount = min(block, _capacity - tubes[to].length);
      for (int i = 0; i < amount; i++) {
        tubes[to].add(tubes[from].removeLast());
      }
      lastFrom = from;
      lastTo = to;
    }
    return tubes;
  }

  int _layoutScore(List<List<int>> tubes) {
    int mixed = 0;
    int transitions = 0;
    int uniqueTop = 0;
    for (final tube in tubes) {
      if (tube.isEmpty) continue;
      final unique = tube.toSet().length;
      if (unique > 1) mixed++;
      uniqueTop += unique;
      for (int i = 1; i < tube.length; i++) {
        if (tube[i] != tube[i - 1]) transitions++;
      }
    }
    return mixed * 100 + transitions * 12 + uniqueTop;
  }

  bool _goodOpening(List<List<int>> tubes) {
    int mixed = 0;
    final seenByColor = List<int>.filled(_colors, 0);
    for (final tube in tubes) {
      if (tube.toSet().length > 1) mixed++;
      for (final color in tube.toSet()) seenByColor[color]++;
    }
    return mixed >= max(2, _colors ~/ 2) &&
        seenByColor.every((count) => count >= 2);
  }

  void _startLevel() {
    _colors = _levelColorCount();
    List<List<int>>? best;
    var bestScore = -1;

    for (int attempt = 0; attempt < 90; attempt++) {
      final candidate = _scrambleCandidate();
      final score = _layoutScore(candidate);
      if (score > bestScore) {
        bestScore = score;
        best = _copyTubes(candidate);
      }
      if (_goodOpening(candidate)) {
        best = candidate;
        break;
      }
    }

    setState(() {
      _tubes = best ?? _scrambleCandidate();
      _selected = null;
      _moves = 0;
      _history = <List<List<int>>>[];
      _won = false;
    });
  }

  bool _isSolved(List<List<int>> tubes) {
    for (final tube in tubes) {
      if (tube.isEmpty) continue;
      if (tube.length != _capacity) return false;
      if (tube.any((v) => v != tube.first)) return false;
    }
    return true;
  }

  void _selectTube(int index) {
    if (_won) return;
    if (_selected == null) {
      if (_tubes[index].isNotEmpty) setState(() => _selected = index);
      return;
    }
    if (_selected == index) {
      setState(() => _selected = null);
      return;
    }
    _pour(_selected!, index);
  }

  void _pour(int from, int to) {
    if (from == to || _tubes[from].isEmpty || _tubes[to].length >= _capacity) {
      setState(() => _selected = null);
      return;
    }

    final source = _tubes[from];
    final target = _tubes[to];
    final color = source.last;
    if (target.isNotEmpty && target.last != color) {
      setState(() => _selected = null);
      return;
    }

    int count = 1;
    for (int i = source.length - 2; i >= 0 && source[i] == color; i--) count++;
    count = min(count, _capacity - target.length);

    _history.add(_copyTubes(_tubes));
    for (int i = 0; i < count; i++) target.add(source.removeLast());
    _moves++;
    _selected = null;
    _won = _isSolved(_tubes);

    if (_won) {
      _savedLevels[_mode] = max(_savedLevels[_mode] ?? 1, _level + 1);
      unawaited(_saveModeProgress(_mode));
    }
    setState(() {});
  }

  void _undo() {
    if (_history.isEmpty || _won) return;
    final previous = _history.removeLast();
    setState(() {
      _tubes = _copyTubes(previous);
      _moves = max(0, _moves - 1);
      _selected = null;
    });
  }

  void _nextLevel() {
    _level++;
    _savedLevels[_mode] = _level;
    unawaited(_saveModeProgress(_mode));
    _startLevel();
  }

  void _changeMode(String mode) {
    setState(() {
      _mode = mode;
      _level = _savedLevels[mode] ?? 1;
      _selected = null;
      _won = false;
    });
    _startLevel();
  }

  void _restart() {
    _level = _savedLevels[_mode] ?? 1;
    _startLevel();
  }

  Future<void> _bootstrap() async {
    await _loadProgress();
    if (!mounted) return;
    _level = _savedLevels[_mode] ?? 1;
    _loadingProgress = false;
    _startLevel();
  }

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProgress) {
      return Scaffold(
        appBar: AppBar(title: Text('Color Stack', style: TextStyle(fontWeight: FontWeight.w900))),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Stack', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: _restart, tooltip: 'Restart level', icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_mode.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
                        Text('Level $_level', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  _GameBadge('MOVES $_moves'),
                ],
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: _modes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 7),
                itemBuilder: (context, index) {
                  final mode = _modes[index];
                  return ChoiceChip(
                    label: Text(mode),
                    selected: _mode == mode,
                    onSelected: (_) => _changeMode(mode),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 2, 12, 4),
              child: Text(
                'Pilih botol sumber lalu botol tujuan. Cairan hanya bisa ke warna yang sama atau botol kosong.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.white54, height: 1.3),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth < 520 ? 54.0 : 62.0;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runSpacing: 18,
                      spacing: constraints.maxWidth < 520 ? 8 : 12,
                      children: [
                        for (int i = 0; i < _tubes.length; i++)
                          _ColorStackTube(
                            tube: _tubes[i],
                            selected: _selected == i,
                            width: width,
                            onTap: () => _selectTube(i),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _history.isEmpty || _won ? null : _undo,
                      icon: const Icon(Icons.undo_rounded, size: 18),
                      label: const Text('UNDO'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _won || _selected == null ? null : () {
                        final source = _tubes[_selected!];
                        final choices = <int>[];
                        for (int i = 0; i < _tubes.length; i++) {
                          if (i == _selected || _tubes[i].length >= _capacity) continue;
                          if (_tubes[i].isEmpty || _tubes[i].last == source.last) choices.add(i);
                        }
                        if (choices.isNotEmpty) _pour(_selected!, choices[_rng.nextInt(choices.length)]);
                      },
                      icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                      label: const Text('HINT'),
                    ),
                  ),
                ],
              ),
            ),
            if (_won)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10261D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: .25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        'Level $_level selesai. Progress $_mode tersimpan di akun Google.',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      )),
                      FilledButton(onPressed: _nextLevel, child: const Text('NEXT')),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ColorStackTube extends StatelessWidget {
  final List<int> tube;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  const _ColorStackTube({required this.tube, required this.selected, required this.width, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        height: 194,
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .025),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? const Color(0xFFD8B4FE) : Colors.white.withValues(alpha: .16),
            width: selected ? 2.6 : 1.3,
          ),
          boxShadow: selected
              ? <BoxShadow>[BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: .22), blurRadius: 20, spreadRadius: 2)]
              : const <BoxShadow>[],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (int slot = 3; slot >= 0; slot--)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.5),
                child: slot < tube.length
                    ? Container(
                        height: 35,
                        width: width - 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.lerp(_ColorStackGameState._colorsPaint[tube[slot]], Colors.white, .12)!,
                              _ColorStackGameState._colorsPaint[tube[slot]],
                            ],
                          ),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: Colors.white.withValues(alpha: .28)),
                          boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black38, blurRadius: 5, offset: Offset(0, 2))],
                        ),
                        child: const Center(child: Icon(Icons.water_drop_rounded, size: 8, color: Colors.white54)),
                      )
                    : Container(
                        height: 35,
                        width: width - 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .018),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: Colors.white.withValues(alpha: .055)),
                        ),
                      ),
              ),
            Container(
              height: 9,
              width: width - 8,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFB8A4FF), Color(0xFF6D28D9)]),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameBadge extends StatelessWidget {
  final String text;
  const _GameBadge(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
  );
}

class _Over extends StatelessWidget {
  final String title;
  final VoidCallback restart;
  const _Over({required this.title, required this.restart});
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF111522), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: restart, icon: const Icon(Icons.refresh_rounded), label: const Text('Main Lagi')),
      ]),
    ),
  );
}

class _Score extends StatelessWidget {
  final String label;
  final String value;
  const _Score(this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: const Color(0xFF171B2A), borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white60))),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
    ]),
  );
}

class _GamePauseButton extends StatelessWidget {
  final bool paused;
  final VoidCallback onTap;
  const _GamePauseButton({required this.paused, required this.onTap});
  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    onPressed: onTap,
    tooltip: paused ? 'Resume' : 'Pause',
    icon: Icon(paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
  );
}

class _GameAudio {
  final AudioPlayer player = AudioPlayer();
  Future<void> start(double base, {double volume = .16}) async {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setVolume(volume);
    await player.play(BytesSource(_gameWav(base), mimeType: 'audio/wav'));
  }
  Future<void> stop() async { await player.stop(); }
  Future<void> dispose() async { await player.dispose(); }
}

Uint8List _gameWav(double base, {int seconds = 6}) {
  const sr = 22050;
  final count = sr * seconds, bytes = count * 2;
  final d = ByteData(44 + bytes);
  void w32(int o, int v) => d.setUint32(o, v, Endian.little);
  void w16(int o, int v) => d.setUint16(o, v, Endian.little);
  void txt(int o, String v) { for (var i = 0; i < v.length; i++) d.setUint8(o + i, v.codeUnitAt(i)); }
  txt(0, 'RIFF'); w32(4, 36 + bytes); txt(8, 'WAVE'); txt(12, 'fmt '); w32(16, 16);
  w16(20, 1); w16(22, 1); w32(24, sr); w32(28, sr * 2); w16(32, 2); w16(34, 16);
  txt(36, 'data'); w32(40, bytes);
  for (var i = 0; i < count; i++) {
    final t = i / sr;
    final f = base * [1, 1.25, 1.5, 1.875][(t * 2).floor() % 4];
    final env = min(1.0, t * 8) * min(1.0, (seconds - t) * 5);
    final v = (.17 * sin(2 * pi * f * t) + .08 * sin(2 * pi * f * 2 * t) + .05 * sin(2 * pi * base / 2 * t)) * env;
    d.setInt16(44 + i * 2, (v * 26000).clamp(-32768, 32767).toInt(), Endian.little);
  }
  return d.buffer.asUint8List();
}

class _LegacyGameStart extends StatelessWidget {
  final String title, description, extra;
  final VoidCallback onStart;
  const _LegacyGameStart({required this.title, required this.description, required this.extra, required this.onStart});
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.all(22),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF111522), borderRadius: BorderRadius.circular(26), border: Border.all(color: Colors.white12)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.sports_esports_rounded, size: 54),
        const SizedBox(height: 14),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, height: 1.45)),
        const SizedBox(height: 12),
        Text(extra, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800)),
        const SizedBox(height: 22),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('START GAME'),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
        )),
      ]),
    ),
  );
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
    if(!started)Positioned.fill(child:Container(color:Colors.black45,child:_LegacyGameStart(title:'Neon Jump • Level '+level.toString(),description:'Auto-run seperti rhythm runner: tap untuk lompat dan hindari spike.',extra:'LEVEL '+level.toString()+' / 5 • Backsound ON saat mulai',onStart:startGame))),
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
      if(!started)Expanded(child:_LegacyGameStart(title:'Worm Arena',description:'Kumpulkan food, tubuh makin panjang, dan hindari tabrakan.',extra:'LEVEL naik tiap 5 FOOD • TANPA INTERNET',onStart:startGame)),
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
  void move(double d){if(started&&!paused)setState(()=>lane=(lane+d).clamp(0,2).toDouble());}
  @override void dispose(){timer?.cancel();audio.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Road Rush',restart:restart,child:Stack(children:[
    Positioned.fill(child:CustomPaint(painter:_RoadPainter(lane,cars))),
    if(!started)Positioned.fill(child:Container(color:Colors.black45,child:_LegacyGameStart(title:'Road Rush',description:'Pindah jalur, hindari mobil, dan bertahan selama mungkin.',extra:'LEVEL 1 → 5 • kecepatan dan traffic meningkat',onStart:startGame))),
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
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Brick Smash',restart:restart,child:GestureDetector(onHorizontalDragUpdate:(d){if(started&&!paused)setState(()=>paddle=(paddle+d.delta.dx/MediaQuery.sizeOf(context).width).clamp(.12,.88).toDouble());},behavior:HitTestBehavior.opaque,child:Stack(children:[
    Positioned.fill(child:CustomPaint(painter:_BrickPainter(bx,by,paddle,bricks))),
    if(!started)Positioned.fill(child:Container(color:Colors.black45,child:_LegacyGameStart(title:'Brick Smash',description:'Pantulkan bola dan hancurkan semua brick.',extra:'5 LEVEL • pola brick berubah setiap level • backsound ON',onStart:startGame))),
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
    if(!started)Positioned.fill(child:Container(color:Colors.black45,child:_LegacyGameStart(title:'Flap Orbit',description:'Tap untuk terbang melewati celah. Semakin tinggi level, semakin cepat.',extra:'LEVEL 1 → 5 • backsound ON',onStart:startGame))),
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
    if(!started)Expanded(child:_LegacyGameStart(title:'Maze Escape',description:'Cari jalan keluar. Tiap level punya pola labirin berbeda.',extra:'5 LEVEL • offline • tanpa timer',onStart:startGame)),
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

class Mini2048Page extends StatefulWidget{const Mini2048Page({super.key});@override State<Mini2048Page> createState()=>_Mini2048State();}
class _Mini2048State extends State<Mini2048Page>{
  final rng=Random();List<int>b=List.filled(16,0);int score=0,best=0;bool started=false,over=false;
  void _add(){final e=[for(int i=0;i<16;i++)if(b[i]==0)i];if(e.isNotEmpty)b[e[rng.nextInt(e.length)]]=rng.nextDouble()<.9?2:4;}
  void startGame(){setState((){started=true;over=false;score=0;b=List.filled(16,0);_add();_add();});}
  void restart(){if(mounted)setState((){started=false;over=false;score=0;b=List.filled(16,0);});}
  List<int>merge(List<int>a){final v=a.where((x)=>x>0).toList();for(int i=0;i<v.length-1;i++)if(v[i]==v[i+1]){v[i]*=2;score+=v[i];best=max(best,score);v.removeAt(i+1);}while(v.length<4)v.add(0);return v;}
  bool _hasMove(){for(int r=0;r<4;r++)for(int c=0;c<4;c++){final v=b[r*4+c];if(c<3&&b[r*4+c+1]==v)return true;if(r<3&&b[(r+1)*4+c]==v)return true;}return false;}
  void move(int dr,int dc){if(!started||over)return;final old=b.toString();if(dr==0){for(int r=0;r<4;r++){final a=[for(int c=0;c<4;c++)b[r*4+c]],q=merge(dc<0?a:a.reversed.toList()),z=dc<0?q:q.reversed.toList();for(int c=0;c<4;c++)b[r*4+c]=z[c];}}else{for(int c=0;c<4;c++){final a=[for(int r=0;r<4;r++)b[r*4+c]],q=merge(dr<0?a:a.reversed.toList()),z=dr<0?q:q.reversed.toList();for(int r=0;r<4;r++)b[r*4+c]=z[r];}}if(old!=b.toString()){_add();setState((){});if(!b.contains(0)&&!_hasMove())setState(()=>over=true);}}
  @override Widget build(BuildContext context)=>_MiniScaffold(title:'Nexora 2048',restart:restart,child:GestureDetector(onHorizontalDragEnd:(d){final v=d.primaryVelocity??0;if(v.abs()>30)move(0,v>0?1:-1);},onVerticalDragEnd:(d){final v=d.primaryVelocity??0;if(v.abs()>30)move(v>0?1:-1,0);},behavior:HitTestBehavior.opaque,child:Stack(children:[
    if(!started)Positioned.fill(child:_LegacyGameStart(title:'Nexora 2048',description:'Geser ubin dan gabungkan angka. Game tanpa level, fokus ke skor.',extra:'MODE ENDLESS • BEST '+best.toString(),onStart:startGame)),
    if(started)Padding(padding:const EdgeInsets.all(16),child:Column(children:[Row(children:[_Badge('SCORE '+score.toString()),const SizedBox(width:8),_Badge('BEST '+best.toString()),const Spacer()]),const SizedBox(height:14),Expanded(child:Center(child:AspectRatio(aspectRatio:1,child:GridView.builder(itemCount:16,physics:const NeverScrollableScrollPhysics(),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:4,crossAxisSpacing:8,mainAxisSpacing:8),itemBuilder:(_,i)=>Container(decoration:BoxDecoration(color:b[i]==0?const Color(0xFF1A1E2A):const Color(0xFF6D28D9),borderRadius:BorderRadius.circular(12)),child:Center(child:Text(b[i]==0?'':b[i].toString(),style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900)))))))),const Text('SWIPE • target 2048',style:TextStyle(color:Colors.white54,fontWeight:FontWeight.w800))])),
    if(over)Positioned.fill(child:_Over(title:'GAME OVER',restart:restart)),
  ])));
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
                          .clamp(.08, .92).toDouble();
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


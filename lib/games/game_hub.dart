// ignore_for_file: prefer_interpolation_to_compose_strings, curly_braces_in_flow_control_structures, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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
    _GameInfo('Whack-a-Mole', 'ARCADE', Icons.ads_click_rounded, Color(0xFFA855F7), 'Tap the target fast.'),
    _GameInfo('Minesweeper', 'PUZZLE', Icons.warning_amber_rounded, Color(0xFFF97316), 'Open safe cells.'),
    _GameInfo('Simon Says', 'PUZZLE', Icons.psychology_rounded, Color(0xFF14B8A6), 'Remember the color sequence.'),
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
      case 'Whack-a-Mole': return const _WhackGame();
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
                const _HubTag('10 GAMES'),
              ]),
              const SizedBox(height: 16),
              const Text('NEXORA GAME HUB', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.8, color: Colors.white70)),
              const SizedBox(height: 5),
              const Text('Play. Beat. Repeat.', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              const Text('10 mini game original Nexora. Offline dan langsung dimainkan.', style: TextStyle(color: Colors.white70, height: 1.35)),
              const SizedBox(height: 17),
              Row(children: [
                _HubStat('ARCADE', '5'), const SizedBox(width: 8),
                _HubStat('PUZZLE', '4'), const SizedBox(width: 8),
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
      ],
    );
  }
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
class _SnakeGame extends StatefulWidget { const _SnakeGame(); @override State<_SnakeGame> createState() => _SnakeGameState(); }
class _SnakeGameState extends State<_SnakeGame> {
  final Random _r = Random(); Timer? _tm;
  List<Point<int>> _s = const [Point(8,8), Point(7,8), Point(6,8)];
  Point<int> _f = const Point(4,4), _d = const Point(1,0);
  int _score=0; bool _run=false, _over=false;
  void _food(){do{_f=Point(_r.nextInt(16),_r.nextInt(16));}while(_s.contains(_f));}
  void _start(){_tm?.cancel();setState((){_s=const[Point(8,8),Point(7,8),Point(6,8)];_d=const Point(1,0);_score=0;_run=true;_over=false;_food();});_tm=Timer.periodic(const Duration(milliseconds:110),(_)=>_tick());}
  void _tick(){if(!_run||_over||!mounted)return;setState((){final h=_s.first,n=Point(h.x+_d.x,h.y+_d.y);if(n.x<0||n.x>=16||n.y<0||n.y>=16||_s.contains(n)){_over=true;_tm?.cancel();return;}var next=[n,..._s];if(n==_f){_score++;_s=next;_food();}else{next.removeLast();_s=next;}});}
  void _turn(Point<int> n){if(n.x+_d.x==0&&n.y+_d.y==0)return;_d=n;}
  void _restart(){_tm?.cancel();setState((){_run=false;_over=false;_score=0;_s=const[Point(8,8),Point(7,8),Point(6,8)];_food();});}
  @override void dispose(){_tm?.cancel();super.dispose();}
  @override Widget build(BuildContext c)=>_GameShell(title:'Snake',restart:_restart,child:Stack(children:[
    if(!_run)Positioned.fill(child:_GameStart(title:'Snake',description:'Makan food dan jangan tabrak diri sendiri.',details:'16 × 16 • OFFLINE',start:_start)),
    if(_run)Column(children:[
      Padding(padding:const EdgeInsets.all(10),child:Text('SCORE '+_score.toString(),style:const TextStyle(fontWeight:FontWeight.w900))),
      Expanded(child:Center(child:AspectRatio(aspectRatio:1,child:CustomPaint(painter:_SnakePainter(_s,_f))))),
      Row(mainAxisAlignment:MainAxisAlignment.center,children:[
        IconButton.filledTonal(onPressed:()=>_turn(const Point(-1,0)),icon:const Icon(Icons.arrow_back)),
        Column(children:[IconButton.filledTonal(onPressed:()=>_turn(const Point(0,-1)),icon:const Icon(Icons.arrow_upward)),IconButton.filledTonal(onPressed:()=>_turn(const Point(0,1)),icon:const Icon(Icons.arrow_downward))]),
        IconButton.filledTonal(onPressed:()=>_turn(const Point(1,0)),icon:const Icon(Icons.arrow_forward)),
      ]),
      const SizedBox(height:8),
    ]),
    if(_over)Positioned.fill(child:_GameOver(title:'GAME OVER',score:_score,restart:_restart)),
  ]));
}
class _SnakePainter extends CustomPainter{
  final List<Point<int>> s; final Point<int> f;
  _SnakePainter(this.s,this.f);
  @override void paint(Canvas c,Size z){final q=min(z.width,z.height)/16;c.drawRect(Offset.zero&z,Paint()..color=const Color(0xFF0B1220));c.drawCircle(Offset(f.x*q+q/2,f.y*q+q/2),q*.28,Paint()..color=Colors.redAccent);for(var i=s.length-1;i>=0;i--){final p=s[i];c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(p.x*q+2,p.y*q+2,q-4,q-4),const Radius.circular(6)),Paint()..color=i==0?Colors.cyanAccent:_hubPurple);}}
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
  Timer? _tm;final Random _r=Random();List<List<int>> _g=List.generate(20,(_)=>List<int>.filled(10,0));List<Point<int>> _p=const[Point(0,0),Point(1,0),Point(2,0),Point(3,0)];int _x=3,_y=0,_score=0;bool _run=false,_over=false;
  static const _shapes=<List<Point<int>>>[[Point(0,0),Point(1,0),Point(2,0),Point(3,0)],[Point(0,0),Point(1,0),Point(0,1),Point(1,1)],[Point(1,0),Point(0,1),Point(1,1),Point(2,1)],[Point(0,0),Point(1,0),Point(1,1),Point(2,1)]];
  bool _ok(List<Point<int>> p,int x,int y)=>p.every((a){final px=x+a.x,py=y+a.y;return px>=0&&px<10&&py>=0&&py<20&&_g[py][px]==0;});
  void _spawn(){_p=List<Point<int>>.from(_shapes[_r.nextInt(_shapes.length)]);_x=3;_y=0;if(!_ok(_p,_x,_y)){_over=true;_tm?.cancel();}}
  void _start(){_tm?.cancel();setState((){_g=List.generate(20,(_)=>List<int>.filled(10,0));_score=0;_run=true;_over=false;_spawn();});_tm=Timer.periodic(const Duration(milliseconds:520),(_)=>_drop());}
  void _drop(){if(!_run||_over||!mounted)return;if(_ok(_p,_x,_y+1)){setState(()=>_y++);}else{_lock();}}
  void _lock(){setState((){for(final a in _p){final px=_x+a.x,py=_y+a.y;if(px>=0&&px<10&&py>=0&&py<20)_g[py][px]=1;}for(var row=19;row>=0;row--){if(_g[row].every((v)=>v>0)){_g.removeAt(row);_g.insert(0,List<int>.filled(10,0));_score+=100;}}_spawn();});}
  void _move(int dx){if(_run&&!_over&&_ok(_p,_x+dx,_y))setState(()=>_x+=dx);}
  void _restart(){_tm?.cancel();setState((){_run=false;_over=false;_score=0;_g=List.generate(20,(_)=>List<int>.filled(10,0));});}
  @override void dispose(){_tm?.cancel();super.dispose();}
  @override Widget build(BuildContext c)=>_GameShell(title:'Tetris',restart:_restart,child:Column(children:[
    if(!_run)Expanded(child:_GameStart(title:'Tetris',description:'Susun blok dan bersihkan baris.',details:'10 × 20 • OFFLINE',start:_start)),
    if(_run)Padding(padding:const EdgeInsets.all(8),child:Text('SCORE '+_score.toString(),style:const TextStyle(fontWeight:FontWeight.w900))),
    if(_run)Expanded(child:Center(child:AspectRatio(aspectRatio:.5,child:CustomPaint(painter:_TetrisPainter(_g,_p,_x,_y))))),
    if(_run)Row(mainAxisAlignment:MainAxisAlignment.center,children:[IconButton.filledTonal(onPressed:()=>_move(-1),icon:const Icon(Icons.arrow_back)),IconButton.filledTonal(onPressed:_drop,icon:const Icon(Icons.arrow_downward)),IconButton.filledTonal(onPressed:()=>_move(1),icon:const Icon(Icons.arrow_forward))]),
    if(_over)Expanded(child:_GameOver(title:'GAME OVER',score:_score,restart:_restart)),
  ]));
}
class _TetrisPainter extends CustomPainter{
  final List<List<int>> g;final List<Point<int>> p;final int x,y;_TetrisPainter(this.g,this.p,this.x,this.y);
  @override void paint(Canvas c,Size s){final q=min(s.width/10,s.height/20);c.drawRect(Offset.zero&s,Paint()..color=const Color(0xFF090D17));for(var yy=0;yy<20;yy++)for(var xx=0;xx<10;xx++)c.drawRect(Rect.fromLTWH(xx*q,yy*q,q-1,q-1),Paint()..color=g[yy][xx]==0?const Color(0xFF141927):_hubPurple);for(final a in p)c.drawRect(Rect.fromLTWH((x+a.x)*q,(y+a.y)*q,q-1,q-1),Paint()..color=Colors.cyanAccent);}
  @override bool shouldRepaint(covariant _TetrisPainter old)=>true;
}

// 4 Flappy
class _FlappyGame extends StatefulWidget { const _FlappyGame(); @override State<_FlappyGame> createState()=>_FlappyGameState(); }
class _FlappyGameState extends State<_FlappyGame>{
  Timer? _tm;final Random _r=Random();double _y=.5,_v=0,_px=1.1,_gap=.5;int _score=0;bool _run=false,_over=false;
  void _start(){_tm?.cancel();setState((){_y=.5;_v=0;_px=1.1;_gap=.5;_score=0;_run=true;_over=false;});_tm=Timer.periodic(const Duration(milliseconds:16),(_)=>_tick());}
  void _tick(){if(!_run||_over||!mounted)return;setState((){_v+=.00052;_y+=_v;_px-=.006;if(_px<-.18){_px=1.1;_gap=.28+_r.nextDouble()*.38;_score++;}final hit=_px<.62&&_px>.30&&(_y<_gap-.15||_y>_gap+.15);if(_y<.02||_y>.98||hit){_over=true;_tm?.cancel();}});}
  void _flap(){if(_run&&!_over)setState(()=>_v=-.0105);}
  void _restart(){_tm?.cancel();setState((){_run=false;_over=false;_score=0;_y=.5;_v=0;_px=1.1;});}
  @override void dispose(){_tm?.cancel();super.dispose();}
  @override Widget build(BuildContext c)=>_GameShell(title:'Flappy',restart:_restart,child:GestureDetector(onTap:_flap,behavior:HitTestBehavior.opaque,child:Stack(children:[
    Positioned.fill(child:CustomPaint(painter:_FlappyPainter(_y,_px,_gap))),
    if(!_run)Positioned.fill(child:Container(color:Colors.black45,child:_GameStart(title:'Flappy',description:'Tap untuk terbang melewati pipa.',details:'ONE TAP • ENDLESS',start:_start))),
    if(_run)Positioned(top:12,left:12,child:_HubTag('SCORE '+_score.toString())),
    if(_over)Positioned.fill(child:_GameOver(title:'GAME OVER',score:_score,restart:_restart)),
  ])));
}
class _FlappyPainter extends CustomPainter{final double y,x,g;_FlappyPainter(this.y,this.x,this.g);@override void paint(Canvas c,Size s){c.drawRect(Offset.zero&s,Paint()..color=const Color(0xFF071522));final pipe=Paint()..color=Colors.green;c.drawRect(Rect.fromLTWH(x*s.width,0,s.width*.13,max(0,s.height*(g-.15))),pipe);c.drawRect(Rect.fromLTWH(x*s.width,s.height*(g+.15),s.width*.13,max(0,s.height*(.99-g-.15))),pipe);c.drawCircle(Offset(s.width*.5,y*s.height),18,Paint()..color=Colors.amber);}@override bool shouldRepaint(covariant _FlappyPainter old)=>true;}

// 5 Breakout
class _BreakoutGame extends StatefulWidget { const _BreakoutGame(); @override State<_BreakoutGame> createState()=>_BreakoutGameState(); }
class _BreakoutGameState extends State<_BreakoutGame>{
  Timer? _tm;double _x=.5,_y=.75,_vx=.008,_vy=-.010,_pad=.5;List<bool> _b=List<bool>.filled(30,true);int _score=0,_lives=3;bool _run=false,_over=false;
  void _start(){_tm?.cancel();setState((){_x=.5;_y=.75;_vx=.008;_vy=-.010;_pad=.5;_b=List<bool>.filled(30,true);_score=0;_lives=3;_run=true;_over=false;});_tm=Timer.periodic(const Duration(milliseconds:16),(_)=>_tick());}
  void _tick(){if(!_run||_over||!mounted)return;setState((){_x+=_vx;_y+=_vy;if(_x<.03||_x>.97){_vx=-_vx;_x=_x.clamp(.03,.97);}if(_y<.04)_vy=_vy.abs();if(_y>.88&&_y<.94&&(_x-_pad).abs()<.16&&_vy>0)_vy=-_vy.abs();final col=((_x-.08)/.18).floor(),row=((_y-.06)/.055).floor();if(col>=0&&col<5&&row>=0&&row<6){final i=row*5+col;if(_b[i]){_b[i]=false;_score+=10;_vy=-_vy;}}if(_y>1.03){_lives--;if(_lives<=0){_over=true;_tm?.cancel();}else{_x=.5;_y=.75;_vy=-.010;}}if(_b.every((v)=>!v)){_over=true;_tm?.cancel();}});}
  void _restart(){_tm?.cancel();setState((){_run=false;_over=false;_score=0;_lives=3;_b=List<bool>.filled(30,true);});}
  @override void dispose(){_tm?.cancel();super.dispose();}
  @override Widget build(BuildContext c)=>_GameShell(title:'Breakout',restart:_restart,child:Column(children:[
    if(!_run)Expanded(child:_GameStart(title:'Breakout',description:'Gerakkan paddle dan hancurkan semua brick.',details:'30 BRICKS • 3 LIVES',start:_start)),
    if(_run)Text('SCORE '+_score.toString()+'  •  LIVES '+_lives.toString(),style:const TextStyle(fontWeight:FontWeight.w900)),
    if(_run)Expanded(child:GestureDetector(onHorizontalDragUpdate:(d)=>setState(()=>_pad=(_pad+d.delta.dx/MediaQuery.sizeOf(c).width).clamp(.12,.88)),child:CustomPaint(painter:_BreakoutPainter(_x,_y,_pad,_b)))),
    if(_over)Expanded(child:_GameOver(title:_b.every((v)=>!v)?'YOU WIN':'GAME OVER',score:_score,restart:_restart)),
  ]));
}
class _BreakoutPainter extends CustomPainter{final double x,y,pad;final List<bool>b;_BreakoutPainter(this.x,this.y,this.pad,this.b);@override void paint(Canvas c,Size s){c.drawRect(Offset.zero&s,Paint()..color=const Color(0xFF090D17));for(var i=0;i<30;i++)if(b[i]){final col=i%5,row=i~/5;c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*(.08+col*.18),s.height*(.06+row*.055),s.width*.15,s.height*.04),const Radius.circular(5)),Paint()..color=_hubPurple);}c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width*(pad-.12),s.height*.92,s.width*.24,12),const Radius.circular(8)),Paint()..color=Colors.white);c.drawCircle(Offset(x*s.width,y*s.height),8,Paint()..color=Colors.cyanAccent);}@override bool shouldRepaint(covariant _BreakoutPainter old)=>true;}

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
  Timer? _tm;final Random _r=Random();double _x=.5,_y=.5,_vx=.008,_vy=.006,_me=.5,_ai=.5;int _you=0,_cpu=0;bool _run=false,_over=false;
  void _start(){_tm?.cancel();setState((){_x=.5;_y=.5;_vx=.008;_vy=.006;_me=.5;_ai=.5;_you=0;_cpu=0;_run=true;_over=false;});_tm=Timer.periodic(const Duration(milliseconds:16),(_)=>_tick());}
  void _resetBall(){_x=.5;_y=.5;_vx=_vx>0 ? .008 : -.008;_vy=_r.nextBool() ? .006 : -.006;}
  void _tick(){if(!_run||_over||!mounted)return;setState((){_x+=_vx;_y+=_vy;if(_y<.04||_y>.96)_vy=-_vy;_ai+=(_y-_ai)*.055;if(_x<.09){if((_y-_me).abs()<.15)_vx=_vx.abs();else{_cpu++;_resetBall();}}if(_x>.91){if((_y-_ai).abs()<.15)_vx=-_vx.abs();else{_you++;_resetBall();}}if(_you>=7||_cpu>=7){_over=true;_tm?.cancel();}});}
  void _player(double v){if(_run&&!_over)setState(()=>_me=v.clamp(.08,.92).toDouble());}
  void _restart(){_tm?.cancel();setState((){_run=false;_over=false;_you=0;_cpu=0;});}
  @override void dispose(){_tm?.cancel();super.dispose();}
  @override Widget build(BuildContext c)=>_GameShell(title:'Pong',restart:_restart,child:Column(children:[
    if(!_run)Expanded(child:_GameStart(title:'Pong',description:'Geser paddle untuk mengalahkan CPU.',details:'FIRST TO 7 • VS CPU',start:_start)),
    if(_run)Text('YOU '+_you.toString()+'  •  CPU '+_cpu.toString(),style:const TextStyle(fontWeight:FontWeight.w900)),
    if(_run)Expanded(child:LayoutBuilder(builder:(context,z)=>GestureDetector(onVerticalDragUpdate:(d)=>_player(d.localPosition.dy/z.maxHeight),onTapDown:(d)=>_player(d.localPosition.dy/z.maxHeight),child:CustomPaint(painter:_PongPainter(_x,_y,_me,_ai))))),
    if(_over)Expanded(child:_GameOver(title:_you>_cpu?'YOU WIN':'CPU WINS',score:_you,restart:_restart)),
  ]));
}
class _PongPainter extends CustomPainter{final double x,y,me,ai;_PongPainter(this.x,this.y,this.me,this.ai);@override void paint(Canvas c,Size s){c.drawRect(Offset.zero&s,Paint()..color=const Color(0xFF08111F));for(double y=0;y<s.height;y+=24)c.drawRect(Rect.fromLTWH(s.width/2,y,2,12),Paint()..color=Colors.white12);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(10,me*s.height-42,10,84),const Radius.circular(6)),Paint()..color=Colors.cyanAccent);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width-20,ai*s.height-42,10,84),const Radius.circular(6)),Paint()..color=_hubPurple);c.drawCircle(Offset(x*s.width,y*s.height),9,Paint()..color=Colors.white);}@override bool shouldRepaint(covariant _PongPainter old)=>true;}

// 8 Whack
class _WhackGame extends StatefulWidget { const _WhackGame(); @override State<_WhackGame> createState()=>_WhackGameState(); }
class _WhackGameState extends State<_WhackGame>{
  Timer? _tm;final Random _r=Random();int _active=0,_score=0,_time=30;bool _run=false,_over=false;
  void _start(){_tm?.cancel();setState((){_active=_r.nextInt(9);_score=0;_time=30;_run=true;_over=false;});_tm=Timer.periodic(const Duration(seconds:1),(_){if(!mounted)return;setState((){_time--;_active=_r.nextInt(9);if(_time<=0){_run=false;_over=true;_tm?.cancel();}});});}
  void _hit(int i){if(_run&&!_over&&i==_active)setState((){_score++;_active=_r.nextInt(9);});}
  void _restart(){_tm?.cancel();setState((){_run=false;_over=false;_score=0;_time=30;_active=0;});}
  @override void dispose(){_tm?.cancel();super.dispose();}
  @override Widget build(BuildContext c)=>_GameShell(title:'Whack-a-Mole',restart:_restart,child:Stack(children:[
    if(!_run&&!_over)Positioned.fill(child:_GameStart(title:'Whack-a-Mole',description:'Tap target secepat mungkin.',details:'30 SECONDS • FAST TAP',start:_start)),
    if(_run)Padding(padding:const EdgeInsets.all(16),child:Column(children:[Text('TIME '+_time.toString()+'  •  SCORE '+_score.toString(),style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:14),Expanded(child:GridView.builder(itemCount:9,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:12,mainAxisSpacing:12),itemBuilder:(_,i)=>InkWell(onTap:()=>_hit(i),borderRadius:BorderRadius.circular(22),child:Container(decoration:BoxDecoration(color:const Color(0xFF151B2A),borderRadius:BorderRadius.circular(22),border:Border.all(color:Colors.white10)),child:Center(child:Icon(i==_active?Icons.bolt_rounded:Icons.circle_outlined,size:i==_active?58:34,color:i==_active?Colors.amber:Colors.white12))))))])),
    if(_over)Positioned.fill(child:_GameOver(title:'TIME UP',score:_score,restart:_restart)),
  ]));
}

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
  final Random _r=Random();final List<Color> _colors=const[Colors.red,Colors.green,Colors.blue,Colors.amber];final List<int> _seq=[];Timer? _tm;int _step=0,_flash=-1,_round=0;bool _run=false,_accept=false,_over=false;
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

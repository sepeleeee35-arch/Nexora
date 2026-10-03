import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

String? nexoraActiveAccountId;

const bg = Color(0xFF05070D);
const panel = Color(0xFF0D1320);
const purple = Color(0xFF8B5CF6);

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
  ];

  Widget openGame(String name) {
    switch (name) {
      case '2048': return const _Twenty();
      case 'Tetris': return const _Tetris();
      case 'Flappy': return const _Flappy();
      case 'Breakout': return const _Breakout();
      case 'Memory': return const _Memory();
      default: return const _Twenty();
    }
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
                  const Text('Five polished mini-games • instant play • touch-first controls.', style: TextStyle(color: Colors.white60, height: 1.35)),
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
  final VoidCallback onTap;
  const _GameCard(this.game, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(24),
    child: Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: game.color.withOpacity(.08), blurRadius: 20, offset: const Offset(0, 8))],
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [game.color.withOpacity(.20), panel], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: game.color.withOpacity(.25)),
      ),
      child: Stack(children: [
        Positioned(right: -18, top: -18, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: game.color.withOpacity(.09)))),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: game.color.withOpacity(.16), borderRadius: BorderRadius.circular(17)),
              child: Icon(game.icon, color: game.color, size: 27),
            ),
            const Spacer(),
            Text(game.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -.3)),
            const SizedBox(height: 3),
            Text(game.subtitle, maxLines: 2, style: const TextStyle(fontSize: 11, color: Colors.white54, height: 1.25)),
            const SizedBox(height: 11),
            Row(children: [
              Text(game.category, style: TextStyle(fontSize: 9, color: game.color, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const Spacer(),
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(color: Colors.white.withOpacity(.08), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, size: 18),
              ),
            ]),
          ]),
        ),
      ]),
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
  const _Twenty();
  @override State<_Twenty> createState() => _TwentyState();
}
class _TwentyState extends State<_Twenty> {
  final random = Random();
  List<int> board = List.filled(16, 0);
  List<int> previous = List.filled(16, 0);
  int score = 0, best = 0, previousScore = 0;
  bool gameOver = false;

  @override void initState() { super.initState(); _reset(); }
  void _reset() {
    board = List.filled(16, 0);
    previous = List.filled(16, 0);
    score = 0;
    previousScore = 0;
    gameOver = false;
    _spawn();
    _spawn();
  }
  void _spawn() {
    final empty = <int>[for (var i = 0; i < 16; i++) if (board[i] == 0) i];
    if (empty.isNotEmpty) board[empty[random.nextInt(empty.length)]] = random.nextDouble() < .9 ? 2 : 4;
  }
  List<int> _merge(List<int> line) {
    final values = line.where((v) => v != 0).toList();
    final out = <int>[];
    var i = 0;
    while (i < values.length) {
      if (i + 1 < values.length && values[i] == values[i + 1]) {
        final merged = values[i] * 2;
        out.add(merged);
        score += merged;
        i += 2;
      } else {
        out.add(values[i]);
        i++;
      }
    }
    while (out.length < 4) out.add(0);
    return out;
  }
  bool _canMove() {
    if (board.contains(0)) return true;
    for (var y = 0; y < 4; y++) {
      for (var x = 0; x < 4; x++) {
        final v = board[y * 4 + x];
        if (x < 3 && board[y * 4 + x + 1] == v) return true;
        if (y < 3 && board[(y + 1) * 4 + x] == v) return true;
      }
    }
    return false;
  }
  void _move(int dx, int dy) {
    if (gameOver) return;
    final oldBoard = List<int>.from(board);
    final oldScore = score;
    final next = List<int>.filled(16, 0);

    for (var line = 0; line < 4; line++) {
      final values = <int>[];
      for (var pos = 0; pos < 4; pos++) {
        final x = dx != 0 ? (dx > 0 ? 3 - pos : pos) : line;
        final y = dy != 0 ? (dy > 0 ? 3 - pos : pos) : line;
        values.add(board[y * 4 + x]);
      }
      final merged = _merge(values);
      for (var pos = 0; pos < 4; pos++) {
        final x = dx != 0 ? (dx > 0 ? 3 - pos : pos) : line;
        final y = dy != 0 ? (dy > 0 ? 3 - pos : pos) : line;
        next[y * 4 + x] = merged[pos];
      }
    }

    if (next.toString() != oldBoard.toString()) {
      previous = oldBoard;
      previousScore = oldScore;
      board = next;
      _spawn();
      best = max(best, score);
      if (!_canMove()) gameOver = true;
    }
    setState(() {});
  }
  Color _tile(int value) {
    if (value == 0) return Colors.white.withOpacity(.045);
    final t = min(1.0, log(max(2, value)) / log(4096));
    return Color.lerp(const Color(0xFFF59E0B), const Color(0xFF8B5CF6), t)!;
  }

  @override
  Widget build(BuildContext context) => _GamePage(
    title: '2048', subtitle: 'Merge Rush • think ahead', accent: const Color(0xFFF59E0B),
    reset: () => setState(_reset),
    child: GestureDetector(
      onHorizontalDragEnd: (d) { final v = d.primaryVelocity ?? 0; if (v != 0) _move(v > 0 ? 1 : -1, 0); },
      onVerticalDragEnd: (d) { final v = d.primaryVelocity ?? 0; if (v != 0) _move(0, v > 0 ? 1 : -1); },
      child: _World(
        top: const Color(0xFF24170A), bottom: const Color(0xFF080A13),
        child: Column(children: [
          _ScoreBar('SCORE $score', 'BEST $best', const Color(0xFFF59E0B)),
          Expanded(child: Center(child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              margin: const EdgeInsets.all(18), padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(25), border: Border.all(color: const Color(0xFFF59E0B).withOpacity(.18))),
              child: GridView.count(
                crossAxisCount: 4, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 8, mainAxisSpacing: 8,
                children: board.map((v) => AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(color: _tile(v), borderRadius: BorderRadius.circular(15)),
                  child: Center(child: Text(v == 0 ? '' : '$v', style: TextStyle(fontSize: v >= 1024 ? 19 : 27, fontWeight: FontWeight.w900))),
                )).toList(),
              ),
            ),
          ))),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: Row(children: [
              Expanded(child: Text(gameOver ? 'NO MORE MOVES' : 'SWIPE TO MERGE', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
              IconButton(
                onPressed: previous.every((v) => v == 0) ? null : () => setState(() { board = List<int>.from(previous); score = previousScore; gameOver = false; previous = List.filled(16, 0); }),
                icon: const Icon(Icons.undo_rounded),
              ),
              if (gameOver) FilledButton.icon(onPressed: () => setState(_reset), icon: const Icon(Icons.refresh_rounded, size: 17), label: const Text('RETRY')),
            ]),
          ),
        ]),
      ),
    ),
  );
}

class _Tetris extends StatefulWidget {
  const _Tetris();
  @override State<_Tetris> createState() => _TetrisState();
}
class _TetrisState extends State<_Tetris> {
  final random = Random();
  final board = List<int>.filled(200, 0);
  final shapes = const [
    [[1,1,1,1]],
    [[1,1],[1,1]],
    [[0,1,0],[1,1,1]],
    [[1,0,0],[1,1,1]],
    [[0,0,1],[1,1,1]],
    [[0,1,1],[1,1,0]],
    [[1,1,0],[0,1,1]],
  ];
  final colors = const [
    Colors.transparent, Color(0xFF22D3EE), Color(0xFFFACC15), Color(0xFFA78BFA),
    Color(0xFF60A5FA), Color(0xFFFB923C), Color(0xFF4ADE80), Color(0xFFF87171),
  ];
  Timer? timer;
  late int current, next, activeKind;
  late List<List<int>> shape;
  int row = 0, col = 3, score = 0, lines = 0, level = 1;
  bool running = false, over = false;

  @override void initState() { super.initState(); _reset(); }
  void _reset() {
    timer?.cancel();
    for (var i = 0; i < board.length; i++) board[i] = 0;
    current = random.nextInt(shapes.length);
    next = random.nextInt(shapes.length);
    score = 0; lines = 0; level = 1; running = false; over = false;
    _load();
  }
  void _load() {
    activeKind = current;
    shape = shapes[activeKind].map((r) => List<int>.from(r)).toList();
    row = 0; col = 3;
    current = next; next = random.nextInt(shapes.length);
  }
  bool _can(int r, int c, List<List<int>> s) {
    for (var y = 0; y < s.length; y++) {
      for (var x = 0; x < s[y].length; x++) {
        if (s[y][x] == 0) continue;
        final xx = c + x, yy = r + y;
        if (xx < 0 || xx >= 10 || yy >= 20) return false;
        if (board[yy * 10 + xx] != 0) return false;
      }
    }
    return true;
  }
  void _start() {
    if (running || over) return;
    running = true;
    _clock();
    setState(() {});
  }
  void _clock() {
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: max(120, 560 - level * 40)), (_) => _tick());
  }
  void _tick() {
    if (!mounted || !running) return;
    if (_can(row + 1, col, shape)) {
      row++;
      setState(() {});
    } else {
      _lock();
    }
  }
  void _softDrop() {
    if (!running) { _start(); return; }
    if (_can(row + 1, col, shape)) { row++; score++; setState(() {}); } else { _lock(); }
  }
  void _rotate() {
    if (!running) { _start(); return; }
    final h = shape.length, w = shape[0].length;
    final rotated = List.generate(w, (_) => List<int>.filled(h, 0));
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) rotated[x][h - 1 - y] = shape[y][x];
    }
    if (_can(row, col, rotated)) { shape = rotated; setState(() {}); }
  }
  void _lock() {
    for (var y = 0; y < shape.length; y++) {
      for (var x = 0; x < shape[y].length; x++) {
        if (shape[y][x] != 0 && row + y >= 0) board[(row + y) * 10 + col + x] = activeKind + 1;
      }
    }
    var cleared = 0;
    for (var y = 19; y >= 0; y--) {
      var full = true;
      for (var x = 0; x < 10; x++) if (board[y * 10 + x] == 0) full = false;
      if (full) {
        for (var yy = y; yy > 0; yy--) {
          for (var x = 0; x < 10; x++) board[yy * 10 + x] = board[(yy - 1) * 10 + x];
        }
        for (var x = 0; x < 10; x++) board[x] = 0;
        cleared++;
        y++;
      }
    }
    if (cleared > 0) {
      lines += cleared;
      score += cleared * cleared * 100 * level;
      level = 1 + lines ~/ 10;
      _clock();
    }
    _load();
    if (!_can(row, col, shape)) {
      running = false; over = true; timer?.cancel();
    }
    setState(() {});
  }
  @override void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => _GamePage(
    title: 'Tetris', subtitle: 'Drop Zone • build clean lines', accent: const Color(0xFFA78BFA),
    reset: () => setState(_reset),
    child: GestureDetector(
      onHorizontalDragUpdate: (d) {
        if (!running) return;
        if (d.delta.dx > 3 && _can(row, col + 1, shape)) col++;
        if (d.delta.dx < -3 && _can(row, col - 1, shape)) col--;
        setState(() {});
      },
      onVerticalDragUpdate: (d) { if (d.delta.dy > 7) _softDrop(); },
      onTap: _rotate,
      child: _World(
        top: const Color(0xFF17112A), bottom: const Color(0xFF070914),
        child: Column(children: [
          _ScoreBar('SCORE $score', 'LINES $lines • LVL $level', const Color(0xFFA78BFA)),
          Expanded(child: Center(child: AspectRatio(
            aspectRatio: .52,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFA78BFA).withOpacity(.22))),
              child: CustomPaint(painter: _TetrisPainter(board, shape, row, col, colors[activeKind + 1]), child: const SizedBox.expand()),
            ),
          ))),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 15),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('NEXT', style: TextStyle(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text('PIECE ${next + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900))]),
              const Spacer(),
              FilledButton(onPressed: over ? () => setState(_reset) : _start, child: Text(over ? 'PLAY AGAIN' : (running ? 'DROP' : 'START'))),
            ]),
          ),
        ]),
      ),
    ),
  );
}

class _TetrisPainter extends CustomPainter {
  final List<int> board;
  final List<List<int>> shape;
  final int row, col;
  final Color active;
  const _TetrisPainter(this.board, this.shape, this.row, this.col, this.active);
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 10;
    final paint = Paint();
    for (var y = 0; y < 20; y++) {
      for (var x = 0; x < 10; x++) {
        paint.color = Colors.white.withOpacity(.025);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x * cell + 1, y * cell + 1, cell - 2, cell - 2), const Radius.circular(4)), paint);
        final v = board[y * 10 + x];
        if (v > 0) {
          paint.color = _colors[v];
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x * cell + 2, y * cell + 2, cell - 4, cell - 4), const Radius.circular(5)), paint);
        }
      }
    }
    paint.color = active;
    for (var y = 0; y < shape.length; y++) {
      for (var x = 0; x < shape[y].length; x++) {
        if (shape[y][x] == 0) continue;
        final yy = row + y, xx = col + x;
        if (yy >= 0 && xx >= 0 && xx < 10 && yy < 20) {
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(xx * cell + 2, yy * cell + 2, cell - 4, cell - 4), const Radius.circular(5)), paint);
        }
      }
    }
  }
  static const _colors = [
    Colors.transparent, Color(0xFF22D3EE), Color(0xFFFACC15), Color(0xFFA78BFA),
    Color(0xFF60A5FA), Color(0xFFFB923C), Color(0xFF4ADE80), Color(0xFFF87171),
  ];
  @override bool shouldRepaint(covariant _TetrisPainter old) => true;
}

class _Flappy extends StatefulWidget {
  const _Flappy();
  @override State<_Flappy> createState() => _FlappyState();
}
class _FlappyState extends State<_Flappy> {
  Timer? timer;
  double birdY = .48, velocity = 0, pipeX = 1.08, gap = .48;
  int score = 0, best = 0;
  bool running = false, over = false;
  final random = Random();

  void _reset() {
    timer?.cancel();
    birdY = .48; velocity = 0; pipeX = 1.08; gap = .48;
    score = 0; running = false; over = false;
  }
  void _flap() {
    if (!running) {
      if (over) _reset();
      running = true;
      timer = Timer.periodic(const Duration(milliseconds: 28), (_) => _tick());
    }
    velocity = -.030;
    setState(() {});
  }
  void _tick() {
    if (!mounted) return;
    birdY += velocity;
    velocity += .00165;
    pipeX -= .0105;
    if (pipeX < -.18) {
      pipeX = 1.05;
      gap = .27 + random.nextDouble() * .45;
      score++;
      best = max(best, score);
    }
    if (birdY < .035 || birdY > .965 || (pipeX < .21 && pipeX > .01 && (birdY < gap - .18 || birdY > gap + .18))) {
      running = false;
      over = true;
      timer?.cancel();
    }
    setState(() {});
  }
  @override void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => _GamePage(
    title: 'Flappy', subtitle: 'Sky Dash • one-tap flight', accent: const Color(0xFF22D3EE),
    reset: () => setState(_reset),
    child: GestureDetector(
      onTap: _flap,
      child: _World(
        top: const Color(0xFF06233E), bottom: const Color(0xFF0B3F45),
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _FlappyPainter(birdY, pipeX, gap))),
          Positioned(top: 18, left: 0, right: 0, child: Column(children: [
            Text('$score', style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w900)),
            Text('BEST $best', style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ])),
          if (!running) Center(child: Container(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 18),
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.flutter_dash_rounded, color: Color(0xFFFDE047), size: 52),
              const SizedBox(height: 8),
              Text(over ? 'TRY AGAIN' : 'SKY DASH', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('TAP TO FLAP • AVOID THE GATES', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ]),
          )),
        ]),
      ),
    ),
  );
}

class _FlappyPainter extends CustomPainter {
  final double birdY, pipeX, gap;
  const _FlappyPainter(this.birdY, this.pipeX, this.gap);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    p.color = Colors.white.withOpacity(.07);
    for (var i = 0; i < 12; i++) {
      canvas.drawCircle(Offset((i * 91.0) % size.width, 65 + (i * 53.0) % max(1.0, size.height)), 2, p);
    }
    final px = pipeX * size.width;
    final top = (gap - .18) * size.height;
    final bottom = (gap + .18) * size.height;
    p.color = const Color(0xFF0EA5E9);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(px, 0, 54, top), const Radius.circular(12)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(px, bottom, 54, size.height - bottom), const Radius.circular(12)), p);
    p.color = const Color(0xFF67E8F9);
    canvas.drawRect(Rect.fromLTWH(px - 4, max(0, top - 10), 62, 10), p);
    canvas.drawRect(Rect.fromLTWH(px - 4, bottom, 62, 10), p);
    final by = birdY * size.height;
    p.color = const Color(0xFFFDE047);
    canvas.drawCircle(Offset(size.width * .19, by), 18, p);
    p.color = Colors.white;
    canvas.drawCircle(Offset(size.width * .20, by - 5), 4, p);
    p.color = Colors.black;
    canvas.drawCircle(Offset(size.width * .20, by - 5), 2, p);
    p.color = const Color(0xFFF59E0B);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * .19 + 17, by + 4), width: 18, height: 8), p);
  }
  @override bool shouldRepaint(covariant _FlappyPainter old) => true;
}

class _Breakout extends StatefulWidget {
  const _Breakout();
  @override State<_Breakout> createState() => _BreakoutState();
}
class _BreakoutState extends State<_Breakout> {
  final blocks = List<int>.filled(48, 1);
  Timer? timer;
  double ballX = .5, ballY = .78, vx = .009, vy = -.014, paddle = .5;
  int score = 0, lives = 3, combo = 0;
  bool running = false, over = false;

  void _reset() {
    timer?.cancel();
    for (var i = 0; i < blocks.length; i++) blocks[i] = 1;
    ballX = .5; ballY = .78; vx = .009; vy = -.014; paddle = .5;
    score = 0; lives = 3; combo = 0; running = false; over = false;
  }
  void _start() {
    if (running || over) return;
    running = true;
    timer = Timer.periodic(const Duration(milliseconds: 20), (_) => _tick());
    setState(() {});
  }
  void _tick() {
    ballX += vx; ballY += vy;
    if (ballX < .025 || ballX > .975) { vx = -vx; ballX = ballX.clamp(.025, .975).toDouble(); }
    if (ballY < .05) { vy = vy.abs(); ballY = .05; }
    if (ballY > .86 && ballY < .95 && (ballX - paddle).abs() < .16 && vy > 0) {
      final offset = (ballX - paddle) / .16;
      vx = (vx + offset * .004).clamp(-.018, .018).toDouble();
      vy = -vy.abs();
      combo++;
    }
    final col = ((ballX * 8).floor().clamp(0, 7)).toInt();
    final row = (((ballY - .09) / .055).floor().clamp(0, 5)).toInt();
    final index = row * 8 + col;
    if (ballY > .08 && ballY < .43 && blocks[index] != 0) {
      blocks[index] = 0;
      score += 10 + combo * 2;
      combo++;
      vy = -vy;
    }
    if (ballY > 1.03) {
      lives--;
      combo = 0;
      ballX = .5; ballY = .78; vx = .009; vy = -.014;
      if (lives <= 0) { running = false; over = true; timer?.cancel(); }
    }
    if (blocks.every((v) => v == 0)) { running = false; over = true; timer?.cancel(); }
    setState(() {});
  }
  @override void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => _GamePage(
    title: 'Breakout', subtitle: 'Brick Rush • build your combo', accent: const Color(0xFFEF4444),
    reset: () => setState(_reset),
    child: GestureDetector(
      onTap: _start,
      onHorizontalDragUpdate: (d) {
        paddle = (paddle + d.delta.dx / MediaQuery.sizeOf(context).width).clamp(.12, .88).toDouble();
        setState(() {});
      },
      child: _World(
        top: const Color(0xFF200A13), bottom: const Color(0xFF070914),
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _BreakoutPainter(blocks, ballX, ballY, paddle))),
          Positioned(top: 16, left: 16, right: 16, child: Row(children: [
            Text('SCORE $score', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            const Spacer(),
            Text('LIVES $lives', style: const TextStyle(color: Color(0xFFFCA5A5), fontWeight: FontWeight.w900, fontSize: 12)),
          ])),
          if (!running) Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15), decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)), child: Text(over ? (lives <= 0 ? 'GAME OVER' : 'LEVEL CLEAR') : 'DRAG PADDLE • TAP TO START', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: .8)))),
        ]),
      ),
    ),
  );
}

class _BreakoutPainter extends CustomPainter {
  final List<int> blocks;
  final double ballX, ballY, paddle;
  const _BreakoutPainter(this.blocks, this.ballX, this.ballY, this.paddle);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    const rowColors = [Color(0xFFF87171), Color(0xFFFB923C), Color(0xFFFACC15), Color(0xFF4ADE80), Color(0xFF22D3EE), Color(0xFFA78BFA)];
    for (var row = 0; row < 6; row++) {
      for (var col = 0; col < 8; col++) {
        if (blocks[row * 8 + col] == 0) continue;
        p.color = rowColors[row];
        final rect = Rect.fromLTWH(col * size.width / 8 + 4, 55 + row * 31, size.width / 8 - 8, 24);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(7)), p);
        p.color = Colors.white.withOpacity(.18);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rect.left + 3, rect.top + 3, rect.width - 6, 5), const Radius.circular(3)), p);
      }
    }
    p.color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH((paddle - .13) * size.width, size.height * .91, .26 * size.width, 13), const Radius.circular(8)), p);
    p.color = const Color(0xFFFCA5A5);
    canvas.drawCircle(Offset(ballX * size.width, ballY * size.height), 8, p);
  }
  @override bool shouldRepaint(covariant _BreakoutPainter old) => true;
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
  ];
  final colors = const [
    Color(0xFF22D3EE), Color(0xFFF59E0B), Color(0xFFA78BFA), Color(0xFFEC4899),
    Color(0xFF34D399), Color(0xFFFB7185), Color(0xFF60A5FA), Color(0xFFF97316),
  ];
  late List<int> cards;
  final open = <int>[];
  final matched = <int>{};
  int moves = 0, streak = 0, bestStreak = 0;
  bool locked = false;

  @override void initState() { super.initState(); _reset(); }
  void _reset() {
    cards = <int>[for (var i = 0; i < 8; i++) ...[i, i]]..shuffle(random);
    open.clear(); matched.clear();
    moves = 0; streak = 0; bestStreak = 0; locked = false;
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
            locked = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => _GamePage(
    title: 'Memory', subtitle: 'Match Lab • build your streak', accent: const Color(0xFFEC4899),
    reset: () => setState(_reset),
    child: _World(
      top: const Color(0xFF180B1C), bottom: const Color(0xFF070914),
      child: Column(children: [
        _ScoreBar('MOVES $moves', 'STREAK $streak', const Color(0xFFEC4899)),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10),
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

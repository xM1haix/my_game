import "dart:math";
import "dart:ui";

import "package:flame/components.dart";
import "package:flame/game.dart";

class MyGame extends FlameGame {
  late TerrainManager terrain;

  double time = 0;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.zoom = 1.0;

    terrain = TerrainManager();
    await add(terrain);
  }

  @override
  void update(double dt) {
    super.update(dt);

    time += dt;
    camera.viewfinder.position.x = time * 40;
    if (time % 2 < dt) {
      terrain.randomModify();
    }
  }
}

class TerrainChunk extends PositionComponent {
  TerrainChunk(this.chunkX, this.chunkY);
  static const chunkSize = 16;
  static const double tileSize = 32;
  final int chunkX;
  final int chunkY;
  late List<List<double>> heightMap;
  var dirty = true;
  Picture? cachedPicture;
  void drawTerrain(Canvas canvas) {
    final paint = Paint();

    for (var x = 0; x < chunkSize; x++) {
      for (var y = 0; y < chunkSize; y++) {
        final height = heightMap[x][y];

        final worldX = x * tileSize;
        final worldY = y * tileSize;

        // fake depth using height
        final projected = project(worldX, worldY, height * 10);

        final rect = Rect.fromLTWH(
          projected.x,
          projected.y - height,
          tileSize,
          tileSize,
        );

        // simple shading based on height
        final shade = (120 + height * 3).clamp(0, 255).toInt();

        paint.color = Color.fromARGB(255, 50, shade, 50);

        canvas.drawRect(rect, paint);
      }
    }
  }

  /// Modify terrain dynamically
  void modify(int x, int y, double delta) {
    heightMap[x][y] = (heightMap[x][y] + delta).clamp(0, 40);
    dirty = true;
  }

  @override
  Future<void> onLoad() async {
    position = Vector2(
      chunkX * chunkSize * tileSize,
      chunkY * chunkSize * tileSize,
    );

    size = Vector2.all(chunkSize * tileSize);

    final rand = Random(chunkX * 9999 + chunkY);

    // generate height map
    heightMap = List.generate(
      chunkSize,
      (x) => List.generate(chunkSize, (y) => rand.nextDouble() * 20),
    );
  }

  /// Perspective projection
  Vector2 project(double x, double y, double z) {
    const depth = 600.0;
    final scale = depth / (depth + z);

    return Vector2(x * scale, y * scale);
  }

  /// Rebuild cached drawing only when dirty
  void rebuildPicture() {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    drawTerrain(canvas);

    cachedPicture = recorder.endRecording();
  }

  @override
  void render(Canvas canvas) {
    if (dirty || cachedPicture == null) {
      rebuildPicture();
      dirty = false;
    }

    canvas.drawPicture(cachedPicture!);
  }
}

class TerrainManager extends Component {
  static const radius = 2;

  final Map<Point<int>, TerrainChunk> chunks = {};

  @override
  Future<void> onLoad() async {
    for (var x = -radius; x <= radius; x++) {
      for (var y = -radius; y <= radius; y++) {
        final chunk = TerrainChunk(x, y);
        chunks[Point(x, y)] = chunk;
        await add(chunk);
      }
    }
  }

  void randomModify() {
    if (chunks.isEmpty) return;
    chunks.values
        .elementAt(Random().nextInt(chunks.length))
        .modify(
          Random().nextInt(TerrainChunk.chunkSize),
          Random().nextInt(TerrainChunk.chunkSize),
          Random().nextDouble() * 20 - 10,
        );
  }
}

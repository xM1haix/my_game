import "package:flame/collisions.dart";
import "package:flame/components.dart";
import "package:flame/effects.dart";
import "package:flame/events.dart";
import "package:flame/game.dart";
import "package:flutter/material.dart";

void main() {
  runApp(const GameWidget.controlled(gameFactory: AgeOfEmpiresClone.new));
}

class AgeOfEmpiresClone extends FlameGame
    with DragCallbacks, ScrollDetector, SecondaryTapCallbacks {
  late final World gameWorld;
  UnitComponent? selectedUnit;

  @override
  void onDragUpdate(DragUpdateEvent event) =>
      camera.viewfinder.position -= event.localDelta;

  @override
  Future<void> onLoad() async {
    gameWorld = World();
    camera = CameraComponent(world: gameWorld);

    // 1. Add terrain first
    await gameWorld.add(ProceduralIsometricMap());

    // 2. Add the unit (higher priority ensures it's "on top" for clicks)
    await gameWorld.add(UnitComponent(position: Vector2(0, 0), priority: 1));

    addAll([gameWorld, camera]);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    final newZoom =
        camera.viewfinder.zoom - (info.scrollDelta.global.y * 0.001);
    camera.viewfinder.zoom = newZoom.clamp(0.2, 3.0);
  }

  // --- RIGHT CLICK TO MOVE ---
  @override
  Future<void> onSecondaryTapDown(SecondaryTapDownEvent event) async {
    if (selectedUnit != null) {
      final worldPosition = camera.viewport.position;
      selectedUnit!.moveTo(worldPosition);
    }
  }
}

// -------------------------------------------------------------------
// TERRAIN (Same as before, simplified for this example)
// -------------------------------------------------------------------
class ProceduralIsometricMap extends Component
    with TapCallbacks, HasGameReference<AgeOfEmpiresClone> {
  @override
  void onTapDown(TapDownEvent event) {
    // If we click the empty grass, deselect the unit
    game.selectedUnit?.isSelected = false;
    game.selectedUnit = null;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF4CAF50);
    for (var r = 0; r < 20; r++) {
      for (var c = 0; c < 20; c++) {
        final x = (c - r) * 32.0;
        final y = (c + r) * 16.0;
        final path = Path()
          ..moveTo(x, y - 16)
          ..lineTo(x + 32, y)
          ..lineTo(x, y + 16)
          ..lineTo(x - 32, y)
          ..close();
        canvas.drawPath(
          path,
          paint
            ..color = (c + r).isEven
                ? const Color(0xFF4CAF50)
                : const Color(0xFF43A047),
        );
      }
    }
  }
}

// -------------------------------------------------------------------
// THE UNIT COMPONENT (The "Soldier")
// -------------------------------------------------------------------
class UnitComponent extends PositionComponent
    with TapCallbacks, HasGameReference<AgeOfEmpiresClone> {
  UnitComponent({required Vector2 position, int priority = 0})
    : super(
        position: position,
        size: Vector2(40, 60),
        anchor: Anchor.bottomCenter,
        priority: priority, // Ensures it renders/overlaps correctly
      );

  var isSelected = false;

  void moveTo(Vector2 target) {
    removeAll(children.query<MoveToEffect>());
    final duration = position.distanceTo(target) / 200;
    add(MoveToEffect(target, EffectController(duration: duration)));
  }

  @override
  Future<void> onLoad() async {
    // CRITICAL: Flame needs a hitbox to register taps reliably
    add(RectangleHitbox());
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Print to console to verify the click is working
    print("Unit clicked!");

    // Deselect existing
    game.selectedUnit?.isSelected = false;

    // Select this
    isSelected = true;
    game.selectedUnit = this;

    // Tell Flame the event is handled so the map doesn't get it
    event.handled = true;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = isSelected ? Colors.yellow : Colors.blue;
    canvas.drawRect(size.toRect(), paint);
  }
}

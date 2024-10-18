const std = @import("std");

const Engine = @import("engine");
const Runtime = Engine.Runtime;
const SceneManager = Engine.Scenes.SceneManager;

const GameScene = @import("game/game.zig").GameScene;
const PlaygroundScene = @import("game/playground.zig").PlaygroundScene;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Init game runtime
    const game = try Runtime.Game.init(allocator, .{});

    // Load scenes
    const playground = try allocator.create(PlaygroundScene);
    playground.* = PlaygroundScene.init(allocator);

    // Register Scenes
    const playground_scene = playground.scene();
    const playground_scene_key = @intFromEnum(GameScene.playground);

    try game.scene_manager.register(playground_scene_key, playground_scene);

    // Load initial scene
    game.scene_manager.transitionTo(playground_scene_key);

    // Run
    game.run(run);

    // Deinit
    game.deinit();

    // Deallocate
    allocator.destroy(playground);
    _ = gpa.deinit();
}

pub fn run(scene_manager: *SceneManager, delta_time: f32) void {
    const scene = scene_manager.getScene() orelse unreachable;

    scene.handleGUI(delta_time);
    scene.handleInput(delta_time);
    scene.update(delta_time);
    scene.render(delta_time);
}

const std = @import("std");

const Engine = @import("engine");
const Runtime = Engine.Runtime;
const SceneManager = Engine.Scenes.SceneManager;

const GameScene = @import("game/game.zig").GameScene;
const PlaygroundScene = @import("game/playground.zig").PlaygroundScene;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    Runtime.init(.{});

    const scene_manager = try SceneManager.init(allocator);
    const playground = try PlaygroundScene.init(allocator);

    defer playground.deinit();
    defer scene_manager.deinit();

    const playground_scene = playground.scene();
    const playground_scene_key = @intFromEnum(GameScene.playground);

    try scene_manager.register(playground_scene_key, playground_scene);
    scene_manager.transitionTo(playground_scene_key);

    Runtime.run(.{}, run, scene_manager);
}

pub fn run(scene_manager: *SceneManager, delta_time: f32) void {
    const scene = scene_manager.getScene() orelse unreachable;

    scene.handleGUI(delta_time);
    scene.handleInput(delta_time);
    scene.update(delta_time);
    scene.render(delta_time);
}

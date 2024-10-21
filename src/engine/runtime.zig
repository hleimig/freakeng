const std = @import("std");
const raylib = @import("raylib");

const SceneManager = @import("scenes.zig").SceneManager;
const ContentManager = @import("content.zig").ContentManager;

const GameLoopFn = *const fn (scene_manager: *SceneManager, delta_time: f32) void;

pub const WindowConfig = struct {
    title: [*:0]const u8 = "Game title",

    width: i32 = 1024,
    height: i32 = 720,

    target_fps: u8 = 60,
};

pub const Game = struct {
    allocator: std.mem.Allocator,

    window_config: WindowConfig,

    content_manager: *ContentManager,
    scene_manager: *SceneManager,

    pub fn init(allocator: std.mem.Allocator, window_config: WindowConfig) !Game {
        raylib.initWindow(window_config.width, window_config.height, window_config.title);
        raylib.setTargetFPS(window_config.target_fps);

        const game: Game = .{
            .allocator = allocator,
            .window_config = window_config,
            .scene_manager = try allocator.create(SceneManager),
            .content_manager = try allocator.create(ContentManager),
        };

        game.content_manager.* = ContentManager.init(allocator);
        game.scene_manager.* = SceneManager.init(allocator, game.content_manager);

        return game;
    }

    pub fn deinit(self: *const Game) void {
        self.content_manager.deinit();
        self.scene_manager.deinit();

        self.allocator.destroy(self.content_manager);
        self.allocator.destroy(self.scene_manager);

        raylib.closeWindow();
    }

    pub fn run(self: *const Game, gameLoopFn: GameLoopFn) void {
        while (!raylib.windowShouldClose()) {
            gameLoopFn(self.scene_manager, raylib.getFrameTime());
        }
    }
};

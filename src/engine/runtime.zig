const raylib = @import("raylib");
const SceneManager = @import("scenes.zig").SceneManager;

const WindowConfig = struct {
    title: [*:0]const u8 = "Game title",

    width: i32 = 1024,
    height: i32 = 720,

    target_fps: u8 = 60,
};

const GameLoopFn = *const fn (scene_manager: *SceneManager, delta_time: f32) void;

pub fn init(window_config: WindowConfig) void {
    raylib.initWindow(window_config.width, window_config.height, window_config.title);
}

pub fn deinit() void {
    raylib.closeWindow();
}

pub fn run(window_config: WindowConfig, gameLoopFn: GameLoopFn, scene_manager: *SceneManager) void {
    raylib.setTargetFPS(window_config.target_fps);

    while (!raylib.windowShouldClose()) {
        gameLoopFn(scene_manager, raylib.getFrameTime());
    }
}

const std = @import("std");
const raylib = @import("raylib");

const Engine = @import("engine");
const ContentManager = Engine.Content.ContentManager;

const Scene = Engine.Scenes.Scene;
const SceneLoadError = Engine.Scenes.SceneLoadError;

const Sprite = Engine.Graphics.Sprite;
const SpriteManager = Engine.Graphics.SpriteManager;

pub const PlaygroundScene = struct {
    allocator: std.mem.Allocator,

    sprite_manager: SpriteManager,

    pub fn init(allocator: std.mem.Allocator) !*PlaygroundScene {
        const new = try allocator.create(PlaygroundScene);
        const sprite_manager = SpriteManager.init(allocator);

        new.* = .{
            .allocator = allocator,
            .sprite_manager = sprite_manager,
        };

        return new;
    }

    pub fn deinit(ptr: *anyopaque) void {
        const self: *PlaygroundScene = @ptrCast(@alignCast(ptr));
        PlaygroundScene.unload(self);
    }

    pub fn load(ptr: *anyopaque, content_manager: *ContentManager) SceneLoadError!void {
        const self: *PlaygroundScene = @ptrCast(@alignCast(ptr));

        const texture = content_manager.loadTexture2D("content/playground/actors/child_1_idle.png");
        const texture_2 = content_manager.loadTexture2D("content/playground/actors/child_1_idle.png");
        const idle_down_frames: [3]raylib.Rectangle = .{
            .{ .x = 0, .y = 0, .width = 128, .height = 128 },
            .{ .x = 128, .y = 0, .width = 128, .height = 128 },
            .{ .x = 256, .y = 0, .width = 128, .height = 128 },
        };

        const idle_left_frames: [3]raylib.Rectangle = .{
            .{ .x = 0, .y = 128, .width = 128, .height = 128 },
            .{ .x = 128, .y = 128, .width = 128, .height = 128 },
            .{ .x = 256, .y = 128, .width = 128, .height = 128 },
        };

        const sprite_idle_down = Sprite.init(texture, &idle_down_frames, 3);
        const sprite_idle_left = Sprite.init(texture_2, &idle_left_frames, 3);

        self.sprite_manager.register(0, sprite_idle_down) catch |err| {
            std.debug.print("Error registering Sprite onto SpriteManager. {}", .{err});
            return SceneLoadError.RegisteringSprite;
        };

        self.sprite_manager.register(1, sprite_idle_left) catch |err| {
            std.debug.print("Error registering Sprite onto SpriteManager. {}", .{err});
            return SceneLoadError.RegisteringSprite;
        };
    }

    pub fn unload(ptr: *anyopaque) void {
        const self: *PlaygroundScene = @ptrCast(@alignCast(ptr));

        self.sprite_manager.deinit();
    }

    pub fn handleGUI(_: *anyopaque, _: f32) void {}

    pub fn handleInput(_: *anyopaque, _: f32) void {}

    pub fn update(ptr: *anyopaque, delta_time: f32) void {
        const self: *PlaygroundScene = @ptrCast(@alignCast(ptr));

        const sprite = self.sprite_manager.getSprite();
        sprite.?.update(delta_time);
    }

    pub fn render(ptr: *anyopaque, delta_time: f32) void {
        const self: *PlaygroundScene = @ptrCast(@alignCast(ptr));

        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.clearBackground(raylib.Color.white);

        const sprite = self.sprite_manager.getSprite();
        sprite.?.render(delta_time, raylib.Vector2.init(100, 100));
    }

    pub fn scene(self: *PlaygroundScene) Scene {
        return .{
            .ptr = self,
            .deinitFn = PlaygroundScene.deinit,
            .loadFn = PlaygroundScene.load,
            .unloadFn = PlaygroundScene.unload,
            .handleGUIFn = PlaygroundScene.handleGUI,
            .handleInputFn = PlaygroundScene.handleInput,
            .updateFn = PlaygroundScene.update,
            .renderFn = PlaygroundScene.render,
        };
    }
};

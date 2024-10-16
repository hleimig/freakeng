const std = @import("std");
const raylib = @import("raylib");

const Engine = @import("engine");
const Scene = Engine.Scenes.Scene;

pub const PlaygroundScene = struct {
    allocator: std.mem.Allocator,

    sprite: *Engine.Graphics.Sprite,

    pub fn init(allocator: std.mem.Allocator) !*PlaygroundScene {
        const new = try allocator.create(PlaygroundScene);
        const sprite = try allocator.create(Engine.Graphics.Sprite);

        new.* = .{
            .allocator = allocator,
            .sprite = sprite,
        };

        return new;
    }

    pub fn deinit(self: *PlaygroundScene) void {
        PlaygroundScene.unload(self);
    }

    pub fn load(ptr: *anyopaque) void {
        const self: *PlaygroundScene = @ptrCast(@alignCast(ptr));

        const texture = raylib.Texture.init("content/playground/actors/child_1_idle.png");
        const frames: [3]raylib.Rectangle = .{
            .{ .x = 0, .y = 0, .width = 128, .height = 128 },
            .{ .x = 128, .y = 0, .width = 128, .height = 128 },
            .{ .x = 256, .y = 0, .width = 128, .height = 128 },
        };

        self.sprite.* = .{
            .texture = texture,
            .frames = &frames,
            .frames_per_second = 3,
        };
    }

    pub fn unload(ptr: *anyopaque) void {
        const self: *PlaygroundScene = @ptrCast(@alignCast(ptr));

        self.sprite.deinit();
    }

    pub fn handleGUI(_: *anyopaque, _: f32) void {}

    pub fn handleInput(_: *anyopaque, _: f32) void {}

    pub fn update(ptr: *anyopaque, delta_time: f32) void {
        const self: *PlaygroundScene = @ptrCast(@alignCast(ptr));

        self.sprite.update(delta_time);
    }

    pub fn render(ptr: *anyopaque, delta_time: f32) void {
        const self: *PlaygroundScene = @ptrCast(@alignCast(ptr));

        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.clearBackground(raylib.Color.white);
        self.sprite.render(delta_time, raylib.Vector2.init(100, 100));
    }

    pub fn scene(self: *PlaygroundScene) Scene {
        return .{
            .ptr = self,
            .loadFn = PlaygroundScene.load,
            .unloadFn = PlaygroundScene.unload,
            .handleGUIFn = PlaygroundScene.handleGUI,
            .handleInputFn = PlaygroundScene.handleInput,
            .updateFn = PlaygroundScene.update,
            .renderFn = PlaygroundScene.render,
        };
    }
};

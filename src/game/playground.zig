const std = @import("std");
const raylib = @import("raylib");

const Engine = @import("engine");
const ContentManager = Engine.Content.ContentManager;
const EntityComponentContainer = Engine.EntityComponent.EntityComponentContainer;
const EntityComponentContainerError = Engine.EntityComponent.EntityComponentContainerError;

const Scene = Engine.Scenes.Scene;
const SceneLoadError = Engine.Scenes.SceneLoadError;

const Sprite = Engine.Graphics.Sprite;
const SpriteManager = Engine.Graphics.SpriteManager;

const Body = Engine.Physics.Body;

const render_sprites = Engine.GraphicsSystems.render_sprites;
const update_sprites = Engine.GraphicsSystems.update_sprites;

pub const PlaygroundScene = struct {
    allocator: std.mem.Allocator,

    container: EntityComponentContainer,

    pub fn init(allocator: std.mem.Allocator) PlaygroundScene {
        return .{
            .allocator = allocator,
            .container = EntityComponentContainer.init(allocator),
        };
    }

    pub fn deinit(ptr: *anyopaque) void {
        const self: *PlaygroundScene = @ptrCast(@alignCast(ptr));
        PlaygroundScene.unload(self);

        self.container.deinit();
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

        var sprite_manager = SpriteManager.init(self.allocator);

        sprite_manager.register(0, sprite_idle_down) catch |err| {
            std.debug.print("Error registering Sprite onto SpriteManager. {}", .{err});
            return SceneLoadError.RegisteringSprite;
        };

        sprite_manager.register(1, sprite_idle_left) catch |err| {
            std.debug.print("Error registering Sprite onto SpriteManager. {}", .{err});
            return SceneLoadError.RegisteringSprite;
        };

        const id = self.container.registerEntity() catch undefined;
        self.container.registerSpriteManagerComponent(id, sprite_manager) catch undefined;
        self.container.registerBodyComponent(id, Body.init(raylib.Vector2.init(100.0, 100.0))) catch undefined;
    }

    pub fn unload(_: *anyopaque) void {}

    pub fn handleGUI(_: *anyopaque, _: f32) void {}

    pub fn handleInput(_: *anyopaque, _: f32) void {}

    pub fn update(ptr: *anyopaque, delta_time: f32) void {
        const self: *PlaygroundScene = @ptrCast(@alignCast(ptr));
        update_sprites(&self.container, delta_time);
    }

    pub fn render(ptr: *anyopaque, delta_time: f32) void {
        const self: *PlaygroundScene = @ptrCast(@alignCast(ptr));

        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.clearBackground(raylib.Color.white);

        render_sprites(&self.container, delta_time);
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

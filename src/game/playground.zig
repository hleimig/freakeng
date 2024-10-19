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

        const texture = content_manager.loadTexture2D("content/playground/sprites/actors/character_set.png");
        const idle_down_frames: [6]raylib.Rectangle = .{
            .{ .x = 192 * 0, .y = 0, .width = 192, .height = 192 },
            .{ .x = 192 * 1, .y = 0, .width = 192, .height = 192 },
            .{ .x = 192 * 2, .y = 0, .width = 192, .height = 192 },
            .{ .x = 192 * 3, .y = 0, .width = 192, .height = 192 },
            .{ .x = 192 * 4, .y = 0, .width = 192, .height = 192 },
            .{ .x = 192 * 5, .y = 0, .width = 192, .height = 192 },
        };

        const sprite_idle_down = Sprite.init(texture, &idle_down_frames, 9);

        var sprite_manager = SpriteManager.init(self.allocator);

        sprite_manager.register(0, sprite_idle_down) catch |err| {
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

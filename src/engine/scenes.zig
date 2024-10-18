const std = @import("std");

const ContentManager = @import("content.zig").ContentManager;

pub const SceneLoadError = error{RegisteringSprite};

const SceneHashMap = std.AutoHashMap(u8, Scene);

pub const SceneManager = struct {
    allocator: std.mem.Allocator,
    content_manager: *ContentManager,

    current: u8 = 0,
    scenes: SceneHashMap,

    pub fn init(allocator: std.mem.Allocator, content_manager: *ContentManager) !*SceneManager {
        const new = try allocator.create(SceneManager);
        new.* = .{
            .allocator = allocator,
            .content_manager = content_manager,
            .scenes = SceneHashMap.init(allocator),
        };

        return new;
    }

    pub fn deinit(self: *SceneManager) void {
        var it = self.scenes.valueIterator();
        while (it.next()) |scene| {
            scene.deinit();
        }

        self.scenes.deinit();
    }

    pub fn register(self: *SceneManager, key: u8, scene: Scene) !void {
        if (!self.scenes.contains(key)) {
            try self.scenes.put(key, scene);
        }
    }

    pub fn transitionTo(self: *SceneManager, key: u8) void {
        self.current = key;
        self.getScene().?.load(self.content_manager) catch |err| {
            std.debug.panic("Error loading a scene. Error: {}", .{err});
        };
    }

    pub fn getScene(self: *SceneManager) ?*Scene {
        return self.scenes.getPtr(self.current);
    }
};

pub const Scene = struct {
    ptr: *anyopaque,

    deinitFn: *const fn (ptr: *anyopaque) void,

    loadFn: *const fn (ptr: *anyopaque, content_manager: *ContentManager) SceneLoadError!void,
    unloadFn: *const fn (ptr: *anyopaque) void,
    handleGUIFn: *const fn (ptr: *anyopaque, delta_time: f32) void,
    handleInputFn: *const fn (ptr: *anyopaque, delta_time: f32) void,
    updateFn: *const fn (ptr: *anyopaque, delta_time: f32) void,
    renderFn: *const fn (ptr: *anyopaque, delta_time: f32) void,

    pub fn deinit(self: Scene) void {
        self.deinitFn(self.ptr);
    }

    pub fn load(self: Scene, content_manager: *ContentManager) !void {
        try self.loadFn(self.ptr, content_manager);
    }

    pub fn unload(self: Scene) void {
        self.unloadFn(self.ptr);
    }

    pub fn handleGUI(self: Scene, delta_time: f32) void {
        self.handleGUIFn(self.ptr, delta_time);
    }

    pub fn handleInput(self: Scene, delta_time: f32) void {
        self.handleInputFn(self.ptr, delta_time);
    }

    pub fn update(self: Scene, delta_time: f32) void {
        self.updateFn(self.ptr, delta_time);
    }

    pub fn render(self: Scene, delta_time: f32) void {
        self.renderFn(self.ptr, delta_time);
    }
};

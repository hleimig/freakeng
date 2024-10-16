const std = @import("std");

const SceneHashMap = std.AutoHashMap(u8, Scene);

pub const SceneManager = struct {
    allocator: std.mem.Allocator,

    current: u8 = 0,
    scenes: SceneHashMap,

    pub fn init(allocator: std.mem.Allocator) !*SceneManager {
        const new = try allocator.create(SceneManager);
        new.* = .{
            .allocator = allocator,
            .scenes = SceneHashMap.init(allocator),
        };

        return new;
    }

    pub fn deinit(self: *SceneManager) void {
        self.scenes.deinit();
    }

    pub fn register(self: *SceneManager, key: u8, scene: Scene) !void {
        if (!self.scenes.contains(key)) {
            try self.scenes.put(key, scene);
        }
    }

    pub fn transitionTo(self: *SceneManager, key: u8) void {
        self.current = key;
        self.getScene().?.load();
    }

    pub fn getScene(self: *SceneManager) ?*Scene {
        return self.scenes.getPtr(self.current);
    }
};

pub const Scene = struct {
    ptr: *anyopaque,

    loadFn: *const fn (ptr: *anyopaque) void,
    unloadFn: *const fn (ptr: *anyopaque) void,
    handleGUIFn: *const fn (ptr: *anyopaque, delta_time: f32) void,
    handleInputFn: *const fn (ptr: *anyopaque, delta_time: f32) void,
    updateFn: *const fn (ptr: *anyopaque, delta_time: f32) void,
    renderFn: *const fn (ptr: *anyopaque, delta_time: f32) void,

    pub fn load(self: Scene) void {
        self.loadFn(self.ptr);
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

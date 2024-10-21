const std = @import("std");
const raylib = @import("raylib");

const SpriteHashMap = std.AutoHashMap(u8, Sprite);

pub const SpriteManager = struct {
    allocator: std.mem.Allocator,

    current: u8 = 0,
    sprites: SpriteHashMap,

    pub fn init(allocator: std.mem.Allocator) SpriteManager {
        return .{
            .allocator = allocator,
            .sprites = SpriteHashMap.init(allocator),
        };
    }

    pub fn deinit(self: *SpriteManager) void {
        var it = self.sprites.valueIterator();
        while (it.next()) |sprite| {
            sprite.deinit();
        }

        self.sprites.deinit();
    }

    pub fn register(self: *SpriteManager, key: u8, scene: Sprite) !void {
        if (!self.sprites.contains(key)) {
            try self.sprites.put(key, scene);
        }
    }

    pub fn transitionTo(self: *SpriteManager, key: u8) void {
        self.current = key;
    }

    pub fn getSprite(self: *SpriteManager) ?*Sprite {
        return self.sprites.getPtr(self.current);
    }
};

pub const Sprite = struct {
    texture: *raylib.Texture2D,
    frames: []const raylib.Rectangle,
    frames_per_second: u8,

    current_frame: u8 = 0,
    time_since_last_frame: f32 = 0.0,

    pub fn init(texture: *raylib.Texture2D, frames: []const raylib.Rectangle, frames_per_second: u8) Sprite {
        std.debug.assert(frames.len < std.math.maxInt(u8));

        return .{
            .texture = texture,
            .frames = frames,
            .frames_per_second = frames_per_second,
        };
    }

    pub fn deinit(_: *Sprite) void {}

    pub fn update(self: *Sprite, delta_time: f32) void {
        self.time_since_last_frame += delta_time;

        const frame_duration: f32 = 1.0 / @as(f32, @floatFromInt(self.frames_per_second));

        if (self.time_since_last_frame > frame_duration) {
            self.current_frame = (self.current_frame + 1) % @as(u8, @intCast(self.frames.len));
            self.time_since_last_frame = 0.0;
        }
    }

    pub fn render(self: *Sprite, _: f32, position: raylib.Vector2) void {
        const src_frame = self.frames[self.current_frame];
        const dest_frame = raylib.Rectangle{
            .x = position.x,
            .y = position.y,
            .width = src_frame.width,
            .height = src_frame.height,
        };

        raylib.drawTexturePro(self.texture.*, src_frame, dest_frame, raylib.Vector2.zero(), 0.0, raylib.Color.white);
    }
};

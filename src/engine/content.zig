const std = @import("std");
const raylib = @import("raylib");

const TextureHashMap = std.AutoHashMap([*:0]const u8, raylib.Texture2D);

pub const ContentManager = struct {
    allocator: std.mem.Allocator,

    textures: TextureHashMap,

    pub fn init(allocator: std.mem.Allocator) ContentManager {
        return .{
            .allocator = allocator,
            .textures = TextureHashMap.init(allocator),
        };
    }

    pub fn deinit(self: *ContentManager) void {
        var it = self.textures.valueIterator();
        while (it.next()) |texture| {
            raylib.unloadTexture(texture.*);
        }

        self.textures.deinit();
    }

    pub fn loadTexture2D(self: *ContentManager, path: [*:0]const u8) *raylib.Texture2D {
        if (!self.textures.contains(path)) {
            const texture = raylib.loadTexture(path);
            self.textures.put(path, texture) catch |err| {
                std.debug.panic("Could not save texture to map. Error: {}", .{err});
            };
        }

        return self.textures.getPtr(path) orelse unreachable;
    }
};

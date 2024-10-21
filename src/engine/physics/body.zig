const std = @import("std");
const raylib = @import("raylib");

pub const Body = struct {
    position: raylib.Vector2,

    pub fn init(position: raylib.Vector2) Body {
        return .{
            .position = position,
        };
    }

    pub fn deinit(_: *Body) void {}
};

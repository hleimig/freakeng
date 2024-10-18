const std = @import("std");
const raylib = @import("raylib");

const Body = @import("physics.zig").Body;
const SpriteManager = @import("graphics.zig").SpriteManager;

const BodyHashMap = std.AutoHashMap(usize, Body);
const SpriteManagerHashMap = std.AutoHashMap(usize, SpriteManager);

pub const EntityComponentContainerError = error{
    UnknownEntity,
    TooManyEntities,
};

pub const EntityComponentContainer = struct {
    allocator: std.mem.Allocator,

    entities: [256]u1,
    last_entity: u8,

    body_components: BodyHashMap,
    sprite_manager_components: SpriteManagerHashMap,

    pub fn init(allocator: std.mem.Allocator) EntityComponentContainer {
        return .{
            .allocator = allocator,
            .entities = std.mem.zeroes([256]u1),
            .last_entity = 0,
            .body_components = BodyHashMap.init(allocator),
            .sprite_manager_components = SpriteManagerHashMap.init(allocator),
        };
    }

    pub fn deinit(self: *EntityComponentContainer) void {
        var bodies_it = self.body_components.valueIterator();
        while (bodies_it.next()) |body| {
            body.deinit();
        }

        var managers_it = self.sprite_manager_components.valueIterator();
        while (managers_it.next()) |manager| {
            manager.deinit();
        }

        self.body_components.deinit();
        self.sprite_manager_components.deinit();
    }

    pub fn registerEntity(self: *EntityComponentContainer) EntityComponentContainerError!u8 {
        if (self.last_entity >= self.entities.len) {
            return EntityComponentContainerError.TooManyEntities;
        }

        self.entities[self.last_entity] = 1;
        self.last_entity += 1;
        return self.last_entity - 1;
    }

    pub fn getEntityCount(self: *EntityComponentContainer) usize {
        return self.last_entity;
    }

    pub fn isEntityRegistered(self: *EntityComponentContainer, id: usize) bool {
        return self.entities[id] == 1;
    }

    pub fn registerBodyComponent(self: *EntityComponentContainer, id: usize, body: Body) EntityComponentContainerError!void {
        if (!self.isEntityRegistered(id)) {
            return EntityComponentContainerError.UnknownEntity;
        }

        self.body_components.put(id, body) catch |err| {
            std.debug.panic("Cannot store body component for entity: {d}. Error: {}", .{ id, err });
        };
    }

    pub fn registerSpriteManagerComponent(self: *EntityComponentContainer, id: usize, sprite_manager: SpriteManager) EntityComponentContainerError!void {
        if (!self.isEntityRegistered(id)) {
            return EntityComponentContainerError.UnknownEntity;
        }

        self.sprite_manager_components.put(id, sprite_manager) catch |err| {
            std.debug.panic("Cannot store sprite_manager component for entity: {d}. Error: {}", .{ id, err });
        };
    }

    pub fn getBodyComponent(self: *EntityComponentContainer, id: usize) ?*Body {
        return self.body_components.getPtr(id);
    }

    pub fn getSpriteManagerComponent(self: *EntityComponentContainer, id: usize) ?*SpriteManager {
        return self.sprite_manager_components.getPtr(id);
    }
};

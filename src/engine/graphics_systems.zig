const std = @import("std");
const raylib = @import("raylib");

const EntityComponentContainer = @import("entity_component_container.zig").EntityComponentContainer;

pub fn update_sprites(container: *EntityComponentContainer, delta_time: f32) void {
    for (0..container.getEntityCount()) |entity| {
        const sprite_manager = container.getSpriteManagerComponent(entity) orelse continue;

        const sprite = sprite_manager.getSprite();
        sprite.?.update(delta_time);
    }
}

pub fn render_sprites(container: *EntityComponentContainer, delta_time: f32) void {
    for (0..container.getEntityCount()) |entity| {
        const body = container.getBodyComponent(entity) orelse continue;
        const sprite_manager = container.getSpriteManagerComponent(entity) orelse continue;
        const sprite = sprite_manager.getSprite() orelse continue;

        sprite.render(delta_time, body.position);
    }
}

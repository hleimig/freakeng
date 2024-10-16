const raylib = @import("raylib");

pub const Sprite = struct {
    texture: raylib.Texture2D,
    frames: []const raylib.Rectangle,
    frames_per_second: f32,

    current_frame: u8 = 0,
    time_since_last_frame: f32 = 0.0,

    pub fn init(texture: raylib.Texture2D, frames: []const raylib.Rectangle, frames_per_second: f32) *const Sprite {
        return &.{
            .texture = texture,
            .frames = frames,
            .frames_per_second = frames_per_second,
        };
    }

    pub fn deinit(self: *Sprite) void {
        raylib.unloadTexture(self.texture);
    }

    pub fn update(self: *Sprite, delta_time: f32) void {
        self.time_since_last_frame += delta_time;

        const frame_duration: f32 = @as(f32, 1) / self.frames_per_second;

        if (self.time_since_last_frame > frame_duration) {
            self.current_frame = @as(u8, (self.current_frame + 1) % self.frames.len);
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

        raylib.drawTexturePro(self.texture, src_frame, dest_frame, raylib.Vector2.zero(), 0.0, raylib.Color.white);
    }
};
const Self = @This();
const root = @import("../../root.zig");

pub const Direction = enum(u1) {
    in = 0,
    out = 1,
};

pub const Value = enum(u1) {
    low = 0,
    high = 1,
};

pub const Ctx = struct {
    port: u16,  // O Device deve definir um enum talvez
    flags: u16, // O Device deve definir as próprias flags como um enum(u16)
    dev: root.Device()
};

ctx: Ctx,

pub fn init(ctx: Ctx) type {
    return .{ .ctx = ctx };
}


pub fn setDirection(self: Self, pin: u8, direction: Direction) anyerror!void{
    return self.ctx.dev.drivers.gpio.setDirection(self.ctx, pin, direction);
}

pub fn write(self: Self, pin: u8, value: Value) anyerror!void{
    return self.ctx.dev.drivers.gpio.write(self.ctx, pin, value);
}

pub fn read(self: Self, pin: u8) anyerror!Value{
    return self.ctx.dev.drivers.gpio.read(self.ctx, pin);
}

pub fn toggle(self: Self, pin: u8) anyerror!Value{
    return self.ctx.dev.drivers.gpio.toggle(self.ctx, pin);
}

// TODO: Pull-up?


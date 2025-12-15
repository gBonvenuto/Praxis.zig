const Gpio = @import("../../../common/drivers/Gpio.zig");
const std = @import("std");
const device = @import("../device.zig"); // TODO: implementar um overlay depois...

const Direction = Gpio.Direction;
const Value = Gpio.Value;

pub const Ctx = struct {
    port: enum(u16) {
        gpio_b,
        gpio_c,
        gpio_d,
    },
    flags: FLAGS,
};

const FLAGS = enum(u16) {
    GPIO_ACTIVE_LOW,
    GPIO_ACTIVE_HIGH,
};

inline fn active(flags: FLAGS) Value {
    if (flags == .GPIO_ACTIVE_HIGH) {
        return .high;
    } else if (flags == .GPIO_ACTIVE_LOW) {
        return .low;
    }
}

const Self = @This();

ctx: Ctx,

pub fn init(ctx: Ctx) Self {
    return .{ .ctx = ctx };
}

pub inline fn setDirection(self: Self, pin: u8, direction: Direction) void {
    const gpio = @field(device.soc, @tagName(self.ctx.port));
    const ddr: *u8 = @ptrCast(gpio.ddr);

    const pin_pos: u8 = (1 << pin);

    if (direction == .out) {
        ddr.* |= pin_pos;
    } else {
        ddr.* &= ~pin_pos;
    }
}

pub inline fn write(self: Self, pin: u8, value: Value) !void {
    const gpio = @field(device.soc, @tagName(self.ctx.port));
    const ddr: *u8 = @ptrCast(gpio.ddr);
    const port: *u8 = @ptrCast(gpio.port);

    // if ddr is not set to out direction, then
    // we should have an error pointing it out
    if ((((ddr.*) >> pin) & 1) != 1) {
        // TODO: Create a pattern for errors independent of target
        return error.Not_OUTPUT_pin;
    }

    const pin_pos = (1 << pin);

    if (value == active(self.ctx.flags)) {
        port.* |= pin_pos;
    } else {
        // port.* &= ~pin_pos;
        port.* &= 0b1101111;
    }
}

pub inline fn toggle(self: Self, pin: u8) !void {
    const gpio = @field(device.soc, @tagName(self.ctx.port));
    const ddr: *u8 = @ptrCast(gpio.ddr);
    const pin_: *u8 = @ptrCast(gpio.pin);

    // if ddr is not set to out direction, then
    // we should have an error pointing it out
    if ((((ddr.*) >> pin) & 1) != 1) {
        return error.Not_OUTPUT_pin;
    }

    const pin_pos = (1 << pin);

    // To toggle on arduino, we just need to set the pin register to 1
    pin_.* |= pin_pos;
}

pub inline fn read(self: Self, pin: u8) void {
    const gpio = @field(device.soc, @tagName(self.ctx.port));
    const pin_: *u8 = @ptrCast(gpio.pin_);

    // It is possible to read on OUTPUT mode, so I'll not return
    // any errors

    return ((pin_.*) >> pin) & 1;
}

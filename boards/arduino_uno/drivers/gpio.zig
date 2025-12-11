const ddr_pin = enum(u1) {
    in = 0,
    out = 1,
};
const ddr = packed struct { pin0: ddr_pin = .in, pin1: ddr_pin = .in, pin2: ddr_pin = .in, pin3: ddr_pin = .in, pin4: ddr_pin = .in, pin5: ddr_pin = .in, pin6: ddr_pin = .in, pin7: ddr_pin = .in };

const port = packed struct {
    pin0: u1 = 0,
    pin1: u1 = 0,
    pin2: u1 = 0,
    pin3: u1 = 0,
    pin4: u1 = 0,
    pin5: u1 = 0,
    pin6: u1 = 0,
    pin7: u1 = 0,
};

const GPIO = struct {
    ddr: *ddr,
    port: *port,
    pin: *u8,
};

pub const gpio_b: GPIO = .{
    .port = @ptrFromInt(0x25),
    .ddr = @ptrFromInt(0x24),
    .pin = @ptrFromInt(0x23),
};
pub const gpio_c: GPIO = .{
    .port = @ptrFromInt(0x28),
    .ddr = @ptrFromInt(0x27),
    .pin = @ptrFromInt(0x26),
};
pub const gpio_d: GPIO = .{
    .port = @ptrFromInt(0x2b),
    .ddr = @ptrFromInt(0x2a),
    .pin = @ptrFromInt(0x29),
};

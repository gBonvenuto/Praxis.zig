const ddr_pin = enum(i1) {
    in = 0,
    out = 1,
};
const ddr = packed struct { pin0: ddr_pin = .in, pin1: ddr_pin = .in, pin2: ddr_pin = .in, pin3: ddr_pin = .in, pin4: ddr_pin = .in, pin5: ddr_pin = .in, pin6: ddr_pin = .in, pin7: ddr_pin = .in };

const port = packed struct {
    pin0: i1 = 0,
    pin1: i1 = 0,
    pin2: i1 = 0,
    pin3: i1 = 0,
    pin4: i1 = 0,
    pin5: i1 = 0,
    pin6: i1 = 0,
    pin7: i1 = 0,
};

const GPIO = struct {
    ddr: *ddr,
    port: *port,
    pin: *u8,
};

pub var gpio_b: GPIO = .{
    .port = @ptrFromInt(0x25),
    .ddr = @ptrFromInt(0x24),
    .pin = @ptrFromInt(0x23),
};
pub var gpio_c: GPIO = .{
    .port = @ptrFromInt(0x28),
    .ddr = @ptrFromInt(0x27),
    .pin = @ptrFromInt(0x26),
};
pub var gpio_d: GPIO = .{
    .port = @ptrFromInt(0x2b),
    .ddr = @ptrFromInt(0x2a),
    .pin = @ptrFromInt(0x29),
};

pub const ddr_pin = enum(u1) {
    in = 0,
    out = 1,
};
pub const ddr = packed struct {
    pin0: ddr_pin = .in,
    pin1: ddr_pin = .in,
    pin2: ddr_pin = .in,
    pin3: ddr_pin = .in,
    pin4: ddr_pin = .in,
    pin5: ddr_pin = .in,
    pin6: ddr_pin = .in,
    pin7: ddr_pin = .in,
};

pub const port = packed struct {
    pin0: u1 = 0,
    pin1: u1 = 0,
    pin2: u1 = 0,
    pin3: u1 = 0,
    pin4: u1 = 0,
    pin5: u1 = 0,
    pin6: u1 = 0,
    pin7: u1 = 0,
};

pub const GPIO = struct {
    ddr: *ddr,
    port: *port,
    pin: *u8,
};

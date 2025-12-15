// TODO: Put memory regions here for maybe auto-generating linker script

const hardware_definitions = @import("../../common/hardware_definitions.zig");
const GPIO = hardware_definitions.GPIO;

pub const drivers = @import("./drivers/drivers.zig");

pub const soc = struct {
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
};

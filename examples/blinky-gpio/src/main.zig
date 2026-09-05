const praxis = @import("praxis");
const config = @import("config");
const drivers = praxis.drivers;

// Vamos torcer para que isso aqui seja comptime
const dev = praxis.Device().init(config);

const port_b = dev.drivers.gpio.init(.{
    .port = .gpio_b,
    .flags = .GPIO_ACTIVE_HIGH,
});

pub fn delay() void {
    var i: u32 = 0;
    while (i < 500_000) : (i += 1) {
        asm volatile ("nop");
    }
}

pub fn main() noreturn {
    port_b.setDirection(5, .out);
    // const ddrb: *u8 = @ptrFromInt(0x24);
    while (true) {
        // port_b.write(5, .low) catch unreachable;
        port_b.toggle(5) catch unreachable;
        delay();
    }
}

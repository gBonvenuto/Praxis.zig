const praxis = @import("praxis");
const drivers = praxis.drivers;
const p_ddrb:  *volatile u8 = @ptrFromInt(0x24);
const p_portb: *volatile u8 = @ptrFromInt(0x25);
const LED_PIN = 5;

pub fn delay() void {
    var i: u32 = 0;
    while (i < 500_000) : (i += 1) {
        asm volatile ("nop" : : );
    }
}

pub fn main() noreturn {
    drivers.gpio.gpio_b.ddr.pin5 = .out;

    while (true) {
        drivers.gpio.gpio_b.port.pin5 ^= 1;
        delay();
    }
}

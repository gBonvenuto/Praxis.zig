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
    p_ddrb.* |= (1 << LED_PIN);

    while (true) {
        p_portb.* ^= (1 << LED_PIN);
        delay();
    }
}

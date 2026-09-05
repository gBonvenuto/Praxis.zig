const praxis = @import("praxis");
const config = @import("config");

// Vamos torcer para que isso aqui seja comptime
const dev = praxis.Device().init(config);

// Peripherals is the low-level implementation of the drivers.
// The user should use praxis.drivers
const peripherals = dev.peripherals;

const usart = peripherals.usart.init(.{
    .baudrate = 9600,
    .character_size = .eight,
    .mode = .asynchronous,
    .parity_mode = .disabled,
    .stop_bits = .one,
    .clock_polarity = .falling_edge,
    .tx_enable = true,
    .rx_enable = true,
    .double_speed = false,
    .multi_processor = false,
    .interrupts = .{
        .rx_complete = false,
        .tx_complete = false,
        .data_register_empty = false,
    },
});

pub fn delay() void {
    var i: u32 = 0;
    while (i < 500_000) : (i += 1) {
        asm volatile ("nop");
    }
}

pub fn main() noreturn {
    
    usart.send_tx("teste");

    // const ddrb: *u8 = @ptrFromInt(0x24);
    while (true) {
        delay();
    }
}

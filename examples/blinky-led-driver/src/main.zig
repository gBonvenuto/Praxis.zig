const praxis = @import("praxis");
const config = @import("config");

// Eu quero inicializar o dispositivo assim
const platform = praxis.platform(config);
const led = platform.resource(.led0);

pub fn delay() void {
    var i: u32 = 0;
    while (i < 500_000) : (i += 1) {
        asm volatile ("nop");
    }
}

pub fn main() noreturn {

    while (true) {
        led.toggle();
        delay();
    }

}

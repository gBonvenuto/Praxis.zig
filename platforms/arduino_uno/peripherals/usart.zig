const device = @import("../device.zig"); // TODO: implementar um overlay depois...

const Self = @This();

pub const Ctx = struct {
    usart: device.USART = device.soc.usart0, // TODO: tenho que pensar em como vou passar esse parâmetro
    baudrate: u32,
    character_size: enum(u3) {
        five = 0b000,
        six = 0b001,
        seven = 0b010,
        eight = 0b011,
        nine = 0b111,
    }, // 5 to 9 bits
    mode: enum(u2) {
        asynchronous = 0b00,
        synchronous = 0b01,
        master_spi = 0b11, // I don't know what this is
    },
    parity_mode: enum(u2) {
        disabled = 0b00,
        enabled_even = 0b10,
        enabled_odd = 0b11,
    },
    stop_bits: enum(u1) {
        one = 0,
        two = 1,
    },
    clock_polarity: enum(u1) {
        falling_edge = 0,
        rising_edge = 1,
    },
    tx_enable: bool,
    rx_enable: bool,
    double_speed: bool,
    multi_processor: bool,
    interrupts: struct {
        rx_complete: bool,
        tx_complete: bool,
        data_register_empty: bool,
    },
};

ctx: Ctx,

pub fn init(ctx: Ctx) Self {
    const usart = ctx.usart;

    // UCSRnA

    usart.UCSRnA.U2Xn = @intFromBool(ctx.double_speed);
    usart.UCSRnA.MPCMn = @intFromBool(ctx.multi_processor);

    // UCSRnB

    usart.UCSRnB.RXCIEn = @intFromBool(ctx.interrupts.rx_complete);
    usart.UCSRnB.TXCIEn = @intFromBool(ctx.interrupts.tx_complete);
    usart.UCSRnB.UDRIEn = @intFromBool(ctx.interrupts.data_register_empty);
    usart.UCSRnB.RXENn = @intFromBool(ctx.rx_enable);
    usart.UCSRnB.TXCIEn = @intFromBool(ctx.tx_enable);
    usart.UCSRnB.UCSZn2 = (ctx.character_size >> 2) & 1;

    // TODO: não implementei nada para o caso de character de 9 bits

    // UCSRnC

    usart.UCSRnC.UMSELn1 = (ctx.mode >> 1) & 1;
    usart.UCSRnC.UMSELn0 = ctx.mode & 1;

    usart.UCSRnC.UPMn1 = (ctx.mode >> 1) & 1;
    usart.UCSRnC.UPMn0 = ctx.mode & 1;

    usart.UCSRnC.USBSn = ctx.stop_bits;

    usart.UCSRnC.UCSZn1 = (ctx.character_size >> 1) & 1;
    usart.UCSRnC.UCSZn0 = ctx.character_size & 1;

    usart.UCSRnC.UCPOLn = ctx.clock_polarity;

    const ret: Self = .{ .ctx = ctx };

    ret.set_baudrate(ctx.baudrate);

    return ret;
}

inline fn calculate_ubrr_register(self: Self, baudrate: u32) u12 {
    const ctx = self.ctx;
    if (!ctx.double_speed and ctx.mode == .asynchronous) {
        return comptime blk: {
            const ret: f64 = device.cpu_frequency / (16 * baudrate) - 1;
            break :blk ret;
        };
    } else if (ctx.double_speed and ctx.mode == .asynchronous) {
        return comptime blk: {
            const ret: f64 = device.cpu_frequency / (8 * baudrate) - 1;
            break :blk ret;
        };
    } else if (ctx.mode == .master_spi) {
        return comptime blk: {
            const ret: f64 = device.cpu_frequency / (2 * baudrate) - 1;
            break :blk ret;
        };
    }
}

pub inline fn set_baudrate(self: Self, baudrate: u32) u12 {
    self.ctx.usart.UBRRn = self.calculate_ubrr_register(baudrate);
}

pub inline fn send_tx(self: Self, char: u8) !void {
    self.ctx.usart.UDRn = char;
}

pub inline fn read_tx(self: Self) !u8 {
    _ = self;
}

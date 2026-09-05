// TODO: Put memory regions here for maybe auto-generating linker script

pub const peripherals = @import("./peripherals/peripherals.zig");

pub const cpu_frequency = 16_000_000; // 16 MHz

pub const soc = struct {
    pub const usart0: USART = .{
        .UDRn = @ptrFromInt(0xc6),
        .UCSRnA = @ptrFromInt(0xc0),
        .UCSRnB = @ptrFromInt(0xc1),
        .UCSRnC = @ptrFromInt(0xc2),
        .UBRRn = @ptrFromInt(0xc4),
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
};

pub const GPIO = struct {
    const pin_val = enum(u1) {
        in = 0,
        out = 1,
    };
    const ddr_t = packed struct {
        pin0: pin_val = .in,
        pin1: pin_val = .in,
        pin2: pin_val = .in,
        pin3: pin_val = .in,
        pin4: pin_val = .in,
        pin5: pin_val = .in,
        pin6: pin_val = .in,
        pin7: pin_val = .in,
    };

    const pin_t = packed struct {
        pin0: u1 = 0,
        pin1: u1 = 0,
        pin2: u1 = 0,
        pin3: u1 = 0,
        pin4: u1 = 0,
        pin5: u1 = 0,
        pin6: u1 = 0,
        pin7: u1 = 0,
    };
    ddr: *volatile ddr_t,
    port: *volatile pin_t,
    pin: *volatile pin_t,
};

pub const USART = struct {
    UDRn: *volatile u8,
    UCSRnA: *volatile packed struct {
        RXCn: u1,
        TXCn: u1,
        UDREn: u1,
        FEn: u1,
        DORn: u1,
        UPEn: u1,
        U2Xn: u1,
        MPCMn: u1,
    },
    UCSRnB: *volatile packed struct {
        RXCIEn: u1,
        TXCIEn: u1,
        UDRIEn: u1,
        RXENn: u1,
        TXENn: u1,
        UCSZn2: u1,
        RXB8n: u1,
        TXB8n: u1,
    },
    UCSRnC: *volatile packed struct { UMSELn1: u1, UMSELn0: u1, UPMn1: u1, UPMn0: u1, USBSn: u1, UCSZn1: u1, UCSZn0: u1, UCPOLn: u1 },

    // TODO: isso aqui são dois registradores,
    // acho que devo colocar o endereço do menor
    // mas talvez eu esteja enganado e tenha que
    // ser o endereço do maior
    UBRRn: *volatile u16,
};

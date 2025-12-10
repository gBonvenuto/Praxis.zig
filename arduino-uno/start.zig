// Stack pointer
// TODO: understand better why 0x20
const p_sph: *volatile u8 = @ptrFromInt(0x3E + 0x20);
const p_spl: *volatile u8 = @ptrFromInt(0x3D + 0x20);

const main = @import("main");

// Code copied from github.com/Rafaelmdcarneiro/arduino-zig/
// As my interest is not in learning avr assembly
fn copy_data_to_ram() void {
    asm volatile (
        \\  ; load Z register with the address of the data in flash
        \\  ldi r30, lo8(__data_load_start)
        \\  ldi r31, hi8(__data_load_start)
        \\  ; load X register with address of the data in ram
        \\  ldi r26, lo8(__data_start)
        \\  ldi r27, hi8(__data_start)
        \\  ; load address of end of the data in ram
        \\  ldi r24, lo8(__data_end)
        \\  ldi r25, hi8(__data_end)
        \\  rjmp .L2
        \\
        \\.L1:
        \\  lpm r18, Z+ ; copy from Z into r18 and increment Z
        \\  st X+, r18  ; store r18 at location X and increment X
        \\
        \\.L2:
        \\  cp r26, r24
        \\  cpc r27, r25 ; check and branch if we are at the end of data
        \\  brne .L1
    );
    // Probably a good idea to add clobbers here, but compiler doesn't seem to care
}

// Code copied from github.com/Rafaelmdcarneiro/arduino-zig/
// As my interest is not in learning avr assembly
fn clear_bss() void {
    asm volatile (
        \\  ; load X register with the beginning of bss section
        \\  ldi r26, lo8(__bss_start)
        \\  ldi r27, hi8(__bss_start)
        \\  ; load end of the bss in registers
        \\  ldi r24, lo8(__bss_end)
        \\  ldi r25, hi8(__bss_end)
        \\  ldi r18, 0x00
        \\  rjmp .L4
        \\
        \\.L3:
        \\  st X+, r18
        \\
        \\.L4:
        \\  cp r26, r24
        \\  cpc r27, r25 ; check and branch if we are at the end of bss
        \\  brne .L3
    );
    // Probably a good idea to add clobbers here, but compiler doesn't seem to care
}

export fn _start() noreturn {
    // @setRuntimeSafety(false);
    p_sph.* = 0x08; // High Byte
    p_spl.* = 0xFF; // Low Byte

    copy_data_to_ram();

    clear_bss();

    main.main();

    while (true) {}
}

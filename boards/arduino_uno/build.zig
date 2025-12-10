// Functions and variables necessary for building specifically to arduino

const std = @import("std");
const common = @import("../../build.zig");

const Self = common.PraxisBuild();

pub fn flashStep(self: *Self) *std.Build.Step {
    const b = self.b;
    const exe = self.exe.?;
    const flash_step = b.step("flash", "Build and Flash the current program do a microcontroller");

    const out_hex = std.mem.concat(b.allocator, u8, &[_][]const u8{ b.install_prefix, "/bin/", exe.out_filename, ".hex" }) catch unreachable;
    const exe_location = std.mem.concat(b.allocator, u8, &[_][]const u8{ b.install_prefix, "/bin/", exe.out_filename }) catch unreachable;

    const elf_to_hex = b.addSystemCommand(&[_][]const u8{
        "avr-objcopy",
        "-O",
        "ihex",
        exe_location,
        out_hex,
    });
    const flash_cmd = b.addSystemCommand(&[_][]const u8{
        "avrdude",
        "-c",
        "arduino",
        "-p",
        "atmega328p",
        "-P",
        "/dev/ttyACM0", // TODO: adicionar opção de mudar a porta
        "-b",
        "115200",
        "-U",
        std.mem.concat(b.allocator, u8, &[_][]const u8{
            "flash:w:",
            out_hex,
            ":i",
        }) catch unreachable,
    });
    elf_to_hex.step.dependOn(b.getInstallStep());
    flash_cmd.step.dependOn(&elf_to_hex.step);
    flash_step.dependOn(&flash_cmd.step);
    return flash_step;
}

pub const target: std.Target.Query = .{
    .cpu_arch = .avr,
    .os_tag = .freestanding,
    .abi = .eabi,
    .cpu_model = .{ .explicit = &std.Target.avr.cpu.atmega328p },
};

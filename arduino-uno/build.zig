const std = @import("std");

// Adds a step called flash to the build that flashes the binary
// to the device
pub fn add_FlashStep(b: *std.Build, exe: *std.Build.Step.Compile) *std.Build.Step {
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

var _target: ?std.Build.ResolvedTarget = null;

pub fn get_target(b: *std.Build) std.Build.ResolvedTarget {
    if (_target == null) {
        const local_target = b.standardTargetOptions(.{
            .default_target = .{
                .cpu_arch = .avr,
                .os_tag = .freestanding,
                .abi = .eabi,
                .cpu_model = .{ .explicit = &std.Target.avr.cpu.atmega328p },
            },
        });
        _target = local_target;
        return _target.?;
    }
    return _target.?;
}

const Options = struct {
    target: ?std.Build.ResolvedTarget = null,
    optimize: ?std.builtin.OptimizeMode = null,
    root_source_file: ?std.Build.LazyPath = null,
};

pub fn add_executable(my_RTOS_dep: *std.Build.Dependency, options: Options) *std.Build.Step.Compile {
    const b = my_RTOS_dep.builder;

    const target = if (options.target != null) options.target.? else get_target(b);
    const optimize = if (options.optimize != null) options.optimize.? else .ReleaseSmall;
    const root_source_file = if (options.root_source_file != null) options.root_source_file else @panic("root_source_file with main is needed");

    const main_exe = b.addExecutable(.{
        .name = "main",
        .root_module = b.createModule(.{
            .root_source_file = root_source_file,
            .target = target,
            .optimize = optimize,
            .link_libc = false,
        }),
    });

    const exe = b.addExecutable(.{
        .name = "arduino-uno",
        .root_module = b.createModule(.{
            .root_source_file = my_RTOS_dep.path("").join(b.allocator, "arduino-uno/start.zig") catch unreachable,
            .target = target,
            .optimize = optimize,
            .link_libc = false,
        }),
    });

    exe.root_module.addImport("main", main_exe.root_module);
    exe.setLinkerScript(my_RTOS_dep.path("").join(b.allocator, "arduino-uno/linker.ld") catch unreachable);
    exe.bundle_compiler_rt = false;

    return exe;
}

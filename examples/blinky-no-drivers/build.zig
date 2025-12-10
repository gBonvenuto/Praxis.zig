const std = @import("std");
const praxis = @import("praxis");

pub fn build(b: *std.Build) !void {
    const praxis_dep = b.dependency("praxis", .{});

    const praxis_build = praxis.PraxisBuild().init(b, praxis_dep, .{
        .root_source_file = b.path("src/main.zig"),
    });


    const exe = praxis_build.add_executable();
    _ = praxis_build.add_flash_step();

    // const exe = arduino_uno.add_executable(praxis_dep, .{
    //     .root_source_file = b.path("src/main.zig"),
    // });

    // adds the flash step
    // _ = arduino_uno.add_FlashStep(b, exe);

    if (exe) |x| {
        b.installArtifact(x);
    }
}

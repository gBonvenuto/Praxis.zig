const std = @import("std");
const my_RTOS = @import("my_RTOS");

pub fn build(b: *std.Build) void {
    const my_RTOS_dep = b.dependency("my_RTOS", .{});

    const print_step = b.step("print-rtos-path", "Exibe o caminho do RTOS no cache de dependências");

    const print_cmd = b.addSystemCommand(&[_][]const u8{
        "echo",
        "Caminho do meu-rtos no cache:",
    });

    // Adicionamos o caminho RESOLVIDO como um ARGUMENTO do comando 'echo'.
    // O getResolvedPath() faz a conversão de LazyPath para a string resolvida.
    print_cmd.addDirectoryArg(my_RTOS_dep.path(""));

    print_step.dependOn(&print_cmd.step);

    const exe = my_RTOS.arduino_uno.add_executable(my_RTOS_dep, .{
        .root_source_file = b.path("src/main.zig"),
    });

    // adds the flash step
    _ = my_RTOS.arduino_uno.add_FlashStep(b, exe);

    b.installArtifact(exe);
}

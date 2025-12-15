const std = @import("std");
const boards = @import("./boards/boards.zig");
const Board = boards.Board;

pub const Options = struct {
    target: ?std.Build.ResolvedTarget = null,
    optimize: ?std.builtin.OptimizeMode = null,
    root_source_file: ?std.Build.LazyPath = null,
    board: ?Board = null,
};

pub fn PraxisBuild() type {
    return struct {
        const Self = @This();
        options: Options,
        b: *std.Build,
        exe: ?*std.Build.Step.Compile = null,
        praxis_dep: *std.Build.Dependency,

        pub fn init(b: *std.Build, praxis_dep: *std.Build.Dependency, options: Options) *Self {
            const this = b.allocator.create(Self) catch @panic("Out of memory");

            this.* = .{
                .b = b,
                .options = options,
                .praxis_dep = praxis_dep,
                .exe = undefined,
            };

            return this;
        }

        pub fn deinit(self: *@This()) !void {
            try self.b.allocator.destroy(@This());
        }

        // TODO:
        fn add_board_option(self: *@This()) ?Board {
            const board = self.b.option(Board, "board", "The board where the program will be flashed to");

            if (board) |brd| brd: {
                self.options.board = brd;

                // Setting the target based on the boards if the target
                // is not already defined by the user
                if (self.options.target != null) {
                    break :brd;
                }

                self.options.target = self.b.standardTargetOptions(.{
                    .default_target = boards.Build(brd).target,
                });
            } else {
                std.debug.print("You need to set a board with `-Dboard`, see `zig build -h`\n", .{});
            }
            return board;
        }
        pub fn add_executable(self: *@This()) ?*std.Build.Step.Compile {
            const b = self.b;
            var options = &self.options;

            options.optimize = if (options.optimize != null) options.optimize.? else .ReleaseSmall;
            options.root_source_file = if (options.root_source_file != null) options.root_source_file else @panic("root_source_file with main is needed");
            options.board = if (options.board != null) options.board else add_board_option(self);
            options.target = if (options.target != null) options.target.? else @panic("target not set. Try using the board option");

            const main_exe = b.addExecutable(.{
                .name = "main",
                .root_module = b.createModule(.{
                    .root_source_file = options.root_source_file,
                    .target = options.target,
                    .optimize = options.optimize,
                    .link_libc = false,
                    .imports = &.{
                        .{
                            .name = "praxis",
                            .module = self.praxis_dep.module("praxis"),
                        },
                    },
                }),
            });

            const config = b.addOptions();
            config.addOption(Board, "board", options.board.?);
            main_exe.root_module.addOptions("config", config);

            const praxis_dep = self.praxis_dep;

            // TODO: generalizar isso aqui
            const exe = b.addExecutable(.{
                .name = "arduino-uno",
                .root_module = b.createModule(.{
                    .root_source_file = praxis_dep.path("").join(b.allocator, "boards/arduino_uno/start.zig") catch unreachable,
                    .target = options.target,
                    .optimize = options.optimize,
                    .link_libc = false,
                }),
            });

            exe.root_module.addImport("main", main_exe.root_module);
            exe.setLinkerScript(praxis_dep.path("").join(b.allocator, "boards/arduino_uno/linker.ld") catch unreachable);
            exe.bundle_compiler_rt = false;

            self.exe = exe;

            return exe;
        }
        pub fn add_flash_step(self: *Self) ?*std.Build.Step {
            if (self.options.board == null) {
                std.debug.print("Board not set, try to use -Dboard option\n", .{});
                return null;
            }

            if (self.exe == null) {
                std.debug.print("You must add the executable step as well\n", .{});
                return null;
            }

            return boards.Build(self.options.board.?).flashStep(self);
        }
    };
}

pub fn build(b: *std.Build) void {
    _ = b.addModule("praxis", .{
        .root_source_file = b.path("./root.zig"),
    });
}

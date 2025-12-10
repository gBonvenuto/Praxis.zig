const std = @import("std");
const boards = @import("./boards/boards.zig");

pub const Options = struct {
    target: ?std.Build.ResolvedTarget = null,
    optimize: ?std.builtin.OptimizeMode = null,
    root_source_file: ?std.Build.LazyPath = null,
};

pub const Board = enum {
    arduino_uno,
    stm32,
};

pub fn PraxisBuild() type {
    return struct {
        const Self = @This();
        options: Options,
        board: ?Board,
        b: *std.Build,
        exe: ?*std.Build.Step.Compile = null,
        praxis_dep: *std.Build.Dependency,

        pub fn init(b: *std.Build, praxis_dep: *std.Build.Dependency, options: Options) *Self {
            const this = b.allocator.create(Self) catch @panic("Out of memory");

            this.* = .{
                .b = b,
                .options = options,
                .praxis_dep = praxis_dep,
                .board = add_board_option(this),
                .exe = undefined,
            };

            return this;
        }

        pub fn deinit(self: *@This()) !void {
            try self.b.allocator.destroy(@This());
        }

        fn add_board_option(self: *@This()) ?Board {
            const board = self.b.option(Board, "board", "The board where the program will be flashed to");

            if (board) |brd| {

                self.board = brd;

                inline for(@typeInfo(boards).@"struct".decls) |v| {
                    if (std.mem.eql(u8, @tagName(brd), v.name)) {
                        self.options.target = self.b.standardTargetOptions(.{
                            .default_target = @field(boards, v.name).target,
                        });
                    }
                }

            }
            return board;
        }
        pub fn add_executable(self: *@This()) ?*std.Build.Step.Compile {
            const b = self.b;
            var options = &self.options;

            if (self.board == null) {
                std.debug.print("Board not set, try to use -Dboard option\n", .{});
                return null;
            }

            options.target = if (options.target != null) options.target.? else @panic("target not set. Try using the board option");
            options.optimize = if (options.optimize != null) options.optimize.? else .ReleaseSmall;
            options.root_source_file = if (options.root_source_file != null) options.root_source_file else @panic("root_source_file with main is needed");

            const main_exe = b.addExecutable(.{
                .name = "main",
                .root_module = b.createModule(.{
                    .root_source_file = options.root_source_file,
                    .target = options.target,
                    .optimize = options.optimize,
                    .link_libc = false,
                }),
            });

            const praxis_dep = self.praxis_dep;

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
            if (self.board == null) {
                std.debug.print("Board not set, try to use -Dboard option\n", .{});
                return null;
            }

            if (self.exe == null) {
                std.debug.print("You must add the executable step as well\n", .{});
                return null;
            }

            inline for (@typeInfo(boards).@"struct".decls) |v| {
                if (std.mem.eql(u8, @tagName(self.board.?), v.name)) {
                    return @field(boards, v.name).flashStep(self);
                }
            }

            return null;
        }
    };
}

pub fn build(b: *std.Build) void {
    _ = b;
}

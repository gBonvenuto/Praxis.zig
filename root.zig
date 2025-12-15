pub const drivers = @import("./common/drivers/drivers.zig");
pub const boards = @import("boards/boards.zig");
const std = @import("std");

// TODO: será que isso aqui faz sentido?
pub fn Device() type {
    return struct {
        board: boards.Board = undefined,
        drivers: type = undefined,

        const Self: type = @This();

        pub fn init(config: type) Self {

            // if (config.board == null) {
            //     @compileError("You have to define a board");
            // }

            const board = @field(boards.Board, @tagName(config.board));

            const device: Self = .{ .board = board, .drivers = boards.Device(board).drivers};
            
            return device;
        }
    };
}

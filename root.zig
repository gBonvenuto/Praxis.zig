pub const boards = @import("boards/boards.zig");
const std = @import("std");

// TODO: será que isso aqui faz sentido?
//
// Outra alternativa seria o device.zig de cada board já ser o struct
// retornado aqui
pub fn platform() type {
    return struct {
        board: boards.Board = undefined,
        peripherals: type = undefined,

        const Self: type = @This();

        pub fn init(config: type) Self {

            // if (config.board == null) {
            //     @compileError("You have to define a board");
            // }

            const board = @field(boards.Board, @tagName(config.board));

            // Qual a diferença entre device e board?
            const device: Self = .{ .board = board, .peripherals = boards.Device(board).peripherals};
            
            return device;
        }
    };
}

pub fn hardware_get_alias() void{

}

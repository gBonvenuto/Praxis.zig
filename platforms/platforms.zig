const Platform  = @This();

// Por que eu tenho isso?
pub const Board = enum {
    arduino_uno,
    stm32,
};

// TODO: maybe do some comptime magic here to create devices and builds based
// on the subdirectories
pub inline fn Build(board: Board) type {
    return switch (board) {
        .arduino_uno => @import("./arduino_uno/build.zig"),
        else => @panic("this board does not have a Build associated with it"),
    };
}

pub inline fn Tree(board: Board) type {
    return switch (board) {
        .arduino_uno => @import("./arduino_uno/tree.zig"),
        else => @panic("this board does not have a Device associated with it"),
    };
}


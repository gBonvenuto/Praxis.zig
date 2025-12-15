pub inline fn Build(board: Board) type {
    return switch (board) {
        .arduino_uno => @import("./arduino_uno/build.zig"),
        else => @panic("this board does not have a Build associated with it"),
    };
}

// TODO: maybe do some comptime magic here to create devices and builds based
// on the subdirectories
pub inline fn Device(board: Board) type {
    return switch (board) {
        .arduino_uno => @import("./arduino_uno/device.zig"),
        else => @panic("this board does not have a Device associated with it"),
    };
}

const std = @import("std");

pub const Board = enum {
    arduino_uno,
    stm32,
};

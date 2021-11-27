pub fn of(comptime T: type) type {
    var Iterator = struct {
        const Self = @This();
        data: []T,
        index: u32,

        pub fn init(data: []T) Self {
            var self: Self = undefined;
            self.data = data;
            self.index = 0;
            return self;
        }

        pub fn reset(self: *Self) void {
            self.index = 0;
        }

        pub fn add(self: *Self, item: T) void {
            self.advance();
            self.data[self.index - 1] = item;
        }

        pub fn next(self: *Self) u32 {
            self.advance();
            return self.data[self.index - 1];
        }

        pub fn advance(self: *Self) void {
            if (self.index < self.data.len) {
                self.index += 1;
            } else {
                panic(@errorReturnTrace(), "BufferExhausted", .{});
            }
        }
    };

    return Iterator;
}

const panic = @import("debug.zig").panic;

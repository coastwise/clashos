pub const mailboxes = [_]*Mailbox{ Mailbox.init(0), Mailbox.init(1) };

const Mailbox = packed struct {
    push_pull_register: u32,
    unused1: u32,
    unused2: u32,
    unused3: u32,
    unused4: u32,
    unused5: u32,
    status_register: u32,
    unused6: u32,

    fn init(index: u32) *Mailbox {
        if (index > 1) {
            panic(@errorReturnTrace(), "mailbox index");
        }
        const PERIPHERAL_BASE = 0x3F000000;
        const MAILBOXES_OFFSET = 0xB880;
        assert(@sizeOf(Mailbox) == 0x20);
        return @intToPtr(*Mailbox, PERIPHERAL_BASE + MAILBOXES_OFFSET + index * @sizeOf(Mailbox));
    }

    fn pushRequestBlocking(this: *Mailbox, request: u32) void {
        while (this.isFull()) {
        }
        this.push(request);
    }

    fn pullResponseBlocking(this: *Mailbox, request: u32) !void {
        while (this.isEmpty()) {
        }
        const response = this.pull();
        if (response != request) {
            return error.UnexpectedBufferAddressOrChannel;
        }
    }

    fn isEmpty(this: *Mailbox) bool {
        const MAILBOX_IS_EMPTY = 0x40000000;
        return this.status() & MAILBOX_IS_EMPTY != 0;
    }

    fn isFull(this: *Mailbox) bool {
        const MAILBOX_IS_FULL = 0x80000000;
        return this.status() & MAILBOX_IS_FULL != 0;
    }

    fn push(this: *Mailbox, word: u32) void {
        mmio.write(@ptrToInt(&this.push_pull_register), word);
    }

    fn pull(this: *Mailbox) u32 {
        return mmio.read(@ptrToInt(&this.push_pull_register));
    }

    fn status(this: *Mailbox) u32 {
        return mmio.read(@ptrToInt(&this.status_register));
    }
};

const assert = std.debug.assert;
const mmio = @import("mmio.zig");
const panic = @import("debug.zig").panic;
const std = @import("std");

const std = @import("std");
const idk = @import("idk");

pub fn DoublyLinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        head: ?*Node = null,
        tail: ?*Node = null,

        const Node = struct {
            value: T,
            prev: ?*Node = null,
            next: ?*Node = null,
        };

        pub fn init(allocator: std.mem.Allocator) Self {
            return @This(){ .allocator = allocator, .head = null, .tail = null };
        }

        pub fn deinit(self: *Self) void {
            var node = self.head;
            while (node) |current| {
                const next = current.next;
                self.allocator.destroy(current);
                node = next;
            }
            self.head = null;
            self.tail = null;
        }

        pub fn append(self: *Self, value: T) !*Node {
            const new_node = try self.allocator.create(Node);
            new_node.* = Node{ .value = value };
            //create new node
            //give the node the value
            if (self.tail) |tail_node| {
                tail_node.next = new_node;
                new_node.prev = tail_node;
                self.tail = new_node;
                //if the list already has elements:
                //  - link the current tail to the new node
                //  - update the tail pointer
            } else {
                self.head = new_node;
                self.tail = new_node;
            }
            //else (the list was empty) head and tail both point to the new node

            return new_node;
        }

        pub fn prepend(self: *Self, value: T) !*Node {
            const new_node = try self.allocator.create(Node);
            new_node.* = Node{ .value = value };

            if (self.head) |head_node| {
                head_node.prev = new_node;
                new_node.next = head_node;
                self.head = new_node;
            } else {
                self.head = new_node;
                self.tail = new_node;
            }

            return new_node;
        }

        pub fn print(self: *Self) void {
            var node = self.head;
            while (node) |n| {
                std.debug.print("{any} ", .{n.value});
                node = n.next;
            }
            std.debug.print("\n", .{});
        }
    };
}

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    try idk.bufferedPrint();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try list.prepend(5);
    try list.append(20);
    try list.append(15);
    list.print();
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list = DoublyLinkedList(i32).init(gpa);
    defer list.deinit();
    const n1 = try list.append(42);
    try std.testing.expect(list.head == n1);
}

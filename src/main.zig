const std = @import("std");
const posix = std.posix;
const net = std.net;
const stdout = std.io.getStdOut().writer();

// For UDP server, socket -> bind -> sendto <=> recvfrom

pub fn main() !void {
    // a UDP socket
    const sockfd = try posix.socket(posix.AF.INET, posix.SOCK.DGRAM, 0);
    errdefer posix.close(sockfd);
    defer posix.close(sockfd);

    // reuse the address
    try posix.setsockopt(sockfd, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));

    // bind to the localhost with given port
    const address = try net.Address.resolveIp("127.0.0.1", 2053);
    const sockaddr = @as(posix.sockaddr, address.any);
    try posix.bind(sockfd, &sockaddr, @sizeOf(posix.sockaddr.in));

    var client_address: posix.sockaddr = undefined;
    var client_address_len: posix.socklen_t = @sizeOf(posix.sockaddr.in);
    var buf: [128]u8 = undefined;
    @memset(&buf, 0);

    // recieve from client
    const rl = try posix.recvfrom(sockfd, &buf, 0, &client_address, &client_address_len);
    try stdout.print("recieved: {s} | bytes: {d}\n", .{buf, rl});

    // send to client
    var msg = [_:0]u8{};  // null terminated empty string
    _ = try posix.sendto(sockfd, &msg, 0, &client_address, client_address_len);
}

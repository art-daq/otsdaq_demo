# test3.py OEI with support for multiple reads/writes per packet

import socket
import struct

class OEI(object):

    def __init__(self,ipaddr):
        self.sock = socket.socket(socket.AF_INET,
                                  socket.SOCK_DGRAM)
        self.target = (ipaddr,2001)

    def read(self,addr,num): # read memory (addr inrem)
        cmd = ""
        cmd += struct.pack("B",0x00)  # read operation
        cmd += struct.pack("B",num)  # read N words
        cmd += struct.pack("Q",addr) # starting addr
        self.sock.sendto(cmd,self.target)
        d,a = self.sock.recvfrom(2+(8*num))
        fmt = "<BB%dQ"%num
        temp = struct.unpack(fmt,d)
        return temp  # (type, seq, data(1), ... ,data(num))

    def write(self,addr,data): # write memory (addr increm)
        cmd = ""
        cmd += struct.pack("B",1)  # write operation
        cmd += struct.pack("B",len(data))  # write n words
        cmd += struct.pack("Q",addr)
        for i in data:
            cmd += struct.pack("Q",i)
        self.sock.sendto(cmd,self.target)

    def readf(self,addr,num): # read FIFO (addr no increm)
        cmd = ""
        cmd += struct.pack("B",0x08)  # read operation, no increm
        cmd += struct.pack("B",num)  # read N words
        cmd += struct.pack("Q",addr) # starting addr
        self.sock.sendto(cmd,self.target)
        d,a = self.sock.recvfrom(2+(8*num))
        fmt = "<BB%dQ"%num
        temp = struct.unpack(fmt,d)
        return temp  # (type, seq, data(1), ... ,data(num))

    def writef(self,addr,data): # write FIFO (addr no increm)
        cmd = ""
        cmd += struct.pack("B",0x09)  # write operation, no increm
        cmd += struct.pack("B",len(data))  # write n words
        cmd += struct.pack("Q",addr)
        for i in data:
            cmd += struct.pack("Q",i)
        self.sock.sendto(cmd,self.target)

    def close(self):
        self.sock.close()


thing = OEI("192.168.133.12")

# single read should be 0xdeadbeef

print hex(thing.read(0xAA55,1)[2])

# write to test register and read it back

thing.write(0x12345678, [0xdeadbeefbabecafe] )
print hex(thing.read(0x12345678,1)[2])

# write 4 words ram

thing.write(0x70000, [21,37,98,294])

# read 4 words from ram

print thing.read(0x70000,4)

# write 6 words to FIFO

thing.writef(0x80000000,[342,11,99,67,224,4535])

# read 6 words from FIFO 

print thing.readf(0x80000000,6)

thing.close()


/***
 This file is part of SockMux for CoreFoundataion
 
 Copyright 2011 Daniel Mack <sockmux@zonque.org>
 
 PulseAudioOSX is free software; you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License (LGPL) as
 published by the Free Software Foundation; either version 2.1 of the
 License, or (at your option) any later version.
 ***/

#import <Foundation/Foundation.h>

#define SOCKMUX_PROTOCOL_MAGIC              0x7ab938ab
#define SOCKMUX_PROTOCOL_HANDSHAKE_MAGIC    0x3f9ab044

struct _SockMuxHandshake {
    UInt32 magic;
    UInt32 handshakeMagic;
    UInt32 protocolVersion;
} __attribute__((packed));

typedef struct _SockMuxHandshake SockMuxHandshake;

struct _SockMuxMessage {
    UInt32 magic;
    UInt32 messageID;
    UInt32 length;
    Byte data[0];
} __attribute__((packed));

typedef struct _SockMuxMessage SockMuxMessage;

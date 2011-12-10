/***
 This file is part of SockMux for CoreFoundataion
 
 Copyright 2011 Daniel Mack <sockmux@zonque.org>
 
 SockMux is free software; you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License (LGPL) as
 published by the Free Software Foundation; either version 2.1 of the
 License, or (at your option) any later version.
 ***/

#if (TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#import <Endian.h>
#endif

#import "SockMuxSender.h"
#import "protocol.h"

#define PROTOCOL_VERSION 1

@implementation SockMuxSender 

@synthesize delegate;

#pragma mark -
#pragma mark Stream Buffer handling

- (void) removeFromBeginningOfBuf: (NSMutableData **) buf
                           length: (NSUInteger) len
{
	if (len == 0)
		return;
	
	const UInt8 *old = [*buf bytes];	
	NSUInteger newLength = [*buf length] - len;
	NSMutableData *newBuf = [NSMutableData dataWithLength: 0];
	
	if (newLength)
		[newBuf appendBytes: old + len
                     length: newLength];
	
	[*buf release];
	*buf = [newBuf retain];
}

#pragma mark -
#pragma mark NSStreamDelegate

- (void) delegateDisconnect
{
    if (delegate && [delegate respondsToSelector: @selector(streamClosedForSender:)])
        [delegate streamClosedForSender: self];
    
    [outputStream setDelegate: nil];
}

- (void) feedOutputStream
{
	if ([outputBuf length] == 0 ||
	    [outputStream hasSpaceAvailable] == NO)
		return;
    
	NSInteger len = [outputStream write: [outputBuf bytes]
                              maxLength: [outputBuf length]];
    
	if (len < 0) {
		[self delegateDisconnect];
		return;
	}
    
	[self removeFromBeginningOfBuf: &outputBuf
                            length: len];
}

- (void)stream: (NSStream *) stream
   handleEvent: (NSStreamEvent) streamEvent
{
	switch (streamEvent) {
		case NSStreamEventHasSpaceAvailable:
			if (stream == outputStream)
				[self feedOutputStream];
            
			break;

		case NSStreamEventEndEncountered:
		case NSStreamEventErrorOccurred:
            [self delegateDisconnect];
			break;
	}
}

- (void) sendData: (NSData *) data
    withMessageID: (UInt32) messageID
{
    if (outputStream.delegate == self) {
        SockMuxMessage msg;

        msg.magic = EndianU32_NtoB(magic);
        msg.messageID = EndianU32_NtoB(messageID);

        if (data)
            msg.length = EndianU32_NtoB([data length]);
        else
            msg.length = 0;

        [outputBuf appendBytes: &msg
                        length: sizeof(msg)];

        if (data)
            [outputBuf appendData: data];

        [self feedOutputStream];
    }    
}

- (void) sendMessageID: (UInt32) messageID
{
    [self sendData: nil
     withMessageID: messageID];
}

- (id) initWithStream: (NSOutputStream *) stream
                magic: (UInt32) _magic
{
    self = [super init];
    if (self) {
        magic = _magic;
        outputBuf = [[NSMutableData dataWithLength: 0] retain];
        outputStream = stream;
        [outputStream setDelegate: self];
    }

    // send handshake
    SockMuxHandshake hs;
    hs.magic = EndianU32_NtoB(magic);
    hs.protocolVersion = EndianU32_NtoB(PROTOCOL_VERSION);
    [outputBuf appendBytes: &hs
                    length: sizeof(hs)];
    [self feedOutputStream];

    return self;
}

@end

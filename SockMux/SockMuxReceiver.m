/***
 This file is part of SockMux for CoreFoundataion
 
 Copyright 2011 Daniel Mack <sockmux@zonque.org>
 
 SockMux is free software; you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License (LGPL) as
 published by the Free Software Foundation; either version 2.1 of the
 License, or (at your option) any later version.
 ***/

#import <TargetConditionals.h>

#if (TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#import <Endian.h>
#endif

#import "SockMuxReceiver.h"
#import "protocol.h"

@implementation SockMuxReceiver

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
#pragma mark Network Protocol implementation

- (void) delegateProtocolError
{
    if (delegate && [delegate respondsToSelector: @selector(protocolErrorForReceiver:)])
        [delegate protocolErrorForReceiver: self];
}

- (void) dispatchInputBuf
{
	while (1) {
		NSUInteger availableLength = [inputBuf length];
		
        if (!handshakeReceived) {
            if (availableLength < sizeof(SockMuxHandshake))
                return;
            
            const SockMuxHandshake *hs = [inputBuf bytes];
            if (EndianU32_BtoN(hs->magic) != magic) {
                [self delegateProtocolError];
                return;
            }
            
            [self removeFromBeginningOfBuf: &inputBuf
                                    length: sizeof(*hs)];
            handshakeReceived = YES;
            protocolVersion = EndianU32_BtoN(hs->protocolVersion);
        }
        
		if (availableLength < sizeof(SockMuxMessage))
			return;
		
		const SockMuxMessage *msg = [inputBuf bytes];
		UInt32 msglen = EndianU32_BtoN(msg->length);
		UInt32 messageID = EndianU32_BtoN(msg->messageID);
        
        if (EndianU32_BtoN(msg->magic) != magic) {
            [self delegateProtocolError];
            return;
        }
		
		if (availableLength < msglen + sizeof(*msg)) {
            // NSLog(@"waiting for %d bytes, got only %d\n", msglen, availableLength);
			return;
		}
        
        if (delegate && [delegate respondsToSelector: @selector(messageReceivedByReceiver:messageID:data:size:)])
            [delegate messageReceivedByReceiver: self
                                      messageID: messageID
                                           data: msg->data
                                           size: msglen];
		
		[self removeFromBeginningOfBuf: &inputBuf
                                length: msglen + sizeof(*msg)];
	}
}

#pragma mark -
#pragma mark NSStreamDelegate

- (void) delegateDisconnect
{
    if (delegate && [delegate respondsToSelector: @selector(streamClosedForReceiver:)])
        [delegate streamClosedForReceiver: self];
    
    [inputStream setDelegate: nil];
}

- (void)stream: (NSStream *) stream
   handleEvent: (NSStreamEvent) streamEvent
{
	NSInteger len;
	uint8_t buf[1024*4];
    
	switch (streamEvent) {
		case NSStreamEventHasBytesAvailable:
            len = [inputStream read: buf
                          maxLength: sizeof(buf)];
            if (len < 0) {
                [self delegateDisconnect];
                break;
            }
            
            if (len) {
                [inputBuf appendBytes: buf
                               length: len];
                [self dispatchInputBuf];
            }
            
			break;
            
		case NSStreamEventEndEncountered:
		case NSStreamEventErrorOccurred:
			[self delegateDisconnect];
			break;
	}
}

- (id) initWithStream: (NSInputStream *) stream
                magic: (UInt32) _magic
{
    self = [super init];
    if (self) {
        magic = _magic;
        inputBuf = [[NSMutableData dataWithLength: 0] retain];
        inputStream = stream;
        [inputStream setDelegate: self];
    }
    
    return self;
}

@end

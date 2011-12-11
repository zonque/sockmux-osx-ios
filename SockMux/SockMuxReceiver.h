/***
 This file is part of SockMux for CoreFoundataion
 
 Copyright 2011 Daniel Mack <sockmux@zonque.org>
 
 SockMux is free software; you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License (LGPL) as
 published by the Free Software Foundation; either version 2.1 of the
 License, or (at your option) any later version.
 ***/

#import <Foundation/Foundation.h>

@class SockMuxReceiver;

@protocol SockMuxReceiverDelegate
@required
- (void) messageReceivedByReceiver: (SockMuxReceiver *) receiver
                         messageID: (UInt32) messageID
                              data: (const Byte *) data
                              size: (UInt32) size;

@optional
- (void) streamClosedForReceiver: (SockMuxReceiver *) receiver;
- (void) protocolErrorForReceiver: (SockMuxReceiver *) receiver;
@end

@interface SockMuxReceiver : NSObject <NSStreamDelegate> {
	NSInputStream *inputStream;
    NSMutableData *inputBuf;
    BOOL handshakeReceived;
    UInt32 protocolVersion;
    UInt32 magic;
}

- (id) initWithStream: (NSInputStream *) stream
                magic: (UInt32) magic;

@property(nonatomic, assign) id delegate;

@end

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
                              size: (IOByteCount) size;

@optional
- (void) streamClosedForReceiver: (SockMuxReceiver *) receiver;
- (void) protocolErrorForReceiver: (SockMuxReceiver *) receiver;
@end

@interface SockMuxReceiver : NSObject <NSStreamDelegate> {
    //id <SockMuxReceiverDelegate> delegate;
	NSInputStream *inputStream;
    NSMutableData *inputBuf;
    BOOL handshakeReceived;
}

- (id) initWithInputStream: (NSInputStream *) stream;
@property(nonatomic, assign) id delegate;

@end

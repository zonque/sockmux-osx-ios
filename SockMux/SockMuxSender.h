/***
 This file is part of SockMux for CoreFoundataion
 
 Copyright 2011 Daniel Mack <sockmux@zonque.org>
 
 SockMux is free software; you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License (LGPL) as
 published by the Free Software Foundation; either version 2.1 of the
 License, or (at your option) any later version.
 ***/

#import <Foundation/Foundation.h>

@class SockMuxSender;

@protocol SockMuxSenderDelegate <NSObject>

@optional
- (void) streamClosedForSender: (SockMuxSender *) sender;
- (void) writeErrorForSender: (SockMuxSender *) sender;

@end

@interface SockMuxSender : NSObject <NSStreamDelegate> {
    id<SockMuxSenderDelegate> delegate;
    NSOutputStream *outputStream;
	NSMutableData *outputBuf;
}

- (id) initWithStream: (NSOutputStream *) stream;
- (void) sendData: (NSData *) data
    withMessageID: (UInt32) messageID;
- (void) sendMessageID: (UInt32) messageID;

@property(nonatomic, assign) id delegate;

@end

//
//  LZWSpoof.m
//  GifPro
//
//  Created by Alex Nichol on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "LZWSpoof.h"

@implementation LZWSpoof

@synthesize buffer;

#pragma mark LZW

+ (NSData *)lzwExpandData:(NSData *)existingData {
	LZWSpoof * destinationBuffer = [[LZWSpoof alloc] init];
	LZWSpoof * existingBuffer = [[LZWSpoof alloc] initWithData:existingData];
	
	LZWBufferRef sourceBuff = [existingBuffer buffer];
	LZWBufferRef destBuff = [destinationBuffer buffer];
	
	NSUInteger clearCodeCount = 254;
	[destinationBuffer addLZWClearCode];
	// loop through every byte, write it, and then write a clear code.
	for (NSUInteger byteIndex = 0; byteIndex < [existingData length]; byteIndex++) {
		NSUInteger startBit = byteIndex * 8;
		for (NSUInteger bitIndex = startBit; bitIndex < startBit + 8; bitIndex++) {
			lzwbuffer_add_bit(destBuff, lzwbuffer_get_bit(sourceBuff, bitIndex));
		}
		lzwbuffer_add_bit(destBuff, NO);
		// add clear code if needed
		clearCodeCount--;
		if (clearCodeCount == 0) {
			[destinationBuffer addLZWClearCode];
			clearCodeCount = 254;
		}
	}
	
	// LZW "STOP" directive
	lzwbuffer_add_bit(destBuff, YES);
	for (int i = 0; i < 7; i++) {
		lzwbuffer_add_bit(destBuff, NO);
	}
	lzwbuffer_add_bit(destBuff, YES);
	
#if !__has_feature(objc_arc)
	[existingBuffer release];
	NSData * theData = [destinationBuffer convertToData];
	[destinationBuffer release];
	return theData;
#else
	return [destinationBuffer convertToData];
#endif
}

#pragma mark Bit Buffer

- (id)initWithData:(NSData *)initialData {
	if ((self = [super init])) {
		buffer = lzwbuffer_create_data((const UInt8 *)[initialData bytes], [initialData length]);
	}
	return self;
}

- (id)init {
	if ((self = [super init])) {
		buffer = lzwbuffer_create();
	}
	return self;
}

#pragma mark LZW Buffer

- (void)addLZWClearCode {
	for (int i = 0; i < 8; i++) {
		lzwbuffer_add_bit(buffer, NO);
	}
	lzwbuffer_add_bit(buffer, YES);
}

#pragma mark Data

- (NSData *)convertToData {
	NSUInteger numBytes = lzwbuffer_bytes_used(buffer);
	return [NSData dataWithBytes:buffer->_bytePool length:numBytes];
}

- (void)dealloc {
	lzwbuffer_free(buffer);
#if !__has_feature(objc_arc)
	[super dealloc];
#endif
}

@end

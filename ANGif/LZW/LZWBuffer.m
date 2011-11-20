//
//  LZWBuffer.c
//  GifPro
//
//  Created by Alex Nichol on 11/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include "LZWBuffer.h"

LZWBufferRef lzwbuffer_create (void) {
	LZWBufferRef buffer = (LZWBufferRef)malloc(sizeof(struct _LZWBuffer));
	buffer->numBits = 0;
	buffer->_totalSize = LZWBufferSize;
	buffer->_bytePool = (UInt8 *)malloc(LZWBufferSize);
	return buffer;
}

LZWBufferRef lzwbuffer_create_data (const UInt8 * bytes, NSUInteger length) {
	LZWBufferRef buffer = (LZWBufferRef)malloc(sizeof(struct _LZWBuffer));
	buffer->numBits = length * 8;
	buffer->_totalSize = length;
	buffer->_bytePool = (UInt8 *)malloc(length);
	memcpy(buffer->_bytePool, bytes, length);
	return buffer;
}

void lzwbuffer_add_bit (LZWBufferRef buffer, BOOL flag) {
	NSUInteger endNumber = buffer->numBits + 1;
	if (endNumber / 8 + (endNumber % 8 == 0 ? 0 : 1) > buffer->_totalSize) {
		buffer->_totalSize += LZWBufferSize;
		buffer->_bytePool = (UInt8 *)realloc(buffer->_bytePool, buffer->_totalSize);
	}
	NSUInteger byteIndex = (buffer->numBits) / 8;
	UInt8 byteMask = (1 << ((buffer->numBits) % 8));
	if (flag) {
		(buffer->_bytePool)[byteIndex] |= byteMask;
	} else {
		(buffer->_bytePool)[byteIndex] &= (0xff ^ byteMask);
	}
	buffer->numBits += 1;
}

BOOL lzwbuffer_get_bit (LZWBufferRef buffer, NSUInteger bitIndex) {
	NSUInteger byteIndex = bitIndex / 8;
	UInt8 byteMask = (1 << (bitIndex % 8));
	return (((buffer->_bytePool[byteIndex] & byteMask) == 0) ? NO : YES);
}

NSUInteger lzwbuffer_bytes_used (LZWBufferRef buffer) {
	NSUInteger numBytes = buffer->numBits / 8 + (buffer->numBits % 8 == 0 ? 0 : 1);
	return numBytes;
}

void lzwbuffer_free (LZWBufferRef buffer) {
	free(buffer->_bytePool);
	free(buffer);
}

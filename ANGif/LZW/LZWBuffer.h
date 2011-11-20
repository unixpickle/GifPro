//
//  LZWBuffer.h
//  GifPro
//
//  Created by Alex Nichol on 11/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef GifPro_LZWBuffer_h
#define GifPro_LZWBuffer_h

#define LZWBufferSize 0x1000

struct _LZWBuffer {
	UInt8 * _bytePool;
	NSUInteger _totalSize;
	NSUInteger numBits;
};

typedef struct _LZWBuffer *LZWBufferRef;

LZWBufferRef lzwbuffer_create (void);
LZWBufferRef lzwbuffer_create_data (const UInt8 * bytes, NSUInteger length);

void lzwbuffer_add_bit (LZWBufferRef buffer, BOOL flag);
BOOL lzwbuffer_get_bit (LZWBufferRef buffer, NSUInteger bitIndex);

NSUInteger lzwbuffer_bytes_used (LZWBufferRef buffer);

void lzwbuffer_free (LZWBufferRef buffer);

#endif

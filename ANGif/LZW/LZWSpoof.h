//
//  LZWSpoof.h
//  GifPro
//
//  Created by Alex Nichol on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "LZWBuffer.h"

#define BitOutOfRangeException @"BitOutOfRangeException"

void LZWDataAddBit (UInt8 ** _bytePool, NSUInteger * _totalSize, NSUInteger * numBits, BOOL flag);
BOOL LZWDataGetBit (UInt8 * _bytePool, NSUInteger bitIndex);

@interface LZWSpoof : NSObject {
	LZWBufferRef buffer;
}

@property (readonly) LZWBufferRef buffer;

+ (NSData *)lzwExpandData:(NSData *)existingData;

- (id)initWithData:(NSData *)initialData;
- (NSData *)convertToData;

- (void)addLZWClearCode;

@end

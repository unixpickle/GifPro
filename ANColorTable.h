//
//  ANGifColorTable.h
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	UInt8 red;
	UInt8 green;
	UInt8 blue;
} ANGifColor;

typedef struct {
	ANGifColor color;
	NSUInteger priority;
} ANGifColorTableEntry;

BOOL ANGifColorIsEqual (ANGifColor color1, ANGifColor color2);

#define ANGifColorIndexOutOfBoundsException @"ANGifColorIndexOutOfBoundsException"
#define ANGifColorTableFullException @"ANGifColorTableFullException"

@interface ANColorTable : NSObject {
	ANGifColorTableEntry * _entries;
	NSUInteger _entryCount;
	NSUInteger _totalAlloced;
	NSUInteger maxColors;
	BOOL hasTransparentFirst;
}

@property (readwrite) NSUInteger maxColors;
@property (readonly) BOOL hasTransparentFirst;

- (id)initWithTransparentFirst:(BOOL)transparentFirst;

- (NSUInteger)numberOfEntries;
- (void)setColor:(ANGifColor)color atIndex:(UInt8)index;
- (UInt8)addColor:(ANGifColor)aColor;
- (ANGifColor)colorAtIndex:(UInt8)index;

- (void)sortByPriority;
- (BOOL)singleSortStep;

@end

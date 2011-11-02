//
//  ANGifColorTable.m
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANGifColorTable.h"

@implementation ANGifColorTable

@synthesize maxColors;

- (id)init {
	if ((self = [super init])) {
		_entries = (ANGifColorTableEntry *)malloc(sizeof(ANGifColorTableEntry));
		_totalAlloced = 1;
		maxColors = 256;
	}
	return self;
}

- (NSUInteger)numberOfEntries {
	return _entryCount;
}

- (void)setColor:(ANGifColor)color atIndex:(UInt8)index {
	if (index >= _entryCount) {
		@throw [NSException exceptionWithName:ANGifColorIndexOutOfBoundsException
									   reason:@"The specified color index was beyond the bounds of the color table."
									 userInfo:nil];
	}
	_entries[index].color = color;
	_entries[index].priority = 1;
}

- (UInt8)addColor:(ANGifColor)aColor {
	for (NSUInteger i = 0; i < _entryCount; i++) {
		if (ANGifColorIsEqual(_entries[i].color, aColor)) {
			_entries[i].priority += 1;
			return (UInt8)i;
		}
	}
	if (_entryCount >= maxColors) {
		@throw [NSException exceptionWithName:ANGifColorTableFullException reason:nil userInfo:nil];
	}
	if (_entryCount == _totalAlloced) {
		_totalAlloced += 3;
		if (_totalAlloced > maxColors) _totalAlloced = maxColors;
		_entries = (ANGifColorTableEntry *)malloc(sizeof(ANGifColorTableEntry) * _totalAlloced);
	}
	_entries[_entryCount].color = aColor;
	_entries[_entryCount].priority = 1;
	return _entryCount++;
}

- (ANGifColor)colorAtIndex:(UInt8)index {
	if (index >= _entryCount) {
		@throw [NSException exceptionWithName:ANGifColorIndexOutOfBoundsException
									   reason:@"The specified color index was beyond the bounds of the color table."
									 userInfo:nil];
	}
	return _entries[index].color;
}

- (void)dealloc {
	free(_entries);
}

#pragma mark - Sorting -

- (void)sortByPriority {
	while ([self singleSortStep]);
}

- (BOOL)singleSortStep {
	if (_entryCount == 0) return NO;
	ANGifColorTableEntry lastEntry = _entries[0];
	for (NSUInteger i = 1; i < _entryCount; i++) {
		ANGifColorTableEntry entry = _entries[i];
		if (entry.priority > lastEntry.priority) {
			// swap order
			_entries[i] = lastEntry;
			_entries[i - 1] = entry;
			return YES;
		}
		lastEntry = entry;
	}
	return NO;
}

@end

BOOL ANGifColorIsEqual (ANGifColor color1, ANGifColor color2) {
	if (color1.red == color2.red && color1.green == color2.green && color1.blue == color2.blue) {
		return YES;
	}
	return NO;
}

//
//  ANGifBasicColorTable.m
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANAvgColorTable.h"

@implementation ANAvgColorTable

- (UInt8)addColor:(ANGifColor)aColor {
	if (_entryCount < maxColors) {
		return [super addColor:aColor];
	}
	
	NSUInteger firstIndex = (self.hasTransparentFirst ? 1 : 0);
	UInt8 bestToCut = firstIndex;
	NSUInteger variance = 256 * 3;
	
	for (NSUInteger index = firstIndex + 1; index < _entryCount; index++) {
		NSUInteger lvariance = 0;
		ANGifColor color = [self colorAtIndex:index];
		lvariance += abs((int)color.red - (int)aColor.red);
		lvariance += abs(color.green - aColor.green);
		lvariance += abs(color.blue - aColor.blue);
		if (lvariance < variance) {
			bestToCut = index;
			variance = lvariance;
		}
	}

	// cut the best cut
	ANGifColor cutColor = [self colorAtIndex:bestToCut];
	cutColor.red = (UInt8)round(((double)cutColor.red + (double)aColor.red) / 2.0);
	cutColor.green = (UInt8)round(((double)cutColor.green + (double)aColor.green) / 2.0);
	cutColor.blue = (UInt8)round(((double)cutColor.blue + (double)aColor.blue) / 2.0);
	_entries[bestToCut].color = cutColor;
	_entries[bestToCut].priority += 1;

	return 0;
}

@end

//
//  ANGifImageFrame.m
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANGifImageFrame.h"

@implementation ANGifImageFrame

@synthesize pixelSource;
@synthesize localColorTable;
@synthesize offsetX, offsetY;
@synthesize delayTime;

- (id)initWithPixelSource:(id<ANGifImageFramePixelSource>)aSource colorTable:(ANColorTable *)table delayTime:(NSTimeInterval)delay {
	if ((self = [super init])) {
		self.pixelSource = aSource;
		self.localColorTable = table;
		self.delayTime = delay;
	}
	return self;
}

- (id)initWithPixelSource:(id<ANGifImageFramePixelSource>)aSource delayTime:(NSTimeInterval)delay {
	self = [self initWithPixelSource:aSource
						  colorTable:nil delayTime:delay];
	return self;
}

- (NSData *)encodeImageUsingColorTable:(ANColorTable *)colorTable {
	NSUInteger color[4];
	ANGifColor gifColor;
	NSMutableData * encodedData = [NSMutableData data];
	NSUInteger width = [pixelSource pixelsWide];
	NSUInteger height = [pixelSource pixelsHigh];
	for (NSUInteger y = 0; y < height; y++) {
		for (NSUInteger x = 0; x < width; x++) {
			[pixelSource getPixel:color atX:x y:y];
			gifColor.red = color[0];
			gifColor.green = color[1];
			gifColor.blue = color[2];
			UInt8 myByte = [colorTable addColor:gifColor];
			[encodedData appendBytes:&myByte length:1];
		}
	}
	return [NSData dataWithData:encodedData]; // return immutable version
}

@end

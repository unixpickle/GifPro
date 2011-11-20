//
//  ANCutColorTable.h
//  GifPro
//
//  Created by Alex Nichol on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define kColorTableSamplePoints 512

#import "ANColorTable.h"
#import "ANGifImageFramePixelSource.h"
#import "ANMutableColorArray.h"

@interface ANCutColorTable : ANColorTable {
	BOOL finishedInit;
}

/**
 * Create a new cut based color table with a given pixel source.
 * @param hasAlpha YES if the color table should have a transparent color reserved, NO otherwise.
 * @param pixelSource The pixel source from which pixels will be sampled.
 */
- (id)initWithTransparentFirst:(BOOL)hasAlpha pixelSource:(id<ANGifImageFramePixelSource>)pixelSource;

/**
 * Create a new cut based color table with a given pixel source.
 * @param hasAlpha YES if the color table should have a transparent color reserved, NO otherwise.
 * @param pixelSource The pixel source from which pixels will be sampled.
 * @param count The number of pixels to sample. Increasing this value will increase the
 * accuracy of the color table, but will decrease performance.
 */
- (id)initWithTransparentFirst:(BOOL)hasAlpha pixelSource:(id<ANGifImageFramePixelSource>)pixelSource samples:(NSUInteger)count;

@end

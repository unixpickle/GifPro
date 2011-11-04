//
//  ANNSImageGifPixelSource.h
//  GifPro
//
//  Created by Alex Nichol on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANGifImageFrame.h"

@interface ANNSImageGifPixelSource : NSObject <ANGifImageFramePixelSource> {
	NSBitmapImageRep * bitmapRep;
}

- (id)initWithImage:(NSImage *)anImage;

@end

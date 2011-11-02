//
//  ANGifImageDescriptor.m
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANGifImageDescriptor.h"

@implementation ANGifImageDescriptor

- (id)initWithImageFrame:(ANGifImageFrame *)anImage {
	if ((self = [super init])) {
		imageFrame = anImage;
	}
	return self;
}

- (NSData *)encodeBlock {
	NSMutableData * encoded = [NSMutableData data];
	
	return [NSData dataWithData:encoded];
}

@end

//
//  NSImage+Resize.m
//  GifPro
//
//  Created by Alex Nichol on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "NSImage+Resize.h"

@implementation NSImage (Resize)

- (NSImage *)imageByResizing:(NSSize)newSize {
	NSImage * resized = [[NSImage alloc] initWithSize:newSize];
	[resized lockFocus];
	[self drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)
			fromRect:NSZeroRect
		   operation:NSCompositeSourceOver fraction:1];
	[resized unlockFocus];
#if __has_feature(objc_arc)
	return resized;
#else
	return [resized autorelease];
#endif
}

@end

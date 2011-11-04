//
//  NSImage+Resize.h
//  GifPro
//
//  Created by Alex Nichol on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSImage (Resize)

- (NSImage *)imageByResizing:(NSSize)newSize;

@end

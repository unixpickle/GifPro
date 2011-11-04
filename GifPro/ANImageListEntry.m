//
//  ANImageListEntry.m
//  GifPro
//
//  Created by Alex Nichol on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "ANImageListEntry.h"

@implementation ANImageListEntry

@synthesize fileName;
@synthesize uniqueID;

+ (ANImageListEntry *)entryWithFileName:(NSString *)aFileName {
	ANImageListEntry * entry = [[ANImageListEntry alloc] init];
	entry.fileName = aFileName;
	entry.uniqueID = arc4random();
#if __has_feature(objc_arc)
	return entry;
#else
	return [entry autorelease];
#endif
}

#if !__has_feature(objc_arc)

- (void)dealloc {
	self.fileName = nil;
	[super dealloc];
}

#endif

@end

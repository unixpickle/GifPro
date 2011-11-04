//
//  ANImageListEntry.m
//  GifPro
//
//  Created by Alex Nichol on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANImageListEntry.h"

@implementation ANImageListEntry

@synthesize fileName;
@synthesize uniqueID;

+ (ANImageListEntry *)entryWithFileName:(NSString *)aFileName {
	ANImageListEntry * entry = [[ANImageListEntry alloc] init];
	entry.fileName = aFileName;
	entry.uniqueID = arc4random();
	return entry;
}

@end

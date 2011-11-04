//
//  ANImageListEntry.h
//  GifPro
//
//  Created by Alex Nichol on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANImageListEntry : NSObject {
	NSString * fileName;
	NSUInteger uniqueID;
}

@property (nonatomic, retain) NSString * fileName;
@property (readwrite) NSUInteger uniqueID;

+ (ANImageListEntry *)entryWithFileName:(NSString *)aFileName;

@end

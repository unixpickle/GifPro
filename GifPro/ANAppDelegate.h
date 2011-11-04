//
//  ANAppDelegate.h
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANGifEncoder.h"
#import "ANNSImageGifPixelSource.h"
#import "ANCutColorTable.h"
#import "ANImageListEntry.h"
#import "ANExportWindow.h"

@interface ANAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource> {
	IBOutlet NSTextField * frameRateField;
	IBOutlet NSImageView * currentFrame;
	IBOutlet NSTableView * imageTable;
	IBOutlet NSStepper * frameRateStepper;
	
	NSIndexSet * sourceIndices;
	NSMutableArray * imageList;
}

@property (assign) IBOutlet NSWindow * window;

- (IBAction)frameRateTicked:(NSStepper *)sender;
- (IBAction)frameRateFieldChanged:(id)sender;
- (IBAction)exportClicked:(id)sender;
- (IBAction)removeSelected:(id)sender;

- (void)beginExportToFile:(NSString *)path;

@end

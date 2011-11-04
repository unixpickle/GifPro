//
//  ANExportWindow.m
//  GifPro
//
//  Created by Alex Nichol on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANExportWindow.h"

@implementation ANExportWindow

- (id)initWithImageFiles:(NSArray *)theFiles outputFile:(NSString *)aFile delay:(NSTimeInterval)dTime {
	if ((self = [super initWithContentRect:NSMakeRect(0, 0, 500, 120) styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO])) {
		outputFile = aFile;
		imageFiles = theFiles;
		imageDelay = dTime;
		loadingBar = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(10, 50, 480, 24)];
		activityLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 70, 480, 24)];
		cancelButton = [[NSButton alloc] initWithFrame:NSMakeRect(405, 15, 90, 32)];
		[loadingBar startAnimation:self];
		[cancelButton setBezelStyle:NSRoundedBezelStyle];
		[cancelButton setBordered:YES];
		[cancelButton setTarget:self];
		[cancelButton setAction:@selector(cancelExport:)];
		[cancelButton setTitle:@"Cancel"];
		[activityLabel setBordered:NO];
		[activityLabel setBackgroundColor:[NSColor clearColor]];
		[activityLabel setStringValue:@"Exporting..."];
		[activityLabel setSelectable:NO];
		[[self contentView] addSubview:loadingBar];
		[[self contentView] addSubview:cancelButton];
		[[self contentView] addSubview:activityLabel];
		
		backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(exportInBackground) object:nil];
		[backgroundThread start];
	}
	return self;
}

- (void)cancelExport:(id)sender {
	[backgroundThread cancel];
	backgroundThread = nil;
	[NSApp endSheet:self];
	[self orderOut:self];
}

#pragma mark Background Thread

- (void)exportInBackground {
	@autoreleasepool {
		NSImage * firstImage = [[NSImage alloc] initWithContentsOfFile:[imageFiles objectAtIndex:0]];
		ANGifEncoder * encoder = [[ANGifEncoder alloc] initWithOutputFile:outputFile
																	 size:NSSizeToCGSize(firstImage.size) globalColorTable:nil];
		[encoder addApplicationExtension:[[ANGifNetscapeAppExtension alloc] initWithRepeatCount:0xffff]]; // loop
		[encoder addImageFrame:[self imageFrameFromImage:firstImage withDelay:imageDelay]];
		for (int i = 1; i < [imageFiles count]; i++) {
			if ([[NSThread currentThread] isCancelled]) {
				[encoder closeFile];
				[[NSFileManager defaultManager] removeItemAtPath:outputFile error:nil];
				return;
			}
			NSImage * anImage = [[NSImage alloc] initWithContentsOfFile:[imageFiles objectAtIndex:i]];
			if ([[NSThread currentThread] isCancelled]) {
				[encoder closeFile];
				[[NSFileManager defaultManager] removeItemAtPath:outputFile error:nil];
				return;
			}
			[encoder addImageFrame:[self imageFrameFromImage:anImage withDelay:imageDelay]];
		}
		[encoder closeFile];
		if ([[NSThread currentThread] isCancelled]) {
			[[NSFileManager defaultManager] removeItemAtPath:outputFile error:nil];
			return;
		}
		[self performSelectorInBackground:@selector(cancelExport:) withObject:nil];
	}
}

- (ANGifImageFrame *)imageFrameFromImage:(NSImage *)image withDelay:(NSTimeInterval)delayTime {
	ANNSImageGifPixelSource * pixSource = [[ANNSImageGifPixelSource alloc] initWithImage:image];
	return [[ANGifImageFrame alloc] initWithPixelSource:pixSource
											 colorTable:[[ANCutColorTable alloc] initWithTransparentFirst:YES pixelSource:pixSource]
											  delayTime:delayTime];
}

@end

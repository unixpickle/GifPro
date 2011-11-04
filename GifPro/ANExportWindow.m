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
		CGSize frameSize = NSSizeToCGSize(firstImage.size);
		ANGifEncoder * encoder = [[ANGifEncoder alloc] initWithOutputFile:outputFile
																	 size:frameSize globalColorTable:nil];
		[encoder addApplicationExtension:[[ANGifNetscapeAppExtension alloc] initWithRepeatCount:0xffff]]; // loop
		[encoder addImageFrame:[self imageFrameFromImage:firstImage]];
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
			[encoder addImageFrame:[self imageFrameFromImage:anImage scaled:frameSize]];
		}
		[encoder closeFile];
		if ([[NSThread currentThread] isCancelled]) {
			[[NSFileManager defaultManager] removeItemAtPath:outputFile error:nil];
			return;
		}
		[self performSelectorInBackground:@selector(cancelExport:) withObject:nil];
	}
}

- (ANGifImageFrame *)imageFrameFromImage:(NSImage *)image {
	ANNSImageGifPixelSource * pixSource = [[ANNSImageGifPixelSource alloc] initWithImage:image];
	return [[ANGifImageFrame alloc] initWithPixelSource:pixSource
											 colorTable:[[ANCutColorTable alloc] initWithTransparentFirst:YES pixelSource:pixSource]
											  delayTime:imageDelay];
}

- (ANGifImageFrame *)imageFrameFromImage:(NSImage *)image scaled:(CGSize)scaleSize {
	if (CGSizeEqualToSize(NSSizeToCGSize([image size]), scaleSize)) {
		return [self imageFrameFromImage:image];
	}
	
	CGSize imageSize = NSSizeToCGSize(image.size);
	NSImage * scaledImage = image;
	NSUInteger offsetX = 0, offsetY = 0;
	
	if (imageSize.width > scaleSize.width || imageSize.height > scaleSize.height) {
		// scale the image and image size
		CGFloat factorX = imageSize.width / scaleSize.width;
		CGFloat factorY = imageSize.height / scaleSize.height;
		if (factorY > factorX) {
			imageSize.width /= factorY;
			imageSize.height /= factorY;
		} else {
			imageSize.width /= factorX;
			imageSize.height /= factorX;
		}
		scaledImage = [image imageByResizing:NSSizeFromCGSize(imageSize)];
	}
	
	offsetX = (NSUInteger)round(scaleSize.width / 2.0 - imageSize.width / 2.0);
	offsetY = (NSUInteger)round(scaleSize.height / 2.0 - imageSize.height / 2.0);
	
	ANGifImageFrame * frame = [self imageFrameFromImage:scaledImage];
	frame.offsetX = offsetX;
	frame.offsetY = offsetY;
	return frame;
}

@end

//
//  ANExportWindow.m
//  GifPro
//
//  Created by Alex Nichol on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Converted to Non-ARC 11/4/11

#import "ANExportWindow.h"

@implementation ANExportWindow

- (id)initWithImageFiles:(NSArray *)theFiles outputFile:(NSString *)aFile delay:(NSTimeInterval)dTime {
	if ((self = [super initWithContentRect:NSMakeRect(0, 0, 500, 120) styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO])) {
#if __has_feature(objc_arc)
		outputFile = aFile;
		imageFiles = theFiles;
#else
		outputFile = [aFile retain];
		imageFiles = [theFiles retain];
#endif
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
#if !__has_feature(objc_arc)
	[backgroundThread release];
#endif
	backgroundThread = nil;
	[NSApp endSheet:self];
	[self orderOut:self];
}

#pragma mark Background Thread

- (void)exportInBackground {
	@autoreleasepool {
		NSDate * endMin = [NSDate dateWithTimeIntervalSinceNow:1];
		NSImage * firstImage = [[NSImage alloc] initWithContentsOfFile:[imageFiles objectAtIndex:0]];
		CGSize frameSize = NSSizeToCGSize(firstImage.size);
		ANGifEncoder * encoder = [[ANGifEncoder alloc] initWithOutputFile:outputFile
																	 size:frameSize globalColorTable:nil];
#if __has_feature(objc_arc)
		[encoder addApplicationExtension:[[ANGifNetscapeAppExtension alloc] initWithRepeatCount:0xffff]]; // loop
#else
		[encoder addApplicationExtension:[[[ANGifNetscapeAppExtension alloc] initWithRepeatCount:0xffff] autorelease]]; // loop
#endif
		
		[encoder addImageFrame:[self imageFrameFromImage:firstImage]];
		
#if __has_feature(objc_arc) != 1
		[firstImage release];
#endif
		
		for (int i = 1; i < [imageFiles count]; i++) {
			NSImage * anImage = [[NSImage alloc] initWithContentsOfFile:[imageFiles objectAtIndex:i]];
			if ([[NSThread currentThread] isCancelled]) {
				[encoder closeFile];
#if __has_feature(objc_arc) != 1
				[anImage release];
				[encoder release];
#endif
				[[NSFileManager defaultManager] removeItemAtPath:outputFile error:nil];
				return;
			}
			[encoder addImageFrame:[self imageFrameFromImage:anImage scaled:frameSize]];
#if __has_feature(objc_arc) != 1
			[anImage release];
#endif
		}
		[encoder closeFile];
#if __has_feature(objc_arc) != 1
		[encoder release];
#endif
		if ([[NSThread currentThread] isCancelled]) {
			[[NSFileManager defaultManager] removeItemAtPath:outputFile error:nil];
			return;
		}
		[NSThread sleepUntilDate:endMin];
		[self performSelectorInBackground:@selector(cancelExport:) withObject:nil];
	}
}

- (ANGifImageFrame *)imageFrameFromImage:(NSImage *)image {
#if __has_feature(objc_arc)
	ANNSImageGifPixelSource * pixSource = [[ANNSImageGifPixelSource alloc] initWithImage:image];
	return [[ANGifImageFrame alloc] initWithPixelSource:pixSource
											 colorTable:[[ANCutColorTable alloc] initWithTransparentFirst:YES pixelSource:pixSource]
											  delayTime:imageDelay];
#else
	ANNSImageGifPixelSource * pixSource = [[[ANNSImageGifPixelSource alloc] initWithImage:image] autorelease];
	ANColorTable * colorTable = [[[ANCutColorTable alloc] initWithTransparentFirst:YES pixelSource:pixSource] autorelease];
	return [[[ANGifImageFrame alloc] initWithPixelSource:pixSource
											 colorTable:colorTable
											  delayTime:imageDelay] autorelease];
#endif
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

#if !__has_feature(objc_arc)

- (void)dealloc {
	[loadingBar release];
	[cancelButton release];
	[activityLabel release];
	[backgroundThread release];
	
	[imageFiles release];
	[outputFile release];
	
	[super dealloc];
}

#endif

@end

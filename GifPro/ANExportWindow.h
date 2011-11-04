//
//  ANExportWindow.h
//  GifPro
//
//  Created by Alex Nichol on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "ANGifEncoder.h"
#import "ANCutColorTable.h"
#import "ANNSImageGifPixelSource.h"
#import "ANGifNetscapeAppExtension.h"
#import "NSImage+Resize.h"

@interface ANExportWindow : NSWindow {
	NSProgressIndicator * loadingBar;
	NSButton * cancelButton;
	NSTextField * activityLabel;
	NSThread * backgroundThread;
	
	NSArray * imageFiles;
	NSString * outputFile;
	NSTimeInterval imageDelay;
}

- (id)initWithImageFiles:(NSArray *)theFiles outputFile:(NSString *)aFile delay:(NSTimeInterval)dTime;
- (void)cancelExport:(id)sender;

- (void)exportInBackground;
- (ANGifImageFrame *)imageFrameFromImage:(NSImage *)image;
- (ANGifImageFrame *)imageFrameFromImage:(NSImage *)image scaled:(CGSize)scaleSize;

@end

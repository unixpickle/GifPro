//
//  ANAppDelegate.m
//  GifPro
//
//  Created by Alex Nichol on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ANAppDelegate.h"

@implementation ANAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	imageList = [[NSMutableArray alloc] init];
	[imageTable becomeFirstResponder];
	[imageTable registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

- (IBAction)frameRateTicked:(NSStepper *)sender {
	[frameRateField setIntValue:[sender intValue]];
}

- (IBAction)frameRateFieldChanged:(id)sender {
	[frameRateStepper setIntValue:[frameRateField intValue]];
	[frameRateField setIntValue:[frameRateStepper intValue]];
}

- (IBAction)exportClicked:(id)sender {
	if ([imageList count] == 0) {
		NSRunAlertPanel(@"No Images", @"You must add at least one external image to the animation before exporting.", @"OK", nil, nil);
		return;
	}
	NSSavePanel * savePanel = [NSSavePanel savePanel];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"gif"]];
	[savePanel setMessage:@"Export a gif file"];
	[savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		NSString * outputFile = nil;
		if (result == NSOKButton) {
			outputFile = [[savePanel URL] path];
		} else return;
		
		[self performSelector:@selector(beginExportToFile:) withObject:outputFile afterDelay:0.5];
	}];
}

- (IBAction)removeSelected:(id)sender {
	NSInteger selected = [imageTable selectedRow];
	if (selected >= 0) {
		[imageList removeObjectAtIndex:selected];
		[imageTable reloadData];
	}
}

- (void)beginExportToFile:(NSString *)path {
	NSMutableArray * imgFiles = [NSMutableArray array];
	[imageList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
		[imgFiles addObject:[obj fileName]];
	}];
	NSTimeInterval delayTime = 1.0 / [frameRateField doubleValue];
	ANExportWindow * export = [[ANExportWindow alloc] initWithImageFiles:imgFiles
															  outputFile:path
																   delay:delayTime];
	[NSApp beginSheet:export modalForWindow:self.window modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
#if !__has_feature(objc_arc)
	[export release];
#endif
}

#pragma mark - Table View -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [imageList count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return [[[imageList objectAtIndex:row] fileName] lastPathComponent];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	if ([imageTable selectedRow] < 0) {
		[currentFrame setImage:nil];
		return;
	}
	NSString * filename = [[imageList objectAtIndex:[imageTable selectedRow]] fileName];
#if __has_feature(objc_arc)
	[currentFrame setImage:[[NSImage alloc] initWithContentsOfFile:filename]];
#else
	[currentFrame setImage:[[[NSImage alloc] initWithContentsOfFile:filename] autorelease]];
#endif
}

#pragma mark Drag and Drop

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
	sourceIndices = rowIndexes;
	NSMutableArray * fileList = [NSMutableArray array];
	[rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * stop) {
		[fileList addObject:[[imageList objectAtIndex:idx] fileName]];
	}];
	[pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType]
				   owner:nil];
    [pboard setPropertyList:fileList forType:NSFilenamesPboardType];
	return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op {
    // Add code here to validate the drop
	if (![tableView isEnabled]) return NSDragOperationNone;
	return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info
			  row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
	NSArray * removeObjects = nil;
	if ([info draggingSource] == tableView) {
		removeObjects = [imageList objectsAtIndexes:sourceIndices];
	}
	
	id selectedItem = nil;
	if ([tableView selectedRow] >= 0) {
		selectedItem = [imageList objectAtIndex:[tableView selectedRow]];
	}
	
	if (![tableView isEnabled]) return NO;
    NSPasteboard * pboard = [info draggingPasteboard];
	NSArray * fileNames = [pboard propertyListForType:NSFilenamesPboardType];
	for (int i = 0; i < [fileNames count]; i++) {
		NSString * fileName = [fileNames objectAtIndex:i];
		[imageList insertObject:[ANImageListEntry entryWithFileName:fileName]
						atIndex:row];
		row++;
	}
	
	if (removeObjects) {
		[imageList removeObjectsInArray:removeObjects];
	}
	if (selectedItem) {
		if ([imageList containsObject:selectedItem]) {
			NSUInteger index = [imageList indexOfObject:selectedItem];
			[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
		}
	}
	
    // Move the specified row to its new location...
	[tableView reloadData];
	[self tableViewSelectionDidChange:nil];
	return YES;
}

#pragma mark Memory Management

#if !__has_feature(objc_arc)

- (void)dealloc {
	[sourceIndices release];
	[imageList release];
}

#endif

@end

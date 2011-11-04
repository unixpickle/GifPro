The ANGif Library
=================

ANGif is a small class library that can be used to encode Graphics Interchange Format files using a simple interface. It could easily be ported to platforms other than Cocoa (e.g. UIKit/CocoaTouch). The `ANGifEncoder` class is the root of all GIF encoding, and can be used as follows:

    ANGifEncoder * encoder = [[ANGifEncoder alloc] initWithOutputFile:@"myFile.gif" size:CGSizeMake(100, 100) globalColorTable:nil];
	[encoder addApplicationExtension:[[ANGifNetscapeAppExtension alloc] init]];
	[encoder addImageFrame:anImageFrame];
	[encoder addImageFrame:anotherImageFrame];
	[encoder closeFile];

The `addImageFrame:` method takes an instance of `ANGifImageFrame`, a basic class for enclosing images. The class itself can be instantiated using the `initWithPixelSource:colorTable:delayTime:` method. As of November 4th, 2011, the best color table to use is `ANCutColorTable`.

The `ANGifImageFramePixelSource` protocol is essential to the use of ANGif. It is suggested that you make a class that wraps a native image class such as `NSBitmapImageRep`, and implements all of the required methods.

The GifPro Project
==================

The Xcode project included with this repository is GifPro, a Mac OS X demo of what ANGif is capable of. The project includes `ANNSImageGifPixelSource`, an `NSBitmapImageRep` wrapper that conforms to the `ANGifImageFramePixelSource` protocol. The `ANExportWindow` class includes most of the code that directly interfaces the ANGif library.

Contribute a Color Table
------------------------

The GIF format works in a way such that files may only have 256 colors per image. This being said, algorithms exist to accurately calculate the best possible choices of colors for the 256-entry color table. The ANGif library is easily extendable to accomedate any color table algorithm that may be designed in the future.

If you are looking to implement a color table for ANGif, it is suggested that you have a look at the code for the `ANColorTable` base class. If you are still uncertain of exactly what you need to do to implement a color table, maybe have a look at `ANCutColorTable`. This was the first color table to be implemented for ANGif, and therefore should be a role model for those that follow.

//
//  UIImage+ACResizeImage
//  Hoccer
//
//  Created by Robert Palmer on 05.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "ACResizeImage.h"


@implementation ACResizeImage

+ (UIImage* )acImage: (UIImage *)image scaledToSize: (CGRect)rect 
{
	CGImageRef imageRef = [image CGImage];
	CGContextRef bitmapContext = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, 
													   CGImageGetBitsPerComponent(imageRef), 
													   rect.size.width * 4, 
													   CGImageGetColorSpace(imageRef), 
													   kCGImageAlphaNoneSkipFirst
													   );
	
	CGContextDrawImage(bitmapContext, rect, imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmapContext);
	
	UIImage *result = [UIImage imageWithCGImage: ref];
	NSLog(@"result: %@", result);
	
	return result;
}

@end

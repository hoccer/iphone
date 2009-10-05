//
//  UIImage+ACResizeImage
//  Hoccer
//
//  Created by Robert Palmer on 05.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "ACResizeImage.h"


@implementation UIImage (ACResizeImage)

- (UIImage* )acImageScaledToSize: (CGRect)rect 
{
	CGImageRef imageRef = [self CGImage];
	CGContextRef bitmapContext = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, 
													   CGImageGetBitsPerComponent(imageRef), 
													   rect.size.width * 4, 
													   CGImageGetColorSpace(imageRef), 
													   kCGImageAlphaNoneSkipFirst
													   );
	
	CGContextDrawImage(bitmapContext, rect, imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmapContext);
	
	UIImage *result = [UIImage imageWithCGImage: ref];
	
	CGContextRelease(bitmapContext);
	
	return result;
}

- (UIImage *)acImageScaledToWidth: (NSInteger)width
{
	float ratio = self.size.width / width;
	
	return [self acImageScaledToSize: CGRectMake(0, 0, width, self.size.height / ratio)];
}


@end

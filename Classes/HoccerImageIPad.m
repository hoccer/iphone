//
//  HoccerImageIPad.m
//  Hoccer
//
//  Created by Robert Palmer on 25.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerImageIPad.h"
#import "Preview.h"


@implementation HoccerImageIPad


- (void) dealloc
{
	[imageInFile release];
	[super dealloc];
}



- (Preview *)thumbnailView
{
	Preview *view = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 319, 234)];
	
	NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"Photobox" ofType:@"png"];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:backgroundImagePath]];
	
	[view addSubview:backgroundImage];
	[view sendSubviewToBack:backgroundImage];
	[backgroundImage release];
	
	[view setImage:self.image];
	return [view autorelease];
}

- (UIDocumentInteractionController*) interactionController{
	return [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath: filepath]];	
};

- (UIImage *)image {
	if (imageInFile == nil) {
		imageInFile = [[UIImage imageWithData:[NSData dataWithContentsOfFile:filepath]] retain];
	}
	
	return imageInFile;
}

@end

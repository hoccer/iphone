//
//  HoccerDataiPad.m
//  Hoccer
//
//  Created by Robert Palmer on 25.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerDataIPad.h"
#import "Preview.h"

@implementation HoccerDataIPad

- (id) initWithData: (NSData *)theData filename: (NSString *)filename {
	self = [super init];
	if (self != nil) {
		documentInteractionController = [[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filepath]] retain];
	}
	
	return self;
}

- (void) dealloc
{
	[documentInteractionController release];
	[filepath release];
	
	[super dealloc];
}



- (void)save {
}

- (void)dismiss {
}

- (UIView *)view {
	return [[[UIImageView alloc] initWithImage: [documentInteractionController.icons objectAtIndex:0]] autorelease];
}

- (Preview *)desktopItemView {
	Preview *view = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 319, 234)];
	
	NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"Photobox" ofType:@"png"];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:backgroundImagePath]];
	
	[view addSubview:backgroundImage];
	[view sendSubviewToBack:backgroundImage];
	[backgroundImage release];
	
	[view setImage:[documentInteractionController.icons objectAtIndex:0]];
	return [view autorelease];
}

- (NSString *)filename {
	return documentInteractionController.name;
}


- (void)previewInViewController: (UIViewController *)view {
	
}

- (void)decorateViewWithGestureDeector: (UIView *)view {
	
}

- (void)saveInSystem {
// [dataType save: data];
}


// new super power methods
- (UIDocumentInteractionController *)interactionController {
	return documentInteractionController;
}

// deprecate
- (BOOL)isDataReady {return NO; }
- (NSString *)saveButtonDescription {return nil; }
- (void)contentWillBeDismissed {}
- (BOOL)needsWaiting {return NO; }
- (void)whenReadyCallTarget: (id)aTarget selector: (SEL)aSelector {}




@end

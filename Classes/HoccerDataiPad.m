//
//  HoccerDataiPad.m
//  Hoccer
//
//  Created by Robert Palmer on 25.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerDataiPad.h"


@implementation HoccerDataiPad

- (id) initWithData: (NSData *)theData filename: (NSString *)filename {
	self = [super init];
	if (self != nil) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString *documentsDirectoryUrl = [paths objectAtIndex:0];
		
		filepath = [documentsDirectoryUrl stringByAppendingPathComponent: filename];
		[theData writeToURL:[NSURL fileURLWithPath:filepath] atomically: NO];
		
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
	return [[UIImageView alloc] initWithImage: [documentInteractionController.icons objectAtIndex:0]];
}

- (Preview *)thumbnailView {
	return nil;
}

- (NSString *)filename {
	return documentInteractionController.name;
}

- (NSString *)mimeType {
	return nil;
}

- (NSData *)data {
	return nil;
}

// new super power methods
- (UIDocumentInteractionController *)interactionController {
	return documentInteractionController;
}



// depracate
- (BOOL)isDataReady {return NO; }
- (NSString *)saveButtonDescription {return nil; }
- (void)contentWillBeDismissed {}
- (BOOL)needsWaiting {return NO; }
- (void)whenReadyCallTarget: (id)aTarget selector: (SEL)aSelector {}




@end

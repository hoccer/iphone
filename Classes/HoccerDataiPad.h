//
//  HoccerDataiPad.h
//  Hoccer
//
//  Created by Robert Palmer on 25.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerContent.h"

@interface HoccerDataIPad : HoccerContent {
	
	UIDocumentInteractionController *documentInteractionController;
}

- (id) initWithData: (NSData *)theData filename: (NSString *)filename;
- (UIDocumentInteractionController *)interactionController;

@end

//
//  HoccerContentIPadPreviewDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 30.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerContentPreviewDelegate.h"
@class HoccerContent;


@interface HoccerContentIPadPreviewDelegate : NSObject <UIDocumentInteractionControllerDelegate> {
	UIViewController *viewControllerForPreview;
	
	UIDocumentInteractionController *interactionController;
}

@property (retain) UIDocumentInteractionController *interactionController;

@end

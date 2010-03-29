//
//  HoccerImage.h
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoccerContent.h"
#import "HoccerData.h"


@interface HoccerImage : HoccerData <HoccerContent> {
	UIImage *image;

	NSThread *secondThread;
	BOOL isDataReady;
	
	id target;
	SEL selector;
	
	// UIDocumentInteractionController *documentInteractionController;
	UIViewController *viewControllerForPreview;
}

@property (nonatomic, retain) NSData* data;
@property (nonatomic, readonly) UIImage* image;

- (id)initWithUIImage: (UIImage *)aImage;
- (id)initWithData: (NSData *)data;
- (void)dismiss;

- (UIView *)view;

@end

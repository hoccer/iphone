//
//  HoccerImage.h
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoccerContent.h"

@interface HoccerImage : HoccerContent {
	UIImage *image;

	NSThread *secondThread;
	BOOL isDataReady;
	
	id target;
	SEL selector;
	
	UIViewController *viewControllerForPreview;
}

@property (nonatomic, readonly) UIImage* image;

- (id)initWithUIImage: (UIImage *)aImage;

- (UIView *)fullscreenView;

@end

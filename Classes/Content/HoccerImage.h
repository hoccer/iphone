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
	id target;
	SEL selector;
}

@property (nonatomic, readonly) UIImage* image;

- (id)initWithUIImage: (UIImage *)aImage;
- (void)whenReadyCallTarget: (id)aTarget selector: (SEL)aSelector;

@end

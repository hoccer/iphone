//
//  HoccerImage.h
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoccerContent.h"


@interface HoccerImage : NSObject <HoccerContent> {
	UIImage *image;
	NSData *data;

	NSThread *secondThread;
	BOOL isDataReady;
	
	id target;
	SEL selector;
}

@property (nonatomic, retain) NSData* data;
@property (nonatomic, readonly) UIImage* image;

- (id)initWithUIImage: (UIImage *)aImage;
- (id)initWithData: (NSData *)data;
- (void)dismiss;

- (UIView *)view;

@end

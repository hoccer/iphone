//
//  PreviewViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PreviewViewController : UIViewController {

	UIView* previewView;	
	id delegate;
	CGPoint origin;
}

@property (retain) UIView* previewView;
@property (nonatomic, retain) id delegate;
@property (assign) CGPoint origin;

- (void)dismissKeyboard;
- (void)resetViewAnimated: (BOOL)animated;
- (void)startPreviewFlyOutAnimation;
@end

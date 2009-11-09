//
//  HiddenViewScrollViewDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 05.11.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HiddenViewScrollViewDelegate : NSObject <UIScrollViewDelegate> {

	UIScrollView *scrollView;
	UIView *hiddenView;
	
	UIView *indicatorView;
	
	BOOL indicatorIsTurnedUp;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIView *indicatorView;
@property (nonatomic, retain) UIView *hiddenView;


@end

//
//  HelpScrollView.h
//  Hoccer
//
//  Created by Robert Palmer on 27.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GesturesInterpreterDelegate.h"


@interface HelpScrollView : UIViewController <UIScrollViewDelegate, GesturesInterpreterDelegate> {
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIPageControl *pageControl;
	NSArray *pages;
	
	BOOL pageControlUsed;
	
	id delegate;
	
	NSDate *lastGesture;
}

@property (nonatomic, assign) id delegate;

- (IBAction)hideView: (id)sender;
- (IBAction)changePage:(id)sender;

@end

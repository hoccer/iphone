//
//  HoccerText.h
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoccerContent.h"


@interface HoccerText : HoccerContent <UITextViewDelegate> {
	UITextView *textView;
	
	Preview *view;
}

@property (nonatomic, readonly) NSString *content;
@property (retain) IBOutlet Preview *view;

@end

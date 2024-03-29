//
//  HoccerText.h
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoccerContent.h"
#import "TextPreview.h"

@interface HoccerText : HoccerContent <UITextViewDelegate> {
	UITextView *textView;
	TextPreview *view;
}

@property (nonatomic, readonly) NSString *content;
@property (retain) IBOutlet TextPreview *view;
@property (retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet HCButton *editButton;

+ (BOOL)isDataAUrl: (NSData *)data;

@end

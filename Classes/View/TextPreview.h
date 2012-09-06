//
//  TextPreview.h
//  Hoccer
//
//  Created by Robert Palmer on 29.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Preview.h"
#import "TextInputViewController.h"

@interface TextPreview : Preview <TextInputViewControllerDelegate> {
	UITextView *textView;
	UIButton *editButton;
	
    BOOL *editing;
	id delegate;
}

@property (retain) IBOutlet UITextView *textView;
@property (retain) IBOutlet UIButton *editButton;

@property (assign) id delegate;

- (IBAction)toggleEditMode: (id)sender;
- (IBAction)showTextInputView:(id)sender;
- (void)setStaticMode;
- (void)setEditMode;

@end
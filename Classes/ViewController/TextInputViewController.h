//
//  TextInputViewController.h
//  Hoccer
//
//  Created by Philip Brechler on 04.09.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextInputViewControllerDelegate.h"

@interface TextInputViewController : UIViewController {
    IBOutlet UITextView *textView;
    IBOutlet UINavigationItem *theNavItem;
    NSString *initialText;
}

@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (retain, nonatomic) IBOutlet UINavigationItem *theNavItem;
@property (strong, atomic) id delegate;

- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;

- (void)setInitialText:(NSString *)text andDelegate:(id)delegate;
@end
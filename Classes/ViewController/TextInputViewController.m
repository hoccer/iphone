//
//  TextInputViewController.m
//  Hoccer
//
//  Created by Philip Brechler on 04.09.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "TextInputViewController.h"
#import "UIBarButtonItem+CustomImageButton.h"

#import <QuartzCore/QuartzCore.h>
#import "HoccerAppDelegate.h"

@implementation TextInputViewController
@synthesize textView;
@synthesize theNavItem;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.textView setText:initialText];
    
    [textView becomeFirstResponder];
    UIBarButtonItem *doneButton = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"nav_bar_btn_done_blue"] target:self action:@selector(doneButtonTapped:)];
    UIBarButtonItem *canelButton = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"nav_bar_btn_cancel"] target:self action:@selector(cancelButtonTapped:)];
    [self.theNavItem setRightBarButtonItem:doneButton];
    [self.theNavItem setLeftBarButtonItem:canelButton];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        UIGraphicsBeginImageContextWithOptions(self.presentingViewController.view.bounds.size, YES, self.presentingViewController.view.window.screen.scale);
        
        [self.presentingViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage* ret = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        self.view.backgroundColor = [UIColor colorWithPatternImage:ret];
    }
    [doneButton release];
    [canelButton release];
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [[self.view.subviews objectAtIndex:0] removeFromSuperview];
    }
}
- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setTheNavItem:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void) moveTextViewForKeyboard:(NSNotification*)aNotification up: (BOOL) up
{
    NSDictionary* userInfo = [aNotification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardEndFrame;
    float editHeight = textView.frame.size.height;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];

    CGRect newFrame = textView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    if (up) {
        editHeight = newFrame.size.height;
        newFrame.size.height -= keyboardFrame.size.height;
    } else {
        newFrame.size.height = editHeight;
    }
    NSLog(@"Old Frame: %@", NSStringFromCGRect(textView.frame));
    textView.frame = newFrame;
    NSLog(@"New Frame: %@", NSStringFromCGRect(newFrame));

    [UIView commitAnimations];
}
- (void)dealloc {
    [textView release];
    [theNavItem release];
    [super dealloc];
}

- (IBAction)doneButtonTapped:(id)sender {
    [textView resignFirstResponder];
    [self.delegate textInputViewController:self didFinishedWithString:textView.text];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        HoccerAppDelegate *appDelegate = (HoccerAppDelegate *)[UIApplication sharedApplication].delegate;
        HoccerViewController *hcVC = (HoccerViewController *)appDelegate.viewController;
        [hcVC cancelPopOver];
    }else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self.delegate textInputViewControllerdidCancel];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)setInitialText:(NSString *)text andDelegate:(id)theDelegate{
    self.delegate = theDelegate;
    initialText = text;
}


@end

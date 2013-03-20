//
//  TextPreview.m
//  Hoccer
//
//  Created by Robert Palmer on 29.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import "TextPreview.h"
#import "NSObject+DelegateHelper.h"

@implementation TextPreview

@synthesize textView;
@synthesize editButton;
@synthesize delegate;

- (void)awakeFromNib {
    textView.editable = NO;
    editing = NO;
	[self setStaticMode];
}

- (void)viewDidLoad {
    [editButton setTitle:NSLocalizedString(@"Button_Edit", nil) forState:UIControlStateNormal];

}

- (IBAction)toggleEditMode: (id)sender {
	if (textView.editable) {
		[delegate checkAndPerformSelector:@selector(textPreviewDidEndEditing:)];
		[self setStaticMode];
	} else {
		[self setEditMode];
	}
}

- (IBAction)showTextInputView:(id)sender; {
    if (!editing) {
        TextInputViewController *textInputViewController;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            textInputViewController = [[TextInputViewController alloc] initWithNibName:@"TextInputViewController" bundle:[NSBundle mainBundle]];
        }
        else {
            textInputViewController = [[TextInputViewController alloc] initWithNibName:@"TextInputViewController-iPad" bundle:[NSBundle mainBundle]];
        }
        [textInputViewController setInitialText:textView.text andDelegate:self];
        
        NSNotification *notification = [NSNotification notificationWithName:@"showTextInputVC" object:textInputViewController];
        [[NSNotificationCenter defaultCenter] postNotification:notification];

    }
}

- (void)setStaticMode {
	textView.editable = NO;
	textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor blackColor];
	textView.opaque = YES;
	
    self.opaque = YES;
	self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"container_text-land.png"]];
	self.opaque = NO;
	textView.userInteractionEnabled = NO; 
	textView.textColor = [UIColor colorWithWhite:0.222 alpha:1.000];
	[textView resignFirstResponder];
}

- (void)setEditMode {
	textView.editable = YES;
	textView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"container_text_edit_linie.png"]];
    textView.textColor = [UIColor blackColor];
	textView.opaque = NO;
	[editButton setImage:[UIImage imageNamed:@"container_btn_single-edit"] forState:UIControlStateNormal];
	
	self.opaque = YES;
	self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"container_text_edit-land.png"]];
	self.opaque = NO;
    textView.textColor = [UIColor colorWithWhite:0.222 alpha:1.000];

	textView.userInteractionEnabled = YES; 
	[textView becomeFirstResponder];	
}

- (BOOL)allowsOverlay {
	return YES;
}

- (void)textInputViewControllerDidCancel {
    NSNotification *notification = [NSNotification notificationWithName:@"textInputVCDidCancel" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)textInputViewController:(TextInputViewController *)controller didFinishedWithString:(NSString *)string {
    [self.textView setText:string];
    [self setStaticMode];
}

@end

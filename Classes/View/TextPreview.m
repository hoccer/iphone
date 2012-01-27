//
//  TextPreview.m
//  Hoccer
//
//  Created by Robert Palmer on 29.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "TextPreview.h"
#import "NSObject+DelegateHelper.h"

@implementation TextPreview

@synthesize textView;
@synthesize editButton;
@synthesize delegate;

- (void)awakeFromNib {
	[self setStaticMode];
}

- (IBAction)toggleEditMode: (id)sender {
	if (textView.editable) {
		[delegate checkAndPerformSelector:@selector(textPreviewDidEndEditing:)];
		[self setStaticMode];
	} else {
		[self setEditMode];
	}
}

- (void)setStaticMode {
	textView.editable = NO;
	textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor blackColor];
	textView.opaque = YES;
	
	[editButton setImage:[UIImage imageNamed:@"container_text_editbtn.png"] forState:UIControlStateNormal];
	
	self.opaque = YES;
	self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"container_text-land.png"]];
	self.opaque = NO;
	textView.userInteractionEnabled = NO; 
	textView.textColor = [UIColor colorWithWhite:0.222 alpha:1.000];
	[textView resignFirstResponder];
}

- (void)setEditMode {
	textView.editable = YES;
	//textView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"container_text_edit_linie.png"]];
    textView.textColor = [UIColor blackColor];
	textView.opaque = NO;
	[editButton setImage:[UIImage imageNamed:@"container_text_edit_savebtn.png"] forState:UIControlStateNormal];
	
	self.opaque = YES;
	self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"container_text_edit-land.png"]];
	self.opaque = NO;
    textView.textColor = [UIColor colorWithWhite:0.222 alpha:1.000];

	textView.userInteractionEnabled = YES; 
	[textView becomeFirstResponder];	
}

- (BOOL)allowsOverlay {
	return !textView.editable;
}



@end

//
//  TextPreview.m
//  Hoccer
//
//  Created by Robert Palmer on 29.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "TextPreview.h"


@implementation TextPreview

@synthesize textView;
@synthesize editButton;

- (void)awakeFromNib {
	[self setStaticMode];
}

- (IBAction)toggleEditMode: (id)sender {
	if (textView.editable) {
		[self setStaticMode];
	} else {
		[self setEditMode];
	}
}

- (void)setStaticMode {
	textView.editable = NO;
	textView.backgroundColor = [UIColor clearColor];
	textView.opaque = YES;
	
	[editButton setImage:[UIImage imageNamed:@"container_text_editbtn.png"] forState:UIControlStateNormal];
	
	self.opaque = YES;
	self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"container_text-land.png"]];
	self.opaque = NO;
	
	[textView resignFirstResponder];
}

- (void)setEditMode {
	textView.editable = YES;
	textView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"container_text_edit_linie.png"]];
	textView.opaque = NO;
	[editButton setImage:[UIImage imageNamed:@"container_text_edit_savebtn.png"] forState:UIControlStateNormal];
	
	self.opaque = YES;
	self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"container_text_edit-land.png"]];
	self.opaque = NO;
	
	[textView becomeFirstResponder];
	
}

@end

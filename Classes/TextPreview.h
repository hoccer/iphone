//
//  TextPreview.h
//  Hoccer
//
//  Created by Robert Palmer on 29.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Preview.h"


@interface TextPreview : Preview {
	UITextView *textView;
	UIButton *editButton;
}

@property (retain) IBOutlet UITextView *textView;
@property (retain) IBOutlet UIButton *editButton;

- (IBAction)toggleEditMode: (id)sender;

- (void)setStaticMode;
- (void)setEditMode;

@end
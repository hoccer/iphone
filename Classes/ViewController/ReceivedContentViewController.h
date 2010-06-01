//
//  ReceivedContentView.h
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoccerContent.h"

@interface ReceivedContentViewController : UIViewController {
	id delegate;
	
	IBOutlet UIBarButtonItem *saveButton;
	IBOutlet UIToolbar *toolbar;
	
	HoccerContent* hoccerContent;
	IBOutlet UIActivityIndicatorView *activity;
}

@property (assign) id delegate;
@property (nonatomic, retain) HoccerContent* hoccerContent;


- (IBAction)save: (id)sender;
- (IBAction)resend: (id)sender;

- (void)setHoccerContent: (HoccerContent *) content;

@end

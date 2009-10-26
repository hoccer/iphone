//
//  ReceivedContentView.h
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoccerContent.h"

@interface ReceivedContentView : UIViewController {
	id delegate;
	
	IBOutlet UIBarButtonItem *saveButton;
	IBOutlet UIToolbar *toolbar;
	
	IBOutlet UIActivityIndicatorView *activity;
	
}

@property (assign) id delegate;

- (IBAction)onSave: (id)sender;
- (IBAction)onDismiss: (id)sender;

- (void)setHoccerContent: (id <HoccerContent>) content;
-  (void)setWaiting;

@end

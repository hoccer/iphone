//
//  ReceivedContentView.h
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoccerContent.h"
#import "MBProgressHUD.h"

@interface ReceivedContentViewController : UIViewController <UIActionSheetDelegate>{
	id delegate;
    
	HoccerContent* hoccerContent;
	
	MBProgressHUD *HUD;
}

@property (assign) id delegate;
@property (nonatomic, retain) HoccerContent* hoccerContent;

- (IBAction)save: (id)sender;
- (IBAction)resend: (id)sender;

- (void)setHoccerContent: (HoccerContent *) content;

@end

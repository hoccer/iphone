//
//  HoccerViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HoccerViewController : UIViewController {
	IBOutlet UIButton *catchButton;
}

@property (retain) UIButton *catchButton;

- (IBAction)onCatch: (id)sender;

@end


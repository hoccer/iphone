//
//  HelpScreen.h
//  Hoccer
//
//  Created by Robert Palmer on 27.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HelpContent;


@interface HelpScreen : UIViewController {
	IBOutlet UILabel *header;
	IBOutlet UITextView *description;
	IBOutlet UIImageView *imageView;
	
	
	HelpContent *content;
	
}

@property (nonatomic, retain) HelpContent *content;

- (id)initWithHelpContent: (HelpContent *)helpContent;
- (IBAction)playVideo: (id)sender;

@end

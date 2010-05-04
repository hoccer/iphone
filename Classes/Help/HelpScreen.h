//
//  HelpScreen.h
//  Hoccer
//
//  Created by Robert Palmer on 27.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#import "GesturesInterpreterDelegate.h"


@class HelpContent;


@interface HelpScreen : UIViewController {
	IBOutlet UILabel *header;
	IBOutlet UITextView *description;
	IBOutlet UIImageView *imageView;
	IBOutlet UIButton *videoButton;
	MPMoviePlayerController *player;
	
	HelpContent *content;
}

@property (nonatomic, retain) HelpContent *content;
@property (nonatomic, retain) MPMoviePlayerController *player;

- (id)initWithHelpContent: (HelpContent *)helpContent;
- (IBAction)playVideo: (id)sender;

@end

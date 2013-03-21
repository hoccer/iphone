//
//  AudioPreview.m
//  Hoccer
//
//  Created by Philip Brechler on 01.08.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "AudioPreview.h"
#import "CGRectUtils.h"


@implementation AudioPreview

@synthesize coverImage, songLabel, audioPlayButton;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [audioPlayButton setTitle:NSLocalizedString(@"Button_Play", nil) forState:UIControlStateNormal];
    audioPlayButton.center = CGPointRound(audioPlayButton.center);
}

- (void)dealloc {
    [coverImage release];
    [songLabel release];
    [audioPlayButton release];
    [super dealloc];
}

- (IBAction)audioPlayButtonPressed:(id)sender
{
    NSNotification *notification = [NSNotification notificationWithName:@"playPlayer" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end

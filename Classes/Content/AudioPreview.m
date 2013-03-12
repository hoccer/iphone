//
//  AudioPreview.m
//  Hoccer
//
//  Created by Philip Brechler on 01.08.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "AudioPreview.h"

@implementation AudioPreview

@synthesize coverImage, songLabel, audioPlayButton;

- (void)awakeFromNib {
    [super awakeFromNib];
    audioPlayButton.titleLabel.text = NSLocalizedString(@"Button_Play", nil);
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

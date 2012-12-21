//
//  AudioPreview.m
//  Hoccer
//
//  Created by Philip Brechler on 01.08.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "AudioPreview.h"

@implementation AudioPreview

@synthesize coverImage, songLabel;


- (void)dealloc {
    [coverImage release];
    [songLabel release];
    [_audioPlayButton release];
    [super dealloc];
}

- (IBAction)audioPlayButtonPressed:(id)sender
{
    NSNotification *notification = [NSNotification notificationWithName:@"playPlayer" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
//    NSLog(@"playPlayer in audioPreview notify");
}

@end

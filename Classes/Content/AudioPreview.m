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
    [super dealloc];
}

@end

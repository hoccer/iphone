//
//  AudioPreview.h
//  Hoccer
//
//  Created by Philip Brechler on 01.08.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Preview.h"
#import "HCButton.h"

@interface AudioPreview : Preview {
    UIImageView *coverImage;
    UILabel *songLabel;
}

@property (nonatomic,retain) IBOutlet UIImageView *coverImage;
@property (nonatomic,retain) IBOutlet UILabel *songLabel;
@property (retain, nonatomic) IBOutlet HCButton *audioPlayButton;

- (IBAction)audioPlayButtonPressed:(id)sender;

@end

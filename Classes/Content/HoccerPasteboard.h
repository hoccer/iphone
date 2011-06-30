//
//  HoccerPasteboard.h
//  Hoccer
//
//  Created by Philip Brechler on 27.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "HoccerContent.h"

@interface HoccerPasteboard : HoccerContent {
    
    NSString *pastedText;
    UIImage *pastedImage;
    NSURL *pastedURL;
    
}

- (HoccerContent *)returnPastedContent;

@end

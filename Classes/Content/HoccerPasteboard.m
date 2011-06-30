//
//  HoccerPasteboard.m
//  Hoccer
//
//  Created by Philip Brechler on 27.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "HoccerPasteboard.h"
#import "HoccerContent.h"

#import "HoccerImage.h"
#import "HoccerText.h"

@implementation HoccerPasteboard

- (id)init
{
    self = [super init];
    
    if (self != nil) {
        UIPasteboard *gpPasteboard = [UIPasteboard generalPasteboard];
        
        
        if (gpPasteboard.string != nil){
            pastedText = gpPasteboard.string;
        }
        else if (gpPasteboard.image != nil){
            pastedImage = gpPasteboard.image;
        }
        else if (gpPasteboard.URL !=nil){
            pastedURL = gpPasteboard.URL;
        }
        else {
            return nil;
        }
    }
    
    return self;
}

- (HoccerContent *)returnPastedContent {
    if (pastedText !=nil){
        NSData *data = [pastedText dataUsingEncoding:NSUTF8StringEncoding];
        HoccerText *text = [[[HoccerText alloc] initWithData:data] autorelease];
        text.isFromContentSource =YES;
        return text;
    }
    else if (pastedImage != nil){
        HoccerContent *content = [[[HoccerImage alloc] initWithUIImage:pastedImage] autorelease];
        return content;
    }
    else if (pastedURL !=nil){
        NSData *data = [[pastedURL absoluteString] dataUsingEncoding:NSUTF8StringEncoding];
        HoccerText *text = [[[HoccerText alloc] initWithData:data] autorelease];
        text.isFromContentSource = YES;

        return text;
    }
    else {
        return nil;
    }
    
}


@end

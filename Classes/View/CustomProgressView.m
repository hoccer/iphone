//
//  CustomProgressView.m
//  Hoccer
//
//  Created by Philip Brechler on 14.06.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "CustomProgressView.h"

@implementation CustomProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    
    CGSize backgroundStretchPoints = {4, 9}, fillStretchPoints = {3, 8};
    
    // Initialize the stretchable images.
    UIImage *background = [[UIImage imageNamed:@"statusbar_track"] stretchableImageWithLeftCapWidth:backgroundStretchPoints.width 
                                                                                           topCapHeight:backgroundStretchPoints.height];
    
    UIImage *fill = [[UIImage imageNamed:@"statusbar_progress"] stretchableImageWithLeftCapWidth:fillStretchPoints.width 
                                                                                       topCapHeight:fillStretchPoints.height];  
    
    // Draw the background in the current rect
    [background drawInRect:rect];
    
    // Compute the max width in pixels for the fill.  Max width being how
    // wide the fill should be at 100% progress.
    NSInteger maxWidth = rect.size.width;
    
    // Compute the width for the current progress value, 0.0 - 1.0 corresponding 
    // to 0% and 100% respectively.
    NSInteger curWidth = floor([self progress] * maxWidth);
    
    // Create the rectangle for our fill image accounting for the position offsets,
    // 1 in the X direction and 1, 3 on the top and bottom for the Y.
    CGRect fillRect = CGRectMake(rect.origin.x,
                                 rect.origin.y,
                                 curWidth,
                                 rect.size.height);
    
    // Draw the fill
    [fill drawInRect:fillRect];
}

@end

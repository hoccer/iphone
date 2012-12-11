//
//  HCHistoryImageWidget.m
//  Hoccer
//
//  Created by Ralph At Hoccer on 18.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "HCHistoryImageWidget.h"
#import "DataManager.h"

@implementation HCHistoryImageWidget

@synthesize delegate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)toggleViewButtonPressed:(id)sender
{
    //changes the +/- icon, updates widget state
    if (self.frame.size.height >= kCellHeight) {
        [self.toggelImage setImage:[UIImage imageNamed:@"widget_plus.png"]];
        self.widgetIsOpen = NO;
    }
    else {
        [self.toggelImage setImage:[UIImage imageNamed:@"widget_minus.png"]];
        self.widgetIsOpen = YES;
    }
    DataManager *dm = [DataManager sharedDataManager];
    
    NSLog(@"########## self.delegate respondsToSelector:@selector(toggleButtonPressed");
    [dm.historyTVC toggleButtonPressed:self];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_historyImageBig release];
    [_historyImageSmall release];
    [_historyFileName release];
    [_historyDate release];
    [_bottomView release];
    [_topView release];
    [_toggelImage release];
    [_toggleViewButton release];
    [super dealloc];
}

@end

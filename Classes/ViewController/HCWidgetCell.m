//
//  HCWidgetCell.m
//  Hoccer
//
//  Created by Ralph At Hoccer on 18.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "HCWidgetCell.h"
#import "DataManager.h"

@implementation HCWidgetCell

@synthesize widgetIsOpen;
@synthesize widgetId;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

@end

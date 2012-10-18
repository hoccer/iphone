//
//  HCDataManager.m
//  Hoccer
//
//  Created by Ralph At Hoccer on 18.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "HCDataManager.h"
#import "HCHistoryImageWidget.h"

@implementation HCDataManager

@synthesize historyObjectsArray;
@synthesize historyTVC;

static HCDataManager* _sharedHCDataManager = nil;

+(HCDataManager *)sharedHCDataManager
{
    //singleton instance
    @synchronized([HCDataManager class])
    {
        if (!_sharedHCDataManager) {
            _sharedHCDataManager = [[HCDataManager alloc] init];
        }
    }
    return _sharedHCDataManager;
}

- (id)init
{
    self = [super init];

    HCHistoryImageWidget *widget1 = [[[HCHistoryImageWidget alloc] init] autorelease];
    NSArray *topLevelObjects1 = [[NSBundle mainBundle] loadNibNamed:@"HCHistoryImageWidget" owner:self options:nil];
    for (NSObject *object in topLevelObjects1) {
        if ([object isKindOfClass:[HCHistoryImageWidget class]]) {
            widget1 = (HCHistoryImageWidget *)object;
            break;
        }
    }
    HCHistoryImageWidget *widget2 = [[[HCHistoryImageWidget alloc] init] autorelease];
    NSArray *topLevelObjects2 = [[NSBundle mainBundle] loadNibNamed:@"HCHistoryImageWidget" owner:self options:nil];
    for (NSObject *object in topLevelObjects2) {
        if ([object isKindOfClass:[HCHistoryImageWidget class]]) {
            widget2 = (HCHistoryImageWidget *)object;
            break;
        }
    }
    HCHistoryImageWidget *widget3 = [[[HCHistoryImageWidget alloc] init] autorelease];
    NSArray *topLevelObjects3 = [[NSBundle mainBundle] loadNibNamed:@"HCHistoryImageWidget" owner:self options:nil];
    for (NSObject *object in topLevelObjects3) {
        if ([object isKindOfClass:[HCHistoryImageWidget class]]) {
            widget3 = (HCHistoryImageWidget *)object;
            break;
        }
    }
    
    widget1.widgetIsOpen = NO;
    widget2.widgetIsOpen = NO;
    widget3.widgetIsOpen = NO;

    widget1.historyFileName.text = @"first picture";
    widget2.historyFileName.text = @"second picture";
    widget3.historyFileName.text = @"third picture";
    
    widget1.historyImageSmall.image = [UIImage imageNamed:@"fail_kitten.jpg"];
    widget2.historyImageSmall.image = [UIImage imageNamed:@"fail_kitten.jpg"];
    widget3.historyImageSmall.image = [UIImage imageNamed:@"fail_kitten.jpg"];
    
    widget1.historyImageBig.image = [UIImage imageNamed:@"fail_kitten.jpg"];
    widget2.historyImageBig.image = [UIImage imageNamed:@"fail_kitten.jpg"];
    widget3.historyImageBig.image = [UIImage imageNamed:@"fail_kitten.jpg"];
    
    
    
    self.historyObjectsArray = [[NSArray alloc] initWithObjects:widget1, widget2, widget3, nil];
    
    return self;
}

@end

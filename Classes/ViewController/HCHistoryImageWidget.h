//
//  HCHistoryImageWidget.h
//  Hoccer
//
//  Created by Ralph At Hoccer on 18.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "HCWidgetCell.h"
#import "HCWidgetCellDelegate.h"

@interface HCHistoryImageWidget : HCWidgetCell {
    id <HCWidgetCellDelegate> delegate;

}

@property (retain, nonatomic) IBOutlet UIImageView *historyImageBig;
@property (retain, nonatomic) IBOutlet UIImageView *historyImageSmall;
@property (retain, nonatomic) IBOutlet UILabel *historyFileName;
@property (retain, nonatomic) IBOutlet UILabel *historyDate;
@property (retain, nonatomic) IBOutlet UIView *bottomView;
@property (retain, nonatomic) IBOutlet UIView *topView;
@property (retain, nonatomic) IBOutlet UIImageView *toggelImage;
@property (retain, nonatomic) IBOutlet UIButton *toggleViewButton;
@property (nonatomic, assign) id <HCWidgetCellDelegate> delegate;

- (IBAction)toggleViewButtonPressed:(id)sender;

@end

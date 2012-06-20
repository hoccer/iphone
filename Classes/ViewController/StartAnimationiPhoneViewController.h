//
//  StartAnimationiPhoneViewController.h
//  Hoccer
//
//  Created by Philip Brechler on 18.06.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface StartAnimationiPhoneViewController : UIViewController {
    IBOutlet UIImageView *objectImageView;
    IBOutlet UIImageView *overlayImageView;
    IBOutlet UIImageView *backgroundImageView;
    IBOutlet UIImageView *upperBarImageView;
    IBOutlet UIImageView *lowerBarImageView;

}

@property (nonatomic, retain) IBOutlet UIImageView *objectImageView;
@property (nonatomic, retain) IBOutlet UIImageView *overlayImageView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UIImageView *upperBarImageView;
@property (nonatomic, retain) IBOutlet UIImageView *lowerBarImageView;
- (void)removeSelf;

@end

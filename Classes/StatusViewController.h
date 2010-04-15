//
//  StatusViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 18.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HocItemData;


@interface StatusViewController : UIViewController {
	id delegate;
	IBOutlet UIProgressView *progressView;	
	IBOutlet UIActivityIndicatorView *activitySpinner;
	IBOutlet UILabel *statusLabel;
	
	HocItemData *hocItemData;
}

@property (assign) id delegate;
@property (retain) HocItemData* hocItemData;

- (void)setUpdate: (NSString *)update;
- (void)setError: (NSError *)error;
- (void)setErrorMessage: (NSString *)message;
- (void)setProgressUpdate: (CGFloat) percentage;
- (void)showActivityInfo;
- (void)hideActivityInfo;

- (IBAction) cancelAction: (id) sender;

- (void)monitorHocItem: (HocItemData *)hocItem;
@end


//
//  ItemViewControllerDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ItemViewController;

@protocol ItemViewControllerDelegate <NSObject>
@optional

//- (void)hoccerControllerUploadWasCanceled: (ItemViewController *)item;
//- (void)hoccerControllerDownloadWasCanceled: (ItemViewController *)item;

- (void)itemViewControllerWasClosed: (ItemViewController *)item;
- (void)itemViewControllerSaveButtonWasClicked: (ItemViewController *)item; 

@end

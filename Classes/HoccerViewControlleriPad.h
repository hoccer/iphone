//
//  HoccerViewControlleriPad.h
//  Hoccer
//
//  Created by Robert Palmer on 23.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerViewController.h"

@class DesktopDataSource;
@class HistoryDesktopDataSource;

@interface HoccerViewControlleriPad : HoccerViewController <UIPopoverControllerDelegate, UIDocumentInteractionControllerDelegate> {
	UIPopoverController *popOver;
	
	HistoryDesktopDataSource *historyData;
}

@property (nonatomic, retain) HistoryDesktopDataSource *historyData;

- (void)toggleHistory:(id)sender;

@end

//
//  HoccerViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PeerGroupRequest;
@class PeerGroupPollingRequest;
@class DownloadRequest;

@class HoccerBaseRequest;

@interface HoccerViewController : UIViewController {
	IBOutlet UILabel *statusLabel;
	
	HoccerBaseRequest *request;
}


- (IBAction)onCancel: (id)sender; 
- (IBAction)onCatch: (id)sender;

@end


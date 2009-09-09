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
@class HoccerImage;

@interface HoccerViewController : UIViewController {
	IBOutlet UILabel *statusLabel;
	IBOutlet UIToolbar *toolbar;
	
	HoccerBaseRequest *request;
	
	HoccerImage *hoccerImage;
}


- (IBAction)onCancel: (id)sender; 
- (IBAction)onCatch: (id)sender;
- (IBAction)saveToGallery: (id)sender;

@end


//
//  DebugViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccelerationRecorder;
@class FeatureHistory;

@interface DebugViewController : UIViewController {

	BOOL recording;
	AccelerationRecorder *recorder;
	
	IBOutlet UIButton *recordingButton;
	IBOutlet UIImageView *imageView;
}

@property BOOL recording;

- (IBAction) record: (id)sender;

@end

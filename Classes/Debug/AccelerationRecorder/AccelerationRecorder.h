//
//  AccelerationRecorder.h
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeatureHistory;

@interface AccelerationRecorder : NSObject <UIAccelerometerDelegate> {
	NSFileHandle *file;
	NSString *filename;
	
	FeatureHistory *featureHistory;
}

@property (nonatomic, copy) NSString* filename; 
@property (nonatomic, retain) FeatureHistory *featureHistory;

- (void)startRecording;
- (void)stopRecording;

@end

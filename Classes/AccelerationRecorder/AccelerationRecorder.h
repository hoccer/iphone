//
//  AccelerationRecorder.h
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccelerationRecorder : NSObject <UIAccelerometerDelegate> {
	NSFileHandle *file;
	NSString *filename;
}

@property (nonatomic, copy) NSString* filename; 

- (void)startRecording;
- (void)stopRecording;

@end

//
//  GesturesInterpreter.h
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CatchDetector;
@class FeatureHistory;


@interface GesturesInterpreter : NSObject <UIAccelerometerDelegate> {
	CatchDetector *catchDetector;
	FeatureHistory *featureHistory;
	
	id delegate;
}

@property (retain) id delegate;

@end

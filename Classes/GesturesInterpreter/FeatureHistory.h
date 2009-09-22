//
//  FeatureHistory.h
//  Hoccer
//
//  Created by Robert Palmer on 22.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeatureHistory : NSObject {

	NSMutableArray *xLineFeatures;
	NSMutableArray *yLineFeatures;
	NSMutableArray *zLineFeatures;
	
}

@property (readonly) NSMutableArray *xLineFeatures, *yLineFeatures, *zLineFeatures;

- (void)addAcceleration : (UIAcceleration *)acceleration;

@end

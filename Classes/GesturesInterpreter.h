//
//  GesturesInterpreter.h
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GesturesInterpreter : NSObject <UIAccelerometerDelegate> {
	id delegate;
}

@property (retain) id delegate;

@end

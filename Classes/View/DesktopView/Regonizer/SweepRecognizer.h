//
//  SweepRecognizer.h
//  Hoccer
//
//  Created by Robert Palmer on 08.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DesktopView;

@interface SweepRecognizer : NSObject {
	BOOL isDetecting;
}


- (void)desktopView: (DesktopView*)view touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)desktopView: (DesktopView*)view touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)desktopView: (DesktopView*)view touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)desktopView: (DesktopView*)view touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end

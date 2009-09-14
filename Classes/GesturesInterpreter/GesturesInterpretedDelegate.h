//
//  GesturesInterpretedDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//



@protocol GesturesInterpretedDelegate

- (void)gesturesInterpreter: (GesturesInterpreter *)aGestureInterpreter didDetectGesture: (NSString *)aGesture;

@end

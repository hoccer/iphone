//
//  FeedbackProvider.m
//  Hoccer
//
//  Created by Robert Palmer on 12.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "FeedbackProvider.h"

SystemSoundID catchId = 0;
SystemSoundID throwId = 0;
SystemSoundID tapId   = 0;

void CreateSystemSoundIDFromWAVInRessources(CFStringRef name, SystemSoundID *id)
{
	CFBundleRef bundle = CFBundleGetMainBundle();
	CFURLRef soundUrl = CFBundleCopyResourceURL(bundle, 
													name, CFSTR("wav"), NULL);
	AudioServicesCreateSystemSoundID(soundUrl, id);
	
	CFRelease(soundUrl);
}


@implementation FeedbackProvider

+  (void)initialize
{
	CreateSystemSoundIDFromWAVInRessources(CFSTR("catch_sound"), &catchId);
	CreateSystemSoundIDFromWAVInRessources(CFSTR("throw_sound"), &throwId);
	CreateSystemSoundIDFromWAVInRessources(CFSTR("tap_sound"), &tapId);
}


+ (void)playCatchFeedback 
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	AudioServicesPlaySystemSound(catchId);
}

+ (void)playThrowFeedback 
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	AudioServicesPlaySystemSound(throwId);
}

+ (void)playTapFeedback
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	AudioServicesPlaySystemSound(tapId);
}

@end

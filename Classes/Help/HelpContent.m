//
//  HelpContent.m
//  Hoccer
//
//  Created by Robert Palmer on 27.10.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import "HelpContent.h"


@implementation HelpContent

@synthesize name;
@synthesize description;
@synthesize imagePath;
@synthesize videoPath;

+ (HelpContent *)sweepHelp {
	HelpContent *content = [[HelpContent alloc] init];
	
	content.name = NSLocalizedString(@"Sweep",nil);
	content.description = NSLocalizedString(@"In order to share with one person directly, place you mobiles screen to screen and drag the content from one screen to the other mobile. Make sure you continue your touch over the other device's screen.",nil);
	content.imagePath = [[NSBundle mainBundle] pathForResource:@"help_sweep_icon" ofType:@"png"];
	content.videoPath = nil;
	
	return [content autorelease];
}


+ (HelpContent *)catchHelp {
	HelpContent *content = [[HelpContent alloc] init];
	
	content.name = NSLocalizedString(@"Catch",nil);
	content.description = NSLocalizedString(@"To catch thrown content, raise your mobile quickly from horocitaly to vertical positon. You will hear a sound if you did it right.",nil);
	content.imagePath = [[NSBundle mainBundle] pathForResource:@"help_catch_icon" ofType:@"png"];
	content.videoPath = [[NSBundle mainBundle] pathForResource:@"catch_180" ofType:@"m4v"];
	
	return [content autorelease];
}

+ (HelpContent *)throwHelp {
	HelpContent *content = [[HelpContent alloc] init];
	
	content.name = NSLocalizedString(@"Throw",nil);
	content.description = NSLocalizedString(@"Move your mobile like throwing a frisbee to share selected content with catchers nearby. You will hear a sound if you did it right.",nil);
	content.imagePath = [[NSBundle mainBundle] pathForResource:@"help_throw_icon" ofType:@"png"];
	content.videoPath = [[NSBundle mainBundle] pathForResource:@"throw_180" ofType:@"m4v"];
	
	return [content autorelease];
}

+ (HelpContent *)tabHelp
{
	HelpContent *content = [[HelpContent alloc] init];
	
	content.name = @"Tab";
	content.description = @"To make sure your content is only receivable by ONE person, give both mobiles a gentle simultaneous tap.";
	content.imagePath = [[NSBundle mainBundle] pathForResource:@"receive" ofType:@"png"];
	content.videoPath = [[NSBundle mainBundle] pathForResource:@"bump_180" ofType:@"mp4"];
	
	return [content autorelease];
}

+ (HelpContent *)keyHelp {
    HelpContent *content = [[HelpContent alloc] init];
	
	content.name = NSLocalizedString(@"Key exchange",nil);
	content.description = NSLocalizedString(@"To send your data encrypted select one or more clients to automatically exchange keys between your devices.",nil);
	content.imagePath = [[NSBundle mainBundle] pathForResource:@"tutorial_key_exchange" ofType:@"png"];
	content.videoPath = nil;
	
	return [content autorelease];
}
+ (HelpContent *)encryptionHelp{
    HelpContent *content = [[HelpContent alloc] init];
	
	content.name = NSLocalizedString(@"Encryption",nil);
	content.description = NSLocalizedString(@"To enable end-to-end encryption tap the lock in the upper left corner of the screen. Devices capable of encryption are marked with a key in the client list.",nil);
	content.imagePath = [[NSBundle mainBundle] pathForResource:@"tutorial_encryption" ofType:@"png"];
	content.videoPath = nil;
	
	return [content autorelease];
}


@end

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


+ (HelpContent *)helpContentWithTitle:(NSString *)title description:(NSString *)description imagePath:(NSString *)imagePath videoPath:(NSString *)videoPath {
    
    HelpContent *content = [[HelpContent alloc] init];
    content.name = title;
    content.description = description;
    content.imagePath = imagePath;
    content.videoPath = videoPath;
    
    return [content autorelease];
}

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)extension {
    
    return [[NSBundle mainBundle] pathForResource:name ofType:extension];
}

+ (HelpContent *)sweepHelp {
    
    return [self helpContentWithTitle:NSLocalizedString(@"HelpTitle_Sweep",nil)
                           description:NSLocalizedString(@"HelpMessage_Sweep",nil)
                             imagePath:[self pathForResource:@"help_sweep_icon" ofType:@"png"]
                             videoPath:nil];
}

+ (HelpContent *)autoReceiveHelp {
    
    return [self helpContentWithTitle:NSLocalizedString(@"HelpTitle_AutoReceive",nil)
                           description:NSLocalizedString(@"HelpMessage_AutoReceive",nil)
                             imagePath:[self pathForResource:@"tutorial_autoreceive" ofType:@"png"]
                             videoPath:nil];
}

+ (HelpContent *)channelHelp {
    
    return [self helpContentWithTitle:NSLocalizedString(@"HelpTitle_Channel",nil)
                          description:NSLocalizedString(@"HelpMessage_Channel",nil)
                            imagePath:[self pathForResource:@"tutorial_channel" ofType:@"png"]
                            videoPath:nil];
}


+ (HelpContent *)catchHelp {
	HelpContent *content = [[HelpContent alloc] init];
	
	content.name = NSLocalizedString(@"HelpTitle_Catch",nil);
	content.description = NSLocalizedString(@"HelpMessage_Catch",nil);
	content.imagePath = [[NSBundle mainBundle] pathForResource:@"help_catch_icon" ofType:@"png"];
	content.videoPath = [[NSBundle mainBundle] pathForResource:@"catch_180" ofType:@"m4v"];
	
	return [content autorelease];
}

+ (HelpContent *)throwHelp {
	HelpContent *content = [[HelpContent alloc] init];
	
	content.name = NSLocalizedString(@"HelpTitle_Throw",nil);
	content.description = NSLocalizedString(@"HelpMessage_Throw",nil);
	content.imagePath = [[NSBundle mainBundle] pathForResource:@"help_throw_icon" ofType:@"png"];
	content.videoPath = [[NSBundle mainBundle] pathForResource:@"throw_180" ofType:@"m4v"];
	
	return [content autorelease];
}

+ (HelpContent *)tabHelp
{
	HelpContent *content = [[HelpContent alloc] init];
	
	content.name = NSLocalizedString(@"HelpTitle_Tab", nil);
	content.description = NSLocalizedString(@"HelpMessage_Tab", nil);
	content.imagePath = [[NSBundle mainBundle] pathForResource:@"receive" ofType:@"png"];
	content.videoPath = [[NSBundle mainBundle] pathForResource:@"bump_180" ofType:@"mp4"];
	
	return [content autorelease];
}

+ (HelpContent *)keyHelp {
    HelpContent *content = [[HelpContent alloc] init];
	
	content.name = NSLocalizedString(@"HelpTitle_Key",nil);
	content.description = NSLocalizedString(@"HelpMessage_Key",nil);
	content.imagePath = [[NSBundle mainBundle] pathForResource:@"tutorial_key_exchange" ofType:@"png"];
	content.videoPath = nil;
	
	return [content autorelease];
}
+ (HelpContent *)encryptionHelp{
    HelpContent *content = [[HelpContent alloc] init];
	
	content.name = NSLocalizedString(@"HelpTitle_Encryption",nil);
	content.description = NSLocalizedString(@"HelpMessage_Encryption",nil);
	content.imagePath = [[NSBundle mainBundle] pathForResource:@"tutorial_encryption" ofType:@"png"];
	content.videoPath = nil;
	
	return [content autorelease];
}


@end

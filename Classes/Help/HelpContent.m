//
//  HelpContent.m
//  Hoccer
//
//  Created by Robert Palmer on 27.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HelpContent.h"


@implementation HelpContent

@synthesize name;
@synthesize description;
@synthesize imagePath;
@synthesize videoPath;

+ (HelpContent *)catchHelp
{
	HelpContent *content = [[HelpContent alloc] init];
	
	content.name = @"Catch";
	content.description = @"To catch thrown content, raise your mobile like catching a ball and hold it for a second. You can try it now, too!";
	content.imagePath = [[NSBundle mainBundle] pathForResource:@"Help_Catch_Icon" ofType:@"png"];
	content.videoPath = [[NSBundle mainBundle] pathForResource:@"catch_180" ofType:@"mp4"];
	
	return [content autorelease];
}

+ (HelpContent *)throwHelp
{
	HelpContent *content = [[HelpContent alloc] init];
	
	content.name = @"Throw";
	content.description = @"Move your mobile like throwing a frisbee to share selected content with catchers nearby. Try the gesture now!";
	content.imagePath = [[NSBundle mainBundle] pathForResource:@"Help_Throw_Icon" ofType:@"png"];
	content.videoPath = [[NSBundle mainBundle] pathForResource:@"throw_180" ofType:@"mp4"];
	
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


@end

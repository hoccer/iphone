//
//  SettingsAction.m
//  Hoccer
//
//  Created by Philip Brechler on 02.08.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "SettingsAction.h"

@implementation SettingsAction
@synthesize description;
@synthesize selector;
@synthesize type;
@synthesize defaultValue;

+ (SettingsAction *)actionWithDescription: (NSString *)theDescription selector: (SEL)theSelector type: (HCSettingsType)theType; {
	SettingsAction *action = [[SettingsAction alloc] init];
	action.description = theDescription;
	action.selector = theSelector;
	action.type = theType;
	
	return [action autorelease];
}

- (void) dealloc {
	[defaultValue release];
	[description release];
	[super dealloc];
}

@end
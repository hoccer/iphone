//
//  VcardWriter.m
//  Hoccer
//
//  Created by Robert Palmer on 06.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "VcardWriter.h"


@implementation VcardWriter

- (id) init
{
	self = [super init];
	if (self != nil) {
		vcardString = [[NSMutableArray alloc] init];
	}
	
	return self;
}


- (void)writeProperty: (NSString *)propertyName 
				value: (NSString *)valueName
			paramater: (NSArray *)parameter 
{
	NSString *line = [NSString stringWithFormat: @"%@:%@", propertyName,  valueName];
}

- (void) dealloc
{
	[vcardString dealloc];
	[super dealloc];
}



- (NSString *)vcardRepresentation 
{
	return vcardString;
}


@end

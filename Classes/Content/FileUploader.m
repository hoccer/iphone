//
//  FileUploader.m
//  Hoccer
//
//  Created by Robert Palmer on 10.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "FileUploader.h"


@implementation FileUploader

- (id)initWithFilename: (NSString *)aFilename {
	self = [super init];
	if (self != nil) {
		filename = [aFilename retain];
	}
	
	return self;
}

@end

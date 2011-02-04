//
//  HoccerFileContent.m
//  Hoccer
//
//  Created by Robert Palmer on 09.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "HoccerFileContent.h"
#import "FileDownloader.h"
#import "FileUploader.h"


@implementation HoccerFileContent

- (id) init{
	self = [super init];
	if (self != nil) {
		transferable = [[FileUploader alloc] initWithFilename:super.filename];
	}
	return self;	
}

- (id) initWithFilename:(NSString *)theFilename {self = [super initWithFilename:theFilename];
	if (self != nil) {
		transferable = [[FileUploader alloc] initWithFilename:filename];
	}
	
	return self;	
}

- (id) initWithDictionary:(NSDictionary *)dict {
	self = [super initWithDictionary:dict];
	if (self != nil) {
		mimeType = [[dict objectForKey:@"type"] retain];
		NSString *downloadURL = [dict objectForKey:@"uri"];
		transferable = [[FileDownloader alloc] initWithURL:downloadURL filename: @""];
	}
	
	return self;
}

-(void) dealloc {
	[transferable release];
	[mimeType release];
	
	[super dealloc]; 
}

- (NSObject <Transferable>*) transferer {
	return transferable;
}

- (NSDictionary *) dataDesctiption {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setObject:self.mimeType forKey:@"type"];
	[dict setObject:[transferable.url stringByRemovingQuery] forKey:@"uri"];
	
	return dict;
}

- (NSString *)filename {
	return transferable.filename;
}

@end

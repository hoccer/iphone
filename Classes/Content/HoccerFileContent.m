//
//  HoccerFileContent.m
//  Hoccer
//
//  Created by Robert Palmer on 09.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "HoccerFileContent.h"
#import "FileDownloader.h"

@implementation HoccerFileContent

- (id) initWithDictionary:(NSDictionary *)dict {
	self = [super initWithDictionary:dict];
	if (self != nil) {
		NSString *downloadURL = [dict objectForKey:@"url"];
		transferable = [[FileDownloader alloc] initWithURL:downloadURL];

		mimeType = [[dict objectForKey:@"type"] retain];
	}
	
	return self;
}

- (id) initWithFilename:(NSString *)theFilename {
	self = [super initWithFilename:theFilename];
	if (self != nil) {
		// transferable = [[FileUploader alloc] initWithFilename:filename];
	}
	
	return self;	
}


-(void) dealloc {
	[transferable release];
	
	[super dealloc]; 
}

- (NSObject <Transferable>*) transferer {
	return transferable;
}

- (NSDictionary *) dataDesctiption {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setObject:self.mimeType forKey:@"type"];
	[dict setObject:((FileDownloader *)transferable).url forKey:@"url"];
	
	return dict;
}

- (NSString *)filename {
	return ((FileDownloader *)transferable).filename;
}

@end

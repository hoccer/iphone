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
#import "NSString+URLHelper.h"

@implementation HoccerFileContent

- (id) init{
	self = [super init];
	if (self != nil) {
        transferables = [[NSMutableArray alloc] init];
 	}
    
	return self;	
}

- (id) initWithFilename:(NSString *)theFilename {
	self = [super initWithFilename:theFilename];
	if (self != nil) {
        filename = [theFilename copy];
        
        transferables = [[NSMutableArray alloc] init];
		NSObject <Transferable> *transferable = [[FileUploader alloc] initWithFilename:filename];
        [transferables addObject: transferable];

	}
	
	return self;	
}

- (id) initWithDictionary:(NSDictionary *)dict {
	self = [super initWithDictionary:dict];
	if (self != nil) {
        transferables = [[NSMutableArray alloc] init];
        
        mimeType = [[dict objectForKey:@"type"] retain];
		NSString *downloadURL = [dict objectForKey:@"uri"];
        
        NSObject <Transferable> *transferable = [[FileDownloader alloc] initWithURL:downloadURL filename: @""];
        
        [transferables addObject: transferable];
	}
	
	return self;
}

- (NSObject <Transferable>*) transferer {
	return [transferables objectAtIndex:0];
}

- (NSArray *)transferers {
    return transferables;
}

- (NSDictionary *) dataDesctiption {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setObject:self.mimeType forKey:@"type"];
	[dict setObject:[[[transferables objectAtIndex:0] url] stringByRemovingQuery] forKey:@"uri"];
	
	return dict;
}

- (NSString *)filename {
    if ([transferables count] > 0) {
        return [[transferables objectAtIndex:0] filename];
    }
    
    return filename;
}

-(void) dealloc {
	[transferables release];
	[mimeType release];
	
	[super dealloc]; 
}

@end

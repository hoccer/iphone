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
#import "FileTransferer.h"

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
        mimeType = @"application/octet-stream";
        transferables = [[NSMutableArray alloc] init];  
        canBeCiphered = YES;
    }
	
	return self;	
}

- (void)viewDidLoad {
    NSObject <Transferable> *transferable = [[FileUploader alloc] initWithFilename:filename];
    transferable.cryptor = self.cryptor;
        
    [transferables addObject: transferable];
    [transferable release];
}

- (id) initWithDictionary:(NSDictionary *)dict {
	self = [super initWithDictionary:dict];
	if (self != nil) {
        transferables = [[NSMutableArray alloc] init];
        
        mimeType = [[dict objectForKey:@"type"] retain];
		if ([dict objectForKey:@"uri"]) {
            NSString *downloadURL = [dict objectForKey:@"uri"];
        
            NSObject <Transferable> *transferable = [[FileDownloader alloc] initWithURL:downloadURL filename: self.filename];
            transferable.cryptor = self.cryptor;
            //NSLog(@"cryptor %@", self.cryptor);
        
            [transferables addObject: transferable];
            [transferable release];
            
            canBeCiphered = NO;
        } else {
            return nil;
        }
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
    NSString *string = [((FileTransferer *)[transferables objectAtIndex:0]) url];
	[dict setObject:[string stringByRemovingQuery] forKey:@"uri"];

    [self.cryptor appendInfoToDictionary:dict];
	return dict;
}

- (NSString *)filename {
    
    if (filename == nil || [filename length] == 0) {
        if ([transferables count] > 0) {
            return [[transferables objectAtIndex:0] filename];
        }
    }
    
    return filename;
}

-(void) dealloc {
	[transferables release];
	[mimeType release];
	
	[super dealloc]; 
}

@end

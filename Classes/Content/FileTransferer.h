//
//  FileTransferer.h
//  Hoccer
//
//  Created by Robert Palmer on 10.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hoccer.h"
#import "TransferController.h"

@interface FileTransferer : NSObject <Transferable, HCFileCacheDelegate> {
	HCFileCache *fileCache;
	
	NSString *url;
	NSString *filename;
	
	NSNumber *progress;
	NSError *error;
	TransferableState state;	
	
}

@property (nonatomic, retain) NSNumber* progress;
@property (nonatomic, retain) NSError* error;
@property (nonatomic, assign) TransferableState state;

@property (nonatomic, retain) NSString *filename;
@property (readonly) NSString *url;

@end

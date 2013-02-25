//
//  FileDownloader.h
//  Hoccer
//
//  Created by Robert Palmer on 09.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hoccer.h"
#import "TransferController.h"
#import "FileTransferer.h"


@interface FileDownloader : FileTransferer {
	NSInteger retryCount;
}

//- (id)initWithURL: (NSString *)aUrl;
- (id)initWithURL: (NSString *)aUrl filename: (NSString *)aFilename;

@end

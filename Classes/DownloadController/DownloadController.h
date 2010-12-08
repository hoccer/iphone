//
//  DownloadController.h
//  Hoccer
//
//  Created by Robert Palmer on 08.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Downloadable <NSObject>
- (void)startTransfer;
- (void)cancelTransfer;
- (NSNumber *)progress;
- (NSError *)error;
@end

@interface DownloadController : NSObject {
	NSMutableArray *downloadQueue;
	NSMutableArray *activeDownloads;
	
//	id <DownloadControllerDelegate> delegate;
}

- (void)addContentToDownloadQueue: (id <Downloadable>) downloadable;

- (void)cancelDownloads;


@end

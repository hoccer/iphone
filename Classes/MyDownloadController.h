//
//  MyDownloadController.h
//  UITest
//
//  Created by david on 18.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadControllerDelegate

- (void) onDownloadDone: (NSMutableData*) theData;
- (void) onError: (NSError*) theError;

@end


@interface MyDownloadController : NSObject {
	NSMutableData * receivedData;
	id delegate;
}

@property (nonatomic, assign) id  delegate;

- (void) fetchURL:(NSURL*)theURL;

@end

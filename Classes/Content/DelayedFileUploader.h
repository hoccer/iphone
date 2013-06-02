//
//  DelayedFileUploaded.h
//  Hoccer
//
//  Created by Robert Palmer on 10.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileUploader.h"


@interface DelayedFileUploader : FileUploader {
	BOOL uploadShouldStart;
    BOOL fileReady;
    BOOL actionReady;
}

- (void)setFileReady: (BOOL)newReady;
- (void)setActionReady: (BOOL)newReady;


@end

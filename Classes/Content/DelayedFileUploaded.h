//
//  DelayedFileUploaded.h
//  Hoccer
//
//  Created by Robert Palmer on 10.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileUploader.h"


@interface DelayedFileUploaded : FileUploader {
	BOOL uploadShouldStart, fileReady;
}

- (void)setFileReady: (BOOL)newReady;


@end

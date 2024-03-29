//
//  DelayedFileUploaded.m
//  Hoccer
//
//  Created by Robert Palmer on 10.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "DelayedFileUploader.h"

@interface DelayedFileUploader ()

- (void)upload;

@end



@implementation DelayedFileUploader

- (id) initWithFilename:(NSString *)aFilename {
	self = [super initWithFilename:aFilename];
	if (self != nil) {
		self.state = TransferableStatePreparing;
	}
	
	return self; 
}

- (void)upload {
	if (uploadShouldStart && fileReady && actionReady) {
		[super startTransfer];
	}
}

- (void) startTransfer {
	uploadShouldStart = YES;
	[self upload];
}

- (void)setFileReady: (BOOL)newReady {
	fileReady = newReady;
	if (fileReady) {
		self.state = TransferableStateReady;
	}
	
	[self upload];
}

- (void)setActionReady: (BOOL)newReady {
	actionReady = newReady;	
	[self upload];
}

@end

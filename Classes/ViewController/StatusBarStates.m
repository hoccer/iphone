//
//  StatusBarStates.m
//  Hoccer
//
//  Created by Robert Palmer on 30.07.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "StatusBarStates.h"

@implementation StatusViewControllerState

@synthesize progressView;
@synthesize activitySpinner;
@synthesize statusLabel;
@synthesize cancelButton;
@synthesize hintButton;
@synthesize recoverySuggestion;

@synthesize cancelButtonImage;

+ (id)state {
	return [[[[self class] alloc] init] autorelease];
}

- (id)init {
	self = [super init];
	if (self != nil) {
		progressView = YES;
		activitySpinner = YES;
		statusLabel = YES;
		cancelButton = YES;
		recoverySuggestion = YES;
		hintButton = YES;
		
		cancelButtonImage = [[UIImage imageNamed:@"statusbar_icon_cancel.png"] retain];		
	}
	
	return self;
}

- (void) dealloc {
	[cancelButtonImage release];
	
	[super dealloc];
}

@end


@implementation ConnectionState 

- (id) init {
	self = [super init];
	if (self != nil) {		
		statusLabel = NO;
		cancelButton = NO;		
		recoverySuggestion = NO;
	}
	return self;
}

@end

@implementation TransferState 

- (id) init {
	self = [super init];
	if (self != nil) {				
		progressView = NO;
	}
	return self;
}

@end


@implementation SuccessState 

- (id) init {
	self = [super init];
	if (self != nil) {				
		activitySpinner = NO;
		statusLabel = NO;
		cancelButton = NO;
		// statusLabel.text = @"Success";
		recoverySuggestion = NO;
		
		cancelButtonImage = [[UIImage imageNamed:@"statusbar_icon_complete.png"] retain];
	}
	return self;
}

@end


@implementation LocationState

- (id)init {
	self = [super init]; 
	if (self != nil) {			
		progressView = YES;
		statusLabel = NO;
		cancelButton = YES;
		hintButton = YES;
		recoverySuggestion = YES;
		
		cancelButtonImage = [[UIImage imageNamed:@"statusbar_icon_cancel.png"] retain];
	}
	return self;
}

@end

@implementation ErrorState

+ (id)stateWithRecovery: (BOOL)recovery {
	return [[[[self class] alloc] initWithRecovery:recovery] autorelease];
}

- (id)initWithRecovery: (BOOL)recovery {
	self = [super init]; 
	if (self != nil) {			
		progressView = YES;
		statusLabel = NO;
		cancelButton = NO;
		cancelButtonImage = [[UIImage imageNamed:@"statusbar_icon_cancel.png"] retain];
		hintButton = YES;
		
		if (recovery) {
			recoverySuggestion = YES;
		} else {
			recoverySuggestion = NO;
		}
	}
	
	return self;
}

@end
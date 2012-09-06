//
//  StatusBarStates.h
//  Hoccer
//
//  Created by Robert Palmer on 30.07.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//



@interface StatusViewControllerState : NSObject {
	BOOL progressView;
	BOOL activitySpinner;
	BOOL statusLabel;
	BOOL cancelButton;
	BOOL hintButton;
	BOOL recoverySuggestion;
	
	UIImage *cancelButtonImage;
}

@property (assign) BOOL progressView;
@property (assign) BOOL activitySpinner;
@property (assign) BOOL statusLabel;
@property (assign) BOOL cancelButton;
@property (assign) BOOL hintButton;
@property (assign) BOOL recoverySuggestion;

@property (retain) UIImage *cancelButtonImage;

+ (id)state;

@end


#pragma mark -
#pragma mark Status View States
@interface ConnectionState : StatusViewControllerState
{}
@end

@interface TransferState : ConnectionState
{}
@end

@interface SendingState : StatusViewControllerState
{}
@end

@interface SuccessState : StatusViewControllerState
{}
@end

@interface LocationState : StatusViewControllerState
{}
@end

@interface ErrorState : StatusViewControllerState
{}

+ (id)stateWithRecovery: (BOOL)recovery;
- (id)initWithRecovery: (BOOL)recovery;

@end
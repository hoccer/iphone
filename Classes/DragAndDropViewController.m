    //
//  PreviewViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "DragAndDropViewController.h"
#import "Preview.h"
#import "NSObject+DelegateHelper.h"

#define kSweepBorder 50

@implementation DragAndDropViewController

@synthesize origin;
@synthesize delegate;
@synthesize shouldSnapBackOnTouchUp;
@synthesize content;
@synthesize requestStamp;

- (id) init {
	self = [super init];
	if (self){
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0, 150, 150)];
		self.view.backgroundColor = [UIColor whiteColor];
		gestureDetected = FALSE;
		self.requestStamp = [NSDate timeIntervalSinceReferenceDate];
	}
	return self;	
}

- (void) dealloc {
	[content release];
	[super dealloc];
}

- (void)setContent:(HoccerContent*)theContent {
	if (theContent != content) {
		[content release];
		content = [theContent retain];

		[self setView:[content desktopItemView]];
	}
}


- (void) setView:(UIView *) aPreview {
	super.view = aPreview;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dismissKeyboard
{
	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextView class]])
			[view resignFirstResponder];
	}
}

- (void)setOrigin: (CGPoint)newOrigin {
	origin = newOrigin;
	[self resetViewAnimated: NO];
}

- (void)userDismissedContent: (id)sender
{
	[self.delegate checkAndPerformSelector: @selector(dragAndDropViewControllerWillBeDismissed:) withObject: self];
}

- (void)resetViewAnimated: (BOOL)animated {}


@end

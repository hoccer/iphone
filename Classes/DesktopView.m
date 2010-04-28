//
//  ReceiveViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "DesktopView.h"
#import "NSObject+DelegateHelper.h"
#import "ContentContainerView.h"

#import "SweepInRecognizer.h"
#import "SweepOutRecognizer.h"
#import "TabRecognizer.h"

@interface DesktopView ()
- (ContentContainerView *)viewContainingView: (UIView *)view;
- (NSArray *)findTouchedViews: (CGPoint) point;
- (void)setUpRecognizer;
@end

@implementation DesktopView

@synthesize dataSource;
@synthesize currentlyTouchedViews;
@synthesize delegate;
@synthesize shouldSnapToCenterOnTouchUp;

- (id) initWithFrame: (CGRect)frame {
	self = [super initWithFrame:frame];
	if (self != nil) {
		[self setUpRecognizer];
	}
	return self;
}

- (id) initWithCoder: (NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self != nil) {
		[self setUpRecognizer];
	}
	return self;
}

- (void)setUpRecognizer {
	sweepRecognizers = [[NSMutableArray alloc] init];
	
	SweepInRecognizer *recognizer = [[[SweepInRecognizer alloc] init] autorelease];
	recognizer.delegate = self;
	[self addSweepRecognizer:recognizer];
	
	SweepOutRecognizer *recognizer2 = [[[SweepOutRecognizer alloc] init] autorelease];
	recognizer2.delegate = self;
	[self addSweepRecognizer:recognizer2];
	
	TabRecognizer *recognizer3 = [[[TabRecognizer alloc] init] autorelease];
	recognizer3.delegate = self;
	[self addSweepRecognizer:recognizer3];
	
	volatileView = [[NSMutableArray alloc] init];
}


- (void)dealloc {
	[sweepRecognizers release];
	[dataSource release];
	[volatileView release];
	
    [super dealloc];
}

- (void)addSweepRecognizer: (SweepRecognizer *)recognizer {
	[sweepRecognizers addObject:recognizer];
}

- (void)animateView: (UIView *)view withAnimation: (CAAnimation *)animation {
	ContentContainerView *containerView = [self viewContainingView:view];

	[[containerView layer] addAnimation:animation forKey:@"centerAnimation"];
}

#pragma mark -
#pragma mark TouchEvents
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint initialTouchPoint = [[touches anyObject] locationInView: self]; 
	
	self.currentlyTouchedViews = [self findTouchedViews:initialTouchPoint];

	for (SweepInRecognizer *recognizer in sweepRecognizers) {
		[recognizer desktopView:self touchesBegan:touches withEvent:event];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {		
	UITouch* touch = [touches anyObject];

	CGPoint prevLocation = [touch previousLocationInView: self];
	CGPoint currentLocation = [touch locationInView: self];
	
	for (ContentContainerView *view in currentlyTouchedViews) {
		[view moveBy:CGSizeMake(currentLocation.x - prevLocation.x, currentLocation.y - prevLocation.y)];
	}
	
	for (SweepInRecognizer *recognizer in sweepRecognizers) {
		[recognizer desktopView:self touchesMoved:touches withEvent:event];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{	
	CGPoint currentLocation = [[touches anyObject] locationInView: self]; 
	for (ContentContainerView *view in currentlyTouchedViews) {
		[self containerView:view didMoveToPosition:currentLocation];
	}
	
	for (SweepInRecognizer *recognizer in sweepRecognizers) {
		[recognizer desktopView:self touchesEnded:touches withEvent:event];
	}
	
	self.currentlyTouchedViews = nil;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	for (SweepInRecognizer *recognizer in sweepRecognizers) {
		[recognizer desktopView:self touchesCancelled:touches withEvent:event];
	}
	
	self.currentlyTouchedViews = nil;
}

#pragma mark -
#pragma mark DataSource Methods

- (void)reloadData {
	for (UIView *subview in volatileView) {
		[subview removeFromSuperview];
	}
	
	[volatileView removeAllObjects];
	
	NSInteger numberOfItems = [dataSource numberOfItems];
	for (NSInteger i = 0; i < numberOfItems; i++) {
		ContentContainerView *containerView = [[ContentContainerView alloc] initWithView:[dataSource viewAtIndex: i]];
		containerView.delegate = self;
		containerView.origin = [dataSource positionForViewAtIndex:i];
		
		[self insertSubview: containerView atIndex:0];
		[volatileView addObject: containerView];
		// [containerView release];
	}
}

- (void)insertView: (UIView *)view atPoint:(CGPoint)point withAnimation: (CAAnimation *)animation {
 	ContentContainerView *containerView = [[ContentContainerView alloc] initWithView: view];
	containerView.delegate = self;
	containerView.origin = point;
	
	[self insertSubview: containerView atIndex:0];
	if (animation != nil) {
		[containerView.layer addAnimation:animation forKey:nil];
	}

	[volatileView addObject: containerView];
}

- (void)removeView: (UIView *)view withAnimation: (CAAnimation *)animation {
	[self doesNotRecognizeSelector: _cmd];
}



#pragma mark -
#pragma mark ContentContainerViewDelegate Methods
- (void)containerView:(ContentContainerView *)view didMoveToPosition:(CGPoint)point {
	[dataSource view: view.containedView didMoveToPoint:view.frame.origin];
}

- (void)containerViewDidClose:(ContentContainerView *)view {
	NSInteger index = [volatileView indexOfObject:view];
	
	if ([delegate respondsToSelector:@selector(desktopView:didRemoveViewAtIndex:)]) {
		[delegate desktopView:self didRemoveViewAtIndex: index];
	}
	[self reloadData];
}

#pragma mark -
#pragma mark SweepInGesturesRecognizer Delegate

- (void)sweepInRecognizerDidBeginSweeping: (SweepInRecognizer *)recognizer {
	sweepIn = [delegate desktopView:self needsEmptyViewAtPoint:recognizer.touchPoint];
	self.currentlyTouchedViews = [self findTouchedViews:recognizer.touchPoint];
}

- (void)sweepInRecognizerDidRecognizeSweepIn: (SweepInRecognizer *)recognizer {
	if (!sweepIn) {
		return;
	}
	
	ContentContainerView *view = [currentlyTouchedViews lastObject];
	
	if (shouldSnapToCenterOnTouchUp) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
		animation.duration = 0.2;
		animation.fromValue = [NSValue valueWithCGPoint: view.center];
		
		view.layer.position = CGPointMake(self.frame.size.width / 2, 140);
		[view.layer addAnimation:animation forKey:nil];
	}
	
	[delegate desktopView: self didSweepInView: view.containedView];
	sweepIn = NO; 
}

- (void)sweepInRecognizerDidCancelSweepIn: (SweepInRecognizer *)recognizer {
	if (!sweepIn) {
		return;
	}
	
	ContentContainerView *view = [currentlyTouchedViews lastObject];

	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	if (recognizer.sweepDirection == kSweepDirectionLeftOut) {
		animation.toValue = [NSValue valueWithCGPoint: CGPointMake(-view.frame.size.width, view.center.y)];
	} else {
		animation.toValue = [NSValue valueWithCGPoint: CGPointMake(self.frame.size.width + view.frame.size.width, view.center.y)];
	}
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	[[view layer] addAnimation:animation forKey:nil];
	
	[dataSource removeView: view.containedView];
	
	sweepIn = NO; 
}

#pragma mark -
#pragma mark SweepOutGestureRecognizer Delegate

- (void)sweepOutRecognizerDidRecognizeSweepOut: (SweepOutRecognizer *)recognizer {
	ContentContainerView *view = [currentlyTouchedViews lastObject];
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.duration = 0.2;
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	
	if (recognizer.sweepDirection == kSweepDirectionLeftOut) {
		animation.toValue = [NSValue valueWithCGPoint: CGPointMake(-view.frame.size.width, view.center.y)];
	} else {
		animation.toValue = [NSValue valueWithCGPoint: CGPointMake(self.frame.size.width + view.frame.size.width, view.center.y)];
	}
	
	[[view layer] addAnimation:animation forKey:@"removeAnimation"];

	if ([delegate respondsToSelector:@selector(desktopView:didSweepOutView:)]) {
		[delegate desktopView:self didSweepOutView: [view containedView]];
	}
}

- (void)sweepOutRecognizerDidCancelSweepOut: (SweepOutRecognizer *)recognizer {
	if (!shouldSnapToCenterOnTouchUp) {
		return;
	}
	
	ContentContainerView *view = [currentlyTouchedViews lastObject];
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.duration = 0.2;

	animation.fromValue = [NSValue valueWithCGPoint: view.center];
	view.origin = CGPointMake(7, 22);
	
	[view.layer addAnimation:animation forKey:nil];
}

#pragma mark -
#pragma mark Tab Recognizer Delegate Methods
- (void)tabRecognizer: (TabRecognizer*) recognizer didDetectTabs: (NSInteger)numberOfTabs {
	if (numberOfTabs == 1) {
		if ([recognizer.tabedView isKindOfClass:[ContentContainerView class]]) {
			[(ContentContainerView *)recognizer.tabedView toggleOverlay:self];
		}
	}
}



#pragma mark -
#pragma mark Private Methods

- (ContentContainerView *)viewContainingView: (UIView *)view {
	for (UIView *subview in self.subviews) {
		if ([subview.subviews count] > 0 && [subview.subviews objectAtIndex:0] == view) {
			return (ContentContainerView *)subview;
		}
	}
	
	return nil;
}

- (NSArray *)findTouchedViews: (CGPoint) point {
	NSMutableArray *touchedViews = [[NSMutableArray alloc] init];
	
	for (UIView *view in volatileView) {
		if ([[view layer] hitTest: point] && [view.layer.animationKeys count] == 0) {
			[touchedViews addObject:view];
			return [touchedViews autorelease];
		}
	}
	
	return [touchedViews autorelease];
}

@end

//
//  ReceiveViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import "DesktopView.h"
#import "NSObject+DelegateHelper.h"
#import "ContentContainerView.h"

#import "SweepInRecognizer.h"
#import "SweepOutRecognizer.h"
#import "TabRecognizer.h"
//#import "PullToReceiveViewController.h"


@interface DesktopView ()
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
        self.backgroundStyle = HCDesktopBackgroundStylePerforated;
	}
	return self;
}

- (id) initWithCoder: (NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self != nil) {
		[self setUpRecognizer];
        self.backgroundStyle = HCDesktopBackgroundStylePerforated;
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
	[[view layer] addAnimation:animation forKey:@"centerAnimation"];
}

#pragma mark -
#pragma mark TouchEvents
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint initialTouchPoint = [[touches anyObject] locationInView:self];
	self.currentlyTouchedViews = [self findTouchedViews:initialTouchPoint];
    [self.delegate desktopView:self wasTouchedWithTouches:touches];

//    if ((initialTouchPoint.x > kSweepInBorder) && (initialTouchPoint.x <  self.frame.size.width - kSweepInBorder)) {
////        NSLog(@"1. DesktopView - touchesBegan - touchPoint  = %0.f - %0.f ", initialTouchPoint.x, initialTouchPoint.y);
//    }
//    else {
////        NSLog(@"2. DesktopView - touchesBegan - touchPoint  = %0.f - %0.f ", initialTouchPoint.x, initialTouchPoint.y);
    
    for (SweepInRecognizer *recognizer in sweepRecognizers) {
        [recognizer desktopView:self touchesBegan:touches withEvent:event];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {		
	UITouch* touch = [touches anyObject];

	CGPoint prevLocation = [touch previousLocationInView: self];
	CGPoint currentLocation = [touch locationInView: self];
	
//    NSLog(@"1.a. DesktopView - touchesMoved from %f - %f", prevLocation.x, prevLocation.y);
//    NSLog(@"1.a. DesktopView - touchesMoved to   %f - %f", currentLocation.x, currentLocation.y);
    
	for (ContentContainerView *view in currentlyTouchedViews) {
		[view moveBy:CGSizeMake(currentLocation.x - prevLocation.x, currentLocation.y - prevLocation.y)];
	}
	
	for (SweepInRecognizer *recognizer in sweepRecognizers) {
		[recognizer desktopView:self touchesMoved:touches withEvent:event];
	}
    [super touchesMoved:touches withEvent:event];
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
    [super touchesEnded:touches withEvent:event];

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	for (SweepInRecognizer *recognizer in sweepRecognizers) {
		[recognizer desktopView:self touchesCancelled:touches withEvent:event];
	}
	
	self.currentlyTouchedViews = nil;
    [super touchesCancelled:touches withEvent:event];

}

#pragma mark -
#pragma mark DataSource Methods
- (void)reloadData
{
	for (UIView *subview in volatileView) {
        [subview removeFromSuperview];
	}
	
	[volatileView removeAllObjects];
	NSInteger numberOfItems = [dataSource numberOfItems];
	for (NSInteger i = 0; i < numberOfItems; i++) {
		UIView *view = [dataSource viewAtIndex:i];
		[view.layer removeAllAnimations];

		if ([view isKindOfClass:[ContentContainerView class]]) {
			ContentContainerView *containerView = (ContentContainerView *)view;
			containerView.delegate = self;
			containerView.origin = [dataSource positionForViewAtIndex:i];
		}
		
		[self insertSubview:view atIndex:3];
		[volatileView addObject: view];
	}
    //[self initPullToReceive];
}

//- (void)initPullToReceive
//{
//    PullToReceiveViewController *pullToReceiveViewController = [[PullToReceiveViewController alloc] init];
//	pullToReceiveViewController.delegate = self;
//	
//    [pullToReceiveViewController viewWillAppear:YES];
//			
//	[self insertSubview:pullToReceiveViewController.view atIndex:0];
//	
//	[pullToReceiveViewController viewDidAppear:YES];
//
//	[pullToReceiveViewController release];
//}

- (void)insertView:(UIView *)view atPoint:(CGPoint)point withAnimation:(CAAnimation *)animation
{
 	ContentContainerView *containerView = (ContentContainerView *)view;
	containerView.delegate = self;
	containerView.origin = point;
	    
	[self insertSubview: containerView atIndex:1];
	if (animation != nil) {
		[containerView.layer addAnimation:animation forKey:nil];
	}

	[volatileView addObject:containerView];
}

- (void)removeView:(UIView *)view withAnimation:(CAAnimation *)animation {
	[self doesNotRecognizeSelector: _cmd];
}

#pragma mark -
#pragma mark ContentContainerViewDelegate Methods
- (void)containerView:(ContentContainerView *)view didMoveToPosition:(CGPoint)point
{
	[dataSource view:view didMoveToPoint:view.frame.origin];
}

#pragma mark -
#pragma mark SweepInGesturesRecognizer Delegate

- (void)sweepInRecognizerDidBeginSweeping: (SweepInRecognizer *)recognizer
{
    //NSLog(@"3. DesktopView - sweepInRecognizerDidBeginSweeping - touchPoint ........ = %f", recognizer.touchPoint.x);
    
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
		animation.delegate = self;
		
		view.layer.position = view.center = CGPointMake(view.superview.frame.size.width /2, view.center.y);
		[view.layer addAnimation:animation forKey:nil];		
		[dataSource view:view didMoveToPoint:CGPointMake(view.superview.frame.size.width /2 - view.frame.size.width / 2, view.center.y - view.frame.size.height / 2)];
	}
	
	[delegate desktopView: self didSweepInView: view];
	sweepIn = NO; 
}

- (void)sweepInRecognizerDidCancelSweepIn: (SweepInRecognizer *)recognizer {
	if (!sweepIn) {
		return;
	}
	
	ContentContainerView *view = [currentlyTouchedViews lastObject];

	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.fromValue = [NSValue valueWithCGPoint:view.center];
	
	if (recognizer.sweepDirection == kSweepDirectionLeftOut) {
		view.center = CGPointMake(-view.frame.size.width, view.center.y);
	} else {
		view.center = CGPointMake(self.frame.size.width + view.frame.size.width, view.center.y);
	}
	
	[view.layer addAnimation:animation forKey:nil];
	
	[dataSource removeView:view];
	
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
		[delegate desktopView:self didSweepOutView: view];
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
	view.center = CGPointMake(view.superview.frame.size.width /2, view.center.y);
	
	[view.layer addAnimation:animation forKey:nil];
}

#pragma mark -
#pragma mark Tab Recognizer Delegate Methods
- (void)tabRecognizer: (TabRecognizer*) recognizer didDetectTabs: (NSInteger)numberOfTabs {
//	if (numberOfTabs == 1) {
//		if ([recognizer.tabedView isKindOfClass:[ContentContainerView class]]) {
//			[(ContentContainerView *)recognizer.tabedView toggleOverlay:self];
//		} else {
//			for (ContentContainerView *view in volatileView) {
//				[view checkAndPerformSelector:@selector(hideOverlay)];
//			}
//		}
//	}
}


#pragma mark - Drawing


- (void)setBackgroundStyle:(HCDesktopBackgroundStyle)backgroundStyle {
    
    _backgroundStyle = backgroundStyle;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    UIImage *patternImage;
    CGSize phase = CGSizeMake(5.5f, 12.5f);
    
    switch (self.backgroundStyle) {
            
        case HCDesktopBackgroundStyleLock:
            patternImage = [UIImage imageNamed:@"lochblech_encrypted-bg.png"];
            break;
        
        case HCDesktopBackgroundStylePerforated:
        default:
            patternImage = [UIImage imageNamed:@"lochblech_bg.png"];
            break;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGColorRef color = [UIColor colorWithPatternImage:patternImage].CGColor;
    CGContextSetFillColorWithColor(context, color);
    CGContextSetPatternPhase(context, phase);
    CGContextFillRect(context, self.bounds);
    
    [super drawRect:rect];
}



#pragma mark -
#pragma mark Private Methods

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

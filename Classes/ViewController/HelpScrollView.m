//
//  HelpScrollView.m
//  Hoccer
//
//  Created by Robert Palmer on 27.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HelpScrollView.h"
#import "NSObject+DelegateHelper.h"

#import "HelpScreen.h"
#import "HelpOverview.h"
#import "HelpContent.h"
#import "FeedbackProvider.h"
#import "AboutViewController.h"

@interface HelpScrollView ()
- (void)setUpPages;
@end

@implementation HelpScrollView

@synthesize delegate;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	pages = [[NSArray arrayWithObjects: 
			  [[[HelpOverview alloc] init] autorelease],
			  [[[HelpScreen alloc] initWithHelpContent: [HelpContent sweepHelp]] autorelease],
			  [[[HelpScreen alloc] initWithHelpContent: [HelpContent throwHelp]] autorelease],
			  [[[HelpScreen alloc] initWithHelpContent: [HelpContent catchHelp]] autorelease],
              //[[[HelpScreen alloc] initWithHelpContent: [HelpContent encryptionHelp]] autorelease],
              [[[HelpScreen alloc] initWithHelpContent: [HelpContent keyHelp]] autorelease],
			  nil] retain];
	
	
	CGSize scrollViewSize = scrollView.frame.size;
	
	scrollView.pagingEnabled = YES;
	scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
	
	scrollView.contentSize = CGSizeMake(scrollViewSize.width  * [pages count], scrollViewSize.height);

	pageControl.numberOfPages = [pages count]; 
	
	[self setUpPages];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"help_bg.png"]];
}

- (void)setUpPages {
	for (int i = 0; i < [pages count]; i++) {
		UIViewController *pageController = [pages objectAtIndex:i]; 
	
		CGRect frame = pageController.view.frame;
		frame.origin.x = scrollView.frame.size.width * i;
		frame.origin.y = 0; 
		
		pageController.view.frame = frame;
		[scrollView  addSubview:pageController.view];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320, 367);
}

- (void)dealloc {
	[scrollView release];
	[pageControl release];
	
	[pages release];
	
    [super dealloc];
}

- (IBAction)hideView: (id)sender
{
	[self.delegate checkAndPerformSelector:@selector(userDidCloseHelpView)];
}

- (void)scrollViewDidScroll: (UIScrollView *)theScrollView {	
	if (pageControlUsed)
		return;
	
	CGFloat pageWidth = theScrollView.frame.size.width;
	int page = floor((theScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	pageControl.currentPage = page;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView   
{
	pageControlUsed = NO;
}


- (IBAction)changePage:(id)sender 
{
    int page = pageControl.currentPage;

    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    
	[scrollView scrollRectToVisible:frame animated:YES];

    pageControlUsed = YES;
}

- (void)gesturesInterpreterDidDetectThrow: (GesturesInterpreter *)aGestureInterpreter
{
	if (pageControl.currentPage == 1) {
		[FeedbackProvider playThrowFeedback];
	}
}

- (void)gesturesInterpreterDidDetectCatch: (GesturesInterpreter *)aGestureInterpreter
{
	if (pageControl.currentPage == 2) {
		[FeedbackProvider playCatchFeedback];
	}
}

@end

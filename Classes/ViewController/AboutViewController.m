//
//  AboutViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 25.10.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import "AboutViewController.h"
#import "NSObject+DelegateHelper.h"

@implementation AboutViewController

@synthesize delegate;
@synthesize textView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
	
    [self.textView setText:NSLocalizedString(@"AboutText", nil)];
    
    CGRect textFrame = self.textView.frame;
    textFrame.size.height = self.view.bounds.size.height - textFrame.origin.y * 2.0f - 20.0f;
    self.textView.frame = textFrame;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_bg"]];
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320, 367);
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


- (IBAction)hideView: (id)sender
{
	[self.delegate checkAndPerformSelector:@selector(userDidCloseAboutView)];
}

@end

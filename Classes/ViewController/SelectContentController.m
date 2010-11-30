//
//  SelectContentController.m
//  Hoccer
//
//  Created by Robert Palmer on 28.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "SelectContentController.h"
#import "NSObject+DelegateHelper.h"
#import "HCButton.h"

@interface Action : NSObject {
	SEL action;
	UIImage *button;
	NSString *label;
}

@property (assign) SEL action;
@property (retain) UIImage *button;
@property (retain) NSString *label;

+ (Action *)actionWithAction: (SEL)selector label: (NSString *)aLabel image : (UIImage *)image;
- (id) initWithAction: (SEL)selector label: (NSString *)aLabel image: (UIImage *)image;

@end

@implementation Action 
@synthesize action;
@synthesize button;
@synthesize label;

+ (Action *)actionWithAction: (SEL)selector label: (NSString *)aLabel image : (UIImage *)image {
	return [[[Action alloc] initWithAction:selector label:aLabel image:image] autorelease];
}

- (id) initWithAction: (SEL)selector label: (NSString *)aLabel image: (UIImage *)image; {
	self = [super init];
	if (self != nil) {
		self.action = selector;
		self.button = image;
		self.label = aLabel;
	}
	
	return self;
}

@end

@interface SelectContentController ()

- (void)initButtons;

@end


@implementation SelectContentController
@synthesize delegate;
@synthesize buttonsContainer;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor clearColor];
	buttons = [[NSMutableArray alloc] init];
	[self initButtons];
	
    [super viewDidLoad];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[buttons release];
	[buttonsContainer release];
    [super dealloc];
}

- (IBAction)camera: (id)sender; {
	[delegate checkAndPerformSelector:@selector(selectCamera:) withObject: self];

}

- (IBAction)image: (id)sender; {
	[delegate checkAndPerformSelector:@selector(selectImage:) withObject: self];
}

- (IBAction)video: (id)sender; {
	[delegate checkAndPerformSelector:@selector(selectVideo:) withObject: self];
}

- (IBAction)text: (id)sender; {
	[delegate checkAndPerformSelector:@selector(selectText:) withObject: self];
}

- (IBAction)contact: (id)sender; {
	[delegate checkAndPerformSelector:@selector(selectContacts:) withObject: self];
}

- (IBAction)mycontact: (id)sender; {
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[delegate checkAndPerformSelector:@selector(toggleSelectContent:) withObject:self];
}


- (void)initButtons {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[buttons addObject: [Action actionWithAction:@selector(camera:) label: @"Camera" image:[UIImage imageNamed: @"select_btn_cam.png"]]];
	}
	
	[buttons addObject: [Action actionWithAction:@selector(image:) label: NSLocalizedString(@"Photo", nil) image:[UIImage imageNamed: @"select_btn_photo.png"]]];
	[buttons addObject: [Action actionWithAction:@selector(text:) label: NSLocalizedString(@"Text", nil) image:[UIImage imageNamed: @"select_btn_text.png"]]];
	[buttons addObject: [Action actionWithAction:@selector(contact:) label: NSLocalizedString(@"Contact", nil) image:[UIImage imageNamed: @"select_btn_contact.png"]]];
 
	for (int i = 0; i < [buttons count]; i++) {
		Action *action = [buttons objectAtIndex: i];
		HCButton *button = [self.buttonsContainer.subviews objectAtIndex:i];
		
		UIImageView *imageView = [[[UIImageView alloc] initWithImage: action.button] autorelease];
		CGRect frame = imageView.frame;
		frame.origin = CGPointMake(frame.origin.x, button.frame.size.height / 2 - frame.size.height / 2 + 13);
		imageView.frame = frame;
		
		[button addSubview: imageView];
		[button setTitle:action.label forState:UIControlStateNormal];
		[button addTarget:self action:action.action forControlEvents:UIControlEventTouchUpInside];
	}
	
	
	if ([buttons count] < 4) {
		CGRect frame = self.buttonsContainer.frame;
		frame.origin.y += 75;
		self.buttonsContainer.frame = frame;
	}
}

@end

//
//  SelectContentController.m
//  Hoccer
//
//  Created by Robert Palmer on 28.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "SelectContentController.h"
#import "NSObject+DelegateHelper.h"

@interface Action : NSObject
{
	SEL action;
	UIImage *button;
}

@property (assign) SEL action;
@property (retain) UIImage *button;

+ (Action *)actionWithAction: (SEL)selector buttonImage : (UIImage *)image;
- (id) initWithAction: (SEL)selector buttonImage: (UIImage *)image;

@end

@implementation Action 
@synthesize action;
@synthesize button;

+ (Action *)actionWithAction: (SEL)selector buttonImage : (UIImage *)image {
	return [[[Action alloc] initWithAction:selector buttonImage:image] autorelease];
}

- (id) initWithAction: (SEL)selector buttonImage: (UIImage *)image; {
	self = [super init];
	if (self != nil) {
		self.action = selector;
		self.button = image;
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
		[buttons addObject: [Action actionWithAction:@selector(camera:) buttonImage:[UIImage imageNamed: @"select_btn_cam.png"]]];
	}
	
	[buttons addObject: [Action actionWithAction:@selector(image:) buttonImage:[UIImage imageNamed: @"select_btn_photo.png"]]];
	[buttons addObject: [Action actionWithAction:@selector(text:) buttonImage:[UIImage imageNamed: @"select_btn_text.png"]]];
	[buttons addObject: [Action actionWithAction:@selector(contact:) buttonImage:[UIImage imageNamed: @"select_btn_contact.png"]]];
 
	for (int i = 0; i < [buttons count]; i++) {
		Action *action = [buttons objectAtIndex: i];
		UIButton *button = [self.buttonsContainer.subviews objectAtIndex:i];
		
		[button setImage:action.button forState:UIControlStateNormal];
		[button setImage:action.button forState:UIControlStateHighlighted];
		[button addTarget:self action:action.action forControlEvents:UIControlEventTouchUpInside];
	}
	
	
	if ([buttons count] < 4) {
		CGRect frame = self.buttonsContainer.frame;
		frame.origin.y += 75;
		self.buttonsContainer.frame = frame;
	}
}

@end

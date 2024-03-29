//
//  SelectContentController.m
//  Hoccer
//
//  Created by Robert Palmer on 28.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
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

- (IBAction)media: (id)sender; {
    [delegate checkAndPerformSelector:@selector(selectMedia:) withObject:self];
}

- (IBAction)mycontact: (id)sender; {
    [delegate checkAndPerformSelector:@selector(selectMyContact:) withObject:self];
}

- (IBAction)audio: (id)sender; {
    [delegate checkAndPerformSelector:@selector(selectMusic:) withObject:self];
}

- (IBAction)video: (id)sender; {
	[delegate checkAndPerformSelector:@selector(selectVideo:) withObject: self];
}

- (IBAction)text: (id)sender; {
	[delegate checkAndPerformSelector:@selector(selectText:) withObject: self];
}

- (IBAction)contact: (id)sender; {
	[delegate checkAndPerformSelector:@selector(selectContact:) withObject: self];
}

- (IBAction)hoclet: (id)sender {
    [delegate checkAndPerformSelector:@selector(selectHoclet:) withObject: self];
}

- (IBAction)pasteboard: (id)sender {
    [delegate checkAndPerformSelector:@selector(selectPasteboard:) withObject: self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[delegate checkAndPerformSelector:@selector(toggleSelectContent:) withObject:self];
// 	[[self nextResponder] touchesBegan:touches withEvent:event];
}


- (void)initButtons {

    [buttons addObject: [Action actionWithAction:@selector(media:) label: NSLocalizedString(@"Button_Camera", nil) image:[UIImage imageNamed: @"select_btn_camera.png"]]];
    
	[buttons addObject: [Action actionWithAction:@selector(text:) label: NSLocalizedString(@"Button_Text", nil) image:[UIImage imageNamed: @"select_btn_text.png"]]];

    [buttons addObject: [Action actionWithAction:@selector(contact:) label: NSLocalizedString(@"Button_Contact", nil) image:[UIImage imageNamed: @"select_btn_contact.png"]]];
    
    //[buttons addObject: [Action actionWithAction:@selector(hoclet:) label: NSLocalizedString(@"Hoclet", nil) image:[UIImage imageNamed: @"select_btn_hocclet.png"]]];
    [buttons addObject: [Action actionWithAction:@selector(audio:) label: NSLocalizedString(@"Button_Audio", nil) image:[UIImage imageNamed: @"select_btn_audio.png"]]];
    
    [buttons addObject: [Action actionWithAction:@selector(pasteboard:) label: NSLocalizedString(@"Button_Paste", nil) image:[UIImage imageNamed: @"select_btn_paste.png"]]];
    
    [buttons addObject: [Action actionWithAction:@selector(mycontact:) label: NSLocalizedString(@"Button_MyContact", nil) image:[UIImage imageNamed: @"select_btn_mycontact.png"]]];

	for (int i = 0; i < [buttons count]; i++) {
		Action *action = [buttons objectAtIndex: i];
		HCButton *button = [self.buttonsContainer.subviews objectAtIndex:i];
		
		UIImageView *imageView = [[[UIImageView alloc] initWithImage: action.button] autorelease];
		CGRect frame = imageView.frame;
		frame.origin = CGPointMake(frame.origin.x, button.frame.size.height / 2 - frame.size.height / 2);
		imageView.frame = frame;
		
        button.fontSize = 8.5f;
        button.verticalTextOffset = 24.0f;
        
		[button addSubview: imageView];
		[button setTitle:action.label forState:UIControlStateNormal];
		[button addTarget:self action:action.action forControlEvents:UIControlEventTouchUpInside];
        button.enabled = YES;
	}
	
	if ([buttons count] < 4) {
		CGRect frame = self.buttonsContainer.frame;
		frame.origin.y += 75;
		self.buttonsContainer.frame = frame;
	}
}

@end

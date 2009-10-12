//
//  HoccerViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "ABPersonVCardCreator.h"
#import "NSObject+DelegateHelper.h"
#import  "NSString+StringWithData.h"

#import "HoccerViewController.h"
#import "HoccerDownloadRequest.h"
#import "HoccerUploadRequest.h"
#import "BaseHoccerRequest.h"
#import "HoccerContentFactory.h"
#import "GesturesInterpreter.h"

@implementation HoccerViewController

@synthesize delegate; 

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidLoad {
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[saveButton release];
	[toolbar release];
    [statusLabel release];
	[locationLabel release];
	
	[previewBox release];
	
	[super dealloc];
}

- (IBAction)onCatch: (id)sender
{
	[self.delegate didPickText];

	//[self.delegate checkAndPerformSelector: @selector(gesturesInterpreterDidDetectThrow:) withObject: nil]; 
}

- (IBAction)parse: (id)sender
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	
	CFArrayRef addresses = ABAddressBookCopyPeopleWithName(addressBook, CFSTR("Appleseed"));
	if (CFArrayGetCount(addresses) < 1) {
		return;
	}
	
	NSData *vcard = [ABPersonVCardCreator vcardWithABPerson: CFArrayGetValueAtIndex(addresses, 0)];
	NSLog(@"vcard: %@", [NSString stringWithData:vcard usingEncoding: NSUTF8StringEncoding]);
}


- (IBAction)onCancel: (id)sender 
{
	NSLog(@"canceling: %@", self.delegate);
	[self.delegate checkAndPerformSelector:@selector(userDidCancelRequest)];
}


- (void)setLocation: (MKPlacemark *)placemark withAccuracy: (float) accuracy
{
	if (placemark.thoroughfare != nil)
		locationLabel.text = [NSString stringWithFormat:@"%@ (~ %4.2fm)", placemark.thoroughfare, accuracy];
}	
	
- (void)setUpdate: (NSString *)update
{
	statusLabel.text = update;
}	

- (void)setContentPreview: (id <HoccerContent>)content
{
	NSLog(@"in %s with content %@", _cmd, content);
	
	if ([previewBox.subviews count] > 0) {
		[[previewBox.subviews objectAtIndex:0] removeFromSuperview];
	}

	UIView *contentView = content.preview;
	contentView.frame   = CGRectMake(0, 0, previewBox.frame.size.width, previewBox.frame.size.height);
	contentView.bounds  = CGRectMake(0, 0, previewBox.frame.size.width, previewBox.frame.size.height);

	contentView.contentMode = UIViewContentModeScaleAspectFill; 
	
	[previewBox addSubview: contentView];
}


@end

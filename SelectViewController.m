//
//  SelectViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 13.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "SelectViewController.h"
#import "HoccerViewController.h"



@implementation SelectViewController

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
	NSLog(@"view did load");
    [super viewDidLoad];
	
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	// UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	// picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	picker.delegate = self;
	
	//[self.view addSubview: picker.view];
	//[self.view setNeedsDisplay];
	
	// [picker release];
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

- (void)dealloc 
{
	[imagePicker release];
    [super dealloc];
}

#pragma mark -

- (void)viewWillAppear: (BOOL)animated
{
	NSLog(@"view will appear");
	
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

	
	// ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	// picker.peoplePickerDelegate = self;
	picker.delegate = self;
	
	[self.view addSubview: picker.view];
	[self.view setNeedsDisplay];
	
}




#pragma mark -
#pragma mark UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSLog(@"Picked a image");
}



#pragma mark -
#pragma mark ABPeoplePickerNavigationController delegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person {

	HoccerViewController *shareView = [[HoccerViewController alloc] init];
	[self.view addSubview: shareView.view];
	
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	shouldContinueAfterSelectingPerson:(ABRecordRef)person 
							  property:(ABPropertyID)property 
							identifier:(ABMultiValueIdentifier)identifier
{
	return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker 
{
}




@end

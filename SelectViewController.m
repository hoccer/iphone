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

@synthesize delegate;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

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
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self.delegate;
	
	[self presentModalViewController:picker animated:YES];
	
	[self.view addSubview: picker.view];
	[self.view removeFromSuperview];
	
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


#pragma mark -
#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
    }

    cell.textLabel.text =@"test";
    return cell;
}


#pragma mark -
#pragma mark UITableViewCell Delegate Methods



@end

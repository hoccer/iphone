//
//  HocletSelectViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "HocletSelectViewController.h"
#import "HoccerHoclet.h"

@implementation HocletSelectViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        hoclets = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hoclets" ofType:@"plist"]];
        NSLog(@"hoclets %@", hoclets);        
    }
    
    return self;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [hoclets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *value = [hoclets objectAtIndex:indexPath.row];
    cell.textLabel.text       = [value objectForKey:@"label"];
    cell.detailTextLabel.text = [value objectForKey:@"url"];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selected = [hoclets objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:[selected objectForKey:@"url"]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HoccerContent *content = [[HoccerHoclet alloc] initWithURL:url];
    content.isFromContentSource = YES;
    
    if ([self.delegate respondsToSelector:@selector(contentSelectController:didSelectContent:)]) {
        [self.delegate contentSelectController:self didSelectContent:content];
    }
    
    [content release];
}

- (UIViewController *)viewController {
    self.navigationItem.title = NSLocalizedString(@"Hoclet", nil);
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                          target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = item;
    [item release];
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:self];
    return [controller autorelease];
}

- (void)cancel: (id)sender {
    if ([self.delegate respondsToSelector:@selector(contentSelectControllerDidCancel:)]) {
        [self.delegate contentSelectControllerDidCancel:self];
    }
}

@end

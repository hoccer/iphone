//
//  SettingViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 03.05.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "SettingViewController.h"
#import "AboutViewController.h"
#import "HelpScrollView.h"
#import "StoreKitManager.h"

@interface SettingsAction : NSObject {
	NSString *description;
	SEL selector;
}

@property (copy) NSString *description;
@property (assign) SEL selector;

+ (SettingsAction *)actionWithDescription: (NSString *)description selector: (SEL)selector;

@end


@implementation SettingsAction
@synthesize description;
@synthesize selector;

+ (SettingsAction *)actionWithDescription: (NSString *)theDescription selector: (SEL)theSelector; {
	SettingsAction *action = [[SettingsAction alloc] init];
	action.description = theDescription;
	action.selector = theSelector;
	
	return [action autorelease];
}

@end


@interface SettingViewController ()

- (void)showTutorial;
- (void)showAbout;
- (void)showHoccerWebsite;
- (void)showTwitter;
- (void)removePropaganda;
- (void) requestProductData;

- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) rememberPurchase;
@end


@implementation SettingViewController
@synthesize parentNavigationController;
@synthesize tableView;
@synthesize hoccerSettingsLogo;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_bg.png"]];
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorColor = [UIColor clearColor];
	
	sections = [[NSMutableArray alloc] init];
	
	SettingsAction *tutorialAction = [SettingsAction actionWithDescription:@"Tutorial" selector:@selector(showTutorial)];
	
	NSArray *section1 = [NSArray arrayWithObjects:tutorialAction, nil];
	[sections addObject:section1];


	SettingsAction *aboutAction = [SettingsAction actionWithDescription:@"About Hoccer" selector:@selector(showAbout)];
	NSArray *section2 = [NSArray arrayWithObjects:aboutAction, nil]; 
	[sections addObject:section2];
	
	if([StoreKitManager isPropagandaEnabled]){
		SettingsAction *buyAction = [SettingsAction actionWithDescription:@"Remove Ads" selector:@selector(removePropaganda)];
		[sections addObject:[NSArray arrayWithObject:buyAction]];
	}
	
	SettingsAction *websiteAction = [SettingsAction actionWithDescription:@"Visit the Hoccer Website" selector:@selector(showHoccerWebsite)];
	SettingsAction *twitterAction = [SettingsAction actionWithDescription:@"Follow Hoccer on Twitter" selector:@selector(showTwitter)];

	NSArray *section3 = [NSArray arrayWithObjects:websiteAction, twitterAction, nil];
	[sections addObject:section3];

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sections count] + 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	}
	
    return [[sections objectAtIndex:section - 1 ] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
	
	if (indexPath.section == 0) {
		[[NSBundle mainBundle] loadNibNamed:@"HoccerSettingsLogo" owner:self options:nil];
		self.hoccerSettingsLogo.selectionStyle =  UITableViewCellSelectionStyleNone;

		return self.hoccerSettingsLogo;
	}
	
	NSInteger section = indexPath.section - 1;
	
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	SettingsAction *action = [[sections objectAtIndex:section] objectAtIndex:[indexPath indexAtPosition:1]];
	cell.textLabel.text = action.description;
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	
	if (section == 0 || section == 1) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 107;
	}
	
	return aTableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return;
	}
	
	NSInteger section = indexPath.section - 1;
	
	SettingsAction *action = [[sections objectAtIndex:section] objectAtIndex:[indexPath indexAtPosition:1]];
	[self performSelector:action.selector];
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark User Actions

- (void)showTutorial {
	HelpScrollView *helpView = [[HelpScrollView alloc] initWithNibName:@"HelpScrollView" bundle:nil];
	helpView.navigationItem.title = @"Tutorial";
	[parentNavigationController pushViewController:helpView animated:YES];
	[helpView release];
}

- (void)showAbout {
	AboutViewController *aboutView = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
	aboutView.navigationItem.title = @"About Hoccer";
	[parentNavigationController pushViewController:aboutView animated:YES];
	[aboutView release];
}

- (void)showHoccerWebsite {
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://www.hoccer.com"]];
}

- (void)showTwitter {
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://www.twitter.com/hoccer"]];
}

- (void)removePropaganda {
	if ([SKPaymentQueue canMakePayments]) {
		[self requestProductData];
	} else {
		NSLog(@"can't make payments");
	}	
}

- (void)requestProductData {
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObject: @"adfree"]];
	request.delegate = self;
	[request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"%s", _cmd);
	NSArray *myProduct = response.products;
	
	if ([myProduct count] > 0) {
		SKProduct *product = [myProduct objectAtIndex:0];

		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
		[[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:product]];
	} 
	
    [request autorelease];
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:			
				[self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
				[self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    [self rememberPurchase];
	// Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
	NSLog(@"restored");
    [self rememberPurchase];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	NSLog(@"failed");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Optionally, display an error here.
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void) rememberPurchase {
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AdFree"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSLog(@"adfree after buying: %d", [[NSUserDefaults standardUserDefaults] boolForKey:@"AdFree"]);	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
	[sections release];
	[hoccerSettingsLogo release];
    [super dealloc];
}


@end


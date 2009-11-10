//
//  HoccerVcard.m
//  Hoccer
//
//  Created by Robert Palmer on 19.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerVcard.h"
#import "ABPersonVCardCreator.h"
#import "NSString+StringWithData.h"

#import "PreviewView.h"
#import "ABPersonCreator.h"


@implementation HoccerVcard

- (id) initWithData: (NSData *)data 
{
	self = [super init];
	if (self != nil) {
		NSString *vcardString = [NSString stringWithData:data usingEncoding:NSUTF8StringEncoding]; 
		ABPersonCreator *creator = [[ABPersonCreator alloc] initWithVcardString: vcardString];
		
		person = creator.person;
		CFRetain(person);
		
		[creator release];
	}
	
	return self;
}

- (id)initWitPerson: (ABRecordRef)aPerson
{
	self = [super init];
	if (self != nil) {
		person = aPerson;
		acPerson = [[ABPersonVCardCreator alloc] initWithPerson:person];
		
		CFRetain(person);
	}
	
	return self;
}

- (void)save 
{
	CFErrorRef error = NULL;
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABAddressBookAddRecord(addressBook, person, &error);
	
	ABAddressBookSave(addressBook, &error);
	CFRelease(addressBook);
}

- (void)dismiss 
{
}

- (UIView *)view 
{
	unknownPersonController = [[ABUnknownPersonViewController alloc] init];
	unknownPersonController.displayedPerson = person;
	
	return unknownPersonController.view;
}

- (PreviewView *)previewWithFrame: (CGRect)frame
{
	PreviewView *view = [[PreviewView alloc] initWithFrame: CGRectMake(0, 0, 319, 234)];
	
	NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"Contactbox" ofType:@"png"];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:backgroundImagePath]];
	
	[view addSubview:backgroundImage];
	[view sendSubviewToBack:backgroundImage];
	[backgroundImage release];
	
	UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(125, 60, 165, 20)];
	label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
	label.textColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
	
	[view addSubview: label];
	
	label.text = [acPerson previewName]; 
	[label release];
	
	return [view autorelease];
}


- (NSString *)filename
{
	return @"vcard.vcf";
}

- (NSString *)mimeType 
{
	return @"text/x-vcard";
}

- (NSData *)data
{
	return [ABPersonVCardCreator vcardWithABPerson: person];
}

- (BOOL)isDataReady
{
	return YES;
}

- (NSString *)saveButtonDescription
{
	return @"Save Contact";
}

- (void) dealloc
{
	CFRelease(person);
	[acPerson release];
	[unknownPersonController release];
	
	[super dealloc];
}

- (void)contentWillBeDismissed 
{}

- (BOOL)needsWaiting 
{
	return NO;
}

- (void)whenReadyCallTarget: (id)aTarget selector: (SEL)aSelector 
{}

@end

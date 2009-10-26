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
	NSLog(@"error: %@", error);
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

- (PreviewView *)preview
{
	PreviewView *previewView = [[PreviewView alloc] initWithFrame:CGRectMake(0, 0, 175, 175)];
	UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(10, 10, 165, 20)];
	
	[previewView addSubview: label];
	
	label.text = [acPerson previewName]; 
	[label release];
	
	return [previewView autorelease];
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

//
//  HoccerVcard.m
//  Hoccer
//
//  Created by Robert Palmer on 19.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerVcard.h"
#import "ABPersonVCardCreator.h"


@implementation HoccerVcard

- (id) initWithData: (NSData *)data 
{
	self = [super init];
	if (self != nil) {
	//	person = 
	}
	
	return self;
}

- (id)initWitPerson: (ABRecordRef) aPerson
{
	self = [super init];
	if (self != nil) {
		person = aPerson;
		CFRetain(person);
	}
	
	return self;
}

- (void)save 
{
}

- (void)dismiss 
{
}

- (UIView *)view 
{
	return nil;
}

- (UIView *)preview
{
	UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(10, 50, 300, 20)];
	
	label.text = @"bla"; //content;
	
	return [label autorelease];
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
	[super dealloc];
	CFRelease(person);
}



@end

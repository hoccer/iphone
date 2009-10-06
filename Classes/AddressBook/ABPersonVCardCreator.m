//
//  ABPersonVCardCreator.m
//  Hoccer
//
//  Created by Robert Palmer on 06.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "ABPersonVCardCreator.h"

@interface ABPersonVCardCreator (Private) 
- (void)generateVcard; 

- (NSString *)nameString;
@end



@implementation ABPersonVCardCreator

+ (NSData* )vcardWithABPerson: (ABRecordRef)record
{
	ABPersonVCardCreator *creator = [[[ABPersonVCardCreator alloc] 
									 initWithPerson:record] autorelease];
	
	
	
	
	
	return [creator vcard];
}

- (id)initWithPerson: (ABRecordRef)record
{
	self = [super init];
	if (self != nil) {
		writer = [[VcardWriter alloc] init];
		
		person = record;
		CFRetain(person);
		
		[self generateVcard];
	}
	return self;
}


- (NSData *)vcard
{
	return [[writer vcardRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
}

- (void) dealloc
{
	[writer release];
	CFRelease(person);
	
	[super dealloc];
}


- (void)generateVcard 
{
	[writer writeHeader];
	[writer writeFormattedName: [self nameString]];
	
	[writer writeFooter];
}

- (NSString *)nameString
{
	CFStringRef firstName = (CFStringRef) ABRecordCopyValue(person, kABPersonFirstNameProperty);
	CFStringRef lastName = (CFStringRef) ABRecordCopyValue(person, kABPersonLastNameProperty);
	
	NSString *combinedName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
	
	CFRelease(firstName);
	CFRelease(lastName);
	
	return combinedName;
}

@end

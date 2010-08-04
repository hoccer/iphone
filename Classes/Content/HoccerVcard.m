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

#import "Preview.h"
#import "ABPersonCreator.h"


@interface HoccerVcard ()

@property (nonatomic, readonly) NSString *name;

@end

@implementation HoccerVcard

@synthesize view;

- (id)initWitPerson: (ABRecordRef)aPerson {
	self = [super init];
	if (self != nil) {		
		person = aPerson;
		CFRetain(person);
		
		abPersonVCardCreator = [[ABPersonVCardCreator alloc] initWithPerson:person];		
		self.data = [abPersonVCardCreator vcard];

		[self saveDataToDocumentDirectory];
		isFromContentSource = YES;
	}
	
	return self;
}

- (ABRecordRef) person{
	if (person == NULL) {
		NSString *vcardString = [NSString stringWithData:self.data usingEncoding:NSUTF8StringEncoding]; 
		ABPersonCreator *creator = [[ABPersonCreator alloc] initWithVcardString: vcardString];
		
		person = creator.person;
		CFRetain(person);
		
		[creator release];	
	}
	
	return person;
}

- (BOOL)saveDataToContentStorage {
	CFErrorRef error = NULL;
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABAddressBookAddRecord(addressBook, self.person, &error);
	
	ABAddressBookSave(addressBook, &error);
	CFRelease(addressBook);
	
	return YES;
}

- (UIView *)fullscreenView 
{
	unknownPersonController = [[ABUnknownPersonViewController alloc] init];
	unknownPersonController.displayedPerson =self.person;
	
	return unknownPersonController.view;
}

- (Preview *)desktopItemView {
	[[NSBundle mainBundle] loadNibNamed:@"ContactsView" owner:self options:nil];
	self.view.name.text = self.name;
	
	return self.view;
}

- (NSString *)mimeType {
	return @"text/x-vcard";
}

- (NSString *)descriptionOfSaveButton {
	return @"Contact";
}

- (NSString *)extension {
	return @"vcf";
}

- (NSString *)defaultFilename {
	return @"Contact";
}

- (void) dealloc {
	if (person != NULL) CFRelease(person);
	[abPersonVCardCreator release];
	[unknownPersonController release];
	
	[super dealloc];
}

- (NSString *)name {
	ABPersonVCardCreator *personCreator = [[[ABPersonVCardCreator alloc] initWithPerson: self.person] autorelease];
	
	return [personCreator previewName];
}

- (UIImage *)historyThumbButton {
	return [UIImage imageNamed:@"history_icon_contact.png"];
}


@end

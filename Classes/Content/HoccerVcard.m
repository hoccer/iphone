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

- (id)initWitPerson: (ABRecordRef)aPerson {
	self = [super init];
	if (self != nil) {		
		person = aPerson;
		CFRetain(person);
		
		abPersonVCardCreator = [[ABPersonVCardCreator alloc] initWithPerson:person];		
		self.data = [abPersonVCardCreator vcard];
		[self saveDataToDocumentDirectory];
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

- (void)saveDataToContentStorage {
	CFErrorRef error = NULL;
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABAddressBookAddRecord(addressBook, self.person, &error);
	
	ABAddressBookSave(addressBook, &error);
	CFRelease(addressBook);
}

- (UIView *)fullscreenView 
{
	unknownPersonController = [[ABUnknownPersonViewController alloc] init];
	unknownPersonController.displayedPerson = person;
	
	return unknownPersonController.view;
}

- (Preview *)desktopItemView {
	Preview *view = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 319, 234)];
	
	NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"Contactbox" ofType:@"png"];
	
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:backgroundImagePath]];
	
	[view addSubview:backgroundImage];
	[view sendSubviewToBack:backgroundImage];
	[backgroundImage release];
	
	UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(106, 56, 165, 20)];
	label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
	label.textColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
	
	[view addSubview: label];
	
	label.text = self.name; 
	[label release];
	
	return [view autorelease];
}

- (NSString *)mimeType {
	return @"text/x-vcard";
}

- (NSString *)descriptionOfSaveButton {
	return @"Save Contact";
}

- (NSString *)extension {
	return @"vcf";
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



@end

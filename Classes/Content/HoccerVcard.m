//
//  HoccerVcard.m
//  Hoccer
//
//  Created by Robert Palmer on 19.10.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
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

@synthesize view,person;

- (id)initWitPerson: (ABRecordRef)aPerson {
	self = [super init];
	if (self != nil) {		
		person = aPerson;
		CFRetain(person);
		
		abPersonVCardCreator = [[ABPersonVCardCreator alloc] initWithPerson:person];		
		self.data = [abPersonVCardCreator vcard];
		vcardString = [[NSString stringWithData:self.data usingEncoding:NSUTF8StringEncoding] retain];

		[self saveDataToDocumentDirectory];
		isFromContentSource = YES;
        canBeCiphered = YES;
	}
	
	return self;
}

- (id) initWithData:(NSData *)theData {
	self = [super initWithData:theData];
	if (self != nil) {
		vcardString = [[NSString stringWithData:self.data usingEncoding:NSUTF8StringEncoding] retain];
        canBeCiphered = YES;
	}
	return self;
}

- (id) initWithFilename: (NSString *)theFilename {
	self = [super initWithFilename:theFilename];
	if (self != nil) {
		vcardString = [[NSString stringWithData:self.data usingEncoding:NSUTF8StringEncoding] retain];
        canBeCiphered = YES;
	}
	return self;
}

- (ABRecordRef)person {
	if (person == NULL) {
		ABPersonCreator *creator = [[ABPersonCreator alloc] initWithVcardString:vcardString];
		
		person = creator.person;
		CFRetain(person);
		if([[NSUserDefaults standardUserDefaults] boolForKey:@"autoSave"]) {
            [self saveDataToContentStorage];
        }
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
	[self sendSaveSuccessEvent];
	
	return YES;
}

- (UIView *)fullscreenView {
	unknownPersonController = [[ABUnknownPersonViewController alloc] init] ;
    
	unknownPersonController.displayedPerson = self.person;

	return unknownPersonController.view;
}

- (Preview *)desktopItemView {
    
	[[NSBundle mainBundle] loadNibNamed:@"ContactsView" owner:self options:nil];
	self.view.name.text = self.name;
    
    CFTypeRef organizationName = ABRecordCopyValue(person, kABPersonOrganizationProperty);
    self.view.company.text = (NSString *)organizationName;
    if (organizationName != NULL) CFRelease(organizationName);
    
    CFTypeRef imageData = ABPersonCopyImageData(person);
    if (imageData != NULL) {
        self.view.image.image = [UIImage imageWithData:(NSData *)imageData];
        CFRelease(imageData);
    }
    
    NSMutableArray *telephone = [[NSMutableArray alloc] initWithCapacity:2];
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (phones != nil) {
        
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            
            CFStringRef locLabelRef = ABMultiValueCopyLabelAtIndex(phones, i);
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, i);
            CFTypeRef phoneLabelRef = ABAddressBookCopyLocalizedLabel(locLabelRef);
            
            NSString *phoneNumber = (NSString *)phoneNumberRef;    
            NSString *phoneLabel = (NSString *)phoneLabelRef;
            
            if ([phoneLabel isEqualToString:@""]){
                phoneLabel = @"phone";
            }
            
            NSString *toPhoneArray = [NSString stringWithFormat:@"%@:  %@", phoneLabel, phoneNumber];
            [telephone addObject:toPhoneArray];
            
            if (phoneLabelRef != NULL) CFRelease(phoneLabelRef);
            if (locLabelRef != NULL) CFRelease(locLabelRef);
            if (phoneNumberRef != NULL) CFRelease(phoneNumberRef);
        }

        if (phones != NULL) CFRelease(phones);
    }
    
    NSMutableArray *emails = [[NSMutableArray alloc] initWithCapacity:2];
    ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (email != nil) {
        
        for(CFIndex i = 0; i < ABMultiValueGetCount(email); i++) {
            
            CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(email, i);
            CFStringRef emailRef = ABMultiValueCopyValueAtIndex(email, i);
            CFTypeRef emailLabelRef = ABAddressBookCopyLocalizedLabel(locLabel);
            
            NSString *emailAdress = (NSString *)emailRef;
            NSString *emailLabel = (NSString *)emailLabelRef;
            
            if ([emailLabel isEqualToString:@""]) {
                emailLabel = @"email";
            }
            
            NSString *toEmailArray = [NSString stringWithFormat:@"%@:  %@", emailLabel, emailAdress];
            [emails addObject:toEmailArray];
            
            if (emailLabelRef != NULL) {
                CFRelease(emailLabelRef);
            }
            if (locLabel != NULL){
                CFRelease(locLabel);
            }
            if (emailRef !=NULL){
                CFRelease(emailRef);
            }
        }
        
        if (email != NULL) CFRelease(email);
    }
    
    NSString *otherInfo = @"";
    for (NSString *number in telephone){
        otherInfo = [otherInfo stringByAppendingFormat:@"%@\n",number];
    }
    
    for (NSString *address in emails){
        otherInfo = [otherInfo stringByAppendingFormat:@"%@\n",address];
    }
	
    self.view.otherInfo.text = otherInfo;
    
    [telephone release];
    [emails release];
    
    CGSize theLabelSize = [self calcLabelSize:otherInfo withFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(252, 106)];
    
    self.view.otherInfo.frame = CGRectMake(26, 98, theLabelSize.width, theLabelSize.height);
    
	return self.view;
}

-(CGSize) calcLabelSize:(NSString *)string withFont:(UIFont *)font  maxSize:(CGSize)maxSize{
    return [string
            sizeWithFont:font
            constrainedToSize:maxSize
            lineBreakMode:UILineBreakModeWordWrap];
    
}

- (NSString *)mimeType {
	return @"text/x-vcard";
}

- (NSString *)descriptionOfSaveButton {
	return NSLocalizedString(@"Button_Save", nil);
}

- (NSString *)extension {
	return @"vcf";
}

- (NSString *)defaultFilename {
	return NSLocalizedString(@"DefaultFilename_VCard", nil);
}

- (void) dealloc {
	if (person != NULL) CFRelease(person);
	[abPersonVCardCreator release];
	[unknownPersonController release];
	[vcardString release];
	
	[super dealloc];
}

- (NSString *)name {
	ABPersonVCardCreator *personCreator = [[[ABPersonVCardCreator alloc] initWithPerson: self.person] autorelease];
	
	return [personCreator previewName];
}

- (UIImage *)imageForSaveButton {
	return [UIImage imageNamed:@"container_btn_double-save.png"];
}

- (UIImage *)historyThumbButton {
	return [UIImage imageNamed:@"history_icon_contact.png"];
}

- (NSDictionary *) dataDesctiption {
	NSString *crypted = [self.cryptor encryptString:vcardString];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	[dictionary setObject:@"text/x-vcard" forKey:@"type"];
	[dictionary setObject:crypted forKey:@"content"];
		
    [self.cryptor appendInfoToDictionary:dictionary];
	return dictionary;
}

@end

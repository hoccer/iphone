//
//  HoccerContentFactoryiPhone.m
//  Hoccer
//
//  Created by Robert Palmer on 25.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerContentFactoryiPhone.h"
#import "HoccerVcard.h"
#import "HoccerImage.h"
#import "HoccerText.h"
#import "HoccerContent.h"

@implementation HoccerContentFactoryIPhone

- (HoccerContent *)createContentFromResponse: (NSHTTPURLResponse *)response withData:(NSData *)data {
	HoccerContent* hoccerContent = nil;
	NSString *mimeType = [response MIMEType];
	
	if ([mimeType isEqual: @"text/x-vcard"]) {
		hoccerContent = [[HoccerVcard alloc] initWithData: data filename: [response suggestedFilename]];
	} else if ([mimeType rangeOfString:@"image/"].location == 0) {
		hoccerContent = [[HoccerImage alloc] initWithData: data filename: [response suggestedFilename]];
	} else if ([mimeType isEqual: @"text/plain"]) {
		hoccerContent = [[HoccerText alloc] initWithData: data filename: [response suggestedFilename]];
	} else {
		hoccerContent = [[HoccerContent alloc] initWithData:data filename: [response suggestedFilename]];
		hoccerContent.mimeType = mimeType;
	}
	
	return [hoccerContent autorelease];
}

- (HoccerContent *)createContentFromFile: (NSString *)filename withMimeType: (NSString *)mimeType {
	HoccerContent* hoccerContent = nil;
		
	if ([mimeType isEqual: @"text/x-vcard"]) {
		hoccerContent = [[HoccerVcard alloc] initWithFilename: filename];
	} else if ([mimeType rangeOfString:@"image/"].location == 0) {
		hoccerContent = [[HoccerImage alloc] initWithFilename: filename];
	} else if ([mimeType isEqual: @"text/plain"]) {
		hoccerContent = [[HoccerText alloc] initWithFilename: filename];
	} else {
		hoccerContent = [[HoccerContent alloc] initWithFilename: filename];
		hoccerContent.mimeType = mimeType;
	}
	
	return [hoccerContent autorelease];
	
} 

- (BOOL) isSupportedType: (NSString *)mimeType {
	return ([mimeType isEqual: @"text/x-vcard"] || [mimeType isEqual: @"text/plain"] || [mimeType rangeOfString:@"image/"].location == 0);
}

@end
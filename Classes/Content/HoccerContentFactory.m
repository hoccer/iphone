//
//  HoccerContentFactory.m
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.

#import "HoccerContentFactory.h"

static HoccerContentFactory* sharedInstance = nil;

@implementation HoccerContentFactory

+ (HoccerContentFactory *)sharedHoccerContentFactory {
	if (sharedInstance == nil) {		
		sharedInstance = [[HoccerContentFactory alloc] init];		
	}
	
	return sharedInstance;
}

- (HoccerContent *)createContentFromDict: (NSDictionary *)dictionary {
	NSLog(@"dictionary: %@", dictionary);
	
	HoccerContent *hoccerContent = nil;
	NSString *type = [dictionary objectForKey:@"type"];
		
	if ([type isEqual: @"text/x-vcard"]) {
		hoccerContent = [[HoccerVcard alloc] initWithDictionary: dictionary];
	} else if ([type rangeOfString:@"image/"].location == 0) {
		hoccerContent = [[HoccerImage alloc] initWithDictionary: dictionary];
	} else if ([type isEqual: @"text/plain"]) {
		hoccerContent = [[HoccerText alloc] initWithDictionary: dictionary];
	} else {
		hoccerContent = [[HoccerContent alloc] initWithDictionary:dictionary];
		hoccerContent.mimeType = type;
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

- (UIImage *)thumbForMimeType: (NSString *)mimeType {
	UIImage *hoccerImage = nil;
	
	if ([mimeType isEqual: @"text/x-vcard"]) {
		hoccerImage = [UIImage imageNamed:@"history_icon_contact.png"];
	} else if ([mimeType rangeOfString:@"image/"].location == 0) {
		hoccerImage = [UIImage imageNamed:@"history_icon_image.png"];
	} else if ([mimeType isEqual: @"text/plain"]) {
	   hoccerImage = [UIImage imageNamed:@"history_icon_text.png"];
	} else {
	   hoccerImage = [UIImage imageNamed:@"history_icon_text.png"];
	}
					   
	return  hoccerImage;
}



@end

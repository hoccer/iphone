//
//  HoccerContentFactory.m
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerContentFactory.h"
#import "HoccerContent.h"
#import "HoccerImage.h"
#import "HoccerUrl.h"
#import "HoccerText.h"

@implementation HoccerContentFactory

+ (id <HoccerContent>)createContentFromResponse: (NSHTTPURLResponse *)response withData:(NSData *)data {
	id <HoccerContent> hoccerContent = nil;
	
//	NSString *mimeType = [[response allHeaderFields] objectForKey:@"Content-Type"];
	NSString *mimeType = [response MIMEType];

	NSLog(@"mime: %@", mimeType);
	
	
	if ([mimeType isEqual: @"text/vcard"]) {
		// TODO: create vcard object; 
		// hoccerContent = [[HoccerVcard alloc] initWithData: data];
	} else if ([mimeType rangeOfString:@"image/"].location == 0) {
		hoccerContent = [[HoccerImage alloc] initWithData: data];
	} else if ([mimeType isEqual: @"text/plain"]) {
		if ([HoccerUrl isDataAUrl: data]) {
			hoccerContent = [[HoccerUrl alloc] initWithData: data];
		} else {
			hoccerContent = [[HoccerText alloc] initWithData: data];
		}
	}

	return hoccerContent;
}


@end

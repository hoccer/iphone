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

@implementation HoccerContentFactory

+ (id <HoccerContent>)createContentFromResponse: (NSHTTPURLResponse *)response withData:(NSData *)data {
	id <HoccerContent> hoccerContent = nil;
	
	NSString *mimeType = [[response allHeaderFields] objectForKey:@"Content-Type"];
	NSLog(@"mime: %@", mimeType);
	
	if ([mimeType rangeOfString:@"image/"].location == 0) {
		hoccerContent = [[HoccerImage alloc] initWithData: data];
	} else {
		hoccerContent = [[HoccerUrl alloc] initWithData: data];
	}

	return hoccerContent;
}


@end

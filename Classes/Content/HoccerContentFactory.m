//
//  HoccerContentFactory.m
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerContentFactory.h"
#import "HoccerContentFactoryIPhone.h"

#import "HoccerContent.h"
#import "HoccerImage.h"
#import "HoccerUrl.h"
#import "HoccerText.h"
#import "HoccerVcard.h"

static HoccerContentFactory* sharedInstance = nil;

@implementation HoccerContentFactory

+ (HoccerContentFactory *) sharedHoccerContentFactory {

	if (sharedInstance == nil) {		
		sharedInstance = [[HoccerContentFactoryIPhone alloc] init];		
	}
	
	return sharedInstance;
}

- (HoccerContent*)createContentFromResponse: (NSHTTPURLResponse *)response withData:(NSData *)data {
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
}


- (BOOL) isSupportedType: (NSString *)mimeType {
	[self doesNotRecognizeSelector:_cmd];

	return NO;
}





@end

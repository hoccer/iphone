//
//  HoccerContentFactory.h
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerContent.h"


@interface HoccerContentFactory : NSObject {

}

+ (HoccerContentFactory *) sharedHoccerContentFactory;

- (HoccerContent*) createContentFromResponse: (NSHTTPURLResponse *)response withData:(NSData *)data;
- (HoccerContent *)createContentFromFile: (NSString *)filename withMimeType: (NSString *)mimeType;
- (HoccerContent *)createContentFromDict: (NSDictionary *)dictionary;

- (BOOL) isSupportedType: (NSString *)mimeType;
- (UIImage *)thumbForMimeType: (NSString *)mimeType;

@end

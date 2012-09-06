//
//  HelpContent.h
//  Hoccer
//
//  Created by Robert Palmer on 27.10.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HelpContent : NSObject {
	NSString *name;
	NSString *description;
	NSString *imagePath;
	NSString *videoPath;
}

@property (retain) NSString *name;
@property (retain) NSString *description;
@property (retain) NSString *imagePath;
@property (retain) NSString *videoPath;

+ (HelpContent *)catchHelp;
+ (HelpContent *)throwHelp;
+ (HelpContent *)tabHelp;
+ (HelpContent *)sweepHelp;
+ (HelpContent *)keyHelp;
+ (HelpContent *)encryptionHelp;


@end

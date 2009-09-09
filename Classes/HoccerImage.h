//
//  HoccerImage.h
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HoccerImage : NSObject {
	UIImage *image;
}

- (id) initWithData: (NSData *)data;
- (void)save;
- (void)dismiss;
- (UIView *)view;
- (UIImage *)image;

@end

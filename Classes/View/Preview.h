//
//  PreviewView.h
//  Hoccer
//
//  Created by Robert Palmer on 19.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Preview : UIView {
	id delegate;
	CGPoint origin;
}

@property (nonatomic, retain) id delegate;
@property (assign) CGPoint origin;


- (void)setImage: (UIImage *)image;
- (void)dismissKeyboard;
- (void)resetViewAnimated: (BOOL)animated;

@end

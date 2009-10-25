//
//  PreviewView.h
//  Hoccer
//
//  Created by Robert Palmer on 19.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PreviewView : UIView {
	id delegate;
}

@property (nonatomic, retain) id delegate;

- (void) setImage: (UIImage *)image;
- (void)dismissKeyboard;


@end

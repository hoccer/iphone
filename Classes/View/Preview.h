//
//  PreviewView.h
//  Hoccer
//
//  Created by Robert Palmer on 19.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Preview : UIView {
	BOOL allowsOverlay;
    UIImageView *imageView;
    UIImageView *backgroundImage;
    UIImageView *contentIdentifier;
}

@property (assign) BOOL allowsOverlay;

- (void) setImage: (UIImage *)image;
- (void) setBackgroundImage: (UIImage *)aImage;
- (void) setContentIdentifier: (UIImage *)aImage;

@end

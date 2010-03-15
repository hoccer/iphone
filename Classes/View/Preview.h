//
//  PreviewView.h
//  Hoccer
//
//  Created by Robert Palmer on 19.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Preview : UIView {
	UIButton* button;
}

- (void) setImage: (UIImage *)image;
- (void) setCloseActionTarget: (id) aTarget action: (SEL) aSelector;

@end

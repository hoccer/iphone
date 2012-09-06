//
//  HCButtonView.h
//  Hoccer
//
//  Created by Robert Palmer on 03.08.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HCButton : UIButton {
	CGFloat textLabelOffset;
}

- (void)setTextLabelOffset: (CGFloat)newOffset;

@end

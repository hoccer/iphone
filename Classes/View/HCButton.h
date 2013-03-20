//
//  HCButtonView.h
//  Hoccer
//
//  Created by Robert Palmer on 03.08.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HCButton : UIButton {
    
	CGFloat     _textLabelOffset;
    CGFloat     _verticalTextOffset;
    CGFloat     _horizontalTextOffset;
}

@property (nonatomic, assign) CGFloat fontSize;

// Vertical offset from bottom edge of button frame
@property (nonatomic, assign) CGFloat verticalTextOffset;

// Horiztonal offset relative to center
@property (nonatomic, assign) CGFloat horizontalTextOffset;




@end

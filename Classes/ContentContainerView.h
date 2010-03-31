//
//  ContentContainerView.h
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ContentContainerView : UIView {
	UIButton *button;
}

- (id) initWithView: (UIView *)insideView;

@end

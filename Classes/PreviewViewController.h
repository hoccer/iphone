//
//  PreviewViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PreviewViewController : UIViewController {

	UIView* previewView;	
	
}

- (id) initWithView: (UIView*) previewView;

@end

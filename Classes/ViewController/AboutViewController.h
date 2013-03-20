//
//  AboutViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 25.10.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutViewController : UIViewController {
	id              delegate;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) IBOutlet UITextView *textView;

- (IBAction)hideView: (id)sender;

@end

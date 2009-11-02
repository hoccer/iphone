//
//  TermOfUse.h
//  Hoccer
//
//  Created by Robert Palmer on 02.11.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TermOfUse : UIViewController {
	id delegate;
}

@property (nonatomic, retain) id delegate;

- (IBAction)userDidAgreeToTermsOfUse: (id)sender;

@end

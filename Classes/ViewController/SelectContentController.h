//
//  SelectContentController.h
//  Hoccer
//
//  Created by Robert Palmer on 28.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SelectContentController : UIViewController {
	NSMutableArray *buttons;
	UIView *buttonsContainer;
	
	id delegate;
}

@property (assign) id delegate;
@property (retain) IBOutlet UIView *buttonsContainer;

- (IBAction)camera: (id)sender;
- (IBAction)image: (id)sender;
- (IBAction)video: (id)sender;
- (IBAction)text: (id)sender;
- (IBAction)contact: (id)sender;
- (IBAction)hoclet: (id)sender;
- (IBAction)pasteboard: (id)sender;
@end

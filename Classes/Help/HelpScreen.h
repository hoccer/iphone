//
//  HelpScreen.h
//  Hoccer
//
//  Created by Robert Palmer on 27.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpScreen : UIViewController {
	IBOutlet UILabel *header;
	
	NSString *name;

}

@property (nonatomic, copy) NSString *name;

- (id)initWithName: (NSString *)name;



@end

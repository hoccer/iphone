//
//  ContentSelectionButtonView.h
//  Hoccer
//
//  Created by Robert Palmer on 02.11.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ContentSelectionButtonView : UIViewController {
	id delegate;
}

@property (nonatomic, assign) id delegate;

- (IBAction)selectContacts: (id)sender;
- (IBAction)selectImage: (id)sender;
- (IBAction)selectText: (id)sender;


@end

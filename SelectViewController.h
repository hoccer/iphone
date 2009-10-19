//
//  SelectViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 13.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>


@interface SelectViewController : UIViewController 
		<UIImagePickerControllerDelegate, 
		  UINavigationControllerDelegate> {

	IBOutlet UIImagePickerController *imagePicker;
	IBOutlet id delegate;
}

@property (retain) id delegate;

@end

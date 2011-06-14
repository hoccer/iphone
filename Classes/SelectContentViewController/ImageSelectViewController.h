//
//  ImageSelectViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 08.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentSelectController.h"

@interface ImageSelectViewController : NSObject <ContentSelectController, UIImagePickerControllerDelegate, UINavigationControllerDelegate> 
{
    id <ContentSelectViewControllerDelegate> delegate;
    UIImagePickerControllerSourceType sourceType;
}

@property (retain) id <ContentSelectViewControllerDelegate> delegate;

- (id)initWithSourceType: (UIImagePickerControllerSourceType)type;

@end

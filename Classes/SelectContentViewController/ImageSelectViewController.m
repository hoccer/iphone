//
//  ImageSelectViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 08.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "ImageSelectViewController.h"
#import "HoccerContent.h"
#import "HoccerImage.h"

@implementation ImageSelectViewController
@synthesize delegate;

- (id)init {
    return [self initWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}


- (id)initWithSourceType: (UIImagePickerControllerSourceType)type {
    self = [super init];
    if (self) {
        sourceType = type;
    }
    
    return self;
}

- (UIViewController *)viewController {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = sourceType;
	imagePicker.delegate = self;

	return [imagePicker autorelease];
}

#pragma mark -
#pragma mark UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    HoccerContent* content = [[[HoccerImage alloc] initWithUIImage:
                               [info objectForKey: UIImagePickerControllerOriginalImage]] autorelease];

    if ([self.delegate respondsToSelector:@selector(contentSelectController:didSelectContent:)]) {
        [self.delegate contentSelectController:self didSelectContent:content];
    }
}




@end

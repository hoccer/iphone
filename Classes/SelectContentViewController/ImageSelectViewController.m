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
#import "HoccerVideo.h"
#import "NSFileManager+FileHelper.h"
#import "UIBarButtonItem+CustomImageButton.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "CustomNavigationBar.h"

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
    if (sourceType == UIImagePickerControllerSourceTypeCamera){
        imagePicker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    }
    else {
        imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    }

    imagePicker.sourceType = sourceType;
	imagePicker.delegate = self;

    
	return [imagePicker autorelease];
}

#pragma mark -
#pragma mark UIImagePickerController Delegate Methods


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    HoccerContent* content;
    if (CFStringCompare((CFStringRef) [info objectForKey:UIImagePickerControllerMediaType], kUTTypeImage, 0) == kCFCompareEqualTo){
     content = [[[HoccerImage alloc] initWithUIImage:
                               [info objectForKey: UIImagePickerControllerOriginalImage]] autorelease];
    }
    else {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        content = [[[HoccerVideo alloc] initWithURL:videoURL] autorelease];
        
        NSString *tempFilePath = [videoURL path];

        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            if ( UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(tempFilePath))
            {
                UISaveVideoAtPathToSavedPhotosAlbum(tempFilePath, nil, nil, nil);
            }
        }
    }

    if ([info objectForKey:UIImagePickerControllerMediaMetadata]){
    
        UIImageWriteToSavedPhotosAlbum([info objectForKey: UIImagePickerControllerOriginalImage], nil,nil,nil);

    }

    if ([self.delegate respondsToSelector:@selector(contentSelectController:didSelectContent:)]) {
        [self.delegate contentSelectController:self didSelectContent:content];
    }
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [navigationController.navigationBar setTranslucent:NO];
        [navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        
    }
}



@end

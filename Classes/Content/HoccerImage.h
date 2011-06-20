//
//  HoccerImage.h
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hoccer.h"
#import "HoccerFileContent.h"
#import "TransferController.h"
#import "FileUploader.h"

@interface HoccerImage : HoccerFileContent <HCFileCacheDelegate> {
	UIImage *image;	
	
	UIImage *thumb;
	
	Preview *preview;
    
    FileUploader *thumbUploader;
    NSString *thumbURL;
    
    FileDownloader *thumbDownloader;
}

@property (nonatomic, readonly) UIImage* image;
@property (nonatomic, readonly) UIImage* thumb;
@property (readonly) Preview *preview;

- (id)initWithUIImage: (UIImage *)aImage;
- (void)updateImage;
- (void)didFinishDataRepresentation;

- (NSString *)thumbFilename;
- (NSString *)thumbURL;

@end

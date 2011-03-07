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

@interface HoccerImage : HoccerFileContent <HCFileCacheDelegate> {
	UIImage *image;	
	
	Preview *preview;
}

@property (nonatomic, readonly) UIImage* image;

- (id)initWithUIImage: (UIImage *)aImage;
- (void)updateImage;
- (void)didFinishDataRepresentation;

@end

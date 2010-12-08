//
//  HoccerImage.h
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hoccer.h"
#import "HoccerContent.h"

@interface HoccerImage : HoccerContent <HCFileCacheDelegate> {
	UIImage *image;	
	
	HCFileCache *fileCache;
	NSString *uploadURL;
	
	Preview *preview;
	
	NSNumber *progress;
}

@property (nonatomic, readonly) UIImage* image;
@property (nonatomic, retain) NSNumber* progress;

- (id)initWithUIImage: (UIImage *)aImage;
- (void)uploadFile;
- (void)updateImage;
- (void)didFinishDataRepresentation;



@end

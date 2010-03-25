//
//  HoccerContent.h
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Preview;

@protocol HoccerContent <NSObject>

- (void)save;
- (void)dismiss;
- (UIView *)view;
- (Preview *)thumbnailView;

- (NSString *)filename;
- (NSString *)mimeType;

- (NSData *)data;
- (BOOL)isDataReady;

- (NSString *)saveButtonDescription;

//- (UIImage *)icon;
//- (void)presentPreviewInViewController:(UIViewController *)viewController;

- (void)contentWillBeDismissed;
- (BOOL)needsWaiting;

- (void)whenReadyCallTarget: (id)aTarget selector: (SEL)aSelector;


@end

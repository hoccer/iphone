//
//  HoccerContetn.h
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HoccerContent <NSObject>

- (id) initWithData: (NSData *)data;
- (void)save;
- (void)dismiss;
- (UIView *)view;
- (UIView *)preview;

- (NSString *)filename;
- (NSString *)mimeType;

- (NSData *)data;
- (BOOL)isDataReady;

- (NSString *)saveButtonDescription;

@end

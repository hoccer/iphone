//
//  TextInputViewControllerDelegate.h
//  Hoccer
//
//  Created by Philip Brechler on 04.09.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TextInputViewController;

@protocol TextInputViewControllerDelegate <NSObject>

- (void)textInputViewController:(TextInputViewController *)controller didFinishedWithString:(NSString *)string;
- (void)textInputViewControllerdidCancel;

@end

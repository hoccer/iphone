//
//  RSAKeyViewController.h
//  Hoccer
//
//  Created by Philip Brechler on 02.08.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSAKeyViewController : UIViewController <UITextViewDelegate> {
    IBOutlet UITextView *keyText;
    NSString *key;
}

@property (nonatomic,retain) IBOutlet UITextView *keyText;
@property (nonatomic,retain) IBOutlet UILabel *warningLabel;

@property (nonatomic,retain) NSString *key;
@end

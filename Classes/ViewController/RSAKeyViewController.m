//
//  RSAKeyViewController.m
//  Hoccer
//
//  Created by Philip Brechler on 02.08.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "RSAKeyViewController.h"
#import "RSA.h"
#import "NSData_Base64Extensions.h"

@implementation RSAKeyViewController

@synthesize keyText,key;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_bg.png"]];

    if ([key isEqualToString:@"public"]){
        NSData *publicKey = [[RSA sharedInstance] getPublicKeyBits];
        keyText.text = [publicKey asBase64EncodedString];
    }
    else if ([key isEqualToString:@"private"]){
        NSData *privateKey = [[RSA sharedInstance] getPrivateKeyBits];
        keyText.text = [privateKey asBase64EncodedString];
    }
    else if ([key isEqualToString:@"shared"]){
        keyText.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"encryptionKey"];
    }
    else {
        keyText.text = key;
    }
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([key isEqualToString:@"shared"]){
        NSString *oldPSK = [[NSUserDefaults standardUserDefaults] objectForKey:@"encryptionKey"];
        if (![oldPSK isEqualToString:keyText.text]) {
            [[NSUserDefaults standardUserDefaults] setObject:keyText.text forKey:@"encryptionKey"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

        
- (void)dealloc {
    
    [keyText release];
    [key release];
    [super dealloc];
            
}

@end

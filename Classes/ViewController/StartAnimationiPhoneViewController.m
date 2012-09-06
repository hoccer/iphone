//
//  StartAnimationiPhoneViewController.m
//  Hoccer
//
//  Created by Philip Brechler on 18.06.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "StartAnimationiPhoneViewController.h"

@implementation StartAnimationiPhoneViewController

@synthesize objectImageView,overlayImageView,backgroundImageView,upperBarImageView,lowerBarImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewDidAppear:(BOOL)animated {
    [self performSelector:@selector(appear:finished:context:) withObject:nil afterDelay:0.5 ];
}

- (void)appear:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         [self.objectImageView setAlpha:1.0];
                     } 
                     completion:^(BOOL finished){
                         [self moveRight:nil finished:nil context:nil];
                     }];

}

- (void)moveRight:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    CGRect newObjectFrame = self.objectImageView.frame;
    newObjectFrame.origin.x = 180;
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.objectImageView.frame = newObjectFrame;
                     } 
                     completion:^(BOOL finished){
                         [self removeObject:nil finished:nil context:nil];
                     }];
    
}

- (void)removeObject:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    [UIView animateWithDuration:0.5
                          delay:0.8
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         [self.objectImageView setAlpha:0];
                     } 
                     completion:^(BOOL finished){
                         [self removeOverlay:nil finished:nil context:nil];
                     }];
    
}

- (void)removeOverlay:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    CGRect upperBarFrame = self.upperBarImageView.frame;
    upperBarFrame.origin.y = 0;
    CGRect lowerBarFrame = self.lowerBarImageView.frame;
    lowerBarFrame.origin.y = 398;
    
    [UIView animateWithDuration:0.5
                          delay:0.8
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         [self.overlayImageView setAlpha:0];
                         [self.backgroundImageView setAlpha:0];
                         [self.upperBarImageView setFrame:upperBarFrame];
                         [self.lowerBarImageView setFrame:lowerBarFrame];
                     } 
                     completion:^(BOOL finished){
                         [self animationFinished];
                     }];
    
}

- (void)showBars:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    CGRect upperBarFrame = self.upperBarImageView.frame;
    upperBarFrame.origin.y = 0;
    CGRect lowerBarFrame = self.lowerBarImageView.frame;
    lowerBarFrame.origin.y = 398;
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         [self.upperBarImageView setFrame:upperBarFrame];
                         [self.lowerBarImageView setFrame:lowerBarFrame];
                     } 
                     completion:^(BOOL finished){
                         [self animationFinished];
                     }];
    
}


- (void)animationFinished {
    [self performSelector:@selector(removeSelf) withObject:nil afterDelay:0.6];
}

- (void)removeSelf {
    [UIView beginAnimations:@"removeWithEffect" context:nil];
    [UIView setAnimationDuration:0.5f];
    //Change frame parameters, you have to adjust
    //self.view.frame = CGRectMake(0,0,320,480);
    self.view.alpha = 0.0f;
    [UIView commitAnimations];
    [self.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5f];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

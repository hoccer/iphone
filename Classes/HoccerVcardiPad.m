//
//  HoccerVcardiPad.m
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerVcardiPad.h"
#import "ACPerson.h"
#import "Preview.h"
#import "ABPersonCreator.h"
#import "NSString+StringWithData.h"

@implementation HoccerVcardiPad

- (Preview *)desktopItemView {
	NSData *filedata = [NSData dataWithContentsOfFile: filepath];
	NSString *vcardString = [NSString stringWithData:filedata usingEncoding:NSUTF8StringEncoding]; 
	NSLog(@"person: %@", vcardString);
	
	
	ABPersonCreator *creator = [[ABPersonCreator alloc] initWithVcardString: vcardString];
	ABRecordRef person = creator.person;
	
	ABPersonVCardCreator *acPerson = [[ABPersonVCardCreator alloc] initWithPerson:person];
	[creator release];
	
	Preview *view = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 319, 234)];
	
	NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"Contactbox" ofType:@"png"];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:backgroundImagePath]];
	
	[view addSubview:backgroundImage];
	[view sendSubviewToBack:backgroundImage];
	[backgroundImage release];
	
	UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(106, 56, 165, 20)];
	label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
	label.textColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
	
	[view addSubview: label];
	
	label.text = [acPerson previewName]; 
	[label release];
	
	return [view autorelease];
}

@end

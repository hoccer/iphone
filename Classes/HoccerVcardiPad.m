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

@implementation HoccerVcardIPad

- (UIDocumentInteractionController*) interactionController{
	return [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath: filepath]];	
};

@end

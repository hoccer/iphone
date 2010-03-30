//
//  HoccerUrlIPad.m
//  Hoccer
//
//  Created by Robert Palmer on 30.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerUrlIPad.h"


@implementation HoccerUrlIPad

- (UIDocumentInteractionController*) interactionController{
	return [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath: filepath]];	
};

@end

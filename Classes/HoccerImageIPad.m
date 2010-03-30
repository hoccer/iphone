//
//  HoccerImageIPad.m
//  Hoccer
//
//  Created by Robert Palmer on 25.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerImageIPad.h"
#import "Preview.h"


@implementation HoccerImageIPad

- (UIDocumentInteractionController*) interactionController{
	return [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath: filepath]];	
};
 

@end

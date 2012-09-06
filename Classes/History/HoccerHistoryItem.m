//
//  hoccerController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import "HoccerHistoryItem.h"


@implementation HoccerHistoryItem

@dynamic latitude;
@dynamic longitude;
@dynamic filepath;
@dynamic creationDate;
@dynamic mimeType;
@dynamic upload;
@dynamic data;

-(void)dealloc{
    [super dealloc];
}
@end

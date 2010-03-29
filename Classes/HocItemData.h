//
//  HocItemData.h
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HoccerRequest;
@class DragAndDropViewController;


@interface HocItemData : NSObject {
	HoccerRequest *request;
	DragAndDropViewController *dragAndDropViewConroller;
}

@property (retain) DragAndDropViewController *dragAndDropViewConroller;

- (void)cancelRequest;
- (BOOL)hasActiveRequest;

@end

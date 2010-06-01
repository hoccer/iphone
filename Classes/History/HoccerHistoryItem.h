//
//  HocItem.h
//  Hoccer
//
//  Created by Robert Palmer on 07.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HoccerHistoryItem : NSManagedObject
{

}

@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *filepath;
@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSString *mimeType;
@property (nonatomic, assign) NSNumber *upload;

@end

//
//  ACPerson.h
//  Hoccer
//
//  Created by Robert Palmer on 22.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ACPerson : NSObject {
	ABRecordRef person;
}

- (id)initWithPerson: (ABRecordRef)aPeron;
- (NSString *)name;


@end

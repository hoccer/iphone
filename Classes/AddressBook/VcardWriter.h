//
//  VcardWriter.h
//  Hoccer
//
//  Created by Robert Palmer on 06.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VcardWriter : NSObject {
	NSMutableString  *vcardString;
}

- (void)writeProperty: (NSString *)propertyName 
				value: (NSString *)valueName
			paramater: (NSArray *)parameter;

- (NSString *)vcardRepresentation;  


@end

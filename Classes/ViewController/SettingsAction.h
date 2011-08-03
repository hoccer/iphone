//
//  SettingsAction.h
//  Hoccer
//
//  Created by Philip Brechler on 02.08.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

enum HCSettingsType {
	HCInplaceSetting,
	HCSwitchSetting,
	HCContinueSetting,
    HCTextField
} typedef HCSettingsType;




@interface SettingsAction : NSObject {
	NSString *description;
	SEL selector;
	HCSettingsType type;
	
	id defaultValue;
}

@property (copy) NSString *description;
@property (assign) SEL selector;
@property (assign) HCSettingsType type;
@property (retain) id defaultValue;

+ (SettingsAction *)actionWithDescription: (NSString *)theDescription selector: (SEL)theSelector type: (HCSettingsType)theType;

@end
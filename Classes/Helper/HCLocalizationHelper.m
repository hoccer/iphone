//
//  HCLocalizationHelper.m
//  Hoccer
//
//  Created by patrick on 18.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import "HCLocalizationHelper.h"


NSString* HCLocalizedString(NSString *key) {
    
    NSString *translation = [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil];
    
    if ([translation isEqualToString:key]) {
        
        // Try the english localization explicitly only then if the user is not already in English anyway.
        if (![[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"en"]) {
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
            NSBundle *languageBundle = [NSBundle bundleWithPath:path];
            translation = [languageBundle localizedStringForKey:key value:@"" table:nil];
        }
    }
    
    return translation;
}

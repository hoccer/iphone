//
//  HCLocalizationHelper.h
//  Hoccer
//
//  Created by patrick on 18.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


// Localization works as follows:
// - You start out with a single language (en, English) where you define all the keys and their translation.
// - NSLocalizedString will check the file Localizations.strings automatically for translations based on the user's language setting.
// - If a user's language is Spanish the App will still show English because there is no Spanish localization file in the project.
// - As soon as you add a Spanish localization file you must provide all translations in it. If there is a missing
//   entry, NSLocalizedString will show the key value, not the translation and also not fall back on the english localization.
//
// HCLocalizedString will instead try to fall back to English whenever the translation result is the same as the key.
NSString* HCLocalizedString(NSString *key);
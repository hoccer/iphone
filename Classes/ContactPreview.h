//
//  ContactPreview.h
//  Hoccer
//
//  Created by Robert Palmer on 29.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Preview.h"

@interface ContactPreview : Preview {
	UILabel *name;
}

@property (retain) IBOutlet UILabel *name;

@end

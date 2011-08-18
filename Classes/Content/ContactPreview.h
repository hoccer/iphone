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
    UILabel *company;
    UILabel *otherInfo;
    UIImageView *image;
}

@property (retain) IBOutlet UILabel *name;
@property (retain) IBOutlet UILabel *company;
@property (retain) IBOutlet UILabel *otherInfo;
@property (retain) IBOutlet UIImageView *image;

@end

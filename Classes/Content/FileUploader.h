//
//  FileUploader.h
//  Hoccer
//
//  Created by Robert Palmer on 10.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileTransferer.h"

@interface FileUploader : FileTransferer {
    
}

- (id)initWithFilename: (NSString *)aFilename;
@property (retain, nonatomic) NSString * uploadURL;

@end

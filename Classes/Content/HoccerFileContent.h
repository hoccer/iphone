//
//  HoccerFileContent.h
//  Hoccer
//
//  Created by Robert Palmer on 09.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileDownloader.h"
#import "HoccerContent.h"
#import "FileTransferer.h"

@interface HoccerFileContent : HoccerContent {
    NSMutableArray *transferables;
}

@end

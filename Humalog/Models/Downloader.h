//
//  Downloader.h
//  Humalog
//
//  Created by David Rodriguez on 4/22/12.
//  Copyright (c) 2012 UNAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSZipArchive.h"
#import "DownloadControlDelegate.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@interface Downloader : NSObject

@property (retain) id<DownloadControlDelegate> delegate;
@property (assign) float advance;
- (void)parseJSON:(NSString *)brand;

@end

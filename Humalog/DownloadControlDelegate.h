//
//  DownloadControlDelegate.h
//  Humalog
//
//  Created by David Rodriguez on 4/24/12.
//  Copyright (c) 2012 UNAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadControlDelegate <NSObject>

@optional
- (void)downloaderDidFinish;
- (void)downloaderIsDownloading;


@end

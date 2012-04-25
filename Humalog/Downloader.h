//
//  Downloader.h
//  Humalog
//
//  Created by David Rodriguez on 4/22/12.
//  Copyright (c) 2012 UNAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZipArchive.h"


#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define kBrandURL [NSString stringWithFormat: @"http://humalog.herokuapp.com/brands/"] //2

@interface Downloader : NSObject

- (void) parseJSON:(NSString *)brand;

- (NSString *) brandName; 
- (NSArray *) brandCategories;
- (NSArray *) brandSlides;

@end

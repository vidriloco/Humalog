//
//  PaperProvider.h
//  Humalog
//
//  Created by Workstation on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocumentDataSource.h"
#import "AnnotationDataSource.h"
#import "ContentDisplayDelegate.h"

#define kPreviewSize CGRectMake(0, 0, 512, 600)

@interface WhitepaperProvider : NSObject<UIWebViewDelegate, DocumentDataSource, AnnotationDataSource> {
    id<ContentDisplayDelegate> delegate;
}

- (void)loadStudies;
- (void)loadIPPs;
- (void)loadReferences;

@property (nonatomic, retain) id<ContentDisplayDelegate> delegate;
@property (nonatomic, readonly) NSArray *whitepaperList;
@end


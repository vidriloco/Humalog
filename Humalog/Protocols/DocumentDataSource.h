//
//  DocumentDataSource.h
//  Humalog
//
//  Created by Workstation on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentControlProtocol.h"

@protocol DocumentDataSource <NSObject>
- (NSUInteger)numberOfDocuments;
- (UIView<ContentControlProtocol> *)viewForDocumentAtIndex:(NSUInteger)index;
@optional
- (NSUInteger)numberOfCategories;
- (NSString *)titleForDocumentAtIndex:(NSUInteger)index;
- (UIImageView *)previewForDocumentAtIndex:(NSUInteger)index;
- (NSRange)rangeForCategoryIndex:(NSUInteger)categoryIndex;
- (NSUInteger)categoryIndexForDocumentAtIndex:(NSUInteger)documentIndex;
@end

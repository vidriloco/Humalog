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
- (UIImageView *)previewForDocumentAtIndex:(NSUInteger)index;
@end

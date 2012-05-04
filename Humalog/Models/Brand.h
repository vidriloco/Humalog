//
//  Brand.h
//  Humalog
//
//  Created by David Rodriguez on 4/22/12.
//  Copyright (c) 2012 UNAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Brand : NSObject

+ (Brand *)sharedInstance;
+ (void)updateElementsFromDefaults;

@property (atomic, strong) NSString *brandName;
@property (atomic, strong) NSURL *brandURL;
@property (atomic, assign) BOOL isUpdated;
@property (atomic, assign) BOOL hasOpening;    
@property (atomic, assign) BOOL hasClosing;
@property (atomic, assign) BOOL hasIPP;
@property (atomic, assign) BOOL hasStudies;
@property (atomic, assign) BOOL hasSpecial;
@property (atomic, assign) BOOL hasReferences;
@property (atomic, assign) BOOL usesStackView;
@property (atomic, assign) int numberOfMenus;
@property (atomic, assign) int numberOfCategories;
@property (atomic, assign) int numberOfIpps;
@property (atomic, assign) int numberOfReferences;
@property (atomic, assign) int numberOfStudies;
@property (atomic, strong) NSArray *interfaceURL;
@property (atomic, strong) NSString *editURL;
@property (atomic, strong) NSArray *pdfs;
@property (atomic, strong) NSArray *categories;
@property (atomic, strong) NSArray *slides;

// New
@property (atomic, strong) NSArray *studies;
@property (atomic, strong) NSArray *IPPs;
@property (atomic, strong) NSArray *references;

@end

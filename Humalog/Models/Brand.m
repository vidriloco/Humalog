//
//  Brand.m
//  Humalog
//
//  Created by David Rodriguez on 4/22/12.
//  Copyright (c) 2012 UNAM. All rights reserved.
//

#import "Brand.h"




@implementation Brand
@synthesize brandName, brandURL;
@synthesize isUpdated, hasOpening,hasClosing, hasIPP, hasStudies, hasSpecial, hasReferences,usesStackView;
@synthesize numberOfMenus, numberOfCategories,numberOfIpps, numberOfReferences, numberOfStudies;
@synthesize editURL,interfaceURL,pdfs,categories,slides;


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        brandName = [NSString string];
        editURL = [NSString string];
        brandURL = [[NSURL alloc]init];
        interfaceURL = [NSArray array];        
        pdfs = [NSArray array];                
        categories = [NSArray array];
        slides = [NSArray array];
    }
    return self;
}



@end

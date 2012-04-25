//
//  ContentProvider.m
//  Humalog
//
//  Created by Workstation on 3/9/12.
//  Copyright (c) 2012 Astra Zeneca. All rights reserved.
//

#import "SlideProvider.h"
#import "WebContentView.h"

@interface SlideProvider() {
    NSMutableDictionary *documentAnnotations;
    NSArray             *documentTitles;
    NSArray             *categoriesAndIndices;
    WebContentView      *webContentView;
}

@end

@implementation SlideProvider
@synthesize delegate;

- (id)init
{
    if ((self = [super init])) {
        webContentView = [[WebContentView alloc] init];
        webContentView.delegate = self;
        webContentView.scalesPageToFit = NO;
        webContentView.scrollView.scrollEnabled = NO;
        
        documentAnnotations = [NSMutableDictionary dictionary];
                
            }
    return self;
}

- (id)initWithCategories:(NSArray *)categories andSlides:(NSArray *)slides withUpdate:(BOOL)update
{

    self = [self init];
    
    if (update) {


    
    NSMutableArray *temp = [NSMutableArray array];

    int length = [[categories valueForKey:@"orden"] count];
    for (int i=1; i<length-1;i++) {
        int cat;
        int nSlide;
        if (i==1) {
            cat = i;
            nSlide = [[[categories valueForKey:@"number_of_slides"] objectAtIndex:i]intValue] ;
        }else {
            cat = cat + nSlide ;
            nSlide = [[[categories valueForKey:@"number_of_slides"] objectAtIndex:i]intValue] ;
        }
        [temp addObject:[NSValue valueWithRange:NSMakeRange(cat,nSlide)]];
    }

    categoriesAndIndices = [NSArray arrayWithArray:temp];
        NSMutableArray *dict = [NSMutableArray array];
        int len = [categoriesAndIndices count];
        for (int i=0; i<len; i++) {
            NSValue *tmp = [categoriesAndIndices objectAtIndex:i];
            NSNumber *val=[NSNumber numberWithInt:[tmp rangeValue].length] ;
            
            NSString *key=[NSString stringWithFormat:@"%d",[tmp rangeValue].location];
            NSString *cadena = key;
            cadena = [cadena stringByAppendingString:@","];
            cadena = [cadena stringByAppendingString:[val stringValue]];
            
            [dict addObject:cadena];
        }

        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"categories_preference"];
      
    
    NSMutableArray *tempo = [NSMutableArray array];;
    for (int i=0; i<[[slides valueForKey:@"name"] count]; i++) {
        for (int j=0; j<[[[slides valueForKey:@"name"] objectAtIndex:i]count]; j++) {
            [tempo addObject:[[[slides valueForKey:@"name"] objectAtIndex:i]objectAtIndex:j]];
        }
    }
    
    documentTitles = tempo;
        [[NSUserDefaults standardUserDefaults] setObject:documentTitles forKey:@"slides_preference"];
    
        NSLog(@"%@",documentTitles);    
        NSLog(@"%@",categoriesAndIndices);        
        
    }else {
         NSMutableArray *temp = [NSMutableArray array];
        
        for (int i=0; i<[categories count]; i++) {
            NSRange match;
            NSString *cadena = [categories objectAtIndex:i];

            match = [cadena rangeOfString:@","];
            NSString *string1 = [cadena substringToIndex:match.location];
            NSString *string2 = [cadena substringFromIndex:match.location+1];

            [temp addObject:[NSValue valueWithRange:NSMakeRange([string1 intValue], [string2 intValue])]];
        }
        categoriesAndIndices = temp;
        documentTitles = slides;
        NSLog(@"%@",documentTitles);    
        NSLog(@"%@",categoriesAndIndices);        
    }
        
    return self;
}

- (NSUInteger)numberOfDocuments
{
    return 12;
}

- (NSString *)titleForDocumentAtIndex:(NSUInteger)index
{
    return [documentTitles objectAtIndex:index];
}

- (UIView<ContentControlProtocol> *)viewForDocumentAtIndex:(NSUInteger)index
{
    
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES) objectAtIndex:0];
    
    NSString *newDir = [documentsDir stringByAppendingPathComponent:@"slides/"];    
    NSString *slideName = [@"slide" stringByAppendingString:[[NSNumber numberWithUnsignedInt:index + 1] stringValue]];
    newDir = [newDir stringByAppendingPathComponent:slideName];
    NSMutableString *path=[NSMutableString string];
    slideName = [slideName stringByAppendingString:@".html"];
    [path appendString:[newDir stringByAppendingPathComponent:slideName]];

    
    if (!path)
        return nil;
    
    NSURL *url = [NSURL URLWithString: [path lastPathComponent] 
                        relativeToURL: [NSURL fileURLWithPath: [path stringByDeletingLastPathComponent] 
                                                  isDirectory: YES]];
    
    [webContentView loadRequest:[NSURLRequest requestWithURL:url]];
    webContentView.scalesPageToFit = YES;
    return webContentView;
}

- (UIImageView *)previewForDocumentAtIndex:(NSUInteger)index
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES) objectAtIndex:0];
    
    NSString *newDir = [documentsDir stringByAppendingPathComponent:@"resources/backs/"];
    NSString *fileName = [[@"brilinta_" stringByAppendingString:[NSNumber numberWithUnsignedInt:index + 1].stringValue] stringByAppendingString:@".jpg"];
    //return [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
    NSLog(@"%@",[newDir stringByAppendingPathComponent:fileName]);
    return [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[newDir stringByAppendingPathComponent:fileName]]];
}

- (NSDictionary *)annotationsForDocumentAtIndex:(NSUInteger)index
{
    return [documentAnnotations objectForKey:[NSNumber numberWithUnsignedInt:index]];
}

- (void)setAnnotations:(NSDictionary *)annotations forDocumentAtIndex:(NSUInteger)index
{
    [documentAnnotations setObject:annotations forKey:[NSNumber numberWithUnsignedInteger:index]];
}

- (NSRange)rangeForCategoryIndex:(NSUInteger)categoryIndex
{
    return [[categoriesAndIndices objectAtIndex:categoryIndex] rangeValue];
}

- (NSUInteger)categoryIndexForDocumentAtIndex:(NSUInteger)documentIndex
{
    for (NSValue *value in categoriesAndIndices)
        if (NSLocationInRange(documentIndex, [value rangeValue]))
            return [categoriesAndIndices indexOfObject:value];
    
    return NSUIntegerMax;
}

// Delegation
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.delegate contentViewDidFinishLoad];
}

@end

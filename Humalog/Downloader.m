//
//  Downloader.m
//  Humalog
//
//  Created by David Rodriguez on 4/22/12.
//  Copyright (c) 2012 UNAM. All rights reserved.
//

#import "Downloader.h"
#import "Brand.h"
#define kBrandURL [NSString stringWithFormat: @"http://humalog.herokuapp.com/brands/"] //2

@interface Downloader(){
    Brand *configurator;
    int pending;
}
@end

@implementation Downloader
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        configurator = [[Brand alloc]init];
        pending=0;
    }
    return self;
}


- (void) parseJSON:(NSString *)brand {
    
    NSString *file=[brand stringByAppendingString:@".json"];
    NSURL *url = [NSURL URLWithString:[kBrandURL stringByAppendingString:file]];
    dispatch_sync(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: 
                        url];
        [self performSelectorOnMainThread:@selector(fetchedData:) 
                               withObject:data waitUntilDone:YES];

//        [self performSelector:@selector(fetchedData:)withObject:data];
    });
    dispatch_release(kBgQueue);
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization 
                          JSONObjectWithData:responseData //1
                          options:kNilOptions 
                          error:&error];
    
    [self updateElementsWithJSON:json];
}

- (void) updateElementsWithJSON:(NSDictionary *)json{
    
    configurator.brandName = [[json objectForKey:@"brand"] valueForKey:@"name"];
    configurator.brandURL = [[json objectForKey:@"brand"] valueForKey:@"url"];
    configurator.categories = [json objectForKey:@"categories"];//Get slides and urls to download
    configurator.slides = [[json objectForKey:@"categories"] valueForKey:@"category"];
    configurator.hasOpening = [[[json objectForKey:@"interface_configuration"] valueForKey:@"has_opening"] boolValue];
    configurator.hasClosing = [[[json objectForKey:@"interface_configuration"] valueForKey:@"has_closing"] boolValue];
    configurator.hasIPP = [[[json objectForKey:@"interface_configuration"] valueForKey:@"has_ipp"] boolValue];
    configurator.hasReferences = [[[json objectForKey:@"interface_configuration"] valueForKey:@"has_references"] boolValue];
    configurator.hasSpecial = [[[json objectForKey:@"interface_configuration"] valueForKey:@"has_special"] boolValue];
    configurator.hasStudies = [[[json objectForKey:@"interface_configuration"] valueForKey:@"has_studies"] boolValue];
    configurator.usesStackView = [[[json objectForKey:@"interface_configuration"] valueForKey:@"uses_stack_view"] boolValue];
    configurator.isUpdated = [[[json objectForKey:@"interface_configuration"] valueForKey:@"updated_device"] boolValue];    
    configurator.numberOfMenus = [[[json objectForKey:@"interface_configuration"] valueForKey:@"number_of_menus"] intValue];    
    configurator.numberOfCategories = [[json objectForKey:@"number_of_categories"]intValue];
    configurator.numberOfIpps = [[json objectForKey:@"number_of_ipps"]intValue];
    configurator.numberOfReferences = [[json objectForKey:@"number_of_references"]intValue];    
    configurator.numberOfStudies = [[json objectForKey:@"number_of_studies"]intValue];        
    configurator.interfaceURL = [json objectForKey:@"interface_urls"];
    configurator.pdfs = [json objectForKey:@"pdfs"];
    configurator.editURL = [json objectForKey:@"update_interface"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[self setCategoriesInPreferences] forKey:@"categories_preference"];
    

    [[NSUserDefaults standardUserDefaults] setObject:[self setSlidesInPreferences] forKey:@"slides_preference"];
    
    
    [[NSUserDefaults standardUserDefaults] setValue:[[json objectForKey:@"interface_configuration"] 
                                                     valueForKey:@"number_of_menus"] forKey:@"menus"];
    
    [self setPDFDefaults];
    
    [[NSUserDefaults standardUserDefaults] setValue:configurator.brandName forKey:@"brand"];
    
    [[NSUserDefaults standardUserDefaults] setValue:[[json objectForKey:@"interface_configuration"] 
                                                     valueForKey:@"has_closing"] 
                                             forKey:@"1"];    
    
    [[NSUserDefaults standardUserDefaults] setValue:[[json objectForKey:@"interface_configuration"] 
                                                     valueForKey:@"has_opening"] 
                                             forKey:@"2"];
    
    [[NSUserDefaults standardUserDefaults] setValue:[[json objectForKey:@"interface_configuration"] 
                                                     valueForKey:@"has_ipp"] 
                                             forKey:@"3"];
    
    [[NSUserDefaults standardUserDefaults] setValue:[[json objectForKey:@"interface_configuration"] 
                                                     valueForKey:@"has_references"] 
                                             forKey:@"4"];
    
    [[NSUserDefaults standardUserDefaults] setValue:[[json objectForKey:@"interface_configuration"] 
                                                     valueForKey:@"has_special"] 
                                             forKey:@"5"];
    
    [[NSUserDefaults standardUserDefaults] setValue:[[json objectForKey:@"interface_configuration"] 
                                                     valueForKey:@"has_studies"] 
                                             forKey:@"6"];
    
    [[NSUserDefaults standardUserDefaults] setValue:[[json objectForKey:@"interface_configuration"] 
                                                     valueForKey:@"uses_stack_view"] 
                                             forKey:@"7"];
    
    [[NSUserDefaults standardUserDefaults] setValue:[[json objectForKey:@"interface_configuration"] 
                                                     valueForKey:@"updated_device"] 
                                             forKey:@"8"];
    
    //Download interface elements
    [self downloadElements];

    
}



-(NSArray *)setCategoriesInPreferences
{
NSMutableArray *temp = [NSMutableArray array];

int length = [[configurator.categories valueForKey:@"orden"] count];
for (int i=1; i<length-1;i++) {
    int cat;
    int nSlide;
    if (i==1) {
        cat = i;
        nSlide = [[[configurator.categories valueForKey:@"number_of_slides"] objectAtIndex:i]intValue] ;
    }else {
        cat = cat + nSlide ;
        nSlide = [[[configurator.categories valueForKey:@"number_of_slides"] objectAtIndex:i]intValue] ;
    }
    [temp addObject:[NSValue valueWithRange:NSMakeRange(cat,nSlide)]];
}


NSMutableArray *dict = [NSMutableArray array];
int len = [temp count];
    for (int i=0; i<len; i++) {
            NSValue *tmp = [temp objectAtIndex:i];
            NSNumber *val=[NSNumber numberWithInt:[tmp rangeValue].length] ;
            
            NSString *key=[NSString stringWithFormat:@"%d",[tmp rangeValue].location];
            NSString *cadena = key;
            cadena = [cadena stringByAppendingString:@","];
            cadena = [cadena stringByAppendingString:[val stringValue]];
            
            [dict addObject:cadena];
    }
    return dict;
}


-(NSArray *)setSlidesInPreferences
{
    NSMutableArray *tempo = [NSMutableArray array];;
    for (int i=0; i<[[configurator.slides valueForKey:@"name"] count]; i++) {
        for (int j=0; j<[[[configurator.slides valueForKey:@"name"] objectAtIndex:i]count]; j++) {
            [tempo addObject:[[[configurator.slides valueForKey:@"name"] objectAtIndex:i]objectAtIndex:j]];
        }
    } 
    return tempo;
}

-(void)setPDFDefaults
{
    NSMutableArray *ipp = [NSMutableArray array];
    NSMutableArray *ref = [NSMutableArray array];
    NSMutableArray *est = [NSMutableArray array];    
    for (int i=0; i<[configurator.pdfs count]; i++) {
        id pdf = [configurator.pdfs objectAtIndex:i];
        if ([[pdf valueForKey:@"pdf_type"] isEqualToString:@"IPP"]) {
            [ipp addObject:[pdf valueForKey:@"name"]];
        }else if ([[pdf valueForKey:@"pdf_type"] isEqualToString:@"Referencia"]){
            [ref addObject:[pdf valueForKey:@"name"]];
        }else {
            [est addObject:[pdf valueForKey:@"name"]];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:ipp forKey:@"IPP"];
    [[NSUserDefaults standardUserDefaults] setObject:ref forKey:@"REF"];
    [[NSUserDefaults standardUserDefaults] setObject:est forKey:@"EST"];    
}

-(void)downloadElements
{
    
    BOOL force = [[NSUserDefaults standardUserDefaults] boolForKey:@"update_interface_preference"];
    BOOL force2 = [[NSUserDefaults standardUserDefaults] boolForKey:@"update_slides_preference"];
    if(!configurator.isUpdated || force){
        
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        path = [path stringByAppendingPathComponent:@"resources"];
        NSError *error;	
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory exist?
        {
            if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])	//Delete it
            {
                NSLog(@"Delete directory error: %@", error);
            }
        }
        
        
        [self downloadWithStringURL:[configurator.interfaceURL valueForKey:@"backgrounds_url"] withDir:@"resources"];
        [self downloadWithStringURL:[configurator.interfaceURL valueForKey:@"btn_url"]withDir:@"resources"];
        [self downloadWithStringURL:[configurator.interfaceURL valueForKey:@"nav_btn_url"]withDir:@"resources"];
        [self downloadWithStringURL:[configurator.interfaceURL valueForKey:@"over_btn_url"]withDir:@"resources"];        
        [self updateServer:configurator.editURL];
        
    }
    if(!configurator.isUpdated || force2) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        path = [path stringByAppendingPathComponent:@"slides"];
        NSError *error;	
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])	
        {
            if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])	
            {
                NSLog(@"Delete directory error: %@", error);
            }
        }
        for (int i=0; i<[[configurator.slides valueForKey:@"url"] count]; i++) {
            for (int j=0; j<[[[configurator.slides valueForKey:@"url"] objectAtIndex:i]count]; j++) {
                [self downloadWithStringURL:[[[configurator.slides valueForKey:@"url"] objectAtIndex:i]objectAtIndex:j] withDir:@"slides"];
            }
        }
        
        for (int i=0; i<[configurator.pdfs count]; i++) {
            id pdf = [configurator.pdfs objectAtIndex:i];
            [self downloadWithStringURL:[pdf valueForKey:@"url"] withDir:@"slides"];
            
        }
        
    }
    
    
    
    NSLog(@"Descarga Completa");
}


- (void) downloadWithStringURL:(NSString *)urlString withDir:(NSString *) dir{
    NSString *urlAsString = urlString;
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url]; 
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest 
                                       queue:queue 
                           completionHandler:^(NSURLResponse *response,NSData *data, NSError *error) 
    {
         if ([data length] >0 && error == nil)
         {
             /* Get the documents directory */
             NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                           NSUserDomainMask,
                                                                           YES) objectAtIndex:0];
             /* Append the file name to the documents directory */
             NSFileManager *filemgr =[NSFileManager defaultManager];

             NSString *newDir = [documentsDir stringByAppendingPathComponent:dir];
             if ([filemgr createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error: NULL] == NO)
             {
                 NSLog(@"Failure in creating directory");
             }
             
             NSString *filePath = [newDir stringByAppendingPathComponent:[url lastPathComponent]];
             /* Write the data to the file */ 
             [data writeToFile:filePath atomically:YES];
             NSLog(@"Successfully saved the file to %@", filePath);
             [self unzip:filePath];  
             pending++;
            [self performSelectorOnMainThread:@selector(downloadComplete) withObject:nil waitUntilDone:YES];
         }
         else if ([data length] == 0 && error == nil)
         { 
             NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil)
         {
             NSLog(@"Error happened = %@", error); 
         }
     }];


}

- (void) updateServer:(NSString*)url{

    NSString *fix = [url stringByDeletingLastPathComponent];
        NSLog(@"url:%@",fix);
    NSURL *rURL = [NSURL URLWithString:fix];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:rURL]; 
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"PUT"];
    NSString *body = @"interface[updated_device=1&commit=Update Interface"; 
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest 
                                       queue:queue
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *error) 
    {
                               
         if ([data length] >0 && error == nil)
         {
            // NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSLog(@"Servidor actualizado"); 

         }
                               
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"Nothing was downloaded.");
                               
         }
                               
         else if (error != nil)
         {
                                   
             NSLog(@"Error happened = %@", error); 
         }
                               
    }];
    
}


- (void)unzip:(NSString *)filePath
{
    

    NSString *newDir = [filePath stringByDeletingLastPathComponent];
    NSFileManager *filemgr =[NSFileManager defaultManager];

    if ([filemgr fileExistsAtPath:filePath] && [[filePath pathExtension] isEqualToString:@"zip"])
    {


        [SSZipArchive unzipFileAtPath:filePath toDestination:newDir];
        
        [filemgr removeItemAtPath:filePath error:NULL];
        NSLog(@"Succes in unzipping:%@",[filePath lastPathComponent]);

        
    }    
}

-(NSString *)brandName
{
    return configurator.brandName;
}

-(NSArray *)brandCategories
{
    return configurator.categories;
}

-(NSArray *)brandSlides
{
    return configurator.slides;
}

-(void)splashIsDone

{
    NSLog(@"Descarga finalizada");
}

-(void)downloadComplete
{
    int totalNumberOfDocuments = [configurator.pdfs count]+4+[configurator.slides count];
    NSLog(@"%d",totalNumberOfDocuments);
        NSLog(@"%d",[configurator.pdfs count]);
        NSLog(@"%d",[configurator.slides count]);    
        NSLog(@"%d",configurator.numberOfCategories);        
        NSLog(@"%d",pending);            
    if (pending==totalNumberOfDocuments) {
        if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(downloaderDidFinish)]) {
            [delegate performSelector:@selector(downloaderDidFinish)];
        }
    }
    
}




@end

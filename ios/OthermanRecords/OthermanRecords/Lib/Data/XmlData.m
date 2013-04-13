//
//  XmlData.m
//  OthermanRecords
//
//  Created by Ca5 on 13/02/04.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "XmlData.h"
#import "Setting.h"

@implementation XmlData
{
    NSString *_file_path;
    NSString *_file_name;
    NSString *_url_str;
    id<XmlDataDelegate> _delegate;
}

NSURLConnection *connection = nil;
NSMutableData *async_data = nil;
NSString *raw_string = nil;
BOOL use_cache = YES;

@synthesize currentXpath;
@synthesize statuses;
@synthesize currentStatus;
@synthesize textNodeCharacters;

- (id)initWithFilename:(NSString *)file_name url_str:(NSString *)url_str delegate:(id<XmlDataDelegate>)delegate
{
    _file_name = file_name;
    _file_path = [NSString stringWithFormat:@"%@/%@/%@", NSHomeDirectory(), @"Documents", _file_name];
    _url_str = url_str;
    _delegate = delegate;
    return [super init];
}

- (BOOL)loadWithCache:(BOOL)cache
{
    use_cache = cache;
    [self loadRemoteFile];
    return YES;
}

- (BOOL)clear
{
    [super clear];
    if(![[NSFileManager defaultManager] fileExistsAtPath:_file_path]){
        return YES;
    }
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:_file_path error:&error];
    if(error){
        NSLog(@"[ERR]clear error: %@", [error localizedDescription]);
        return NO;
    }
    return YES;
}

- (void) loadRemoteFile
{
    // async connection
    NSURL *url = [NSURL URLWithString:_url_str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    connection = [
                  [NSURLConnection alloc]
                  initWithRequest : request
                  delegate : self
                  ];
    if (connection==nil) {
        UIAlertView *alert = [
                              [UIAlertView alloc]
                              initWithTitle : @"ConnectionError"
                              message : @"ConnectionError"
                              delegate : nil
                              cancelButtonTitle : @"OK"
                              otherButtonTitles : nil
                              ];
        [alert show];
    }
}

-(void) loadLocalFile
{
    NSData *raw_data = [[NSData alloc] initWithContentsOfFile:_file_path];
    NSArray *dlist = [self parseStatuses:raw_data];
    [self setList:(NSMutableArray *)dlist];
    [_delegate didFinishLoading];
}

- (void) saveLocalFile:(NSString *)raw_data
{
    NSError *error = nil;
    [raw_data writeToFile:_file_path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(error){
        NSLog(@"[ERR]save local file error: %@", [error localizedDescription]);
    }
}

/* async connection delegated methods */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    if(!use_cache || ![[NSFileManager defaultManager] fileExistsAtPath:_file_path]){
        //force to load remote xml
        async_data = [[NSMutableData alloc] initWithData:0];
    }else{
        //load remote xml if modified
        NSString *lastModifiedString = nil;  
        if ([response respondsToSelector:@selector(allHeaderFields)]) {  
            lastModifiedString = [[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Last-Modified"];  
        }
        
        NSDate *lastModifiedServer = nil;  
        @try {  
            NSDateFormatter *df = [[NSDateFormatter alloc] init];  
            df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";  
            df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];  
            lastModifiedServer = [df dateFromString:lastModifiedString];  
        }  
        @catch (NSException * e) {  
            NSLog(@"Error parsing last modified date: %@ - %@", lastModifiedString, [e description]);  
        }          
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDate *lastModifiedLocal = nil;
        if ([fileManager fileExistsAtPath:_file_path]) {  
            NSError *error = nil;  
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:_file_path error:&error];  
            if (error) {  
                NSLog(@"Error reading file attributes for: %@ - %@", _file_path, [error localizedDescription]);  
            }  
            lastModifiedLocal = [fileAttributes fileModificationDate];  
        }
        if([lastModifiedLocal laterDate:lastModifiedServer] != lastModifiedServer){
            NSLog(@"[INFO]use local file : %@", lastModifiedLocal);  

            [connection cancel];
            [super clear]; // clear old datas
            [self loadLocalFile];
        }else{
            async_data = [[NSMutableData alloc] initWithData:0];
            [super clear]; // clear old data
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [async_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSString *error_str = [error localizedDescription];
    NSLog(@"[ERR]connection error:%@", error_str);
    [_delegate didFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    int enc_arr[] = {
        NSUTF8StringEncoding,			// UTF-8
        NSShiftJISStringEncoding,		// Shift_JIS
        NSJapaneseEUCStringEncoding,	// EUC-JP
        NSISO2022JPStringEncoding,		// JIS
        NSUnicodeStringEncoding,		// Unicode
        NSASCIIStringEncoding			// ASCII
    };
    
    NSString *raw_string = nil;
    int max = sizeof(enc_arr) / sizeof(enc_arr[0]);
    for (int i=0; i<max; i++) {
        raw_string = [
                    [NSString alloc]
                    initWithData : async_data
                    encoding : enc_arr[i]
                    ];
        if (raw_string!=nil) {
            break;
        }
    }
    [self saveLocalFile:raw_string];
    NSArray *dlist = [self parseStatuses:async_data];
    [self setList:(NSMutableArray *)dlist];
    [_delegate didFinishLoading];
}
/* async connection delegated methods -end */


/* XMLParser delegated methods */
- (void) parserDidStartDocument:(NSXMLParser *)parser {
    self.currentXpath = [[NSMutableString alloc] init];
    self.statuses = [[NSMutableArray alloc] init];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    //should be overridden
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

    //should be overridden
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.textNodeCharacters appendString:string];
}
/* XMLParser delegated methods -end */

- (NSArray *) parseStatuses:(NSData *)xmlData {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    [parser setDelegate:self];
    [parser parse];
    
    
    //sort sample.... sort by "track"
    //should be overridden if need sort
    /*
     NSSortDescriptor *sortDescNumber;
     sortDescNumber = [[NSSortDescriptor alloc] initWithKey:@"track" ascending:YES];
     NSArray *sortDescArray;
     sortDescArray = [NSArray arrayWithObjects:sortDescNumber, nil];
     NSArray *sortArray;
     sortArray = [self.statuses sortedArrayUsingDescriptors:sortDescArray];
     
     
     return sortArray;
     */
    
    return self.statuses;
}

@end


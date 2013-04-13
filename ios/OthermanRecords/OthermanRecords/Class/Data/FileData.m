//
//  FileData.m
//  OthermanRecords
//
//  Created by ca54makske on 13/03/02.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "FileData.h"
#import "MultiRequestOperation.h"

@implementation FileData
{
    NSString *_dir;
    id<FileDataDelegate> _delegate;
    NSURLConnection *_connection;
    NSMutableData *_async_data;
    NSString *_raw_string;
    BOOL _use_cache;
    NSOperationQueue *_queue;
}

- (id)initWithDirname:(NSString *)lastdir delegate:(id<FileDataDelegate>)delegate
{
    _dir = [NSString stringWithFormat:@"%@/%@/%@", NSHomeDirectory(), @"Documents", lastdir];
    _delegate = delegate;
    return [super init];
}

- (BOOL)loadWithURL:(NSURL *)url filename:(NSString*)filename cache:(BOOL)cache
{
    _use_cache = cache;
    [self loadRemoteFile:url];
    return YES;
}

- (BOOL)clear
{
    [super clear];
    if(![[NSFileManager defaultManager] fileExistsAtPath:_dir]){
        return YES;
    }
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[_dir stringByAppendingString:@"/*"] error:&error];
    if(error){
        NSLog(@"[ERR]clear error: %@", [error localizedDescription]);
        return NO;
    }
    return YES;
}

- (BOOL)removeWithFileName:(NSString *)file_name
{
    [super clear];
    NSString *filepath = [_dir stringByAppendingFormat:@"/%@", file_name];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filepath]){
        return YES;
    }
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[_dir stringByAppendingFormat:@"/%@", file_name] error:&error];
    if(error){
        NSLog(@"[ERR]remove error: FileName:%@ Error:%@", file_name, [error localizedDescription]);
        return NO;
    }
    return YES;
}

- (void) loadRemoteFile:(NSURL *)url filename:(NSString *)filename 
{
    NSString *filepath = [_dir stringByAppendingFormat:@"/%@", filename];
    if(_use_cache || ![[NSFileManager defaultManager] fileExistsAtPath:filepath]){
        MultiRequestOperation *mro = [[MultiRequestOperation alloc] initWithURL:url];
        if(!_queue){
            _queue = [[NSOperationQueue alloc] init];
        }
        
        [mro addObserver:self forKeyPath:@"isFinished"
                 options:NSKeyValueObservingOptionNew context:(__bridge void *)filename];
        [_queue addOperation:mro];
    }else{
        [self loadLocalFile:filename];
    }
}

-(void) loadLocalFile:(NSString *)filename
{
    NSString *filepath = [_dir stringByAppendingFormat:@"/%@", filename];
    NSData *raw_data = [[NSData alloc] initWithContentsOfFile:filepath];
    int index = [[self valueForKeyPath:@"filename"] indexOfObject:filename];
    if(index == NSNotFound) {
        [self addObject:[NSDictionary dictionaryWithObjectsAndKeys:raw_data, filename, nil]];
    }else{
        NSMutableDictionary *dic = (NSMutableDictionary *)[self objectAtIndex:index];
        [dic setObject:raw_data forKey:filename];
    }
    //[_delegate didFinishLoading];
}

- (void) saveLocalFile:(NSString *)raw_data
{
    NSError *error = nil;
    [raw_data writeToFile:_dir atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(error){
        NSLog(@"[ERR]save local file error: %@", [error localizedDescription]);
    }
}

/* async connection delegated methods */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    if(!_use_cache || ![[NSFileManager defaultManager] fileExistsAtPath:_dir]){
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
        if ([fileManager fileExistsAtPath:_dir]) {
            NSError *error = nil;
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:_dir error:&error];
            if (error) {
                NSLog(@"Error reading file attributes for: %@ - %@", _dir, [error localizedDescription]);
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


@end

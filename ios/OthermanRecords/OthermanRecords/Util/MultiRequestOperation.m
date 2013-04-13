//
//  MultiRequestOperation.m
//  OthermanRecords
//
//  Created by ca54makske on 13/02/28.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "MultiRequestOperation.h"

@implementation MultiRequestOperation
{
    NSMutableData *_data;
    BOOL _isExecuting, _isFinished;
    NSURL *_url;
}
@synthesize data = _data;

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString*)key {
    if ([key isEqualToString:@"isExecuting"] ||
        [key isEqualToString:@"isFinished"]) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return _isExecuting;
}

- (BOOL)isFinished {
    //NSLog(@"isFinished %@", _opeid);
    return _isFinished;
}

- (id) initWithURL:(NSURL *)url
{
    _url = url;    
    _isExecuting = NO;
    _isFinished = NO;
    return [super init];
}

- (void) start
{
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isExecuting"];
    // async connection
    NSURLRequest *request = [NSURLRequest requestWithURL:_url];
    NSURLConnection *connection = [
                                   [NSURLConnection alloc]
                                   initWithRequest : request
                                   delegate : self
                                   ];
    if (connection != nil) {
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate distantFuture]];
        } while (_isExecuting);
    }else{
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



/* async connection delegated methods */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _data = [[NSMutableData alloc] initWithData:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"];
    NSString *error_str = [error localizedDescription];
    NSLog(@"[ERR]thumbnail connection error:%@", error_str);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {     
     [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
     [self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"];
}


@end

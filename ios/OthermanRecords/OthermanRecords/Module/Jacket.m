//
//  Jacket.m
//  OthermanRecords
//
//  Created by ca54makske on 13/03/02.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "Jacket.h"
#import "MultiRequestOperation.h"

@implementation Jacket
{
    NSOperationQueue *_queue;
    NSMutableDictionary *_list;
}
id<JacketDelegate> jacketDelegate = nil;



+(Jacket *)instanceWithDelegate:(id<JacketDelegate>) delegate
{
    jacketDelegate = delegate;
    static dispatch_once_t pred;
    static Jacket *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[[self class] alloc] init];
    });
    return shared;
}

-(id)init
{
    AlbumList *album = [AlbumList instanceWithDelegate:self];
    if([album count] == 0){
        [album load];
    }
    _list = [NSMutableDictionary dictionary];
    return [super init];
}

-(void)load
{
    [self loadWithCache:YES];
}

-(void)loadWithCache:(BOOL)cache
{
    AlbumList *album = [AlbumList instanceWithDelegate:self];
    for(int i = 0; i < [album count]; i++ ){
        NSString *cutnum = [[album objectAtIndex:i] objectForKey:@"cutnum"];
        if(cache && [_list objectForKey:cutnum]){
            NSLog(@"skip load image");
            continue;
        }
        NSURL *jacketurl = [album jacketURLWithCutnum:cutnum];
        MultiRequestOperation *mro = [[MultiRequestOperation alloc] initWithURL:jacketurl];
        if(!_queue){
            _queue = [[NSOperationQueue alloc] init];
        }
        
        [mro addObserver:self forKeyPath:@"isFinished"
                 options:NSKeyValueObservingOptionNew context:(__bridge void *)(cutnum)];
        [_queue addOperation:mro];
    }
}

- (UIImage *)imageWithCutnum:(NSString *)cutnum
{
    if(![_list objectForKey:cutnum]){
        return [UIImage imageNamed:@"noimage.jpg"];
    }else{
        return[_list objectForKey:cutnum];
    }
}


- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object
                        change:(NSDictionary*)change context:(void*)context
{
    NSString *cutnum = (__bridge NSString *)context;

    [_list setObject:[[UIImage alloc] initWithData:((MultiRequestOperation *)object).data] forKey:cutnum];
    [object removeObserver:self forKeyPath:keyPath];
    [jacketDelegate jacketDidFinishLoadingWithCutnum:cutnum];
}



/**************** delegated from AlbumList	****************/
-(void) albumDidFailWithError:(NSError *)error
{
    [jacketDelegate jacketDidFailWithError:error];
}

-(void) albumDidFinishLoading
{
    //do nothing
}
@end

//
//  MultiRequestOperation.h
//  OthermanRecords
//
//  Created by ca54makske on 13/02/28.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultiRequestOperation : NSOperation

@property NSMutableData *data;

- (id) initWithURL:(NSURL *)url;


@end

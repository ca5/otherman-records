//
//  Jacket.h
//  OthermanRecords
//
//  Created by ca54makske on 13/03/02.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlbumList.h"

@protocol JacketDelegate
-(void) jacketDidFailWithError:(NSError *)error;
-(void) jacketDidFinishLoadingWithCutnum:(NSString *)cutnum;
@end

@interface Jacket : NSObject <AlbumDelegate>
+(Jacket *)instanceWithDelegate:(id<JacketDelegate>) delegate;
-(void)load;
-(void)loadWithCache:(BOOL)cache;
-(UIImage *)imageWithCutnum:(NSString *)cutnum;


@end

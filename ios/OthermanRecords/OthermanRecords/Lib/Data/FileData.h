//
//  FileData.h
//  OthermanRecords
//
//  Created by ca54makske on 13/03/02.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "Data.h"
@protocol FileDataDelegate
-(void) didFailWithError:(NSError *)error;
-(void) didFinishLoading;
@end

@interface FileData : Data

@end

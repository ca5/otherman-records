//
//  XmlData.h
//  OthermanRecords
//
//  Created by Ca5 on 13/02/04.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Data.h"
@protocol XmlDataDelegate
-(void) didFailWithError:(NSError *)error;
-(void) didFinishLoading;
@end


@interface XmlData : Data <NSXMLParserDelegate>
{
    NSString *_file_path;
    NSString *_file_name;
    NSString *_url_str;
    id _delegate;

}
@property (retain , nonatomic) NSMutableString *currentXpath;
@property (retain , nonatomic) NSMutableArray *statuses;
@property (retain , nonatomic) NSMutableDictionary *currentStatus;
@property (retain , nonatomic) NSMutableString *textNodeCharacters;
//@property (retain , nonatomic) NSArray *list;

- (id)initWithFilename:(NSString *)file_name url_str:(NSString *)url_str delegate:(id<XmlDataDelegate>)delegate;
- (NSArray *) parseStatuses:(NSData *)xmlData;


@end

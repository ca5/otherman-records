//
//  Track.m
//  OthermanRecords
//
//  Created by Ca5 on 13/02/05.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "TrackList.h"
#import "Setting.h"



@implementation TrackList
id<TrackDelegate> trackDelegate = nil;
NSString * cutnum = nil;
NSString * date = nil;


+(TrackList *)instanceWithDelegate:(id<TrackDelegate>) delegate
{
    trackDelegate = delegate;
    static dispatch_once_t pred;
    static TrackList *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[[self class] alloc] init];
    });
    return shared;
}

-(id)init
{
    return [super initWithFilename:RELEASES_XML_FILE url_str:RELEASES_XML_URL delegate:self];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    [self.currentXpath appendString: elementName];
    [self.currentXpath appendString: @"/"];
    
    
    
    self.textNodeCharacters = [[NSMutableString alloc] init];
    if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/"]) {
        self.currentStatus = [[NSMutableDictionary alloc] init];
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSString *textData = [self.textNodeCharacters stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/"]) {
        [self.currentStatus setValue:cutnum forKey:@"cutnum"];
        [self.currentStatus setValue:cutnum forKey:@"date"];
        [self.statuses addObject:self.currentStatus];
        self.currentStatus = nil;
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/mtime/"]) {
        [self.currentStatus setValue:textData forKey:@"mtime"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/md5/"]) {
        [self.currentStatus setValue:textData forKey:@"md5"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/title/"]) {
        [self.currentStatus setValue:textData forKey:@"title"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/creator/"]) {
        [self.currentStatus setValue:textData forKey:@"creator"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/track/"]) {
        [self.currentStatus setValue:textData forKey:@"track"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/filename/"]) {
        [self.currentStatus setValue:textData forKey:@"filename"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/num/"]) {
        [self.currentStatus setValue:textData forKey:@"num"];
    }else if ([self.currentXpath isEqualToString: @"releases/release/cutnum/"]) {
        cutnum = textData;
    }else if ([self.currentXpath isEqualToString: @"releases/release/date/"]) {
        date = textData;
    }
    
    int delLength = [elementName length] + 1;
    int delIndex = [self.currentXpath length] - delLength;
    
    [self.currentXpath deleteCharactersInRange:NSMakeRange(delIndex,delLength)];
}

-(void)didFinishLoading
{
    NSLog(@"didFinishLoading(from XmlDataDelegate)");
    [self sort];
    [trackDelegate trackDidFinishLoading];
}

-(void)didFailWithError:(NSError *)error
{
    [trackDelegate didFailWithError:error];
}

- (NSArray *)listWithCutnum:(NSString *)cutnum
{
    NSMutableArray *result = [NSMutableArray array];
    for(int n = 0; n < [self count]; n ++){
        if([cutnum isEqualToString:[[self objectAtIndex:n] objectForKey:@"cutnum"]]){
            [result addObject:[self objectAtIndex:n]];
        }
    }
    return result;
}

- (NSDictionary *)trackWithCutnum:(NSString *)cutnum tracknum:(NSString *)tracknum;
{
    NSArray *list = [self listWithCutnum:cutnum];
    for(int n = 0; n < [list count]; n ++){
        if([tracknum isEqualToString:[[list objectAtIndex:n] objectForKey:@"num"]]){
            return [list objectAtIndex:n];
        }
    }
    return nil;
}

- (NSURL *)trackURLWithCutnum:(NSString *)cutnum tracknum:(NSString *)tracknum
{
    return [NSURL URLWithString:
            [[self trackWithCutnum:cutnum tracknum:tracknum] objectForKey:@"filename"]];
}


-(void)sort
{
    [self setList:[[self sortedArrayUsingFunction:comparator context:nil] mutableCopy]];
}

int comparator(id val1, id val2, void *context)
{
    //compare date
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY/MM/dd"];
    NSDate *date1 = [df dateFromString:[(NSDictionary *)val1 objectForKey:@"date"]];
    NSDate *date2 = [df dateFromString:[(NSDictionary *)val2 objectForKey:@"date"]];
    
    NSComparisonResult result = [date1 compare:date2];
    switch(result){
        case NSOrderedSame:
            // date1 = date2
            break;
            
        case NSOrderedAscending:
        case NSOrderedDescending:
            // date1 != date2
            return result;
    }
    
    //compare cutnum
    NSString *cutnum1 = [(NSDictionary *)val1 objectForKey:@"cutnum"];
    NSString *cutnum2 = [(NSDictionary *)val2 objectForKey:@"cutnum"];
    result = [cutnum1 compare:cutnum2];
    switch(result){
        case NSOrderedSame:
            // cutnum1 = cutnum2
            break;
            
        case NSOrderedAscending:
        case NSOrderedDescending:
            // cutnum1 != cutnum2
            return result;
    }
    
    //compare tracknum
    float num1 = [[(NSDictionary *)val1 objectForKey:@"num"] floatValue];
    float num2 = [[(NSDictionary *)val2 objectForKey:@"num"] floatValue];
    if(num1 < num2){
        return NSOrderedAscending;
    } else if (num1 < num2){
        return NSOrderedDescending;
    }else{
        return NSOrderedSame;
    }
}


@end

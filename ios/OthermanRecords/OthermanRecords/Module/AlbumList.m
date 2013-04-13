//
//  Album.m
//  OthermanRecords
//
//  Created by Ca5 on 13/02/06.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "AlbumList.h"
#import "Setting.h"

@implementation AlbumList
id<AlbumDelegate> albumDelegate = nil;


+(AlbumList *)instanceWithDelegate:(id<AlbumDelegate>) delegate
{
    albumDelegate = delegate;
    static dispatch_once_t pred;
    static AlbumList *shared = nil;
    
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
    if ([self.currentXpath isEqualToString: @"releases/release/"]) {
        self.currentStatus = [[NSMutableDictionary alloc] init];
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSString *textData = [self.textNodeCharacters stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([self.currentXpath isEqualToString: @"releases/release/"]) {
        [self.statuses addObject:self.currentStatus];
        self.currentStatus = nil;
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/description/"]) {
        NSString *description = [[textData stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<![CDATA["]] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"]]>"]];

        [self.currentStatus setValue:description forKey:@"description"];

        
    } else if ([self.currentXpath isEqualToString: @"releases/release/cutnum/"]) {
        [self.currentStatus setValue:textData forKey:@"cutnum"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/album/"]) {
        [self.currentStatus setValue:textData forKey:@"album"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/artists/"]) {
        [self.currentStatus setValue:textData forKey:@"artists"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/jacket/"]) {
        [self.currentStatus setValue:textData forKey:@"jacket"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/thumbnail/"]) {
        [self.currentStatus setValue:textData forKey:@"thumbnail"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/date/"]) {
        [self.currentStatus setValue:textData forKey:@"date"];
        
    }
    
    int delLength = [elementName length] + 1;
    int delIndex = [self.currentXpath length] - delLength;
    
    [self.currentXpath deleteCharactersInRange:NSMakeRange(delIndex,delLength)];
}

- (NSArray *) parseStatuses:(NSData *)xmlData {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    [parser setDelegate:self];
    [parser parse];
    
    //sort
    NSSortDescriptor *sortDescNumber;
    sortDescNumber = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescArray;
    sortDescArray = [NSArray arrayWithObjects:sortDescNumber, nil];
    NSArray *sortArray;
    sortArray = [self.statuses sortedArrayUsingDescriptors:sortDescArray];
     
     
     return sortArray;
     //return self.statuses;
}

-(void)didFinishLoading
{
    [albumDelegate albumDidFinishLoading];
}

-(void)didFailWithError:(NSError *)error
{
    [albumDelegate albumDidFailWithError:error];
}

- (NSDictionary *)albumWithCutnum:(NSString *)cutnum
{
    for(int n = 0; n < [self count]; n ++){
        if([cutnum isEqualToString:[[self objectAtIndex:n] objectForKey:@"cutnum"]]){
            return [self objectAtIndex:n];
        }
    }
    return nil;
}

- (NSURL *)jacketURLWithCutnum:(NSString *)cutnum
{
    return [NSURL URLWithString:[[self albumWithCutnum:cutnum] objectForKey:@"jacket"]];
}

- (NSURL *)thumbnailURLWithCutnum:(NSString *)cutnum
{
    return [NSURL URLWithString:[[self albumWithCutnum:cutnum] objectForKey:@"tumbnail"]];

}
@end

//
//  Track.m
//  OthermanRecords
//
//  Created by Ca5 on 13/02/05.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "Track.h"
#import "Setting.h"

@implementation Track
id<TrackDelegate> trackDelegate = nil;


+(Track *)getInstance:(id<TrackDelegate>) delegate
{
    trackDelegate = delegate;
    static dispatch_once_t pred;
    static Track *shared = nil;
    
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
        [self.statuses addObject:self.currentStatus];
        self.currentStatus = nil;
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/mtime/"]) {
        [self.currentStatus setValue:textData forKey:@"mtime"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/md5/"]) {
        [self.currentStatus setValue:textData forKey:@"md5"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/title/"]) {
        [self.currentStatus setValue:textData forKey:@"title"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/md5/"]) {
        [self.currentStatus setValue:textData forKey:@"md5"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/creator/"]) {
        [self.currentStatus setValue:textData forKey:@"creator"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/track/"]) {
        [self.currentStatus setValue:textData forKey:@"track"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/filename/"]) {
        [self.currentStatus setValue:textData forKey:@"filename"];
        
    } else if ([self.currentXpath isEqualToString: @"releases/release/tracks/track/cutnum/"]) {
        [self.currentStatus setValue:textData forKey:@"cutnum"];
    }
    
    int delLength = [elementName length] + 1;
    int delIndex = [self.currentXpath length] - delLength;
    
    [self.currentXpath deleteCharactersInRange:NSMakeRange(delIndex,delLength)];
}

-(void)didFinishLoading
{
    NSLog(@"didFinishLoading(from XmlDataDelegate)");
    [trackDelegate didFinishLoadingTrack:self];
}

-(void)didFailWithError:(NSError *)error
{
    [trackDelegate didFailWithError:error];
}

@end

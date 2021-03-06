//
//  RSSParser.m
//
//  Created by Mike Mayo on 1/28/10.
//  Copyright Mike Mayo 2010. All rights reserved.
//

#import "RSSParser.h"
#import "FeedItem.h"


@implementation RSSParser

@synthesize feedItem, currentDataType, feedItems;

#pragma mark -
#pragma mark Date Parser

-(NSDate *)dateFromString:(NSString *)dateString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
	[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzzz"];
	NSDate *date = [dateFormatter dateFromString:dateString];
	return date;
}

#pragma mark -
#pragma mark XML Parser Delegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	
	//Extract the attribute here.
	//aBook.bookID = [[attributeDict objectForKey:@"id"] integerValue];
	
//	if (![elementName isEqualToString:@"uri"]) {
//		// if it's not the uri, it's a data type
//		currentDataType = [NSString stringWithString:elementName];
//	}
	
	if ([elementName isEqualToString:@"rss"]) {
		// we're getting started, so go ahead and alloc the array
		self.feedItems = [[NSMutableArray alloc] initWithCapacity:1];
	} else if ([elementName isEqualToString:@"item"]) {
		self.feedItem = [[FeedItem alloc] init];
		parsingItem = YES;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
//	<pubDate>Fri, 15 Jan 2010 16:16:59 -0600</pubDate>
	
	if ([elementName isEqualToString:@"item"]) {
		[self.feedItems addObject:self.feedItem];
		parsingItem = NO;
	} else if ([elementName isEqualToString:@"title"]) {		
		feedItem.title = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"link"]) {
		feedItem.link = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"guid"]) {
		feedItem.guid = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"description"]) {
		feedItem.description = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"content:encoded"]) {
		feedItem.content = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
		
		// &lt;p&gt;Huddle 16 is currently experiencing network related issue, you may see issues connecting to your server and accessing the Cloud Servers section of the control panel.&amp;#0160; The control panel may be loading slowly or timing out completely. Our technicians are working to
        // quickly resolve the issue. We will post another update once PHP 5 sites
        // are back to normal speeds.&lt;/p&gt;&lt;p&gt;&lt;/p&gt;&lt;p&gt;Update: Connectivity is returning, and all issues should begin resolving.&lt;/p&gt;
        feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"&lt;/p&gt;&lt;p&gt;" withString:@"\n\n"];        
        feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"&lt;p&gt;" withString:@""];
        feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"&lt;/p&gt;" withString:@""];
        feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"</p><p>" withString:@"\n\n"];        
        feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
        feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        
		if ([feedItem.content characterAtIndex:0] == ' ' && [feedItem.content length] > 0) {
			feedItem.content = [feedItem.content substringFromIndex:1];
		}
		
	} else if ([elementName isEqualToString:@"dc:creator"]) {
		feedItem.creator = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"pubDate"]) {
		feedItem.pubDate = [self dateFromString:[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}
	
	currentElementValue = nil;	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (!currentElementValue) {
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	} else {
		[currentElementValue appendString:string];
	}
}

#pragma mark -
#pragma mark Memory Management



@end

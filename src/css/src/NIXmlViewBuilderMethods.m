//
//  NIXmlViewBuilderFunctions.m
//  Nimbus
//
//  Created by Metral, Max on 5/14/13.
//  Copyright (c) 2013 Jeff Verkoeyen. All rights reserved.
//

#import "NIXmlViewBuilderMethods.h"
#import "UIView+NIStyleable.h"

////////////////////////////////////////////////////////////////////////////////
@interface NIUIXMLParser : NSObject <NSXMLParserDelegate>
@property (nonatomic,strong) NSMutableDictionary *result;
@property (nonatomic,strong) NSMutableArray *elementStack;
@property (nonatomic,assign) BOOL isInProperties;
@end
////////////////////////////////////////////////////////////////////////////////


NSDictionary* NIViewDictionaryFromXmlData(NSData *xml) {
  NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xml];
  NIUIXMLParser *delegate = [[NIUIXMLParser alloc] init];
  parser.delegate = delegate;
  
  BOOL success = [parser parse];
  if (success) {
    return delegate.result;
  }
  return nil;
}

NSDictionary* NIViewDictionaryFromXmlFile(NSString *xmlPath) {
  return NIViewDictionaryFromXmlData([NSData dataWithContentsOfFile:xmlPath]);
}

////////////////////////////////////////////////////////////////////////////////

@implementation NIUIXMLParser
-(id) init {
  self = [super init];
  self.elementStack = [[NSMutableArray alloc] init];
  return self;
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
  NSMutableDictionary *nd = [[NSMutableDictionary alloc] init];
  
  if (!self.result) {
    self.result = nd;
  } else {
    // This has to be inside a view.
    if ([elementName isEqualToString:@"Properties"]) {
      
    }
  }
  
  if (self.elementStack.count) {
    NSMutableDictionary *curView = [self.elementStack lastObject];
    NSMutableArray *subviews = (NSMutableArray*) [curView objectForKey:NICSSViewSubviewsKey];
    if (!subviews) {
      subviews = [[NSMutableArray alloc] init];
      [curView setObject:subviews forKey:NICSSViewSubviewsKey];
    }
    [subviews addObject:nd];
  }
  [self.elementStack addObject:nd];
  
  [nd setObject:elementName forKey:NICSSViewKey];
  if (attributeDict) {
    [attributeDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
      [nd setObject:obj forKey:key];
    }];
  }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
  NSMutableDictionary *nd = [self.elementStack lastObject];
  NSMutableString *txt = [nd objectForKey:NICSSViewTextKey];
  NSCharacterSet *ws = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
  if ([txt rangeOfCharacterFromSet:ws].location == NSNotFound) {
    [nd removeObjectForKey:NICSSViewTextKey];
  } else if (txt) {
    [nd setObject:[txt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:NICSSViewTextKey];
  }
  [self.elementStack removeLastObject];
}

-(void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
  if (self.elementStack.count == 0) { return; }
  NSString *string = [[NSString alloc] initWithData:CDATABlock encoding: NSUTF8StringEncoding];
  [self parser:parser foundCharacters:string];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  if (self.elementStack.count == 0) { return; }
  NSMutableDictionary *inProgress = [self.elementStack lastObject];
  NSMutableString *text = [inProgress objectForKey:NICSSViewTextKey];
  if (!text) {
    text = [[NSMutableString alloc] initWithString:string];
    [inProgress setObject:text forKey:NICSSViewTextKey];
  } else {
    if (![text isKindOfClass:[NSMutableString class]]) {
      text = [text mutableCopy];
    }
    [text appendString:string];
  }
}
@end


//
// Copyright 2011 Jeff Verkoeyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// See: http://bit.ly/hS5nNh for unit test macros.

#import <SenTestingKit/SenTestingKit.h>

#import "NimbusCSS.h"

@interface NICSSParserTests : SenTestCase {
@private
  NSBundle* _unitTestBundle;
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICSSParserTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUp {
  _unitTestBundle = [NSBundle bundleWithIdentifier:@"com.nimbus.css.unittests"];
  STAssertNotNil(_unitTestBundle, @"Unable to find the bundle %@", [NSBundle allBundles]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tearDown {
  _unitTestBundle = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testFailures {
  NICSSParser* parser = [[NICSSParser alloc] init];
  
  STAssertNil([parser dictionaryForPath:nil], @"Parsing nil path should result in nil.");
  STAssertNil([parser dictionaryForPath:nil pathPrefix:nil], @"Parsing nil path should result in nil.");
  STAssertNil([parser dictionaryForPath:nil pathPrefix:nil delegate:nil], @"Parsing nil path should result in nil.");
  STAssertNil([parser dictionaryForPath:@"" pathPrefix:nil], @"Parsing empty path should result in nil.");
  STAssertNil([parser dictionaryForPath:nil pathPrefix:@""], @"Parsing empty path should result in nil.");
  STAssertNil([parser dictionaryForPath:@"nonexistent_file" pathPrefix:@""], @"Parsing nonexistent file should result in nil.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testEmptyFile {
  NICSSParser* parser = [[NICSSParser alloc] init];
  
  NSString* pathToFile = NIPathForBundleResource(_unitTestBundle, @"empty.css");

  NSDictionary* rulesets = [parser dictionaryForPath:pathToFile];
  STAssertEquals([rulesets count], (NSUInteger)0, @"There should be no rule sets for an empty file.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testComments {
  NICSSParser* parser = [[NICSSParser alloc] init];
  
  NSString* pathToFile = NIPathForBundleResource(_unitTestBundle, @"comments.css");
  
  NSDictionary* rulesets = [parser dictionaryForPath:pathToFile];
  STAssertEquals([rulesets count], (NSUInteger)0, @"There should be no rule sets.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testMalformed {
  NICSSParser* parser = [[NICSSParser alloc] init];

  NSString* pathToFile = NIPathForBundleResource(_unitTestBundle, @"malformed.css");

  NSDictionary* rulesets = [parser dictionaryForPath:pathToFile];
  STAssertNil(rulesets, @"The file should have failed to process.");
  STAssertTrue(parser.didFailToParse, @"The parser should have failed.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testEmptyRulesets {
  NICSSParser* parser = [[NICSSParser alloc] init];

  NSString* pathToFile = NIPathForBundleResource(_unitTestBundle, @"empty-rulesets.css");

  NSDictionary* rulesets = [parser dictionaryForPath:pathToFile];
  STAssertEquals([rulesets count], (NSUInteger)7, @"There should be seven rule sets.");
  STAssertNotNil([rulesets objectForKey:@"#topLevelView"], @"Key should exist.");
  STAssertNotNil([rulesets objectForKey:@"#topLevelView UILabel"], @"Key should exist.");
  STAssertNotNil([rulesets objectForKey:@"UIButton"], @"Key should exist.");
  STAssertNotNil([rulesets objectForKey:@"UILabel"], @"Key should exist.");
  STAssertNotNil([rulesets objectForKey:@"UINavigationBar ContainerView UILabel"], @"Key should exist.");
  STAssertNotNil([rulesets objectForKey:@"UINavigationBar UILabel"], @"Key should exist.");
  STAssertNotNil([rulesets objectForKey:@"UITextView"], @"Key should exist.");

  for (id key in rulesets) {
    STAssertEquals([[rulesets objectForKey:key] count], (NSUInteger)1, @"All rulesets should only have the rule set order.");
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testMediaRulesets {
    NICSSParser* parser = [[NICSSParser alloc] init];
    
    NSString* pathToFile = NIPathForBundleResource(_unitTestBundle, @"media-rulesets.css");
    
    NSDictionary* rulesets = [parser dictionaryForPath:pathToFile];
   // STAssertNotNil([rulesets objectForKey:@"UIView"], @"@media tag with all known combinations didn't match one.");
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if ([UIScreen mainScreen].scale == 1.0) {
            STAssertNotNil([rulesets objectForKey:@"UINavigationBar"], @"@media tag didn't match properly.");
            STAssertNotNil([rulesets objectForKey:@"#UINavigationBar"], @"@media tag didn't match properly.");
            STAssertNil([rulesets objectForKey:@"#UITextField"], @"@media tag shouldn't have matched.");
            STAssertNil([rulesets objectForKey:@"UIButton"], @"@media tag shouldn't have matched.");
            STAssertNil([rulesets objectForKey:@"#UIButton"], @"@media tag shouldn't have matched.");
            STAssertNil([rulesets objectForKey:@"#UILabel"], @"@media tag shouldn't have matched.");
        } else {
            STAssertNotNil([rulesets objectForKey:@"UINavigationBar"], @"@media tag didn't match properly.");
            STAssertNotNil([rulesets objectForKey:@"#UITextField"], @"@media tag didn't match properly.");            
            STAssertNil([rulesets objectForKey:@"#UINavigationBar"], @"@media tag shouldn't have matched.");
            STAssertNil([rulesets objectForKey:@"UIButton"], @"@media tag shouldn't have matched.");
            STAssertNil([rulesets objectForKey:@"#UIButton"], @"@media tag shouldn't have matched.");
            STAssertNil([rulesets objectForKey:@"#UILabel"], @"@media tag shouldn't have matched.");
        }
    } else {
        if ([UIScreen mainScreen].scale == 1.0) {
            STAssertNotNil([rulesets objectForKey:@"UIButton"], @"@media tag didn't match properly.");
            STAssertNotNil([rulesets objectForKey:@"#UIButton"], @"@media tag didn't match properly.");
            STAssertNil([rulesets objectForKey:@"UINavigationBar"], @"@media tag shouldn't have matched.");
            STAssertNil([rulesets objectForKey:@"#UINavigationBar"], @"@media tag shouldn't have matched.");
            STAssertNil([rulesets objectForKey:@"#UITextField"], @"@media tag shouldn't have matched.");
            STAssertNil([rulesets objectForKey:@"#UILabel"], @"@media tag shouldn't have matched.");
        } else {
            STAssertNotNil([rulesets objectForKey:@"UIButton"], @"@media tag didn't match properly.");
            STAssertNotNil([rulesets objectForKey:@"#UILabel"], @"@media tag didn't match properly.");
            STAssertNil([rulesets objectForKey:@"UINavigationBar"], @"@media tag shouldn't have matched.");
            STAssertNil([rulesets objectForKey:@"#UINavigationBar"], @"@media tag shouldn't have matched.");
            STAssertNil([rulesets objectForKey:@"#UITextField"], @"@media tag shouldn't have matched.");
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testRulesets {
  NICSSParser* parser = [[NICSSParser alloc] init];

  NSString* pathToFile = NIPathForBundleResource(_unitTestBundle, @"rulesets.css");

  NSDictionary* rulesets = [parser dictionaryForPath:pathToFile];
  STAssertEquals([rulesets count], (NSUInteger)4, @"There should be four rule sets.");

  STAssertTrue([[[[rulesets objectForKey:@".className"] objectForKey:@"background-color"] objectAtIndex:0] isEqualToString:@"orange"], @"Value should match.");
  STAssertTrue([[[[rulesets objectForKey:@"UIButton"] objectForKey:@"color"] objectAtIndex:0] isEqualToString:@"red"], @"Value should match.");
  STAssertTrue([[[[rulesets objectForKey:@"UIButton"] objectForKey:@"height"] objectAtIndex:0] isEqualToString:@"20px"], @"Value should match.");
  STAssertTrue([[[[rulesets objectForKey:@"UIButton"] objectForKey:@"width"] objectAtIndex:0] isEqualToString:@"100%"], @"Value should match.");
  STAssertTrue([[[[rulesets objectForKey:@"UIButton:hover"] objectForKey:@"color"] objectAtIndex:0] isEqualToString:@"blue"], @"Value should match.");
  STAssertTrue([[[[rulesets objectForKey:@"UILabel"] objectForKey:@"font-size"] objectAtIndex:0] isEqualToString:@"23"], @"Value should match.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testRulesetOverrides {
  NICSSParser* parser = [[NICSSParser alloc] init];

  NSString* pathToFile = NIPathForBundleResource(_unitTestBundle, @"rulesets-overrides.css");

  NSDictionary* rulesets = [parser dictionaryForPath:pathToFile];
  STAssertEquals([rulesets count], (NSUInteger)3, @"There should be three rule sets.");

  STAssertTrue([[[[rulesets objectForKey:@".className"] objectForKey:@"background-color"] objectAtIndex:0] isEqualToString:@"green"], @"Value should match.");
  STAssertTrue([[[[rulesets objectForKey:@"UIButton"] objectForKey:@"color"] objectAtIndex:0] isEqualToString:@"black"], @"Value should match.");
  STAssertTrue([[[[rulesets objectForKey:@"UIButton"] objectForKey:@"height"] objectAtIndex:0] isEqualToString:@"20px"], @"Value should match.");
  STAssertTrue([[[[rulesets objectForKey:@"UIButton"] objectForKey:@"width"] objectAtIndex:0] isEqualToString:@"100%"], @"Value should match.");
  STAssertTrue([[[[rulesets objectForKey:@"UILabel"] objectForKey:@"font-size"] objectAtIndex:0] isEqualToString:@"50"], @"Value should match.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testImports {
  NICSSParser* parser = [[NICSSParser alloc] init];

  NSString* pathPrefix = NIPathForBundleResource(_unitTestBundle, nil);

  NSDictionary* rulesets = [parser dictionaryForPath:@"includer.css" pathPrefix:pathPrefix];
  STAssertEquals([rulesets count], (NSUInteger)2, @"There should be two values.");
  NSSet* dependencies = [rulesets objectForKey:kDependenciesSelectorKey];
  STAssertEquals(dependencies.count, (NSUInteger)1, @"Should be exactly one dependency.");
  STAssertTrue([[dependencies anyObject] isEqualToString:@"includee.css"], @"Should be equal.");

  STAssertTrue([[[[rulesets objectForKey:@"UIButton"] objectForKey:@"width"] objectAtIndex:0] isEqualToString:@"50%"], @"Value should match.");
  STAssertTrue([[[[rulesets objectForKey:@"UIButton"] objectForKey:@"height"] objectAtIndex:0] isEqualToString:@"20px"], @"Value should match.");
}

@end

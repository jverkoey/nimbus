//
// Copyright 2011-2014 NimbusKit
//
// Forked from Three20 June 10, 2011 - Copyright 2009-2011 Facebook
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

#import <XCTest/XCTest.h>

#import "NimbusCore+Additions.h"

@interface NimbusCoreAdditionTests : XCTestCase {
}

@end


@implementation NimbusCoreAdditionTests

#pragma mark - NSString Additions

- (void)testNSString_queryContentsUsingEncoding {
	NSDictionary* query;

	query = NIQueryDictionaryFromStringUsingEncoding(@"", NSUTF8StringEncoding);
	XCTAssertTrue([query count] == 0, @"Query: %@", query);

	query = NIQueryDictionaryFromStringUsingEncoding(@"q", NSUTF8StringEncoding);
	XCTAssertTrue([query[@"q"] isEqual:@[[NSNull null]]],
                @"Query: %@", query);

	query = NIQueryDictionaryFromStringUsingEncoding(@"q=", NSUTF8StringEncoding);
	XCTAssertTrue([query[@"q"] isEqual:@[@""]],
                @"Query: %@", query);

	query = NIQueryDictionaryFromStringUsingEncoding(@"q=three20", NSUTF8StringEncoding);
	XCTAssertTrue([query[@"q"] isEqual:@[@"three20"]],
                @"Query: %@", query);

	query = NIQueryDictionaryFromStringUsingEncoding(@"q=three20%20github", NSUTF8StringEncoding);
	XCTAssertTrue([query[@"q"] isEqual:@[@"three20 github"]],
                @"Query: %@", query);

	query = NIQueryDictionaryFromStringUsingEncoding(@"q=three20&hl=en", NSUTF8StringEncoding);
	XCTAssertTrue([query[@"q"] isEqual:@[@"three20"]],
                @"Query: %@", query);
	XCTAssertTrue([query[@"hl"] isEqual:@[@"en"]],
                 @"Query: %@", query);

	query = NIQueryDictionaryFromStringUsingEncoding(@"q=three20&hl=", NSUTF8StringEncoding);
	XCTAssertTrue([query[@"q"] isEqual:@[@"three20"]],
                @"Query: %@", query);
	XCTAssertTrue([query[@"hl"] isEqual:@[@""]],
                @"Query: %@", query);

	query = NIQueryDictionaryFromStringUsingEncoding(@"q=&&hl=", NSUTF8StringEncoding);
	XCTAssertTrue([query[@"q"] isEqual:@[@""]],
                @"Query: %@", query);
	XCTAssertTrue([query[@"hl"] isEqual:@[@""]],
                @"Query: %@", query);

	query = NIQueryDictionaryFromStringUsingEncoding(@"q=three20=repo&hl=en", NSUTF8StringEncoding);
	XCTAssertNil(query[@"q"], @"Query: %@", query);
	XCTAssertTrue([query[@"hl"] isEqual:@[@"en"]],
                @"Query: %@", query);

	query = NIQueryDictionaryFromStringUsingEncoding(@"&&", NSUTF8StringEncoding);
	XCTAssertTrue([query count] == 0, @"Query: %@", query);

	query = NIQueryDictionaryFromStringUsingEncoding(@"q=foo&q=three20", NSUTF8StringEncoding);
	NSArray* qArr = @[@"foo", @"three20"];
	XCTAssertTrue([query[@"q"] isEqual:qArr], @"Query: %@", query);

	query = NIQueryDictionaryFromStringUsingEncoding(@"q=foo&q=three20&hl=en", NSUTF8StringEncoding);
	qArr = @[@"foo", @"three20"];
	XCTAssertTrue([query[@"q"] isEqual:qArr], @"Query: %@", query);
	XCTAssertTrue([query[@"hl"] isEqual:@[@"en"]],
                @"Query: %@", query);

	query = NIQueryDictionaryFromStringUsingEncoding(@"q=foo&q=three20&hl=en&g", NSUTF8StringEncoding);
	qArr = @[@"foo", @"three20"];
	XCTAssertTrue([query[@"q"] isEqual:qArr], @"Query: %@", query);
	XCTAssertTrue([query[@"hl"] isEqual:@[@"en"]],
                @"Query: %@", query);
	XCTAssertTrue([query[@"g"] isEqual:@[[NSNull null]]],
                @"Query: %@", query);

	query = NIQueryDictionaryFromStringUsingEncoding(@"q&q=three20&hl=en&g", NSUTF8StringEncoding);
	qArr = @[[NSNull null], @"three20"];
	XCTAssertTrue([query[@"q"] isEqual:qArr], @"Query: %@", query);
	XCTAssertTrue([query[@"hl"] isEqual:@[@"en"]],
                @"Query: %@", query);
}

- (void)testNSString_stringByAddingQueryDictionary {
  NSString* baseUrl = @"http://google.com/search";
  XCTAssertTrue([NIStringByAddingQueryDictionaryToString(baseUrl, nil) isEqualToString:
                [baseUrl stringByAppendingString:@"?"]], @"Empty dictionary fail.");

  XCTAssertTrue([NIStringByAddingQueryDictionaryToString(baseUrl, @{}) isEqualToString:
                [baseUrl stringByAppendingString:@"?"]], @"Empty dictionary fail.");

  XCTAssertTrue([NIStringByAddingQueryDictionaryToString(baseUrl, @{@"q":@"three20"}) isEqualToString:
                [baseUrl stringByAppendingString:@"?q=three20"]], @"Single parameter fail.");

  NSDictionary* query = @{@"q": @"three20",
                          @"hl": @"en"};
  NSString* baseUrlWithQuery = NIStringByAddingQueryDictionaryToString(baseUrl, query);
  XCTAssertTrue([baseUrlWithQuery isEqualToString:[baseUrl
                                                  stringByAppendingString:@"?hl=en&q=three20"]]
                || [baseUrlWithQuery isEqualToString:[baseUrl
                                                     stringByAppendingString:@"?q=three20&hl=en"]],
                @"Additional query parameters not correct. %@",
                NIStringByAddingQueryDictionaryToString(baseUrl, query));
}

- (void)testNSString_versionStringCompare {
  XCTAssertTrue(NICompareVersionStrings(@"3.0", @"3.0")      == NSOrderedSame, @"same version");
  XCTAssertTrue(NICompareVersionStrings(@"3.0a2", @"3.0a2")  == NSOrderedSame, @"same version alpha");
  XCTAssertTrue(NICompareVersionStrings(@"3.0", @"2.5")      == NSOrderedDescending, @"major no alpha");
  XCTAssertTrue(NICompareVersionStrings(@"3.1", @"3.0")      == NSOrderedDescending, @"minor no alpha");
  XCTAssertTrue(NICompareVersionStrings(@"3.0a1", @"3.0")    == NSOrderedAscending, @"alpha-no alpha");
  XCTAssertTrue(NICompareVersionStrings(@"3.0a1", @"3.0a4")  == NSOrderedAscending, @"alpha diff");
  XCTAssertTrue(NICompareVersionStrings(@"3.0a2", @"3.0a19") == NSOrderedAscending, @"numeric alpha");
  XCTAssertTrue(NICompareVersionStrings(@"3.0a", @"3.0a1")   == NSOrderedAscending, @"empty alpha");
  XCTAssertTrue(NICompareVersionStrings(@"3.02", @"3.03")    == NSOrderedAscending, @"point diff");
  XCTAssertTrue(NICompareVersionStrings(@"3.0.2", @"3.0.3")  == NSOrderedAscending, @"point diff");
}

- (void)testNSString_md5Hash {
  XCTAssertTrue([NIMD5HashFromString(@"nimbus") isEqualToString:@"0e78d66f33c484a3c3b36d69bd3114cf"],
                @"MD5 hashes don't match.");
}

- (void)testNSString_sha1Hash {
  XCTAssertTrue([NISHA1HashFromString(@"nimbus") isEqualToString:@"c1b42d95fd18ad8a56d4fd7bbb4105952620d857"],
                @"SHA1 hashes don't match.");
}

@end

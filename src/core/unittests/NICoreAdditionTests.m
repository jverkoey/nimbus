//
// Copyright 2011 Jeff Verkoeyen
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

#import <SenTestingKit/SenTestingKit.h>

#import "NimbusCore+Additions.h"

@interface NimbusCoreAdditionTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NimbusCoreAdditionTests


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSString Additions


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSString_queryContentsUsingEncoding {
	NSDictionary* query;

	query = [@"" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([query count] == 0, @"Query: %@", query);

	query = [@"q" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([[query objectForKey:@"q"] isEqual:[NSArray arrayWithObject:[NSNull null]]],
               @"Query: %@", query);

	query = [@"q=" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([[query objectForKey:@"q"] isEqual:[NSArray arrayWithObject:@""]],
               @"Query: %@", query);

	query = [@"q=three20" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([[query objectForKey:@"q"] isEqual:[NSArray arrayWithObject:@"three20"]],
               @"Query: %@", query);

	query = [@"q=three20%20github" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([[query objectForKey:@"q"] isEqual:[NSArray arrayWithObject:@"three20 github"]],
               @"Query: %@", query);

	query = [@"q=three20&hl=en" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([[query objectForKey:@"q"] isEqual:[NSArray arrayWithObject:@"three20"]],
               @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"hl"] isEqual:[NSArray arrayWithObject:@"en"]],
               @"Query: %@", query);

	query = [@"q=three20&hl=" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([[query objectForKey:@"q"] isEqual:[NSArray arrayWithObject:@"three20"]],
               @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"hl"] isEqual:[NSArray arrayWithObject:@""]],
               @"Query: %@", query);

	query = [@"q=&&hl=" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([[query objectForKey:@"q"] isEqual:[NSArray arrayWithObject:@""]],
               @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"hl"] isEqual:[NSArray arrayWithObject:@""]],
               @"Query: %@", query);

	query = [@"q=three20=repo&hl=en" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertNil([query objectForKey:@"q"], @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"hl"] isEqual:[NSArray arrayWithObject:@"en"]],
               @"Query: %@", query);

	query = [@"&&" queryContentsUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue([query count] == 0, @"Query: %@", query);

	query = [@"q=foo&q=three20" queryContentsUsingEncoding:NSUTF8StringEncoding];
	NSArray* qArr = [NSArray arrayWithObjects:@"foo", @"three20", nil];
	STAssertTrue([[query objectForKey:@"q"] isEqual:qArr], @"Query: %@", query);

	query = [@"q=foo&q=three20&hl=en" queryContentsUsingEncoding:NSUTF8StringEncoding];
	qArr = [NSArray arrayWithObjects:@"foo", @"three20", nil];
	STAssertTrue([[query objectForKey:@"q"] isEqual:qArr], @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"hl"] isEqual:[NSArray arrayWithObject:@"en"]],
               @"Query: %@", query);

	query = [@"q=foo&q=three20&hl=en&g" queryContentsUsingEncoding:NSUTF8StringEncoding];
	qArr = [NSArray arrayWithObjects:@"foo", @"three20", nil];
	STAssertTrue([[query objectForKey:@"q"] isEqual:qArr], @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"hl"] isEqual:[NSArray arrayWithObject:@"en"]],
               @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"g"] isEqual:[NSArray arrayWithObject:[NSNull null]]],
               @"Query: %@", query);

	query = [@"q&q=three20&hl=en&g" queryContentsUsingEncoding:NSUTF8StringEncoding];
	qArr = [NSArray arrayWithObjects:[NSNull null], @"three20", nil];
	STAssertTrue([[query objectForKey:@"q"] isEqual:qArr], @"Query: %@", query);
	STAssertTrue([[query objectForKey:@"hl"] isEqual:[NSArray arrayWithObject:@"en"]],
               @"Query: %@", query);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSString_stringByAddingQueryDictionary {
  NSString* baseUrl = @"http://google.com/search";
  STAssertTrue([[baseUrl stringByAddingQueryDictionary:nil] isEqualToString:
                [baseUrl stringByAppendingString:@"?"]], @"Empty dictionary fail.");

  STAssertTrue([[baseUrl stringByAddingQueryDictionary:[NSDictionary dictionary]] isEqualToString:
                [baseUrl stringByAppendingString:@"?"]], @"Empty dictionary fail.");

  STAssertTrue([[baseUrl stringByAddingQueryDictionary:[NSDictionary
                                                        dictionaryWithObject:@"three20"
                                                        forKey:@"q"]] isEqualToString:
                [baseUrl stringByAppendingString:@"?q=three20"]], @"Single parameter fail.");

  NSDictionary* query = [NSDictionary
                         dictionaryWithObjectsAndKeys:
                         @"three20", @"q",
                         @"en",      @"hl",
                         nil];
  NSString* baseUrlWithQuery = [baseUrl stringByAddingQueryDictionary:query];
  STAssertTrue([baseUrlWithQuery isEqualToString:[baseUrl
                                                  stringByAppendingString:@"?hl=en&q=three20"]]
               || [baseUrlWithQuery isEqualToString:[baseUrl
                                                     stringByAppendingString:@"?q=three20&hl=en"]],
               @"Additional query parameters not correct. %@",
               [baseUrl stringByAddingQueryDictionary:query]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSString_versionStringCompare {
  STAssertTrue([@"3.0"   versionStringCompare:@"3.0"]    == NSOrderedSame, @"same version");
  STAssertTrue([@"3.0a2" versionStringCompare:@"3.0a2"]  == NSOrderedSame, @"same version alpha");
  STAssertTrue([@"3.0"   versionStringCompare:@"2.5"]    == NSOrderedDescending, @"major no alpha");
  STAssertTrue([@"3.1"   versionStringCompare:@"3.0"]    == NSOrderedDescending, @"minor no alpha");
  STAssertTrue([@"3.0a1" versionStringCompare:@"3.0"]    == NSOrderedAscending, @"alpha-no alpha");
  STAssertTrue([@"3.0a1" versionStringCompare:@"3.0a4"]  == NSOrderedAscending, @"alpha diff");
  STAssertTrue([@"3.0a2" versionStringCompare:@"3.0a19"] == NSOrderedAscending, @"numeric alpha");
  STAssertTrue([@"3.0a"  versionStringCompare:@"3.0a1"]  == NSOrderedAscending, @"empty alpha");
  STAssertTrue([@"3.02"  versionStringCompare:@"3.03"]   == NSOrderedAscending, @"point diff");
  STAssertTrue([@"3.0.2" versionStringCompare:@"3.0.3"]  == NSOrderedAscending, @"point diff");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSString_md5Hash {
  STAssertTrue([[@"nimbus" md5Hash] isEqualToString:@"0e78d66f33c484a3c3b36d69bd3114cf"],
               @"MD5 hashes don't match.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSString_sha1Hash {
  STAssertTrue([[@"nimbus" sha1Hash] isEqualToString:@"c1b42d95fd18ad8a56d4fd7bbb4105952620d857"],
               @"SHA1 hashes don't match.");
}


@end

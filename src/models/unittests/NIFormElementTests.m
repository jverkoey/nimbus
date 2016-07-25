//
//  NIFormElementTests.m
//  Nimbus
//
//  Created by Jans Pavlovs on 25.07.16.
//  Copyright © 2016. g. Jeff Verkoeyen. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NimbusModels.h"

@interface NIFormElementTests : XCTestCase
@end

@implementation NIFormElementTests

- (void)testFormElementEqual {
  NSInteger commonID = 24;
  NIFormElement *element1 = [NIFormElement elementWithID:commonID];
  NIFormElement *element2 = [NIFormElement elementWithID:commonID];
  
  XCTAssertEqualObjects(element1, element2);
}

- (void)testFormElementNotEqual {
  NIFormElement *element1 = [NIFormElement elementWithID:24];
  NIFormElement *element2 = [NIFormElement elementWithID:25];
  
  XCTAssertNotEqualObjects(element1, element2);
}

@end

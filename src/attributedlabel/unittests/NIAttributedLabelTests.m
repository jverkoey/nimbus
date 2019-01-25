//
// Copyright 2011-2014 NimbusKit
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

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "NimbusAttributedLabel.h"
#import "NIAttributedLabel+Testing.h"

@interface NIAttributedLabelTestMonitor : NSObject <NIAttributedLabelDelegate>

@property(nonatomic, assign) BOOL doNotRespondToLongPressCallback;

@property(nonatomic, readonly) int longPressCallbackCount;
@property(nonatomic, readonly) int actionSheetCallbackCount;

@end

@implementation NIAttributedLabelTestMonitor

- (BOOL)respondsToSelector:(SEL)selector {
  if (selector == @selector(attributedLabel:didLongPressTextCheckingResult:atPoint:)) {
    return !_doNotRespondToLongPressCallback;
  }

  return [super respondsToSelector:selector];
}

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didLongPressTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
  _longPressCallbackCount++;
}

- (BOOL)attributedLabel:(NIAttributedLabel *)attributedLabel shouldPresentActionSheet:(UIActionSheet *)actionSheet withTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
  _actionSheetCallbackCount++;
  return NO;
}

@end

@interface NIAttributedLabelTests : XCTestCase
@end


@implementation NIAttributedLabelTests

- (void)testLongPressCallbackOverridesActionSheetCallbackWhenTouchingLink {
  // Create an attributed string with a link.
  NSString *string = @"NimbusKit";
  NSURL *URL = [NSURL URLWithString:@"http://nimbuskit.info/"];
  NSTextCheckingResult *textCheckingResult = [NSTextCheckingResult linkCheckingResultWithRange:NSMakeRange(0, string.length) URL:URL];
  NSDictionary<NSAttributedStringKey, id> *attributes = @{ NIAttributedLabelLinkAttributeName : textCheckingResult };
  NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];

  // Create a label.
  NIAttributedLabel *label = [[NIAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
  label.attributedText = attributedText;

  // Create a monitor for attributed label callbacks.
  NIAttributedLabelTestMonitor *monitor = [[NIAttributedLabelTestMonitor alloc] init];
  label.delegate = monitor;

  // Simulate touching a link.
  label.touchedLink = textCheckingResult;
  [label _longPressTimerDidFire:nil];

  // Verify expected callbacks.
  XCTAssertEqual(monitor.longPressCallbackCount, 1);
  XCTAssertEqual(monitor.actionSheetCallbackCount, 0);
}

- (void)testActionSheetCallbackDeliveredWhenTouchingLink {
  // Create an attributed string with a link.
  NSString *string = @"NimbusKit";
  NSURL *URL = [NSURL URLWithString:@"http://nimbuskit.info/"];
  NSTextCheckingResult *textCheckingResult = [NSTextCheckingResult linkCheckingResultWithRange:NSMakeRange(0, string.length) URL:URL];
  NSDictionary<NSAttributedStringKey, id> *attributes = @{ NIAttributedLabelLinkAttributeName : textCheckingResult };
  NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];

  // Create a label.
  NIAttributedLabel *label = [[NIAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
  label.attributedText = attributedText;

  // Create a monitor for attributed label callbacks and make it not respond to the long press callback.
  NIAttributedLabelTestMonitor *monitor = [[NIAttributedLabelTestMonitor alloc] init];
  monitor.doNotRespondToLongPressCallback = YES;
  label.delegate = monitor;

  // Simulate touching a link.
  label.touchedLink = textCheckingResult;
  [label _longPressTimerDidFire:nil];

  // Verify expected callbacks.
  XCTAssertEqual(monitor.longPressCallbackCount, 0);
  XCTAssertEqual(monitor.actionSheetCallbackCount, 1);
}

@end

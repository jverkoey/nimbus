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

#import "NimbusAttributedLabel.h"

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

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

+ (NIAttributedLabel *)makeGenericMultilineLabelWithFrame:(CGRect)frame {
  // Create an attributed string with a link.
  NSString *string = @"Unlinked content. Linked content.\nLinked content. Unlinked content.";
  NSURL *URL = [NSURL URLWithString:@"http://youtube.com"];
  NSTextCheckingResult *textCheckingResult =
      [NSTextCheckingResult linkCheckingResultWithRange:NSMakeRange(18, 32) URL:URL];
  NSDictionary<NSAttributedStringKey, id> *attributes =
      @{NIAttributedLabelLinkAttributeName : textCheckingResult};
  NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:string
                                                                       attributes:attributes];

  // Create a label.
  NIAttributedLabel *label = [[NIAttributedLabel alloc] initWithFrame:frame];
  label.attributedText = attributedText;
  label.numberOfLines = 0;

  return label;
}

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

- (void)testPreOrderedLinks {
  CGRect labelFrame = CGRectMake(0,0,200,200);
  NIAttributedLabel *label = [NIAttributedLabelTests makeGenericMultilineLabelWithFrame:labelFrame];

  // Create pre-order non-merged multiline links.
  label.linkOrdering = NILinkOrderingFirst;
  label.shouldMergeMultilineLinks = NO;
  NSMutableArray<NIViewAccessibilityElement *> *accessibleElements =
      [label.accessibleElements copy];

  // Given labelFrame (0,0,200), expect {(96, 3, 81, 12),(0, 18, 85, 12),(0,0,200,200)}.
  CGRect firstFrame = [accessibleElements objectAtIndex:0].frameInContainer;
  CGRect secondFrame = [accessibleElements objectAtIndex:1].frameInContainer;
  // Test second frame starts at start of labelFrame.
  XCTAssertEqual(secondFrame.origin.x, labelFrame.origin.x);
  // Test first frame starts after second frame.
  XCTAssertGreaterThan(firstFrame.origin.x,secondFrame.origin.x);
  // Test first frame start above second frame.
  XCTAssertLessThan(firstFrame.origin.y,secondFrame.origin.y);
  // Test both frames have the same height (same attribute).
  XCTAssertEqual(firstFrame.size.height,secondFrame.size.height);
  // Test last element is labelFrame.
  XCTAssertTrue(CGRectEqualToRect([accessibleElements objectAtIndex:2].frameInContainer, labelFrame));

  // Create pre-order merged multiline links.
  [label invalidateAccessibleElements];
  label.shouldMergeMultilineLinks = YES;
  NSMutableArray<NIViewAccessibilityElement *> *accessibleMergedElements =
      [label.accessibleElements copy];

  // Given labelFrame (0,0,200), expect {(0, 3, 177, 27),(0,0,200,200)}.
  CGRect mergedFrame = [accessibleMergedElements objectAtIndex:0].frameInContainer;
  // Test first frame starts at start of labelFrame.
  XCTAssertEqual(mergedFrame.origin.x, labelFrame.origin.x);
  // Test last element is labelFrame.
  XCTAssertTrue(CGRectEqualToRect([accessibleMergedElements objectAtIndex:1].frameInContainer,
                                  labelFrame));

  // Test pre-order non-merged multiline link frames union to merged multiline link frame.
  XCTAssertTrue(
      CGRectEqualToRect(CGRectUnion(firstFrame, secondFrame), mergedFrame));
}

- (void)testPostOrderedLinks {
  CGRect labelFrame = CGRectMake(0,0,200,200);
  NIAttributedLabel *label = [NIAttributedLabelTests makeGenericMultilineLabelWithFrame:labelFrame];

  // Create post-order non-mergegd multiline links.
  label.linkOrdering = NILinkOrderingLast;
  label.shouldMergeMultilineLinks = NO;
  NSMutableArray<NIViewAccessibilityElement *> *accessibleElements =
      [label.accessibleElements copy];

  // Given labelFrame (0,0,200), expect {(0,0,200,200),(96, 3, 81, 12),(0, 18, 85, 12)}.
  CGRect firstFrame = [accessibleElements objectAtIndex:1].frameInContainer;
  CGRect secondFrame = [accessibleElements objectAtIndex:2].frameInContainer;
  // Test first frame is labelFrame.
  XCTAssertTrue(CGRectEqualToRect([accessibleElements objectAtIndex:0].frameInContainer, labelFrame));
  // Test second frame starts at start of labelFrame.
  XCTAssertEqual(secondFrame.origin.x, labelFrame.origin.x);
  // Test first frame starts after second frame.
  XCTAssertGreaterThan(firstFrame.origin.x,secondFrame.origin.x);
  // Test first frame start above second frame.
  XCTAssertLessThan(firstFrame.origin.y,secondFrame.origin.y);
  // Test both frames have the same height (same attribute).
  XCTAssertEqual(firstFrame.size.height,secondFrame.size.height);

  // Create post-order merged multiline links.
  [label invalidateAccessibleElements];
  label.shouldMergeMultilineLinks = YES;
  NSMutableArray<NIViewAccessibilityElement *> *accessibleMergedElements =
      [label.accessibleElements copy];

  // Test first frame is labelFrame.
  XCTAssertTrue(CGRectEqualToRect([accessibleMergedElements objectAtIndex:0].frameInContainer,
                                  labelFrame));
  // Given labelFrame (0,0,200), expect {(0,0,200,200),(0, 3, 177, 27)}.
  CGRect mergedFrame = [accessibleMergedElements objectAtIndex:1].frameInContainer;
  // Test first frame starts at start of labelFrame.
  XCTAssertEqual(mergedFrame.origin.x, labelFrame.origin.x);

  // Test post-order non-merged multiline links union to merged multiline link.
  XCTAssertTrue(
      CGRectEqualToRect(CGRectUnion(firstFrame, secondFrame), mergedFrame));
}

- (void)testInOrderLinks {
  CGRect labelFrame = CGRectMake(0,0,200,200);
  NIAttributedLabel *label = [NIAttributedLabelTests makeGenericMultilineLabelWithFrame:labelFrame];

  // Links in-order non-merged multiline links.
  label.linkOrdering = NILinkOrderingOriginal;
  label.shouldMergeMultilineLinks = NO;
  NSMutableArray<NIViewAccessibilityElement *> *accessibleElements =
      [label.accessibleElements copy];

  // Given labelFrame (0,0,200), expect {(0, 3, 96, 12),(0, 3, 177, 27),(85, 18, 93, 12)}.
  CGRect firstFrame = [accessibleElements objectAtIndex:0].frameInContainer;
  CGRect mergedFrame = [accessibleElements objectAtIndex:1].frameInContainer;
  CGRect secondFrame = [accessibleElements objectAtIndex:2].frameInContainer;
  // Test first frame starts at start of labelFrame.
  XCTAssertEqual(firstFrame.origin.x, labelFrame.origin.x);
  // Test first frame has same origin as merged frame.
  XCTAssertTrue(CGPointEqualToPoint(firstFrame.origin, mergedFrame.origin));
  // Test first frame has smaller width than merged frame.
  XCTAssertLessThan(firstFrame.size.width, mergedFrame.size.width);
  // Test first frame has smaller height than merged frame.
  XCTAssertLessThan(firstFrame.size.height, mergedFrame.size.height);

  // Test first frame start above second frame.
  XCTAssertLessThan(firstFrame.origin.y, secondFrame.origin.y);
  // Test second frame has smaller width than merged frame.
  XCTAssertLessThan(secondFrame.size.width, mergedFrame.size.width);
  // Test second frame has smaller height than merged frame.
  XCTAssertLessThan(secondFrame.size.height, mergedFrame.size.height);
  // Test first and second frames have the same height (same attribute).
  XCTAssertEqual(firstFrame.size.height,secondFrame.size.height);

  // Links in-order merged multiline links.
  [label invalidateAccessibleElements];
  label.shouldMergeMultilineLinks = YES;
  NSMutableArray<NIViewAccessibilityElement *> *accessibleMergedElements =
      [label.accessibleElements copy];

  for (int frameIndex = 0; frameIndex < accessibleMergedElements.count; frameIndex++) {
    XCTAssertTrue(
        CGRectEqualToRect([accessibleElements objectAtIndex:frameIndex].frameInContainer,
                          [accessibleMergedElements objectAtIndex:frameIndex].frameInContainer));
  }
}

@end

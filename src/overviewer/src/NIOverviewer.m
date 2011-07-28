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

#import "NIOverviewer.h"

#ifdef DEBUG

#import "NIDeviceInfo.h"
#import "NIOverviewerView.h"
#import "NIOverviewerPageView.h"
#import "NIOverviewerSwizzling.h"
#import "NIOverviewerLogger.h"

// Static state.
static CGFloat  sOverviewerHeight   = 60;
static BOOL     sOverviewerIsAwake  = NO;

static NSTimer* sOverviewerHeartbeatTimer = nil;

static NIOverviewerView* sOverviewerView = nil;
static NIOverviewerLogger* sOverviewerLogger = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Logging


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @internal
 *
 * Replaces the default logging mechanism with a custom implementation.
 *
 * Your method prototype should look like this:
 *
 *   void logger(const char *message, unsigned length, BOOL withSyslogBanner)
 *
 *      @attention This method is undocumented, unsupported, and unlikely to be around
 *                 forever. Don't go using it in production code.
 *
 * http://support.apple.com/kb/TA45403?viewlocale=en_US
 */
extern void _NSSetLogCStringFunction(void(*)(const char *, unsigned, BOOL));


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Pipes NSLog messages to the overviewer and stderr.
 *
 * This method is passed as an argument to _NSSetLogCStringFunction to pipe all NSLog
 * messages through here.
 */
void NIOverviewerLogMethod(const char *message, unsigned length, BOOL withSyslogBanner) {
  static NSDateFormatter* formatter = nil;
  if (nil == formatter) {
    formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:kCFDateFormatterMediumStyle];
    [formatter setDateStyle:kCFDateFormatterMediumStyle];
  }

  NSDate* date = [NSDate date];

  // We don't autorelease here in an attempt to minimize autorelease thrashing in tight
  // loops.
  NSString* formattedLogMessage = [[NSString alloc] initWithFormat:
                                   @"%@: %s\n", [formatter stringFromDate:date], message];

  [[NIOverviewer logger] addConsoleLog:
   [[[NIOverviewerConsoleLogEntry alloc] initWithLog:
     [NSString stringWithCString:message encoding:NSUTF8StringEncoding]]
    autorelease]];

  fprintf(stderr, "%s", [formattedLogMessage UTF8String]);
  
  NI_RELEASE_SAFELY(formattedLogMessage);
}

#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewer


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Device Orientation Changes

#ifdef DEBUG

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)didChangeOrientation {
  static UIDeviceOrientation lastOrientation = UIDeviceOrientationUnknown;

  // Don't animate the overviewer if the device didn't actually change orientations.
  if (lastOrientation != [[UIDevice currentDevice] orientation]
      && [[UIDevice currentDevice] orientation] != UIDeviceOrientationUnknown
      && [[UIDevice currentDevice] orientation] != UIDeviceOrientationFaceUp
      && [[UIDevice currentDevice] orientation] != UIDeviceOrientationFaceDown) {

    // When we flip from landscape to landscape or portait to portait the animation lasts
    // twice as long.
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    BOOL isLongAnimation = (UIDeviceOrientationIsLandscape(lastOrientation)
                            == UIDeviceOrientationIsLandscape(currentOrientation));
    lastOrientation = currentOrientation;

    // Hide the overviewer right away, we'll make it fade back in when the rotation is
    // finished.
    sOverviewerView.hidden = YES;

    // Delay showing the overviewer again until the rotation finishes.
    [self cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(showOverviewerAfterRotation) withObject:nil
               afterDelay:NIDeviceRotationDuration(isLongAnimation)];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)statusBarWillChangeFrame {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:NIStatusBarFrameAnimationDuration()];
  [UIView setAnimationCurve:NIStatusBarFrameAnimationCurve()];
  CGRect frame = [NIOverviewer frame];
  sOverviewerView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
  [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showOverviewerAfterRotation {
  // Don't modify the overviewer's frame directly, just modify the transform/center/bounds
  // properties so that the view is rotated with the device.

  sOverviewerView.transform = NIRotateTransformForOrientation(NIInterfaceOrientation());

  // Fetch the frame only to calculate the center.
  CGRect frame = [NIOverviewer frame];
  sOverviewerView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));

  CGRect bounds = sOverviewerView.bounds;
  bounds.size.width = (UIInterfaceOrientationIsLandscape(NIInterfaceOrientation())
                       ? frame.size.height
                       : frame.size.width);
  sOverviewerView.bounds = bounds;

  // Get ready to fade the overviewer back in.
  sOverviewerView.hidden = NO;
  sOverviewerView.alpha = 0;
  
  [sOverviewerView flashScrollIndicators];

  // Fade!
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.2];
  sOverviewerView.alpha = 1;
  [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)didReceiveMemoryWarning {
  [sOverviewerLogger addEventLog:
   [[[NIOverviewerEventLogEntry alloc] initWithType:NIOverviewerEventDidReceiveMemoryWarning]
    autorelease]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)heartbeat {
  [NIDeviceInfo beginCachedDeviceInfo];
  NIOverviewerDeviceLogEntry* logEntry =
  [[[NIOverviewerDeviceLogEntry alloc] initWithTimestamp:[NSDate date]]
   autorelease];
  logEntry.bytesOfTotalDiskSpace = [NIDeviceInfo bytesOfTotalDiskSpace];
  logEntry.bytesOfFreeDiskSpace = [NIDeviceInfo bytesOfFreeDiskSpace];
  logEntry.bytesOfFreeMemory = [NIDeviceInfo bytesOfFreeMemory];
  logEntry.bytesOfTotalMemory = [NIDeviceInfo bytesOfTotalMemory];
  logEntry.batteryLevel = [NIDeviceInfo batteryLevel];
  logEntry.batteryState = [NIDeviceInfo batteryState];
  [NIDeviceInfo endCachedDeviceInfo];

  [sOverviewerLogger addDeviceLog:logEntry];
  
  [sOverviewerView updatePages];
}


#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)applicationDidFinishLaunching {
#ifdef DEBUG
  if (!sOverviewerIsAwake) {
    sOverviewerIsAwake = YES;

    // Set up the logger right away so that all calls to NSLog will be captured by the
    // overviewer.
    _NSSetLogCStringFunction(NIOverviewerLogMethod);

    sOverviewerLogger = [[NIOverviewerLogger alloc] init];

    NIOverviewerSwizzleMethods();

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didChangeOrientation)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(statusBarWillChangeFrame)
                                                 name: UIApplicationWillChangeStatusBarFrameNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didReceiveMemoryWarning)
                                                 name: UIApplicationDidReceiveMemoryWarningNotification
                                               object: nil];

    sOverviewerHeartbeatTimer = [[NSTimer scheduledTimerWithTimeInterval: 0.5
                                                                  target: self
                                                                selector: @selector(heartbeat)
                                                                userInfo: nil
                                                                 repeats: YES]
                                 retain];
  }
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)addOverviewerToWindow:(UIWindow *)window {
#ifdef DEBUG
  if (nil != sOverviewerView) {
    // Remove the old Overviewer in case this gets called multiple times (not sure why you would
    // though).
    [sOverviewerView removeFromSuperview];
    NI_RELEASE_SAFELY(sOverviewerView);
  }

  sOverviewerView = [[NIOverviewerView alloc] initWithFrame:[self frame]];
  
  [sOverviewerView addPageView:[NIOverviewerMemoryPageView page]];
  [sOverviewerView addPageView:[NIOverviewerDiskPageView page]];
  [sOverviewerView addPageView:[NIOverviewerConsoleLogPageView page]];
  [sOverviewerView addPageView:[NIOverviewerMaxLogLevelPageView page]];

  // Hide the view initially because the initial frame will be wrong when the device
  // starts the app in any orientation other than portrait. Don't worry, we'll fade the
  // view in once we get our first device notification.
  sOverviewerView.hidden = YES;

  [window addSubview:sOverviewerView];
  
  NSLog(@"The Overviewer has been added to a window.");
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NIOverviewerLogger *)logger {
#ifdef DEBUG
  return sOverviewerLogger;
#else
  return nil;
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)height {
#ifdef DEBUG
  return sOverviewerHeight;
#else
  return 0;
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGRect)frame {
#ifdef DEBUG
  UIInterfaceOrientation orient = NIInterfaceOrientation();
  CGFloat overviewerWidth;
  CGRect frame;

  // We can't take advantage of automatic view positioning because the overviewer exists
  // at the topmost view level (even above the root view controller). As such, we have to
  // calculate the frame depending on the interface orientation.
  if (orient == UIInterfaceOrientationLandscapeLeft) {
    overviewerWidth = [UIScreen mainScreen].bounds.size.height;
    frame = CGRectMake(NIOverviewerStatusBarHeight(), 0, sOverviewerHeight, overviewerWidth);

  } else if (orient == UIInterfaceOrientationLandscapeRight) {
    overviewerWidth = [UIScreen mainScreen].bounds.size.height;
    frame = CGRectMake([UIScreen mainScreen].bounds.size.width
                       - (NIOverviewerStatusBarHeight() + sOverviewerHeight), 0,
                       sOverviewerHeight, overviewerWidth);

  } else if (orient == UIInterfaceOrientationPortraitUpsideDown) {
    overviewerWidth = [UIScreen mainScreen].bounds.size.width;
    frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height
                       - (NIOverviewerStatusBarHeight() + sOverviewerHeight),
                       overviewerWidth, sOverviewerHeight);

  } else if (orient == UIInterfaceOrientationPortrait) {
    overviewerWidth = [UIScreen mainScreen].bounds.size.width;
    frame = CGRectMake(0, NIOverviewerStatusBarHeight(), overviewerWidth, sOverviewerHeight);

  } else {
    overviewerWidth = [UIScreen mainScreen].bounds.size.width;
    frame = CGRectMake(0, NIOverviewerStatusBarHeight(), overviewerWidth, sOverviewerHeight);
  }

  if ([[UIApplication sharedApplication] isStatusBarHidden]) {
    // When the status bar is hidden we want to position the overviewer offscreen.
    switch (orient) {
      case UIInterfaceOrientationLandscapeLeft: {
        frame = CGRectOffset(frame, -frame.size.width, 0);
        break;
      }
      case UIInterfaceOrientationLandscapeRight: {
        frame = CGRectOffset(frame, frame.size.width, 0);
        break;
      }
      case UIInterfaceOrientationPortrait: {
        frame = CGRectOffset(frame, 0, -frame.size.height);
        break;
      }
      case UIInterfaceOrientationPortraitUpsideDown: {
        frame = CGRectOffset(frame, 0, frame.size.height);
        break;
      }
    }
  }
  return frame;

#else
  return CGRectZero;
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIView *)view {
#ifdef DEBUG
  return sOverviewerView;
#else
  return nil;
#endif
}


@end
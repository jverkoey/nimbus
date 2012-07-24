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

#import "NIOverview.h"

#ifdef DEBUG

#import "NIDeviceInfo.h"
#import "NIOverviewView.h"
#import "NIOverviewPageView.h"
#import "NIOverviewSwizzling.h"
#import "NIOverviewLogger.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

// Static state.
static CGFloat  sOverviewHeight   = 60;
static BOOL     sOverviewIsAwake  = NO;

static NSTimer* sOverviewHeartbeatTimer = nil;

static NIOverviewView* sOverviewView = nil;
static NIOverviewLogger* sOverviewLogger = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Logging


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @internal
 *
 * An undocumented method that replaces the default logging mechanism with a custom implementation.
 *
 * Your method prototype should look like this:
 *
 *   void logger(const char *message, unsigned length, BOOL withSyslogBanner)
 *
 *      @attention This method is undocumented, unsupported, and unlikely to be around
 *                 forever. Don't go using it in production code.
 *
 * Source: http://support.apple.com/kb/TA45403?viewlocale=en_US
 */
extern void _NSSetLogCStringFunction(void(*)(const char *, unsigned, BOOL));

void NIOverviewLogMethod(const char* message, unsigned length, BOOL withSyslogBanner);


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Pipes NSLog messages to the Overview and stderr.
 *
 * This method is passed as an argument to _NSSetLogCStringFunction to pipe all NSLog
 * messages through here.
 */
void NIOverviewLogMethod(const char* message, unsigned length, BOOL withSyslogBanner) {
  static NSDateFormatter* formatter = nil;
  if (nil == formatter) {
    formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:kCFDateFormatterMediumStyle];
    [formatter setDateStyle:kCFDateFormatterMediumStyle];
  }

  // Don't autorelease here in an attempt to minimize autorelease thrashing in tight
  // loops.
  
  NSString* formattedLogMessage = [[NSString alloc] initWithCString: message
                                                           encoding: NSUTF8StringEncoding];

  NIOverviewConsoleLogEntry* entry = [[NIOverviewConsoleLogEntry alloc]
                                      initWithLog:formattedLogMessage];

  [[NIOverview logger] addConsoleLog:entry];

  formattedLogMessage = [[NSString alloc] initWithFormat:
                         @"%@: %s\n", [formatter stringFromDate:[NSDate date]], message];

  fprintf(stderr, "%s", [formattedLogMessage UTF8String]);
}

#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverview


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Device Orientation Changes

#ifdef DEBUG

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)didChangeOrientation {
  static UIDeviceOrientation lastOrientation = UIDeviceOrientationUnknown;

  // Don't animate the overview if the device didn't actually change orientations.
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

    // Hide the overview right away, we'll make it fade back in when the rotation is
    // finished.
    sOverviewView.hidden = YES;

    // Delay showing the overview again until the rotation finishes.
    [self cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(showoverviewAfterRotation) withObject:nil
               afterDelay:NIDeviceRotationDuration(isLongAnimation)];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)statusBarWillChangeFrame {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:NIStatusBarBoundsChangeAnimationDuration()];
  [UIView setAnimationCurve:NIStatusBarBoundsChangeAnimationCurve()];
  CGRect frame = [NIOverview frame];
  sOverviewView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
  [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showoverviewAfterRotation {
  // Don't modify the overview's frame directly, just modify the transform/center/bounds
  // properties so that the view is rotated with the device.

  sOverviewView.transform = NIRotateTransformForOrientation(NIInterfaceOrientation());

  // Fetch the frame only to calculate the center.
  CGRect frame = [NIOverview frame];
  sOverviewView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));

  CGRect bounds = sOverviewView.bounds;
  bounds.size.width = (UIInterfaceOrientationIsLandscape(NIInterfaceOrientation())
                       ? frame.size.height
                       : frame.size.width);
  sOverviewView.bounds = bounds;

  // Get ready to fade the overview back in.
  sOverviewView.hidden = NO;
  sOverviewView.alpha = 0;
  
  [sOverviewView flashScrollIndicators];

  // Fade!
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.2];
  sOverviewView.alpha = 1;
  [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)didReceiveMemoryWarning {
  [sOverviewLogger addEventLog:
   [[NIOverviewEventLogEntry alloc] initWithType:NIOverviewEventDidReceiveMemoryWarning]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)heartbeat {
  [NIDeviceInfo beginCachedDeviceInfo];
  NIOverviewDeviceLogEntry* logEntry =
  [[NIOverviewDeviceLogEntry alloc] initWithTimestamp:[NSDate date]];
  logEntry.bytesOfTotalDiskSpace = [NIDeviceInfo bytesOfTotalDiskSpace];
  logEntry.bytesOfFreeDiskSpace = [NIDeviceInfo bytesOfFreeDiskSpace];
  logEntry.bytesOfFreeMemory = [NIDeviceInfo bytesOfFreeMemory];
  logEntry.bytesOfTotalMemory = [NIDeviceInfo bytesOfTotalMemory];
  logEntry.batteryLevel = [NIDeviceInfo batteryLevel];
  logEntry.batteryState = [NIDeviceInfo batteryState];
  [NIDeviceInfo endCachedDeviceInfo];

  [sOverviewLogger addDeviceLog:logEntry];
  
  [sOverviewView updatePages];
}


#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)applicationDidFinishLaunching {
#ifdef DEBUG
  if (!sOverviewIsAwake) {
    sOverviewIsAwake = YES;

    // Set up the logger right away so that all calls to NSLog will be captured by the
    // overview.
    _NSSetLogCStringFunction(NIOverviewLogMethod);

    sOverviewLogger = [[NIOverviewLogger alloc] init];

    NIOverviewSwizzleMethods();

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

    sOverviewHeartbeatTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                                                  target: self
                                                                selector: @selector(heartbeat)
                                                                userInfo: nil
                                                                 repeats: YES];
  }
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)addOverviewToWindow:(UIWindow *)window {
#ifdef DEBUG
  if (nil != sOverviewView) {
    // Remove the old overview in case this gets called multiple times (not sure why you would
    // though).
    [sOverviewView removeFromSuperview];
  }

  sOverviewView = [[NIOverviewView alloc] initWithFrame:[self frame]];
  
  [sOverviewView addPageView:[NIOverviewMemoryPageView page]];
  [sOverviewView addPageView:[NIOverviewDiskPageView page]];
  [sOverviewView addPageView:[NIOverviewMemoryCachePageView page]];
  [sOverviewView addPageView:[NIOverviewConsoleLogPageView page]];
  [sOverviewView addPageView:[NIOverviewMaxLogLevelPageView page]];

  // Hide the view initially because the initial frame will be wrong when the device
  // starts the app in any orientation other than portrait. Don't worry, we'll fade the
  // view in once we get our first device notification.
  sOverviewView.hidden = YES;

  [window addSubview:sOverviewView];
  
  NSLog(@"The overview has been added to a window.");
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NIOverviewLogger *)logger {
#ifdef DEBUG
  return sOverviewLogger;
#else
  return nil;
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)height {
#ifdef DEBUG
  return sOverviewHeight;
#else
  return 0;
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGRect)frame {
#ifdef DEBUG
  UIInterfaceOrientation orient = NIInterfaceOrientation();
  CGFloat overviewWidth;
  CGRect frame;

  // We can't take advantage of automatic view positioning because the overview exists
  // at the topmost view level (even above the root view controller). As such, we have to
  // calculate the frame depending on the interface orientation.
  if (orient == UIInterfaceOrientationLandscapeLeft) {
    overviewWidth = [UIScreen mainScreen].bounds.size.height;
    frame = CGRectMake(NIOverviewStatusBarHeight(), 0, sOverviewHeight, overviewWidth);

  } else if (orient == UIInterfaceOrientationLandscapeRight) {
    overviewWidth = [UIScreen mainScreen].bounds.size.height;
    frame = CGRectMake([UIScreen mainScreen].bounds.size.width
                       - (NIOverviewStatusBarHeight() + sOverviewHeight), 0,
                       sOverviewHeight, overviewWidth);

  } else if (orient == UIInterfaceOrientationPortraitUpsideDown) {
    overviewWidth = [UIScreen mainScreen].bounds.size.width;
    frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height
                       - (NIOverviewStatusBarHeight() + sOverviewHeight),
                       overviewWidth, sOverviewHeight);

  } else if (orient == UIInterfaceOrientationPortrait) {
    overviewWidth = [UIScreen mainScreen].bounds.size.width;
    frame = CGRectMake(0, NIOverviewStatusBarHeight(), overviewWidth, sOverviewHeight);

  } else {
    overviewWidth = [UIScreen mainScreen].bounds.size.width;
    frame = CGRectMake(0, NIOverviewStatusBarHeight(), overviewWidth, sOverviewHeight);
  }

  if ([[UIApplication sharedApplication] isStatusBarHidden]) {
    // When the status bar is hidden we want to position the overview offscreen.
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
  return sOverviewView;
#else
  return nil;
#endif
}


@end

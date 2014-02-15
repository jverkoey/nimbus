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

#import "NIOverviewLogger.h"
#import "NIDeviceInfo.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

NSString* const NIOverviewLoggerDidAddDeviceLog = @"NIOverviewLoggerDidAddDeviceLog";
NSString* const NIOverviewLoggerDidAddConsoleLog = @"NIOverviewLoggerDidAddConsoleLog";
NSString* const NIOverviewLoggerDidAddEventLog = @"NIOverviewLoggerDidAddEventLog";

@implementation NIOverviewLogger {
  NSMutableOrderedSet* _deviceLogs;
  NSMutableOrderedSet* _consoleLogs;
  NSMutableOrderedSet* _eventLogs;
  NSTimeInterval _oldestLogAge;
  NSTimer* _heartbeatTimer;
}

+ (NIOverviewLogger*)sharedLogger
{
  static dispatch_once_t pred = 0;
  static NIOverviewLogger* instance = nil;
  
  dispatch_once(&pred, ^{
    instance = [[NIOverviewLogger alloc] init];
  });
  
  return instance;
}

- (id)init {
  if ((self = [super init])) {
    _deviceLogs = [[NSMutableOrderedSet alloc] init];
    _consoleLogs = [[NSMutableOrderedSet alloc] init];
    _eventLogs = [[NSMutableOrderedSet alloc] init];
    
    _oldestLogAge = 60;
    
    _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                                       target: self
                                                     selector: @selector(heartbeat)
                                                     userInfo: nil
                                                      repeats: YES];
  }
  return self;
}

- (void)dealloc {
  [_heartbeatTimer invalidate];
  _heartbeatTimer = nil;
}

- (void)heartbeat {
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
  
  [self addDeviceLog:logEntry];
}

- (void)pruneEntriesFromLinkedList:(NSMutableOrderedSet *)ll {
  NSDate* cutoffDate = [NSDate dateWithTimeIntervalSinceNow:-_oldestLogAge];
  while ([[((NIOverviewLogEntry *)[ll firstObject])
           timestamp] compare:cutoffDate] == NSOrderedAscending) {
    [ll removeObjectAtIndex:0];
  }
}

- (void)addDeviceLog:(NIOverviewDeviceLogEntry *)logEntry {
  [self pruneEntriesFromLinkedList:_deviceLogs];

  [_deviceLogs addObject:logEntry];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:NIOverviewLoggerDidAddDeviceLog
                                                      object:nil
                                                    userInfo:@{@"entry":logEntry}];
}

- (void)addConsoleLog:(NIOverviewConsoleLogEntry *)logEntry {
  [_consoleLogs addObject:logEntry];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:NIOverviewLoggerDidAddConsoleLog
                                                      object:nil
                                                    userInfo:@{@"entry":logEntry}];
}

- (void)addEventLog:(NIOverviewEventLogEntry *)logEntry {
  [self pruneEntriesFromLinkedList:_eventLogs];

  [_eventLogs addObject:logEntry];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:NIOverviewLoggerDidAddEventLog
                                                      object:nil
                                                    userInfo:@{@"entry":logEntry}];
}

@end


@implementation NIOverviewLogEntry

- (id)initWithTimestamp:(NSDate *)timestamp {
  if ((self = [super init])) {
    _timestamp = timestamp;
  }
  return self;
}

@end


@implementation NIOverviewDeviceLogEntry
@end


@implementation NIOverviewConsoleLogEntry

- (id)initWithLog:(NSString *)logText {
  if ((self = [super initWithTimestamp:[NSDate date]])) {
    _log = [logText copy];
  }

  return self;
}

@end


@implementation NIOverviewEventLogEntry

- (id)initWithType:(NSInteger)type {
  if ((self = [super initWithTimestamp:[NSDate date]])) {
    _type = type;
  }
  
  return self;
}

@end

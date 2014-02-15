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

#import "NIOperations.h"

#import "NIDebuggingTools.h"
#import "NIPreprocessorMacros.h"
#import "NIOperations+Subclassing.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@implementation NIOperation

- (void)dealloc {
  // For an unknown reason these block objects are not released when the NIOperation is deallocated
  // with ARC enabled.
  _didStartBlock = nil;
  _didFinishBlock = nil;
  _didFailWithErrorBlock = nil;
  _willFinishBlock = nil;
}

#pragma mark - Initiate delegate notification from the NSOperation

- (void)didStart {
	[self performSelectorOnMainThread:@selector(onMainThreadOperationDidStart)
                         withObject:nil
                      waitUntilDone:[NSThread isMainThread]];
}

- (void)didFinish {
	[self performSelectorOnMainThread:@selector(onMainThreadOperationDidFinish)
                         withObject:nil
                      waitUntilDone:[NSThread isMainThread]];
}

- (void)didFailWithError:(NSError *)error {
  self.lastError = error;

	[self performSelectorOnMainThread:@selector(onMainThreadOperationDidFailWithError:)
                         withObject:error
                      waitUntilDone:[NSThread isMainThread]];
}

- (void)willFinish {
  if ([self.delegate respondsToSelector:@selector(nimbusOperationWillFinish:)]) {
    [self.delegate nimbusOperationWillFinish:self];
  }

  if (nil != self.willFinishBlock) {
    self.willFinishBlock(self);
  }
}

#pragma mark - Main Thread

- (void)onMainThreadOperationDidStart {
  // This method should only be called on the main thread.
  NIDASSERT([NSThread isMainThread]);

  if ([self.delegate respondsToSelector:@selector(nimbusOperationDidStart:)]) {
    [self.delegate nimbusOperationDidStart:self];
  }

  if (nil != self.didStartBlock) {
    self.didStartBlock(self);
  }
}

- (void)onMainThreadOperationDidFinish {
  // This method should only be called on the main thread.
  NIDASSERT([NSThread isMainThread]);

  if ([self.delegate respondsToSelector:@selector(nimbusOperationDidFinish:)]) {
    [self.delegate nimbusOperationDidFinish:self];
  }

  if (nil != self.didFinishBlock) {
    self.didFinishBlock(self);
  }
}

- (void)onMainThreadOperationDidFailWithError:(NSError *)error {
  // This method should only be called on the main thread.
  NIDASSERT([NSThread isMainThread]);

  if ([self.delegate respondsToSelector:@selector(nimbusOperationDidFail:withError:)]) {
    [self.delegate nimbusOperationDidFail:self withError:error];
  }

  if (nil != self.didFailWithErrorBlock) {
    self.didFailWithErrorBlock(self, error);
  }
}

@end

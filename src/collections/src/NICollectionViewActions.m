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

#import "NICollectionViewActions.h"

#import "NICollectionViewCellFactory.h"
#import "NimbusCore.h"
#import "NIActions+Subclassing.h"
#import <objc/runtime.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@implementation NICollectionViewActions


#pragma mark - UICollectionViewDelegate


- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  BOOL shouldHighlight = NO;

  NIDASSERT([collectionView.dataSource isKindOfClass:[NICollectionViewModel class]]);
  if ([collectionView.dataSource isKindOfClass:[NICollectionViewModel class]]) {
    NICollectionViewModel* model = (NICollectionViewModel *)collectionView.dataSource;
    id object = [model objectAtIndexPath:indexPath];

    if ([self isObjectActionable:object]) {
      NIObjectActions* action = [self actionForObjectOrClassOfObject:object];

      // If the cell is tappable, reflect that in the selection style.
      if (nil != action.tapAction || nil != action.tapSelector
          || nil != action.detailAction || nil != action.detailSelector
          || nil != action.navigateAction || nil != action.navigateSelector) {
        shouldHighlight = YES;
      }
    }
  }

  return shouldHighlight;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  NIDASSERT([collectionView.dataSource isKindOfClass:[NICollectionViewModel class]]);
  if ([collectionView.dataSource isKindOfClass:[NICollectionViewModel class]]) {
    NICollectionViewModel* model = (NICollectionViewModel *)collectionView.dataSource;
    id object = [model objectAtIndexPath:indexPath];

    if ([self isObjectActionable:object]) {
      NIObjectActions* action = [self actionForObjectOrClassOfObject:object];

      BOOL shouldDeselect = NO;
      if (action.tapAction) {
        // Tap actions can deselect the cell if they return YES.
        shouldDeselect = action.tapAction(object, self.target, indexPath);
      }
      if (action.tapSelector && [self.target respondsToSelector:action.tapSelector]) {
        NSMethodSignature *methodSignature = [self.target methodSignatureForSelector:action.tapSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.selector = action.tapSelector;
        if (methodSignature.numberOfArguments >= 3) {
          [invocation setArgument:&object atIndex:2];
        }
        if (methodSignature.numberOfArguments >= 4) {
          [invocation setArgument:&indexPath atIndex:3];
        }
        [invocation invokeWithTarget:self.target];

        NSUInteger length = invocation.methodSignature.methodReturnLength;
        if (length > 0) {
          char *buffer = (void *)malloc(length);
          memset(buffer, 0, sizeof(char) * length);
          [invocation getReturnValue:buffer];
          for (NSUInteger index = 0; index < length; ++index) {
            if (buffer[index]) {
              shouldDeselect = YES;
              break;
            }
          }
          free(buffer);
        }
      }

      if (action.detailAction) {
        // Tap actions can deselect the cell if they return YES.
        action.detailAction(object, self.target, indexPath);
      }
      if (action.detailSelector && [self.target respondsToSelector:action.detailSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:action.detailSelector withObject:object withObject:indexPath];
#pragma clang diagnostic pop
      }

      if (action.navigateAction) {
        // Tap actions can deselect the cell if they return YES.
        action.navigateAction(object, self.target, indexPath);
      }
      if (action.navigateSelector && [self.target respondsToSelector:action.navigateSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:action.navigateSelector withObject:object withObject:indexPath];
#pragma clang diagnostic pop
      }

      if (shouldDeselect) {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
      }
    }
  }
}

@end

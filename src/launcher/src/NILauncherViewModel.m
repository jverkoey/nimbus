//
// Copyright 2011-2012 Jeff Verkoeyen
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

#import "NILauncherViewModel.h"

#import "NILauncherView.h"
#import "NILauncherViewObject.h"
#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NILauncherViewModel()
@property (nonatomic, readwrite, NI_STRONG) NSMutableArray* pages;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NILauncherViewModel

@synthesize pages = _pages;
@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithArrayOfPages:(NSArray *)pages delegate:(id<NILauncherViewModelDelegate>)delegate {
  if ((self = [super init])) {
    // Make the entire pages array mutable.
    NSMutableArray* mutablePages = [NSMutableArray arrayWithCapacity:pages.count];
    for (NSArray* subArray in pages) {
      // You must add an array of arrays.
      NIDASSERT([subArray isKindOfClass:[NSArray class]]);

      [mutablePages addObject:[subArray mutableCopy]];
    }
    self.pages = mutablePages;

    _delegate = delegate;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray *)_pageAtIndex:(NSInteger)pageIndex {
  NIDASSERT(self.pages.count > pageIndex && pageIndex >= 0);
  return [self.pages objectAtIndex:pageIndex];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)appendPage:(NSArray *)page {
  [self.pages addObject:[page mutableCopy]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)appendObject:(id<NILauncherViewObject>)object toPage:(NSInteger)pageIndex {
  NSAssert(self.pages.count > pageIndex && pageIndex >= 0, @"Page index is out of bounds.");

  [[self _pageAtIndex:pageIndex] addObject:object];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<NILauncherViewObject>)objectAtIndex:(NSInteger)index pageIndex:(NSInteger)pageIndex {
  NSAssert(self.pages.count > pageIndex && pageIndex >= 0, @"Page index is out of bounds.");

  NSArray* objects = [self _pageAtIndex:pageIndex];
  NSAssert(objects.count > index && index >= 0, @"Index is out of bounds.");

  return [objects objectAtIndex:index];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSCoding


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)coder {
  NSUInteger numberOfPages = self.pages.count;
  [coder encodeValueOfObjCType:@encode(NSUInteger) at:&numberOfPages];

  for (NSArray* page in self.pages) {
    NSUInteger numberOfObjects = page.count;
    [coder encodeValueOfObjCType:@encode(NSUInteger) at:&numberOfObjects];

    for (id object in page) {
      // The object must conform to NSCoding in order to be encoded.
      NIDASSERT([object conformsToProtocol:@protocol(NSCoding)]);
      [coder encodeObject:object];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)decoder {
  if ((self = [super init])) {
    NSUInteger numberOfPages = 0;
    [decoder decodeValueOfObjCType:@encode(NSUInteger) at:&numberOfPages];

    NSMutableArray* pages = [NSMutableArray arrayWithCapacity:numberOfPages];
    for (NSUInteger ixPage = 0; ixPage < numberOfPages; ++ixPage) {
      NSUInteger numberOfObjects = 0;
      [decoder decodeValueOfObjCType:@encode(NSUInteger) at:&numberOfObjects];

      NSMutableArray* objects = [NSMutableArray arrayWithCapacity:numberOfObjects];
      for (NSUInteger ixObject = 0; ixObject < numberOfObjects; ++ixObject) {
        [objects addObject:[decoder decodeObject]];
      }
      [pages addObject:objects];
    }

    _pages = pages;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NILauncherDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPagesInLauncherView:(NILauncherView *)launcherView {
  return self.pages.count;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)launcherView:(NILauncherView *)launcherView numberOfButtonsInPage:(NSInteger)page {
  return [[self.pages objectAtIndex:page] count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView<NILauncherButtonView> *)launcherView:(NILauncherView *)launcherView buttonViewForPage:(NSInteger)page atIndex:(NSInteger)index {
  id<NILauncherViewObject> object = [self objectAtIndex:index pageIndex:page];

  Class buttonViewClass = object.buttonViewClass;
  // You must provide a button view class.
  NIDASSERT(nil != buttonViewClass);

  NSString* reuseIdentifier = NSStringFromClass(buttonViewClass);
  UIView<NILauncherButtonView>* buttonView = [launcherView dequeueReusableViewWithIdentifier:reuseIdentifier];

  if (nil == buttonView) {
    buttonView = [[buttonViewClass alloc] initWithReuseIdentifier:reuseIdentifier];
  }

  // Give the button view a chance to update itself.
  if ([buttonView respondsToSelector:@selector(shouldUpdateViewWithObject:)]) {
    [buttonView performSelector:@selector(shouldUpdateViewWithObject:) withObject:object];
  }

  // Give the delegate a chance to customize this button.
  [self.delegate launcherViewModel:self
               configureButtonView:buttonView
                   forLauncherView:launcherView
                         pageIndex:page
                       buttonIndex:index
                            object:object];
  
  return buttonView;
}


@end

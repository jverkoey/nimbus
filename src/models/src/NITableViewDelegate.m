//
// Copyright 2011 Jared Egan
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

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "NICellFactory.h"
#import "NITableViewModel.h"
#import "NITableViewDelegate.h"
#import "NINonRetainingCollections.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NITableViewDelegate ()
@property (nonatomic, NI_STRONG) NSMutableSet* forwardDelegates;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewDelegate

#pragma mark -
#pragma mark Init & Factory
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDataSource:(NITableViewModel *)dataSource {
	if ((self = [super init])) {
        _dataSource = dataSource;
        _forwardDelegates = NICreateNonRetainingMutableSet();
	}
    
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDataSource:(NITableViewModel *)dataSource
                delegate:(id<NITableViewSystemDelegate,UIScrollViewDelegate>)delegate {
	if ((self = [super init])) {
        _dataSource = dataSource;
        _forwardDelegates = NICreateNonRetainingMutableSet();
        [_forwardDelegates addObject:delegate];
	}
    
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    self.forwardDelegates = nil;
    self.tableSystem = nil;
}

#pragma mark -
#pragma mark UITableViewDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [_dataSource objectAtIndexPath:indexPath];
    
    if ([object conformsToProtocol:@protocol(NICellObject)]) {
        Class cls = [(id<NICellObject>)object cellClass];
        if ([cls conformsToProtocol:@protocol(NICell)]) {
            Method method = class_getClassMethod(cls, @selector(heightForObject:atIndexPath:tableView:));
            
            if (method != NULL) {
                return [cls heightForObject:object
                                atIndexPath:indexPath
                                  tableView:tableView];
            }
        }
    }
    
    // Default option
    return tableView.rowHeight;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Forward Invocations


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldForwardSelector:(SEL)selector {
    struct objc_method_description description;
    description = protocol_getMethodDescription(@protocol(NITableViewSystemDelegate), selector, NO, YES);
    if (description.name != NULL && description.types != NULL) {
        return YES;
    }
    description = protocol_getMethodDescription(@protocol(UIScrollViewDelegate), selector, NO, YES);
    return (description.name != NULL && description.types != NULL);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)respondsToSelector:(SEL)selector {
    if ([super respondsToSelector:selector]) {
        return YES;
        
    } else if ([self shouldForwardSelector:selector]) {
        for (id delegate in self.forwardDelegates) {
            if ([delegate respondsToSelector:selector]) {
                return YES;
            }
        }
    }
    return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature == nil) {
        for (id delegate in self.forwardDelegates) {
            if ([delegate respondsToSelector:selector]) {
                signature = [delegate methodSignatureForSelector:selector];
            }
        }
    }
    return signature;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)forwardInvocation:(NSInvocation *)invocation {
    BOOL didForward = NO;
    
    if ([self shouldForwardSelector:invocation.selector]) {
        for (id delegate in self.forwardDelegates) {
            if ([delegate respondsToSelector:invocation.selector]) {
                [invocation invokeWithTarget:delegate];
                didForward = YES;
                break;
            }
        }
    }
    
    if (!didForward) {
        [super forwardInvocation:invocation];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITableViewDelegate>)forwardingTo:(id<UITableViewDelegate>)forwardDelegate {
    [self.forwardDelegates addObject:forwardDelegate];
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeForwarding:(id<UITableViewDelegate>)forwardDelegate {
    [self.forwardDelegates removeObject:forwardDelegate];
}

@end

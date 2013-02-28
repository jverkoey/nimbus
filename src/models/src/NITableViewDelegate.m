//
//  NITableViewDelegate.m
//  Nimbus
//
//  Created by Jared Egan on 2/28/13.
//  Copyright 2013 Jeff Verkoeyen. All rights reserved.
//

#import "NITableViewDelegate.h"

#import "NimbusCore.h"

#import "NICellFactory.h"
#import "NITableViewSystem.h"

#import "objc/runtime.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface NITableViewDelegate()

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewDelegate

#pragma mark -
#pragma mark Init & Factory
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDataSource:(NITableViewModel *)dataSource {
	if ((self = [super init])) {
        self.dataSource = dataSource;
	}

	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDataSource:(NITableViewModel *)dataSource
                delegate:(id<NITableViewSystemDelegate,UIScrollViewDelegate>)delegate {
	if ((self = [super init])) {
        self.dataSource = dataSource;
        self.delegate = delegate;
	}

	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    self.delegate = nil;
    self.tableSystem = nil;
}

#pragma mark -
#pragma mark UITableViewDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {


    if ([_delegate conformsToProtocol:@protocol(NITableViewSystemDelegate)]) {
        id object = [self.dataSource objectAtIndexPath:indexPath];

        if (object != nil) {
            if ([_delegate respondsToSelector:@selector(tableSystem:didSelectObject:atIndexPath:)]) {
                [_delegate tableSystem:self.tableSystem didSelectObject:object atIndexPath:indexPath];
            }

            /*
            if ([object isKindOfClass:[KBTableItem class]]) {
                KBTableItem *item = (KBTableItem *)object;

                if (item.selectionBlock) {
                    item.selectionBlock(item, indexPath);
                }

                if (item.delegate != nil && item.selector != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

                    [item.delegate performSelector:item.selector withObject:item];
#pragma clang diagnostic pop
                }
            }
             */
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.dataSource objectAtIndexPath:indexPath];

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

#pragma mark -
#pragma mark UIScrollViewDelegate
// Forward all scrolling delegate messages to our delegate
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.delegate scrollViewDidZoom:scrollView];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.delegate scrollViewWillBeginDecelerating:scrollView];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [self.delegate viewForZoomingInScrollView:scrollView];
    }

    return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.delegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.delegate scrollViewShouldScrollToTop:scrollView];
    }

    // return a yes if you want to scroll to the top. if not defined, assumes YES
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.delegate scrollViewDidScrollToTop:scrollView];
    }
}

@end

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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NIPreprocessorMacros.h" /* for NI_WEAK */

/**
 * An object designed to easily implement snapshot rotation.
 *
 * Snapshot rotation involves taking two screenshots of a UIView: the "before" and the "after"
 * state of the rotation. These two images are then cross-faded during the rotation, creating an
 * animation that minimizes visual artifacts that would otherwise be noticed when rotation occurs.
 *
 * This feature will only function on iOS 6.0 and higher. On older iOS versions the view will rotate
 * just as it always has.
 *
 * This functionality has been adopted from WWDC 2012 session 240 "Polishing Your Interface
 * Rotations".
 *
 *      @ingroup NimbusCore
 *      @defgroup Snapshot-Rotation Snapshot Rotation
 *      @{
 */

@protocol NISnapshotRotationDelegate;

/**
 * The NISnapshotRotation class provides support for implementing snapshot-based rotations on views.
 *
 * You must call this object's rotation methods from your controller in order for the rotation
 * object to implement the rotation animations correctly.
 */
@interface NISnapshotRotation : NSObject

// Designated initializer.
- (id)initWithDelegate:(id<NISnapshotRotationDelegate>)delegate;

@property (nonatomic, readwrite, NI_WEAK) id<NISnapshotRotationDelegate> delegate;

@property (nonatomic, readonly, assign) CGRect frameBeforeRotation;
@property (nonatomic, readonly, assign) CGRect frameAfterRotation;

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

@end

/**
 * The NITableViewSnapshotRotation class implements the fixedInsetsForSnapshotRotation: delegate
 * method and forwards all other delegate methods along.
 *
 * If you are rotating a UITableView you can instantiate a NITableViewSnapshotRotation object and
 * use it just like you would a snapshot rotation object. The NITableViewSnapshotRotation class
 * intercepts the fixedInsetsForSnapshotRotation: method and returns insets that map to the
 * dimensions of the content view for the first visible cell in the table view.
 *
 * The assigned delegate only needs to implement containerViewForSnapshotRotation: and
 * rotatingViewForSnapshotRotation:.
 */
@interface NITableViewSnapshotRotation : NISnapshotRotation
@end

/**
 * The methods declared by the NISnapshotRotation protocol allow the adopting delegate to respond to
 * messages from the NISnapshotRotation class and thus implement snapshot rotations.
 */
@protocol NISnapshotRotationDelegate <NSObject>
@required

/** @name Accessing Rotation Views */

/**
 * Tells the delegate to return the container view of the rotating view.
 *
 * This is often the controller's self.view. This view must not be the same as the rotatingView and
 * rotatingView must be in the subview tree of containerView.
 *
 *        @sa NISnapshotRotation::rotatingViewForSnapshotRotation:
 */
- (UIView *)containerViewForSnapshotRotation:(NISnapshotRotation *)snapshotRotation;

/**
 * Tells the delegate to return the rotating view.
 *
 * The rotating view is the view that will be snapshotted during the rotation.
 *
 * This view must not be the same as the containerView and must be in the subview tree of
 * containerView.
 *
 *        @sa NISnapshotRotation::containerViewForSnapshotRotation:
 */
- (UIView *)rotatingViewForSnapshotRotation:(NISnapshotRotation *)snapshotRotation;

@optional

/** @name Configuring Fixed Insets */

/**
 * Asks the delegate to return the insets of the rotating view that should be fixed during rotation.
 *
 * This method will only be called on iOS 6.0 and higher.
 *
 * The returned insets will denote which parts of the snapshotted images will not stretch during
 * the rotation animation.
 */
- (UIEdgeInsets)fixedInsetsForSnapshotRotation:(NISnapshotRotation *)snapshotRotation;

@end

/**
 * Returns a UIImage snapshot of the given view.
 *
 * This method takes into account the offset of scrollable views and captures whatever is currently
 * in the frame of the view.
 *
 *      @param view A snapshot will be taken of this view.
 *      @returns A UIImage with the snapshot of @c view.
 */
UIImage* NISnapshotOfView(UIView* view);

/**
 * Returns a UIImageView with an image snapshot of the given view.
 *
 * The frame of the returned view is set to match the frame of @c view.
 *
 *      @param view A snapshot will be taken of this view.
 *      @returns A UIImageView with the snapshot of @c view and matching frame.
 */
UIImageView* NISnapshotViewOfView(UIView* view);

/**
 * @}
 */

/** @name Creating a Snapshot Rotation Object */

/**
 * Initializes a newly allocated rotation object with a given delegate.
 *
 *      @param delegate A delegate that implements the NISnapshotRotation protocol.
 *      @returns A NISnapshotRotation object initialized with @c delegate.
 *      @fn NISnapshotRotation::initWithDelegate:
 */

/** @name Accessing the Delegate */

/**
 * The delegate of the snapshot rotation object.
 *
 * The delegate must adopt the NISnapshotRotation protocol. The NISnapshotRotation class, which does
 * not retain the delegate, invokes each protocol method the delegate implements.
 *
 *      @fn NISnapshotRotation::delegate
 */

/** @name Implementing UIViewController Autorotation */

/**
 * Prepares the animation for a rotation by taking a snapshot of the rotatingView in its current
 * state.
 *
 * This method must be called from your UIViewController implementation.
 *
 *      @fn NISnapshotRotation::willRotateToInterfaceOrientation:duration:
 */

/**
 * Crossfades between the initial and final snapshots.
 *
 * This method must be called from your UIViewController implementation.
 *
 *      @fn NISnapshotRotation::willAnimateRotationToInterfaceOrientation:duration:
 */

/**
 * Finalizes the rotation animation by removing the snapshot views from the container view.
 *
 * This method must be called from your UIViewController implementation.
 *
 *      @fn NISnapshotRotation::didRotateFromInterfaceOrientation:
 */

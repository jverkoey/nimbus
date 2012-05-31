//
//  NIPhotoScrubberViewDelegate.h
//  Nimbus
//
//  Created by Gregory Hill on 3/14/12.
//  Copyright (c) 2012 Jeff Verkoeyen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The delegate for the photo scrubber.
 *
 *      @ingroup Photos-Protocols
 *
 * Sends notifications of state changes.
 *
 *      @see NIPhotoScrubberView
 */
@protocol NIPhotoScrubberViewDelegate <NSObject>

@optional

#pragma mark Selection Changes /** @name Selection Changes */

/**
 * The photo scrubber changed its selection.
 *
 * Use photoScrubberView.selectedPhotoIndex to access the current selection.
 */
- (void)photoScrubberViewDidChangeSelection:(NIPhotoScrubberView *)photoScrubberView;

@end

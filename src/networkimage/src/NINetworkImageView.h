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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NIInMemoryCache.h"
#import "NimbusCore.h"

@protocol NINetworkImageViewDelegate;
@protocol ASICacheDelegate;

// See the diskCacheLifetime property for more documentation related to this enumeration.
typedef enum {
  /**
   * Store images on disk in the session disk cache. Images stored with this lifetime will
   * be removed when the app starts again or when the session cache is explicitly cleared.
   */
  NINetworkImageViewDiskCacheLifetimeSession,

  /**
   * Store images on disk in the permanent disk cache. Images stored with this lifetime will
   * only be removed when the permanent cache is explicitly cleared.
   */
  NINetworkImageViewDiskCacheLifetimePermanent,
} NINetworkImageViewDiskCacheLifetime;

typedef enum {
  NINetworkImageViewScaleToFitLeavesExcessAndScaleToFillCropsExcess = 0x00,
  NINetworkImageViewScaleToFitCropsExcess    = 0x01,
  NINetworkImageViewScaleToFillLeavesExcess  = 0x02,
} NINetworkImageViewScaleOptions;

/**
 * A protocol defining the set of characteristics for an operation to be used with
 * NINetworkImageView.
 */
@protocol NINetworkImageOperation <NSObject>
@required
@property (readonly, copy) NSString* cacheIdentifier;
@property (assign) CGRect imageCropRect;
@property (assign) CGSize imageDisplaySize;
@property (assign) NINetworkImageViewScaleOptions scaleOptions;
@property (assign) CGInterpolationQuality interpolationQuality;
@property (assign) UIViewContentMode imageContentMode;
@property (strong) UIImage* imageCroppedAndSizedForDisplay;
@end

/**
 * A network-enabled image view that consumes minimal amounts of memory.
 *
 * Intelligently crops and resizes images for optimal memory use and uses threads to avoid
 * processing images on the UI thread.
 *
 * @ingroup NimbusNetworkImage
 */
@interface NINetworkImageView : UIImageView <NIOperationDelegate>

#pragma mark Creating a Network Image View

- (id)initWithImage:(UIImage *)image;

#pragma mark Configurable Presentation Properties

@property (nonatomic, strong) UIImage* initialImage;     // Default: nil
@property (nonatomic, assign) BOOL sizeForDisplay;       // Default: YES
@property (nonatomic, assign) NINetworkImageViewScaleOptions scaleOptions; // Default: NINetworkImageViewScaleToFitLeavesExcessAndScaleToFillCropsExcess
@property (nonatomic, assign) CGInterpolationQuality interpolationQuality; // Default: kCGInterpolationDefault

#pragma mark Configurable Properties

@property (nonatomic, strong) NIImageMemoryCache* imageMemoryCache;    // Default: [Nimbus imageMemoryCache]
@property (nonatomic, strong) NSOperationQueue* networkOperationQueue; // Default: [Nimbus networkOperationQueue]

@property (nonatomic, assign) NSTimeInterval maxAge;     // Default: 0

#pragma mark Requesting a Network Image

- (void)setPathToNetworkImage:(NSString *)pathToNetworkImage;
- (void)setPathToNetworkImage:(NSString *)pathToNetworkImage forDisplaySize:(CGSize)displaySize;
- (void)setPathToNetworkImage:(NSString *)pathToNetworkImage forDisplaySize:(CGSize)displaySize contentMode:(UIViewContentMode)contentMode;
- (void)setPathToNetworkImage:(NSString *)pathToNetworkImage forDisplaySize:(CGSize)displaySize contentMode:(UIViewContentMode)contentMode cropRect:(CGRect)cropRect;
- (void)setPathToNetworkImage:(NSString *)pathToNetworkImage cropRect:(CGRect)cropRect;
- (void)setPathToNetworkImage:(NSString *)pathToNetworkImage contentMode:(UIViewContentMode)contentMode;

- (void)setNetworkImageOperation:(NIOperation<NINetworkImageOperation> *)operation forDisplaySize:(CGSize)displaySize contentMode:(UIViewContentMode)contentMode cropRect:(CGRect)cropRect;

#pragma mark State

@property (nonatomic, readonly, assign, getter=isLoading) BOOL loading;

#pragma mark Reusable View

- (void)prepareForReuse;

#pragma mark Delegation

@property (nonatomic, weak) id<NINetworkImageViewDelegate> delegate;

#pragma mark Subclassing

- (void)networkImageViewDidStartLoading;
- (void)networkImageViewDidLoadImage:(UIImage *)image;
- (void)networkImageViewDidFailWithError:(NSError *)error;

@end


/**
 * The image view delegate used to inform of state changes.
 *
 * @ingroup NimbusNetworkImage
 */
@protocol NINetworkImageViewDelegate <NSObject>
@optional

/**
 * The image has begun an asynchronous download of the image.
 */
- (void)networkImageViewDidStartLoad:(NINetworkImageView *)imageView;

/**
 * The image has completed an asynchronous download of the image.
 */
- (void)networkImageView:(NINetworkImageView *)imageView didLoadImage:(UIImage *)image;

/**
 * The asynchronous download failed.
 */
- (void)networkImageView:(NINetworkImageView *)imageView didFailWithError:(NSError *)error;

/**
 * The progress of the download.
 */
- (void)networkImageView:(NINetworkImageView *)imageView readBytes:(long long)readBytes totalBytes:(long long)totalBytes;

@end

/**
 * Flags for modifying the way cropping is handled when scaling images to fit or fill.
 *
 * @enum NINetworkImageViewScaleOptions
 * @ingroup NimbusNetworkImage
 *
 * By default the network image view will behave in the following way for these content modes:
 *
 * - <b>UIViewContentModeScaleAspectFit</b>: Leaves unfilled space as transparent.
 * - <b>UIViewContentModeScaleAspectFill</b>: Crops any excess pixels.
 *
 * The resulting image size will exactly match the display size.
 *
 * You can modify this behavior using the following two flags which should be set using
 * binary operators.
 *
 * @htmlonly
 * <pre>
 *   NINetworkImageViewScaleToFitCropsRemainder
 *   The final image size will be shrunk to fit the image such that there is no transparency.
 *
 *   NINetworkImageViewScaleToFillLeavesRemainder
 *   The final image size will be grown to include the excess pixels.
 * </pre>
 * @endhtmlonly
 *
 * <h1>Examples</h1>
 *
 * The following examples use this image:
 *
 * @image html clouds500x375.jpeg "Dimensions: 500x375"
 *
 *
 * <h2>Default settings with UIViewContentModeScaleAspectFit</h2>
 *
 * <h3>Result image (display size 100x100)</h3>
 *
 * @image html clouds100x100-fit.png "Fit image with default settings leaves transparent pixels. Size: 100x100."
 *
 * <h3>Example code</h3>
 *
 * @code
 *  imageView.scaleOptions = NINetworkImageViewScaleToFitLeavesExcessAndScaleToFillCropsExcess;
 *
 *  [imageView setPathToNetworkImage: @"http://farm2.static.flickr.com/1165/644335254_4b8a712be5.jpg"
 *                    forDisplaySize: CGSizeMake(100, 100)
 *                       contentMode: UIViewContentModeScaleAspectFit];
 *
 *       source image size: 500x375  [aspect ratio: 1.3333]
 *            display size: 100x100  [aspect ratio: 1]
 *       result image size: 100x100  [aspect ratio: 1] (transparency on the left and right edges)
 *          image blt size: 100x75   [aspect ratio: 1.3333]
 * @endcode
 *
 *
 * <h2>Default settings with UIViewContentModeScaleAspectFill</h2>
 *
 * <h3>Result image (display size 100x100)</h3>
 *
 * @image html clouds100x100-fill.png "Fill image with default settings chops excess pixels. Size: 100x100."
 *
 * <h3>Example code</h3>
 *
 * @code
 *  [imageView setPathToNetworkImage: @"http://farm2.static.flickr.com/1165/644335254_4b8a712be5.jpg"
 *                    forDisplaySize: CGSizeMake(100, 100)
 *                       contentMode: UIViewContentModeScaleAspectFill];
 *
 *       source image size: 500x375  [aspect ratio: 1.3333]
 *            display size: 100x100  [aspect ratio: 1]
 *       result image size: 100x100  [aspect ratio: 1]
 *          image blt size: 133x100  [aspect ratio: 1.3333]
 * @endcode
 *
 *
 * <h2>NINetworkImageViewScaleToFitCropsExcess with UIViewContentModeScaleAspectFit</h2>
 *
 * <h3>Result image (display size 100x100)</h3>
 *
 * @image html clouds100x100-fit-cropped.png "Fit image with NINetworkImageViewScaleToFitCropsExcess crops the transparency. Size: 100x75."
 *
 * <h3>Example code</h3>
 *
 * @code
 *  // Turn on NINetworkImageViewScaleToFitCropsExcess
 *  imageView.scaleOptions |= NINetworkImageViewScaleToFitCropsExcess;
 *
 *  [imageView setPathToNetworkImage: @"http://farm2.static.flickr.com/1165/644335254_4b8a712be5.jpg"
 *                    forDisplaySize: CGSizeMake(100, 100)
 *                       contentMode: UIViewContentModeScaleAspectFill];
 *
 *       source image size: 500x375  [aspect ratio: 1.3333]
 *            display size: 100x100  [aspect ratio: 1]
 *       result image size: 100x75   [aspect ratio: 1.3333]
 *          image blt size: 100x75   [aspect ratio: 1.3333]
 * @endcode
 *
 *
 * <h2>NINetworkImageViewScaleToFillLeavesExcess with UIViewContentModeScaleAspectFill</h2>
 *
 * <h3>Result image (display size 100x100)</h3>
 *
 * @image html clouds100x100-fill-excess.png "Fill image with NINetworkImageViewScaleToFillLeavesExcess leaves the excess. Size: 133x100."
 *
 * <h3>Example code</h3>
 *
 * @code
 *  // Turn on NINetworkImageViewScaleToFillLeavesExcess
 *  imageView.scaleOptions |= NINetworkImageViewScaleToFillLeavesExcess;
 *
 *  [imageView setPathToNetworkImage: @"http://farm2.static.flickr.com/1165/644335254_4b8a712be5.jpg"
 *                    forDisplaySize: CGSizeMake(100, 100)
 *                       contentMode: UIViewContentModeScaleAspectFill];
 *
 *       source image size: 500x375  [aspect ratio: 1.3333]
 *            display size: 100x100  [aspect ratio: 1]
 *       result image size: 133x100  [aspect ratio: 1.3333]
 *          image blt size: 133x100  [aspect ratio: 1.3333]
 * @endcode
 */

/**
 * @class NINetworkImageView
 *
 *
 * <h2>Examples</h2>
 *
 * <h3>Two basic methods for setting the display size of the network image</h3>
 *
 * @code
 *  UIImage* image; // some previously loaded image.
 *  NINetworkImageView* imageView = [[[NINetworkImageView alloc] initWithImage:image] autorelease];
 *
 *  // Method #1: Use the image's frame to determine the display size for the network image.
 *  imageView.frame = CGRectMake(0, 0, 100, 100);
 *  [imageView setPathToNetworkImage:@"http://farm2.static.flickr.com/1165/644335254_4b8a712be5.jpg"];
 *
 *  // Method #2: use the method setPathToNetworkImage:forDisplaySize:
 *  [imageView setPathToNetworkImage: @"http://farm2.static.flickr.com/1165/644335254_4b8a712be5.jpg"
 *                    forDisplaySize: CGSizeMake(100, 100)];
 * @endcode
 *
 * <i>Code Breakdown</i>
 *
 * @code
 *  NINetworkImageView* imageView = [[[NINetworkImageView alloc] initWithImage:image] autorelease];
 * @endcode
 *
 * Initializes the network image view with a preloaded image, usually a "default" image
 * to be displayed until the network image downloads.
 *
 * @code
 *  imageView.frame = CGRectMake(0, 0, 100, 100);
 *  [imageView setPathToNetworkImage:@"http://farm2.static.flickr.com/1165/644335254_4b8a712be5.jpg"];
 * @endcode
 *
 * We must take care to set the frame before requesting the network image, otherwise the
 * image's display size will be 0,0 and the network image won't be cropped or sized to fit.
 *
 * @code
 *  [imageView setPathToNetworkImage: @"http://farm2.static.flickr.com/1165/644335254_4b8a712be5.jpg"
 *                    forDisplaySize: CGSizeMake(100, 100)];
 * @endcode
 *
 * If you don't want to modify the frame of the image, you can alternatively specify
 * the display size as a parameter to the setPathToNetworkImage: method.
 *
 *
 * <h3>Use a different contentMode for the network image.</h3>
 *
 * @code
 *  UIImage* image; // some previously loaded image.
 *  NINetworkImageView* imageView = [[[NINetworkImageView alloc] initWithImage:image] autorelease];
 *
 *  imageView.frame = CGRectMake(0, 0, 100, 100);
 *  imageView.contentMode = UIViewContentModeCenter; // Centers the image in the frame.
 *  [imageView setPathToNetworkImage: @"http://farm2.static.flickr.com/1165/644335254_4b8a712be5.jpg"
 *                       contentMode: UIViewContentModeScaleAspectFill];
 * @endcode
 *
 * <i>Code Breakdown</i>
 *
 * @code
 *  [imageView setPathToNetworkImage: @"http://farm2.static.flickr.com/1165/644335254_4b8a712be5.jpg"
 *                       contentMode: UIViewContentModeScaleAspectFill];
 * @endcode
 *
 * This means: <i>after the image is downloaded, crop and resize the image with an aspect
 * fill content mode.</i>
 * The image returned from the thread will be cropped and sized to fit the imageView perfectly
 * at the given 100x100 dimensions.
 * Because imageView has a contentMode of UIViewContentModeCenter, if we were to make the
 * image view larger the downloaded image would stay in the center of the image view and
 * leave empty space on all sides.
 */


/** @name Creating a Network Image View */

/**
 * Designated initializer.
 *
 * @param image  This will be the initialImage.
 * @fn NINetworkImageView::initWithImage:
 */


/**
 * @name Configurable Presentation Properties
 */

/**
 * The image being displayed while the network image is being fetched.
 *
 * This is the same image passed into initWithImage: immediately after initialization. This
 * is used when preparing this view for reuse. Changing the initial image after creating
 * the object will only display the new image if the currently displayed image is
 * is the initial image or nil.
 *
 * The initial image is drawn only using the view's contentMode. Cropping and resizing are only
 * performed on the image fetched from the network.
 *
 * @fn NINetworkImageView::initialImage
 */

/**
 * A flag for enabling the resizing of images for display.
 *
 * When enabled, the downloaded image will be resized to fit the dimensions of the image view
 * using the image view's content mode.
 *
 * When disabled, the full image is drawn as-is. This is generally much less efficient when
 * working with large photos and will also increase the memory footprint.
 *
 * If your images are pre-cropped and sized then this isn't necessary, but the network image
 * loader is smart enough to realize this so it's in your best interest to leave this on.
 *
 * By default this is YES.
 *
 * @fn NINetworkImageView::sizeForDisplay
 */

/**
 * Options for modifying the way images are cropped when scaling.
 *
 * By default this is NINetworkImageViewScaleToFitLeavesExcessAndScaleToFillCropsExcess.
 *
 * @see NINetworkImageViewScaleOptions
 * @fn NINetworkImageView::scaleOptions
 */

/**
 * The interpolation quality to use when resizing the image.
 *
 * The default value is kCGInterpolationDefault.
 *
 * @fn NINetworkImageView::interpolationQuality
 */


/** @name Configurable Properties */


/**
 * The image memory cache used by this image view to store the image in memory.
 *
 * It may be useful to specify your own image memory cache if you have a unique memory requirement
 * and do not want the image being placed in the global memory cache, potentially pushing out
 * other images.
 *
 * By default this is [Nimbus imageMemoryCache].
 *
 * @attention Setting this to nil will disable the memory cache. This will force the
 *                 image view to load the image from the disk cache or network, depending on
 *                 what is available.
 *
 * @remark If you replace Nimbus' global image memory cache with a new image cache after
 *              creating this image view, this image view will still use the old image cache.
 *
 * @see Nimbus::globalImageMemoryCache
 * @see Nimbus::setGlobalImageMemoryCache:
 * @fn NINetworkImageView::imageMemoryCache
 */

/**
 * The image disk cache used by this image view to store the image on disk.
 *
 * After the image has finished downloading we store it in a disk cache to avoid hitting the
 * network again if we want to load the image later on.
 *
 * By default this is [ASIDownloadCache sharedCache].
 *
 * @attention Setting this to nil will disable the disk cache. Images downloaded from the
 *                 network will be stored in the memory cache, if available.
 *
 * @fn NINetworkImageView::imageMemoryCache
 */

/**
 * The network operation queue used by this image view to load the image from network and disk.
 *
 * By default this is [Nimbus networkOperationQueue].
 *
 * @attention This property must be non-nil. If you attempt to set it to nil, a debug
 *                 assertion will fire and Nimbus' global network operation queue will be set.
 *
 * @see Nimbus::globalNetworkOperationQueue
 * @see Nimbus::setGlobalNetworkOperationQueue:
 *
 * @fn NINetworkImageView::networkOperationQueue
 */

/**
 * The maximum amount of time that an image will stay in memory after the request completes.
 *
 * If this value is non-zero then the respone header's expiration date information will be
 * ignored in favor of using this value.
 *
 * If this value is zero then the response header's max-age value will be used if it exists,
 * otherwise it will use the Expires value if it exists.
 *
 * A negative value will cause this image to NOT be stored in the memory cache.
 *
 * By default this is 0.
 *
 * @fn NINetworkImageView::maxAge
 */

/**
 * The lifetime for an image stored in the disk cache.
 *
 * You can choose to keep the image around forever (until explicitly deleted) or for the life
 * of an applicaton's session (when the app starts the next time the cache will be cleared).
 *
 * Example: Clearing the session cache.
 * @code
 *  [imageDiskCache clearCachedResponsesForStoragePolicy:ASICacheForSessionDurationCacheStoragePolicy];
 * @endcode
 *
 * Example: Clearing the permanent cache.
 * @code
 *  [imageDiskCache clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
 * @endcode
 *
 * By default this is NINetworkImageViewDiskCacheLifetimePermanent.
 *
 * @fn NINetworkImageView::diskCacheLifetime
 */

/**
 * The last path assigned to the image view.
 *
 * This property may be used to avoid setting the network path repeatedly and clobbering
 * previous requests.
 *
 * @note It is debatable whether this has any practical use and is being considered
 *            for removal.
 *
 * @fn NINetworkImageView::lastPathToNetworkImage
 */


/** @name State */

/**
 * Whether there is an active request for this image view.
 *
 * If there is currently an image being fetched then this will be YES.
 *
 * @fn NINetworkImageView::isLoading
 */


/** @name Delegation */

/**
 * Delegate for state change notifications.
 *
 * @fn NINetworkImageView::delegate
 */


/** @name Reusable View */

/**
 * Kill any network requests and replace the displayed image with the initial image.
 *
 * Prepares this view for reuse by cancelling any existing requests and displaying the
 * initial image again.
 *
 * @fn NINetworkImageView::prepareForReuse
 */


/**
 * @name Requesting a Network Image
 */

/**
 * Load an image from the network using the current frame as the display size.
 *
 * Loads the image from the memory cache if possible, otherwise fires off a network request
 * with this object's network image information.
 *
 * Uses self.contentMode to crop and resize the image.
 *
 * The image's current frame will be used as the display size for the image.
 *
 * @param pathToNetworkImage  The network path to the image to be displayed.
 * @fn NINetworkImageView::setPathToNetworkImage:
 */

/**
 * Load an image from the network with a specific display size.
 *
 * Loads the image from the memory cache if possible, otherwise fires off a network request
 * with this object's network image information.
 *
 * Uses self.contentMode to crop and resize the image.
 *
 * @param pathToNetworkImage  The network path to the image to be displayed.
 * @param displaySize         Used instead of the image's frame to determine the display size.
 * @fn NINetworkImageView::setPathToNetworkImage:forDisplaySize:
 */

/**
 * Load an image from the network with a specific display size.
 *
 * Loads the image from the memory cache if possible, otherwise fires off a network request
 * with this object's network image information.
 *
 * @param pathToNetworkImage  The network path to the image to be displayed.
 * @param displaySize         Used instead of the image's frame to determine the display size.
 * @param contentMode         The content mode used to crop and resize the image.
 * @fn NINetworkImageView::setPathToNetworkImage:forDisplaySize:contentMode:
 */

/**
 * Load an image from the network with a crop rect and the current frame as the display size.
 *
 * Loads the image from the memory cache if possible, otherwise fires off a network request
 * with this object's network image information.
 *
 * Uses self.contentMode to crop and resize the image.
 *
 * The image's current frame will be used as the display size for the image.
 *
 * @param pathToNetworkImage  The network path to the image to be displayed.
 * @param cropRect            x/y, width/height are in percent coordinates.
 *                                 Valid range is [0..1] for all values.
 * @fn NINetworkImageView::setPathToNetworkImage:cropRect:
 */

/**
 * Load an image from the network with a specific display size.
 *
 * Loads the image from the memory cache if possible, otherwise fires off a network request
 * with this object's network image information.
 *
 * The image's current frame will be used as the display size for the image.
 *
 * @param pathToNetworkImage  The network path to the image to be displayed.
 * @param contentMode         The content mode used to crop and resize the image.
 * @fn NINetworkImageView::setPathToNetworkImage:contentMode:
 */

/**
 * Load an image from the network with a specific display size and crop rect.
 *
 * Loads the image from the memory cache if possible, otherwise fires off a network request
 * with this object's network image information.
 *
 * @param pathToNetworkImage  The network path to the image to be displayed.
 * @param cropRect            x/y, width/height are in percent coordinates.
 *                                 Valid range is [0..1] for all values.
 * @param displaySize         Used instead of the image's frame to determine the display size.
 * @param contentMode         The content mode used to crop and resize the image.
 * @fn NINetworkImageView::setPathToNetworkImage:forDisplaySize:contentMode:cropRect:
 */


/**
 * @name Subclassing
 *
 * The following methods are provided to aid in subclassing and are not meant to be
 * used externally.
 */

/**
 * A network request has begun.
 *
 * @fn NINetworkImageView::networkImageViewDidStartLoading
 */

/**
 * The image has been loaded, either from the network or in-memory.
 *
 * @fn NINetworkImageView::networkImageViewDidLoadImage:
 */

/**
 * A network request failed to load.
 *
 * @fn NINetworkImageView::networkImageViewDidFailWithError:
 */

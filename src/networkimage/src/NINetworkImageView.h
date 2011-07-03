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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef NIMBUS_STATIC_LIBRARY
#import "NimbusCore/NIInMemoryCache.h"
#else
#import "NIInMemoryCache.h"
#endif

@class NIHTTPImageRequest;
@protocol NINetworkImageViewDelegate;
@protocol ASICacheDelegate;

/**
 * A network-enabled image view that consumes minimal amounts of memory.
 *
 *      @ingroup Network-Image-User-Interface
 *
 * Intelligently crops and resizes images for optimal memory use and uses threads to avoid
 * processing images on the UI thread.
 *
 * Example: two basic methods for setting the display size of the network image
 *
 * @code
 *  UIImage* image; // some previously loaded image.
 *
 *  // Initialize the network image view with a preloaded image, usually a "default" image
 *  // to be displayed until the network image downloads.
 *  NINetworkImageView imageView = [[[NINetworkImageView alloc] initWithImage:image] autorelease];
 *
 *  // Method #1: Use the image's frame to determine the display size for the network image.
 *
 *  // We must take care to set the frame before requesting the network image, otherwise the
 *  // image's display size will be 0,0 and the network image won't be cropped or sized to fit.
 *  imageView.frame = CGRectMake(0, 0, 100, 100);
 *
 *  // Begin loading the network image.
 *  [imageView setPathToNetworkImage:@"http://farm2.static.flickr.com/1165/644335254_4b8a712be5.jpg"];
 *
 *  // Method #2: use the method setPathToNetworkImage:forDisplaySize:
 *
 *  // If you don't want to modify the frame of the image yet, you can alternatively specify
 *  // the display size as a parameter to the setPathToNetworkImage: method.
 *  [imageView setPathToNetworkImage: @"http://farm2.static.flickr.com/1165/644335254_4b8a712be5.jpg"
 *                    forDisplaySize: CGSizeMake(100, 100)];
 * @endcode
 *
 */
@interface NINetworkImageView : UIImageView {
@private
  // The active network request for the image.
  NIHTTPImageRequest* _request;

  NSString* _memoryCachePrefix;

  UIImage* _initialImage;

  NSString* _lastPathToNetworkImage;

  BOOL _cropImageForDisplay;
  BOOL _sizeForDisplay;

  id<NINetworkImageViewDelegate> _delegate;

  // Expiration information.
  NSTimeInterval  _maxAge;

  NIImageMemoryCache*   _imageMemoryCache;
  id<ASICacheDelegate>  _imageDiskCache;
  NSOperationQueue*     _networkOperationQueue;
}

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
 */
@property (nonatomic, readwrite, retain) UIImage* initialImage;


/**
 * @name Presentation Configuration
 * @{
 *
 * Properties that allow you to configure the way downloaded images are displayed. These properties
 * do not affect the way the initial image is drawn.
 */
#pragma mark Presentation Configuration

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
 * By default this is enabled.
 */
@property (nonatomic, readwrite, assign) BOOL sizeForDisplay;

/**
 * A flag for enabling the cropping of images to fit their display frame.
 *
 * Applicable only when sizeForDisplay is enabled.
 *
 * When enabled, the final image is cropped to fit the display size perfectly. If you have
 * a very wide picture being placed in a square frame and the image is sized to fill with aspect
 * ratio maintained, then the left and right edges of the image will be cropped and you will
 * have a square image.
 *
 * When disabled, the final image will not be cropped, leaving the excess parts of the image
 * intact. It is your responsibility to enable clipping if you do not wish to see these parts
 * of the image.
 *
 * Turning this off is useful when you want to show a grid of square images but still be
 * able to access the image at the correct aspect ratio.
 *
 * By default this is enabled.
 */
@property (nonatomic, readwrite, assign) BOOL cropImageForDisplay;


/**@}*/// End of Presentation Configuration


/**
 * @name Basic Configuration
 * @{
 *
 * Basic properties of the image view that are exposed for configuration.
 */
#pragma mark Basic Configuration

/**
 * The image memory cache used by this image view to store the image in memory.
 *
 * It may be useful to specify your own image memory cache if you have a unique memory requirement
 * and do not want the image being placed in the global memory cache, potentially pushing out
 * other images.
 *
 *      @attention Setting this to nil will disable the memory cache. This will force the
 *                 image view to load the image from the disk cache or network, depending on
 *                 what is available.
 *
 *      @remark If you replace Nimbus' global image memory cache with a new image cache after
 *              creating this image view, this image view will still use the old image cache.
 *
 *      @see Nimbus::globalImageMemoryCache
 *      @see Nimbus::setGlobalImageMemoryCache:
 *
 * By default this will be Nimbus' global image memory cache.
 */
@property (nonatomic, readwrite, retain) NIImageMemoryCache* imageMemoryCache;

/**
 * The image disk cache used by this image view to store the image on disk.
 *
 * After the image has finished downloading we store it in a disk cache to avoid hitting the
 * network again if we want to load the image later on.
 *
 *      @attention Setting this to nil will disable the disk cache. Images downloaded from the
 *                 network will be stored in the memory cache, if available.
 *
 * By default this is [ASIDownloadCache sharedCache].
 */
@property (nonatomic, readwrite, retain) id<ASICacheDelegate> imageDiskCache;

/**
 * The network operation queue used by this image view to load the image from network and disk.
 *
 *      @attention This property must be non-nil. If you attempt to set it to nil, a debug
 *                 assertion will fire and Nimbus' global network operation queue will be set.
 *
 *      @see Nimbus::globalNetworkOperationQueue
 *      @see Nimbus::setGlobalNetworkOperationQueue:
 *
 * By default this will be Nimbus' global network operation queue.
 */
@property (nonatomic, readwrite, retain) NSOperationQueue* networkOperationQueue;

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
 */
@property (nonatomic, readwrite, assign) NSTimeInterval maxAge;

/**@}*/// End of Basic Configuration


/**
 * A prefix for the memory cache key.
 *
 * Prefixed to the memory cache key when looking for and storing this image in the memory cache.
 *
 * This makes it possible to keep multiple versions of a network image from the same url in
 * memory cropped and/or resized using different parameters. This can be useful if you're
 * downloading a high resolution photo and using that same photo in various locations with
 * different presentation requirements (a table view 50x50 icon and a larger 300x200 thumbnail
 * for example).
 *
 * By default this is nil.
 */
@property (nonatomic, readwrite, copy) NSString* memoryCachePrefix;

/**
 * The last path assigned to the image view.
 *
 * This property may be used to avoid setting the network path repeatedly and clobbering
 * previous requests.
 *
 *      @note It is debatable whether this has any practical use and is being considered
 *            for removal.
 */
@property (nonatomic, readonly, copy) NSString* lastPathToNetworkImage;

/**
 * Whether there is an active request for this image view.
 *
 * If there is currently an image being fetched then this will be YES.
 */
@property (nonatomic, readonly, assign) BOOL isLoading;

/**
 * Delegate for state change notifications.
 */
@property (nonatomic, readwrite, assign) id<NINetworkImageViewDelegate> delegate;

/**
 * Designated initializer.
 *
 *      @param image  This will be the initialImage.
 */
- (id)initWithImage:(UIImage *)image;

/**
 * Kill any network requests and replace the displayed image with the initial image.
 *
 * Prepares this view for reuse by cancelling any existing requests and displaying the
 * initial image again.
 */
- (void)prepareForReuse;


/**
 * @name Request a network image
 * @{
 *
 * The following methods each achieve the same goal of loading an image from the network but
 * allow for customization of the parameters.
 */
#pragma mark Request a network image

/**
 * Load an image from the network using the current frame as the display size.
 *
 * Loads the image from the memory cache if possible, otherwise fires off a network request
 * with this object's network image information.
 *
 * The image's current frame will be used as the display size for the image.
 *
 *      @param pathToNetworkImage  The network path to the image to be displayed.
 */
- (void)setPathToNetworkImage: (NSString *)pathToNetworkImage;

/**
 * Load an image from the network with a specific display size.
 *
 * Loads the image from the memory cache if possible, otherwise fires off a network request
 * with this object's network image information.
 *
 *      @param pathToNetworkImage  The network path to the image to be displayed.
 *      @param displaySize         Used instead of the image's frame to determine the display size.
 */
- (void)setPathToNetworkImage: (NSString *)pathToNetworkImage
               forDisplaySize: (CGSize)displaySize;

/**
 * Load an image from the network with a crop rect and the current frame as the display size.
 *
 * Loads the image from the memory cache if possible, otherwise fires off a network request
 * with this object's network image information.
 *
 * The image's current frame will be used as the display size for the image.
 *
 *      @param pathToNetworkImage  The network path to the image to be displayed.
 *      @param cropRect            x/y, width/height are in percent coordinates.
 *                                 Valid range is [0..1] for all values.
 */
- (void)setPathToNetworkImage: (NSString *)pathToNetworkImage
                     cropRect: (CGRect)cropRect;

/**
 * Load an image from the network with a specific display size and crop rect.
 *
 * Loads the image from the memory cache if possible, otherwise fires off a network request
 * with this object's network image information.
 *
 *      @param pathToNetworkImage  The network path to the image to be displayed.
 *      @param cropRect            x/y, width/height are in percent coordinates.
 *                                 Valid range is [0..1] for all values.
 *      @param displaySize         Used instead of the image's frame to determine the display size.
 */
- (void)setPathToNetworkImage: (NSString *)pathToNetworkImage
                     cropRect: (CGRect)cropRect
               forDisplaySize: (CGSize)displaySize;


/**@}*/// End of Request a network image


/**
 * @name Subclassing
 * @{
 *
 * The following methods are provided to aid in subclassing and are not meant to be
 * used externally.
 */
#pragma mark Subclassing

/**
 * A network request has begun.
 */
- (void)networkImageViewDidStartLoading;

/**
 * The image has been loaded, either from the network or in-memory.
 */
- (void)networkImageViewDidLoadImage:(UIImage *)image;

/**
 * A network request failed to load.
 */
- (void)networkImageViewDidFailToLoad:(NSError *)error;

/**@}*/

@end


/**
 * The image view delegate used to inform of state changes.
 *
 *      @ingroup Network-Image-Protocols
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
- (void)networkImageViewDidFailLoad:(NINetworkImageView *)imageView;

@end

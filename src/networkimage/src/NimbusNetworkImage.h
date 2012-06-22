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

/**
 * @defgroup NimbusNetworkImage Nimbus Network Image
 * @{
 *
 * <div id="github" feature="networkimage"></div>
 *
 * Image views that load images from the network and efficiently store the result in memory and on
 * disk.
 *
 * @image html NINetworkImageViewExample1.png "The various available content modes."
 *
 * <h2>Minimum Requirements</h2>
 *
 * Required frameworks:
 *
 * - UIKit.framework
 * - CoreText.framework
 * - AFNetworking https://github.com/AFNetworking/AFNetworking
 *
 * Minimum Operating System: <b>iOS 4.0</b>
 *
 * Source located in <code>src/networkimage/src</code>
 *
 * Presented below is an architectural overview of the Nimbus network image library.
 *
 * @image html NINetworkImageDesign1.png "NINetworkImage Design"
 *
 * -# To begin using a network image view, simply create an instance of an NINetworkImageView
 *    and use it as you would a UIImageView. The initial image you assign to the view will be
 *    used as the "loading" image and must be a locally accessible image. Note that this
 *    image will not be cropped and resized in any way, so you should take care to crop and
 *    resize it beforehand as necessary.
 * -# Once you have created your network image view and assigned the initial image, the next step
 *    is to load the network image. Call any of the @link NINetworkImageView::setPathToNetworkImage: setPathToNetworkImage@endlink methods to fire
 *    off a network request for the image on a separate thread.
 * -# A new NINetworkImageRequest thread will spin off and initiate the request to the network.
 * -# Once the image has been retrieved from the net, the thread crops and resizes the image
 *    depending on the presentation configurations specified by the image view. In this example,
 *    @link NINetworkImageView::sizeForDisplay sizeForDisplay@endlink and
 *    @link NINetworkImageView::cropImageForDisplay cropImageForDisplay@endlink are enabled.
 *    In this step the image is resized to fit the aspect ratio of the display size.
 * -# We then crop the image to fit the display frame.
 * -# Upon completion of all image modifications, we complete the request and return only the
 *    modified image to the image view. This helps to reduce memory usage.
 * -# The resized and cropped image is then stored in the in-memory image cache for quick access
 *    in the future.
 * -# At last, the image view sets the new image and displays it.
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NimbusCore.h"
#import "NIImageProcessing.h"
#import "NINetworkImageView.h"

/**@}*/

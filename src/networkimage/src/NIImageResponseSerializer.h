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

#import "AFURLResponseSerialization.h"

#import "NINetworkImageView.h" // For NINetworkImageViewScaleOptions.

/**
 * The NIImageResponseSerializer class provides an implementation of the AFNetworking serializer
 * object for Nimbus network images.
 *
 * This object is used internally with NINetworkImageView, though it can be used with custom
 * AFNetworking implementations. Each of the properties should be respected as per the documentation
 * in NIImageProcessing.
 */
@interface NIImageResponseSerializer : AFImageResponseSerializer
@property (nonatomic, assign) UIViewContentMode contentMode;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) CGSize displaySize;
@property (nonatomic, assign) NINetworkImageViewScaleOptions scaleOptions;
@property (nonatomic, assign) CGInterpolationQuality interpolationQuality;
@end

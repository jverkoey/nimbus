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
 * @mainpage
 *
 * Nimbus is an iOS framework whose feature set grows only as fast as its documentation.
 *
 * By focusing on documentation first and features second, Nimbus hopes to be a framework
 * that accelerates the development process of any application by being easy to use and simple
 * to understand.
 *
 * <h2>Getting Started</h2>
 *
 * - Start by exploring the "Getting Started" <a href="https://github.com/jverkoey/nimbus/tree/master/examples/gettingstarted">example applications</a>.
 * - Follow Nimbus' development through its <a href="http://jverkoey.github.com/nimbus/group___version-_history.html">version history</a>.
 * - See the <a href="http://jverkoey.github.com/nimbus/group___version-3-to-4.html">latest API diffs</a>.
 * - Read the <a href="http://jverkoey.github.com/nimbus/group___three20-_migration-_guide.html">Three20 Migration Guide</a>.
 *
 * <h2>Nimbus' Background</h2>
 *
 * Nimbus has been built with much inspiration from the Three20 framework. That being said, there
 * are a number of fundamental problems with Three20 that Nimbus works very hard to avoid.
 * Among them:
 *
 * - Poor documentation.
 * - Spaghetti dependencies.
 * - Suffering from a "kitchen sink" complex.
 * - A complex build structure.
 * - An enormous number of difficult-to-solve bugs.
 * - Next-to-zero test coverage.
 *
 * For its weaknesses, Three20 does provide a good deal of value through its feature set. It is
 * used in over 100 apps in the app store by companies such as Facebook, LinkedIn, Posterous,
 * Meetup, and SCVNGR.
 *
 * Nimbus hopes to one day provide as much value as Three20 does on a feature-by-feature
 * comparison, but with the invaluable benefit of sublime documentation and test coverage.
 *
 * <h2>Nimbus' Development Roadmap</h2>
 *
 * I'm a strong believer in shipping early, shipping fast, and shipping often. Any other way of
 * being genuinely frustrates me so I hope to apply this to Nimbus.
 *
 * I plan to tackle Nimbus by first building a strong foundation in the Nimbus Core. From there
 * I will branch out and tackle migrating a variety of features over from Three20. Some features
 * on my immediate horizon in increasing order of difficulty:
 *
 * - The Launcher (done!)
 * - Network images (done!)
 * - TTNavigator (in progress)
 *
 * I will use a <b>MAJOR.MINOR.INCREMENTAL</b> versioning system.
 *
 * <b>Major</b> version numbers will be reserved for major milestones in the project (completing a
 * large set of features, for example).
 *
 * <b>Minor</b> version numbers will be reserved for minor milestones in the project (completing a
 * small set of features, for example).
 *
 * <b>Incremental</b> version numbers will be reserved for stable cuts of Nimbus after individual
 * tasks are completed (fully implementing the Launcher, for example).
 *
 * I'd like to treat the incremental version number like points from a video game. Finishing an
 * individual task will increase the score for a particular major release, so version 1.130.2
 * indicates "the first major release of Nimbus, 130 tasks tackled, and 2 incremental builds
 * for bugfixes and daily progress since the 130th task was finished". Perhaps there may be some
 * merit in allowing people who complete tasks to earn these points in some sense as well to
 * encourage some friendly competition.
 *
 * <h2>Who's working on Nimbus?</h2>
 *
 * Nimbus was started by me (Jeff Verkoeyen) in June of 2011. My background includes over 10 years
 * of software development and experience at Google and Facebook designing software and
 * building user interfaces. I took over the Three20 project in 2009 after its original creator,
 * Joe Hewitt, moved on to other projects. Over the proceeding 6 months much time was invested in
 * splitting the framework apart and attempting to clobber its spaghetti dependencies while
 * improving the project's documentation.
 *
 * In early May of 2010, my life was completely shaken up: my mother suddenly passed
 * away at age 42 due to a pulmonary embolism. This is relevant because for the following year
 * I checked out of life and, as a direct result, little progress was made with Three20. Over the
 * last year I've found that shedding baggage is not only an emotionally satisfying process, but
 * also a necessary one. So I am shedding Three20's baggage and out of the remaining bits building
 * Nimbus. I learned a great deal from working with an open source project and community and
 * sincerely hope to carry much of this knowledge over to Nimbus.
 *
 * <h2>What's happening to Three20?</h2>
 *
 * My goal with Nimbus is to eventually provide a feature set that overlaps Three20's. I
 * sincerely hope to make it easy for anyone using Three20 to transition to Nimbus. In the
 * meantime, Three20 will likely stay in a bug-fixing state. The library is stable as it stands
 * so I have every bit of confidence in the community to tackle any bugs as necessary.
 */

/**
 * @defgroup Version-History Version History
 *
 * Presented here are the API diffs for each major release of Nimbus.
 */

/**
 * @defgroup Version-5-0 Version 0.5 API Changes
 * @ingroup Version-History
 *
 * Version 0.5.0 of Nimbus was released on July 29, 2011. This major version introduced the new
 * Nimbus @link NimbusOverview Overview@endlink, a debugging tool that shows detailed information
 * about the state of your device and application in the device's status bar area.
 *
 * @image html overview1.png "The Overview added to the network photo album app."
 *
 *
 * <h2>Added Frameworks</h2>
 *
 * - @link NimbusOverview Nimbus Overview@endlink
 *
 *
 * <h2>Core</h2>
 *
 * <h3>NICommonMetrics[.h]</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>NIStatusBarFrameAnimationCurve()</code>
 * - <span class="apiDiffAdded">Added</span> <code>NIStatusBarFrameAnimationDuration()</code>
 * - <span class="apiDiffAdded">Added</span> <code>NIStatusBarHeight()</code>
 * - <span class="apiDiffAdded">Added</span> <code>NIDeviceRotationDuration()</code>
 *
 * <h3>NIDataStructures[.h]</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>[NILinkedList @link NILinkedList::objectEnumerator objectEnumerator@endlink]</code>
 *
 * <h3>NIDeviceOrientation[.h]</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>NIRotateTransformForOrientation()</code>
 *
 *
 * <h2>Network Image</h2>
 *
 * <h3>NINetworkImageView[.m]</h3>
 *
 * - <span class="apiDiffBugfix">Bugfix</span> Cancel network requests without blocking on the main thread.
 *
 *
 * <h2>Photos</h2>
 *
 * <h3>NIToolbarPhotoViewController[.m]</h3>
 *
 * - <span class="apiDiffBugfix">Bugfix</span> Fix various memory leaks related to not releasing views on dealloc.
 * - <span class="apiDiffBugfix">Bugfix</span> Fix memory leak when toggling the toolbar mode between a scrubber and buttons.
 *
 *
 * <h2>Examples</h2>
 *
 * <h3>NetworkPhotoAlbums</h3>
 *
 * - <span class="apiDiffBugfix">Bugfix</span> Fix various memory leaks related to not releasing views on dealloc.
 *
 *
 * <h2>Real Live People Involved in this Release</h2>
 *
 * <div class="contributor_profile"> 
 *  <img width="135px" height="135px" src="http://www.gravatar.com/avatar/f3c8603c353afa79b9f1c77f35efd566?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 *  <div class="name">Jeff Verkoeyen</div> 
 *  <div class="github"><a href="http://github.com/jverkoey">jverkoey</a></div> 
 * </div>
 *
 * <div class="clearfix"></div>
 *
 * <h3>Add Your Name to This List</h3>
 *
 * Contributions are highly encouraged! If you have a feature that you feel would fit within the
 * Nimbus framework, feel free to fire off a pull request on GitHub. Bugs may be reported
 * using the issue tracker on GitHub as well.
 *
 * Check out the <a href="https://github.com/jverkoey/nimbus/issues?sort=created&direction=desc&state=open&page=1&milestone=5">tasks grab bag</a>
 * for opportunities to help out.
 *
 * <h2>Robots Involved in this Release</h2>
 *
 * <div class="contributor_profile"> 
 *  <div class="name"><a href="http://www.stack.nl/~dimitri/doxygen/">Doxygen</a></div> 
 * </div>
 *
 * <div class="clearfix"></div>
 */

/**
 * @defgroup Version-4 Version 0.4 API Changes
 * @ingroup Version-History
 *
 * Version 0.4 of Nimbus was released on July 20, 2011. This major version introduced the new
 * Nimbus @link NimbusPhotos photo viewer@endlink, a high-performance, low memory footprint photo
 * viewer built for the iPhone and iPad. This version of Nimbus also introduced
 * @link NimbusProcessors Processors@endlink and JSONKit.
 *
 * <h2>Minor Releases</h2>
 *
 * - Version @link Version-4-1 0.4.1.0@endlink - Released on July 22, 2011
 *
 *
 * <h2>Added Frameworks</h2>
 *
 * - @link NimbusPhotos Nimbus Photos@endlink
 * - @link NimbusProcessors Nimbus Processors@endlink
 * - JSONKit
 *
 *
 * <h2>Core</h2>
 *
 * <h3>NIBlocks[.h] <span class="apiDiffAdded">Added</span></h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>NIBasicBlock</code>
 * - <span class="apiDiffAdded">Added</span> <code>NIErrorBlock</code>
 *
 * <h3>NICommonMetrics[.h/m] <span class="apiDiffAdded">Added</span></h3>
 *
 * @link Common-Metrics Common Metrics@endlink
 *
 * - <span class="apiDiffAdded">Added</span> <code>NIToolbarHeightForOrientation()</code>
 * - <span class="apiDiffAdded">Added</span> <code>NIStatusBarAnimationCurve()</code>
 * - <span class="apiDiffAdded">Added</span> <code>NIStatusBarAnimationDuration()</code>
 *
 * <h3>NIDataStructures[.h]</h3>
 *
 * @link Data-Structures Data Structures@endlink
 *
 * - Documentation updated for NILinkedList.
 *
 * <h3>NIDebuggingTools[.h]</h3>
 *
 * @link Debugging-Tools Debugging Tools@endlink
 *
 * - Documentation updated.
 *
 * <h3>NIDeviceOrientation[.h]</h3>
 *
 * @link Device-Orientation Device Orientation@endlink
 *
 * - Documentation updated.
 *
 * <h3>NIInMemoryCache[.h]</h3>
 *
 * - Documentation updated for NIMemoryCache and NIImageMemoryCache.
 * - <span class="apiDiffAdded">Added</span> <code>@link NIMemoryCache::hasObjectWithName: -[NIMemoryCache hasObjectWithName:]@endlink</code>
 * - <span class="apiDiffAdded">Added</span> <code>@link NIMemoryCache::dateOfLastAccessWithName: -[NIMemoryCache dateOfLastAccessWithName:]@endlink</code>
 * - <span class="apiDiffAdded">Added</span> <code>@link NIMemoryCache::didSetObject:withName: -[NIMemoryCache didSetObject:withName:]@endlink</code>
 * - <span class="apiDiffBugfix">Bugfix</span> NIMemoryCache now automatically responds to <code>UIApplicationDidReceiveMemoryWarningNotification</code> notifications.
 * - <span class="apiDiffBugfix">Bugfix</span> Fixed infinite loop in NIImageMemoryCache when adding images to an empty cache that was
 *            too small to fit the image.
 *
 * <h3>NIOperations[.h/m] <span class="apiDiffAdded">Added</span></h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>NIOperation</code>
 * - <span class="apiDiffAdded">Added</span> <code>NIOperationDelegate</code>
 * - <span class="apiDiffAdded">Added</span> <code>NIReadFileFromDiskOperation</code>
 *
 * <h3>NISDKAvailability[.h]</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>NIScreenScale()</code>
 * - <span class="apiDiffAdded">Added</span> <code>NIUITapGestureRecognizerClass()</code>
 *
 * <h3>NIState[.h]</h3>
 *
 * - <span class="apiDiffModified">Modified</span> <code>+[Nimbus @link Nimbus::imageMemoryCache imageMemoryCache@endlink]</code>
 * <table class="modificationtable"><tr><th></th><th>Declaration</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">+ (NIImageMemoryCache *)globalImageMemoryCache</td></tr> 
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>+ (NIImageMemoryCache *)imageMemoryCache</tt></td></tr></table>
 *
 * - <span class="apiDiffModified">Modified</span> <code>+[Nimbus @link Nimbus::networkOperationQueue networkOperationQueue@endlink]</code>
 * <table class="modificationtable"><tr><th></th><th>Declaration</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">+ (NSOperationQueue *)globalNetworkOperationQueue</td></tr> 
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>+ (NSOperationQueue *)networkOperationQueue</tt></td></tr></table>
 *
 * - <span class="apiDiffModified">Modified</span> <code>+[Nimbus @link Nimbus::setImageMemoryCache: setImageMemoryCache:@endlink]</code>
 * <table class="modificationtable"><tr><th></th><th>Declaration</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">+ (void)setGlobalImageMemoryCache:(NIImageMemoryCache *)imageMemoryCache</td></tr> 
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>+ (void)setImageMemoryCache:(NIImageMemoryCache *)imageMemoryCache</tt></td></tr></table>
 *
 * - <span class="apiDiffModified">Modified</span> <code>+[Nimbus @link Nimbus::setNetworkOperationQueue: setNetworkOperationQueue:@endlink]</code>
 * <table class="modificationtable"><tr><th></th><th>Declaration</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">+ (void)setGlobalNetworkOperationQueue:(NSOperationQueue *)queue</td></tr> 
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>+ (void)setNetworkOperationQueue:(NSOperationQueue *)queue</tt></td></tr></table>
 *
 *
 * <h2>Network Image</h2>
 *
 * <h3>NIHTTPImageRequest[.h]</h3>
 *
 * - <span class="apiDiffRemoved">Removed</span> <code>NIHTTPImageRequest.cropImageForDisplay</code>
 * - <span class="apiDiffAdded">Added</span> <code>@link NIHTTPImageRequest::scaleOptions NIHTTPImageRequest.scaleOptions@endlink</code>
 * - <span class="apiDiffAdded">Added</span> <code>@link NIHTTPImageRequest::interpolationQuality NIHTTPImageRequest.interpolationQuality@endlink</code>
 * - <span class="apiDiffAdded">Added</span> <code>@link NIHTTPImageRequest::imageFromSource:withContentMode:cropRect:displaySize:scaleOptions:interpolationQuality: +[NIHTTPImageRequest imageFromSource:withContentMode:cropRect:displaySize:scaleOptions:interpolationQuality:]@endlink</code>
 * - <span class="apiDiffFeature">Feature</span> Better configuration for image scaling and cropping via @link NINetworkImageViewScaleOptions@endlink.
 *
 * <h3>NINetworkImageView[.h]</h3>
 *
 * - <span class="apiDiffRemoved">Removed</span> <code>NINetworkImageView.cropImageForDisplay</code>
 * - <span class="apiDiffAdded">Added</span> <code>NINetworkImageViewScaleToFitLeavesExcessAndScaleToFillCropsExcess</code>
 * - <span class="apiDiffAdded">Added</span> <code>NINetworkImageViewScaleToFitCropsExcess</code>
 * - <span class="apiDiffAdded">Added</span> <code>NINetworkImageViewScaleToFillLeavesExcess</code>
 * - <span class="apiDiffAdded">Added</span> <code>@link NINetworkImageView::scaleOptions NINetworkImageView.scaleOptions@endlink</code>
 * - <span class="apiDiffAdded">Added</span> <code>@link NINetworkImageView::interpolationQuality NINetworkImageView.interpolationQuality@endlink</code>
 * - <span class="apiDiffFeature">Feature</span> Added support for loading images from disk.
 * - <span class="apiDiffFeature">Feature</span> Better configuration for image scaling and cropping via @link NINetworkImageViewScaleOptions@endlink.
 *
 *
 * <h2>Real Live People Involved in this Release</h2>
 *
 * <div class="contributor_profile"> 
 *  <img width="135px" height="135px" src="http://www.gravatar.com/avatar/f3c8603c353afa79b9f1c77f35efd566?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 *  <div class="name">Jeff Verkoeyen</div> 
 *  <div class="github"><a href="http://github.com/jverkoey">jverkoey</a></div> 
 * </div>
 *
 * <div class="clearfix"></div>
 *
 * <h3>Add Your Name to This List</h3>
 *
 * Contributions are highly encouraged! If you have a feature that you feel would fit within the
 * Nimbus framework, feel free to fire off a pull request on GitHub. Bugs may be reported
 * using the issue tracker on GitHub as well.
 *
 * Check out the <a href="https://github.com/jverkoey/nimbus/issues?sort=created&direction=desc&state=open&page=1&milestone=5">tasks grab bag</a>
 * for opportunities to help out.
 *
 *
 * <h2>Robots Involved in this Release</h2>
 *
 * <div class="contributor_profile"> 
 *  <div class="name"><a href="http://www.stack.nl/~dimitri/doxygen/">Doxygen</a></div> 
 * </div>
 *
 * <div class="clearfix"></div>
 */

/**
 * @defgroup Version-4-1 Version 0.4.1 API Changes
 * @ingroup Version-4
 *
 * Version 0.4.1 of Nimbus was released on July 22, 2011. This minor version introduced the new
 * Nimbus @link NIPhotoScrubberView photo scrubber@endlink, a highly responsive photo
 * scrubber built for the iPhone and iPad and modeled after Apple's own Photos.app's photo
 * scrubber.
 *
 * @image html scrubber1.png "Screenshot of NIPhotoScrubberView on the iPad."
 *
 * <h2>Core</h2>
 *
 * <h3>NICommonMetrics[.h]</h3>
 *
 * - <span class="apiDiffModified">Modified</span> Fixed incorrect documentation for <code>NIStatusBarAnimationCurve()</code>.
 *
 * <h3>NIDataStructures[.h]</h3>
 *
 * - <span class="apiDiffModified">Modified</span> Added a new documentation section @link Data-Structures Comparison of Data Structures@endlink.
 *
 * <h3>NIInMemoryCache[.m]</h3>
 *
 * - <span class="apiDiffBugfix">Bugfix</span> Fixed a memory leak in NIMemoryCache.
 *
 *
 * <h2>Photos</h2>
 *
 * <h3>NIPhotoAlbumScrollView[.h]</h3>
 *
 * - <span class="apiDiffBugfix">Bugfix</span> Fixed race condition where loading the thumbnail disabled zooming.
 *   (thanks to <a href="http://github.com/steipete">steipete</a>.)
 * - <span class="apiDiffAdded">Added</span> <code>NIPhotoAlbumScrollView.@link NIPhotoAlbumScrollView::zoomingAboveOriginalSizeIsEnabled zoomingAboveOriginalSizeIsEnabled@endlink</code>
 * - <span class="apiDiffAdded">Added</span> <code>- [NIPhotoAlbumScrollView @link NIPhotoAlbumScrollView::setCenterPhotoIndex:animated: setCenterPhotoIndex:animated:@endlink]</code>
 * - <span class="apiDiffModified">Modified</span> <code>NIPhotoAlbumScrollView.@link NIPhotoAlbumScrollView::zoomingIsEnabled zoomingIsEnabled@endlink</code>
 * @htmlonly<table class="modificationtable"><tr><th></th><th>Accessor Name</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">@property (nonatomic, readwrite, assign) BOOL zoomingIsEnabled</td></tr> 
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>@property (nonatomic, readwrite, assign, getter=isZoomingEnabled) BOOL zoomingIsEnabled</tt></td></tr></table>@endhtmlonly
 * - <span class="apiDiffModified">Modified</span> <code>NIPhotoAlbumScrollView.@link NIPhotoAlbumScrollView::centerPhotoIndex centerPhotoIndex@endlink</code>
 * @htmlonly<table class="modificationtable"><tr><th></th><th>Method Name and Access</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">@property (nonatomic, readonly, assign) NSInteger currentCenterPhotoIndex</td></tr> 
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>@property (nonatomic, readwrite, assign) NSInteger centerPhotoIndex</tt></td></tr></table>@endhtmlonly
 *
 * <h3>NIPhotoScrollView[.h]</h3>
 *
 * - <span class="apiDiffBugfix">Bugfix</span> Fix thumbnail size calculations for photos that are smaller than the screen so that the thumbnail is placed exactly where the photo will appear.
 * - <span class="apiDiffAdded">Added</span> <code>NIPhotoScrollView.@link NIPhotoScrollView::zoomingAboveOriginalSizeIsEnabled zoomingAboveOriginalSizeIsEnabled@endlink</code>
 * - <span class="apiDiffModified">Modified</span> <code>NIPhotoScrollView.@link NIPhotoScrollView::zoomingIsEnabled zoomingIsEnabled@endlink</code>
 * @htmlonly<table class="modificationtable"><tr><th></th><th>Accessor Name</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">@property (nonatomic, readwrite, assign) BOOL zoomingIsEnabled</td></tr> 
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>@property (nonatomic, readwrite, assign, getter=isZoomingEnabled) BOOL zoomingIsEnabled</tt></td></tr></table>@endhtmlonly
 * - <span class="apiDiffModified">Modified</span> <code>NIPhotoScrollView.@link NIPhotoScrollView::doubleTapToZoomIsEnabled doubleTapToZoomIsEnabled@endlink</code>
 * @htmlonly<table class="modificationtable"><tr><th></th><th>Accessor Name</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">@property (nonatomic, readwrite, assign, getter=isDoubleTapToZoomIsEnabled) BOOL doubleTapToZoomIsEnabled</td></tr> 
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>@property (nonatomic, readwrite, assign, getter=isDoubleTapToZoomEnabled) BOOL doubleTapToZoomIsEnabled</tt></td></tr></table>@endhtmlonly
 *
 *
 * <h3>NIPhotoScrubberView[.h/m] <span class="apiDiffAdded">Added</span></h3>
 *
 *
 * <h3>NIToolbarPhotoViewController[.h]</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>NIToolbarPhotoViewController.@link NIToolbarPhotoViewController::scrubberIsEnabled scrubberIsEnabled@endlink</code>
 * - <span class="apiDiffAdded">Added</span> <code>NIToolbarPhotoViewController.@link NIToolbarPhotoViewController::photoScrubberView photoScrubberView@endlink</code>
 *
 *
 * <h2>Examples</h2>
 *
 * <h3>NetworkPhotoAlbums</h3>
 *
 * - <span class="apiDiffFeature">Feature</span> Added Shark Week and Game of Thrones albums to the example application.
 * - <span class="apiDiffFeature">Feature</span> Implemented the photo scrubber data source in the Facebook and Dribbble controllers.
 * - <span class="apiDiffBugfix">Bugfix</span> Network requests are no longer duplicated.
 * - <span class="apiDiffBugfix">Bugfix</span> Cancel network requests when the controller is released to avoid crashing.
 *   (thanks to <a href="http://github.com/steipete">steipete</a>.)
 *
 *
 * <h2>Real Live People Involved in this Release</h2>
 *
 * <div class="contributor_profile"> 
 *  <img width="135px" height="135px" src="http://www.gravatar.com/avatar/7adfa1038eb46b001fd5c85a47dffc13?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 *  <div class="name">Peter Steinberger</div> 
 *  <div class="github"><a href="http://github.com/steipete">steipete</a></div> 
 * </div>
 *
 * <div class="contributor_profile"> 
 *  <img width="135px" height="135px" src="http://www.gravatar.com/avatar/f3c8603c353afa79b9f1c77f35efd566?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 *  <div class="name">Jeff Verkoeyen</div> 
 *  <div class="github"><a href="http://github.com/jverkoey">jverkoey</a></div> 
 * </div>
 *
 * <div class="clearfix"></div>
 *
 * <h3>Add Your Name to This List</h3>
 *
 * Contributions are highly encouraged! If you have a feature that you feel would fit within the
 * Nimbus framework, feel free to fire off a pull request on GitHub. Bugs may be reported
 * using the issue tracker on GitHub as well.
 *
 * Check out the <a href="https://github.com/jverkoey/nimbus/issues?sort=created&direction=desc&state=open&page=1&milestone=5">tasks grab bag</a>
 * for opportunities to help out.
 *
 * <h2>Robots Involved in this Release</h2>
 *
 * <div class="contributor_profile"> 
 *  <div class="name"><a href="http://www.stack.nl/~dimitri/doxygen/">Doxygen</a></div> 
 * </div>
 *
 * <div class="clearfix"></div>
 */

/**
 * @defgroup Version-3 Version 0.3
 * @ingroup Version-History
 *
 * <h2>0.3.4 - Monday, July 4, 2011</h2>
 *
 * Add network images to Nimbus.
 *
 * Goal tasks:
 *
 * - Migrate the new TTNetworkImageView object and the network image stack using ASIHTTPRequest
 *   to Nimbus. (+1)
 * - Build an in-memory object cache (+1)
 * - Build an in-memory image cache from the in-memory object cache (+1)
 * - Refactor the core library so that it's easier to jump to headers from source files (+1)
 */

/**
 * @defgroup Version-2 Version 0.2
 * @ingroup Version-History
 *
 * <h2>0.2.1 - Tuesday June 14, 2011</h2>
 *
 * The first feature release of Nimbus.
 *
 * Goal tasks:
 *
 * - Migrate Three20's Launcher to Nimbus (+1)
 */

/**
 * @defgroup Version-1 Version 0.1
 * @ingroup Version-History
 *
 * <h2>0.1.4 - Friday June 10, 2011</h2>
 *
 * The first public release of Nimbus.
 *
 * Goal tasks for this release:
 * 
 * Migrate the following from Three20:
 *
 * - Global core methods (+1)
 * - Debugging tools (+1)
 * - Availability (+1)
 * - Additions (+1)
 */

/**
 * @defgroup Three20-Migration-Guide Three20 Migration Guide
 *
 * <h2>Getting Started</h2>
 *
 * If you've added Three20 to one of your projects then you're undoubtedly familiar with the
 * incredible overhead of the framework's size and work involved in tweaking project
 * settings. While the concept of shared static libraries has its benefits, the reality is
 * that most applications are standalone entities and it is rare that you would be switching
 * between applications rapidly enough to justify the shared build times.
 *
 * Nimbus reduces build times by throwing this model out the window altogether and being
 * truly modular. When you add Nimbus to your project, you only add the code for the features
 * you <i>want</i> to use, and you add this code directly to your project. With Nimbus, you only
 * need to manage one project's settings, one target for your application, and zero dependent
 * static libraries (unless you're using a non-Nimbus library of course). This also means that
 * if there is a feature within Nimbus that you've already built or included in your app
 * (ASIHTTPRequest), for example, then you can simply use that code and modify it as you wish.
 *
 * <h3>The Nimbus Namespace</h3>
 *
 * The Nimbus namespace is an <code>NI</code> prefix to all types and functions. Three20's
 * is <code>TT</code>. Quite often Three20 features will exist in Nimbus as well. When this
 * is the case, you simply have to replace the <code>TT</code> prefix with <code>NI</code>.
 *
 * <h3>Using Nimbus Alongside Three20</h3>
 *
 * It is possible for both frameworks to exist in one application because the two frameworks
 * use different prefices. This has the obvious downside of only increasing the size of your
 * application, but as Nimbus develops the benefit of replacing certain features with Nimbus
 * equivalents may prove worth the cost. In the future it is hoped that Nimbus will reach
 * feature parity with Three20, at which point you would be able to remove Three20 from your
 * project altogether.
 *
 * <h2>Features That Map One-to-One</h2>
 *
 * Certain features map from Three20 to Nimbus directly. You can begin using these features
 * by doing a global find and replace in your application's code.
 *
 * <h3>Debugging Tools</h3>
 *
 * <pre>
 *  Three20                         Nimbus
 *  -----------------------------   --------------------------------------
 *  TTDASSERT()                     NIDASSERT()
 *  TTDCONDITIONLOG()               NIDCONDITIONLOG()
 *  TTDPRINT()                      NIDPRINT()
 *  TTDPRINTMETHODNAME()            NIDPRINTMETHODNAME()
 *  TTDINFO()                       NIDINFO()
 *  TTDERROR()                      NIDERROR()
 *  TTDWARNING()                    NIDWARNING()
 * </pre>
 *
 * <h3>Device Orientation</h3>
 *
 * <pre>
 *  Three20                         Nimbus
 *  -----------------------------   --------------------------------------
 *  TTIsSupportedOrientation()      NIIsSupportedOrientation()
 * </pre>
 *
 * <h3>Network Activity</h3>
 *
 * <pre>
 *  Three20                         Nimbus
 *  -----------------------------   --------------------------------------
 *  TTNetworkRequestStarted()       NINetworkActivityTaskDidStart()
 *  TTNetworkRequestStopped()       NINetworkActivityTaskDidFinish()
 * </pre>
 *
 * <h3>Preprocessor Macros</h3>
 *
 * <pre>
 *  Three20                         Nimbus
 *  -----------------------------   --------------------------------------
 *  __TT_DEPRECATED_METHOD          __NI_DEPRECATED_METHOD
 *  TT_FIX_CATEGORY_BUG()           NI_FIX_CATEGORY_BUG()
 *  TT_RELEASE_SAFELY()             NI_RELEASE_SAFELY()
 * </pre>
 *
 * <h2>Three20 Features Deprecated by Nimbus Features</h2>
 *
 * Some features built for Nimbus completely deprecate closely related Three20 features. To
 * switch from using the Three20 feature to the Nimbus equivalent may require some extra work
 * beyond a simply find-and-replace. Where possible the architectural differences are noted
 * below to aid in the transition process.
 *
 * <h3>In-Memory Caching With TTURLCache</h3>
 *
 * Nimbus provides NIMemoryCache for caching objects in memory. It is designed only for
 * storing objects in memory and does not provide disk caching. This is by design: touching
 * the disk should be an explicit activity so that the performance implications are obvious.
 * TTURLCache was not clear on how it accessed the disk cache.
 *
 * Due to this design choice, one of the primary differences between NIMemoryCache and
 * TTURLCache is the fact that NIMemoryCache does not provide a disk cache. You can't
 * use an NIMemoryCache to store or load images from disk.
 *
 * TTURLCache is primarily used for caching images. It uses a fake,
 * least-recently-used cache removal algorithm where images are removed in the same order that
 * they were added to the cache. This can lead to unexpected cache misses when the cache is
 * used heavily and images start being removed even though they were recently used.
 *
 * NIImageMemoryCache solves this problem by taking advantage of the true least-recently-used
 * cache removal algorithm built into NIMemoryCache. Whenever an image is accessed it moves
 * to the end of a linked list. When the cache limit is reached or a memory warning is received,
 * images are removed from the front of the linked list until the memory constraints are
 * satisfied.
 *
 * <h3>Global Singletons</h3>
 *
 * Three20 implements singletons directly in the class that provides the singleton
 * implementation. This places too much emphasis on the fact that the object is meant to
 * be used as a singleton, so Nimbus avoids this practice.
 *
 * Instead, Nimbus provides access to singletons via the global Nimbus state object. You'll
 * notice that Nimbus is highlighted as a link throughout the documentation, this is because
 * Nimbus is a class within the Nimbus framework. To access singletons, you call class
 * methods on Nimbus.
 *
 * For example, to access Nimbus' equivalent to TTURLCache, you use
 * <code>[Nimbus imageMemoryCache]</code>.
 *
 * <h3>Network Images with TTImageView</h3>
 *
 * Three20's network image view is completely deprecated by Nimbus' NINetworkImageView.
 * Three20's network image view is an overly complicated TTView object with too many
 * non-critical features built in. NINetworkImageView, on the other hand, is a simple
 * UIImageView view.
 *
 * NINetworkImageView is incredibly efficient when it comes to using memory. Where TTImageView
 * would download an image and them simply crop and resize the image whenever the view was
 * drawn, NINetworkImageView crops and resizes the image on a separate thread and then draws
 * the image without any scaling required. The image stored in the memory cache is also much
 * smaller as result. Performance is noticeably improved when many image views are on
 * the screen at once. A good example would be flipping through a friend list on the iPad with
 * large, high-resolution images laid out in a grid.
 *
 * NINetworkImageView also handles retina displays more intelligently than TTImageView by
 * creating scaled UIImages.
 *
 * <h3>Photo Albums with TTPhotoViewController</h3>
 *
 * Three20's photo album viewer was built around the time iOS 3.0 was first coming out. Take
 * a second to let that sink in, because that was a hell of a long time ago by the iOS SDK's
 * standards.
 *
 * Around that time the scroll view implementations were certainly lacking some of the nice
 * features required by a photo viewer. As a result, Three20 included a from-the-ground-up
 * implementation of TTScrollView. This is no longer necessary and the new
 * Nimbus photo viewer rejoices in the use of native UIScrollViews.
 *
 * Three20's photo viewer was also incredibly entrenched in the Three20 network model battleground
 * with no hope of salvation. Nimbus' photo viewer is built using a light-weight, completely
 * independent data source/delegate design that is similar in principle to UITableView.
 *
 * Instead of using a TTPhotoViewController, you can now use an NIToolbarPhotoViewController.
 * All you are required to do is implement the data source methods. Examples of such
 * implementations can be found in the network photo album sample app.
 *
 * Nimbus photo viewer is faster, performs better under low-memory conditions, uses native
 * scroll views and has an overall lower memory footprint. It also encourages processing data
 * on separate threads instead of in the main UI thread like Three20's network stack does.
 */

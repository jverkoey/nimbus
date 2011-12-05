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
 * - <a href="http://wiki.nimbuskit.info/Add-Nimbus-to-your-project">Add Nimbus to your project</a>.
 * - Follow Nimbus' development through its <a href="http://jverkoey.github.com/nimbus/group___version-_history.html">version history</a>.
 * - See the <a href="http://jverkoey.github.com/nimbus/group___version-9-0.html">latest API diffs</a>.
 * - Read the <a href="http://jverkoey.github.com/nimbus/group___three20-_migration-_guide.html">Three20 Migration Guide</a>.
 * - Ask questions and get updates via the <a href="http://groups.google.com/group/nimbusios">Nimbus mailing list</a>.
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
 * Most of the discussion revolving around Nimbus' roadmap is in the Github issue tracker. In
 * particular, check out the grab bag of tasks that are actively being worked on here:
 * 
 * https://github.com/jverkoey/nimbus/issues?milestone=5&sort=created&direction=desc&state=open
 * 
 * 
 * <h2>Nimbus Contributors</h2>
 * 
 * Contributing to Nimbus is a great way to feel all warm and fuzzy inside. Either by adding your
 * banner to the cause and writing code or donating money to the pledgie link, every bit is greatly
 * appreciated and helps keep Nimbus running.
 * 
 * http://pledgie.com/campaigns/15519
 * 
 * <h3>Source Code Contributors (alphabetical by last name)</h3>
 * 
 * <div class="contributor_profile"> 
 * <div class="name">bubnov</div> 
 * <div class="github"><a href="http://github.com/bubnov">bubnov</a></div> 
 * </div>
 *
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/c28f6b282ad61bff6aa9aba06c62ad66?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Roger Chapman</div> 
 * <div class="github"><a href="http://github.com/rogchap">rogchap</a></div> 
 * </div>
 * 
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/87c842e2d3f2b9e87e339cbc86463e8d?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Manu Cornet</div> 
 * <div class="github"><a href="http://github.com/lmanul">lmanul</a></div> 
 * </div>
 * 
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/a7acedfd4044ad79252e3b062aef25e7?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Glenn Grant</div> 
 * <div class="github"><a href="http://github.com/alias1">alias1</a></div> 
 * </div>
 *
 * <div class="contributor_profile">
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/ca1536c2ef2e263ed2aec69c1d147677?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Aviel Lazar</div> 
 * <div class="github"><a href="http://github.com/aviell">aviell</a></div> 
 * </div>
 *
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/22f25c7b3f0f15a6854fae62bbd3482f?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Benedikt Meurer</div> 
 * <div class="github"><a href="http://github.com/bmeurer">bmeurer</a></div> 
 * </div>
 *
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/8d33edcb6695ab66b1e48067e4e3723c?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Anderson Miller</div> 
 * <div class="github"><a href="http://github.com/candersonmiller">candersonmiller</a></div> 
 * </div>
 *
 * <div class="contributor_profile">
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/ec5d7ba9c004f79817c76146247e787e?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Basil Shkara</div> 
 * <div class="github"><a href="http://github.com/baz">baz</a></div> 
 * </div>
 *
 * <div class="contributor_profile">
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/7adfa1038eb46b001fd5c85a47dffc13?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Peter Steinberger</div> 
 * <div class="github"><a href="http://github.com/steipete">steipete</a></div> 
 * </div>
 * 
 * <div class="contributor_profile">
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/f3c8603c353afa79b9f1c77f35efd566?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Jeff Verkoeyen</div> 
 * <div class="github"><a href="http://github.com/jverkoey">jverkoey</a></div> 
 * </div>
 * 
 * <div class="contributor_profile">
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/b0190e056d8b13400d4ae6eba8a7018d?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Hwee-Boon Yar</div> 
 * <div class="github"><a href="http://github.com/hboon">hboon</a></div> 
 * </div>
 *
 * <div style="clear:both"></div>
 * 
 * <h3>Generous Donations Have Been Made By the Following People</h3>
 * 
 * - Peter Nelson
 * - Craig Gilchrist
 * - Atsushi Nagase
 * 
 * 
 * <h2>The Nimbus Backstory</h2>
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
 * @defgroup Version-9-0 Version 0.9 API Changes
 * @ingroup Version-History
 *
 * Version 0.9.0 of Nimbus was released on October 24, 2011. This major version introduced
 * the new Nimbus @link NimbusCSS CSS@endlink and Chameleon, a new way to rapidly prototype
 * styling your iOS applications using CSS.
 *
 * Watch the Chameleon Youtube video: http://www.youtube.com/watch?v=i_5LbQ8e9BU
 *
 * Read the Chameleon blog post: http://blog.jeffverkoeyen.com/nimbus-chameleon
 *
 *
 * <h2>Added Frameworks</h2>
 *
 * - @link NimbusCSS CSS@endlink
 *
 *
 * <h2>Attributed Label</h2>
 *
 * <h3>NIAttributedLabel[.h|m]</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>[NIAttributedLabel @link NIAttributedLabel::removeAllLinks removeAllLinks@endlink]</code> (thanks to <a href="http://github.com/hboon">hboon</a>.)
 *
 *
 * <h2>Core</h2>
 *
 * <h3>NIDataStructures[.h|m]</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>[NILinkedList @link NILinkedList::addObjectsFromArray: addObjectsFromArray:@endlink]</code>
 *
 * <h3>NIPreprocessorMacros.h</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>RGBCOLOR</code> and <code>RGBACOLOR</code>
 *
 *
 * <h2>Models</h2>
 *
 * <h3>ModelCatalog</h3>
 *
 * - <span class="apiDiffBugfix">Bugfix</span> Fixed a crashing bug due to setting textField.textColor to nil (thanks to <a href="http://github.com/lmanul">lmanul</a>.)
 *
 *
 * <h2>Examples</h2>
 *
 * <h3>CSSDemo [added]</h3>
 *
 *
 * <h2>Real Live People Involved in this Release</h2>
 *
 * <div class="contributor_profile"> 
 * <div class="name">bubnov</div> 
 * <div class="github"><a href="http://github.com/bubnov">bubnov</a></div> 
 * </div>
 *
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/c28f6b282ad61bff6aa9aba06c62ad66?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Roger Chapman</div> 
 * <div class="github"><a href="http://github.com/rogchap">rogchap</a></div> 
 * </div>
 *
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/87c842e2d3f2b9e87e339cbc86463e8d?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Manu Cornet</div> 
 * <div class="github"><a href="http://github.com/lmanul">lmanul</a></div> 
 * </div>
 *
 * <div class="contributor_profile">
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/f3c8603c353afa79b9f1c77f35efd566?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Jeff Verkoeyen</div> 
 * <div class="github"><a href="http://github.com/jverkoey">jverkoey</a></div> 
 * </div>
 * 
 * <div class="contributor_profile">
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/b0190e056d8b13400d4ae6eba8a7018d?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Hwee-Boon Yar</div> 
 * <div class="github"><a href="http://github.com/hboon">hboon</a></div> 
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
 *  <div class="name"><a href="https://github.com/nimbusios/Doxygen">Nimbus Doxygen</a></div> 
 * </div>
 *
 * <div class="clearfix"></div>
 */

/**
 * @defgroup Version-8-0 Version 0.8 API Changes
 * @ingroup Version-History
 *
 * Version 0.8.0 of Nimbus was released on September 28, 2011. This major version introduced
 * the new Nimbus @link NimbusAttributedLabel Attributed Label@endlink, an iOS SDK-based
 * solution for styled text built by Roger Chapman (<a href="http://github.com/rogchap">rogchap</a>).
 *
 *  @image html NIAttributedLabelExample1.png "A mashup of possible label styles"
 *
 *
 * <h2>Added Frameworks</h2>
 *
 * - @link NimbusAttributedLabel Attributed Label@endlink
 *
 *
 * <h2>Core</h2>
 *
 * <h3>NIFoundationMethods[.h|m]</h3>
 *
 * - <span class="apiDiffBugfix">Bugfix</span> Make boundf and boundi perform consistently for invalid bounds (e.g. max < min).
 *
 * <h3>NINavigationAppearance[.h|m] Added</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>@link NINavigationAppearance NINavigationAppearance@endlink</code> (thanks to <a href="http://github.com/baz">baz</a>.)
 *
 *
 * <h2>Interapp</h2>
 *
 * <h3>NIInterapp[.h|m]</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>@link NIInterapp::applicationIsInstalledWithScheme: applicationIsInstalledWithScheme:@endlink</code> (thanks to <a href="http://github.com/alias1">alias1</a>.)
 * - <span class="apiDiffAdded">Added</span> <code>@link NIInterapp::applicationWithScheme: applicationWithScheme:@endlink</code> (thanks to <a href="http://github.com/alias1">alias1</a>.)
 * - <span class="apiDiffAdded">Added</span> <code>@link NIInterapp::applicationWithScheme:andAppStoreId: applicationWithScheme:andAppStoreId:@endlink</code> (thanks to <a href="http://github.com/alias1">alias1</a>.)
 * - <span class="apiDiffAdded">Added</span> <code>@link NIInterapp::applicationWithScheme:andPath: applicationWithScheme:andPath:@endlink</code> (thanks to <a href="http://github.com/alias1">alias1</a>.)
 * - <span class="apiDiffAdded">Added</span> <code>@link NIInterapp::applicationWithScheme:appStoreId:andPath: applicationWithScheme:appStoreId:andPath:@endlink</code> (thanks to <a href="http://github.com/alias1">alias1</a>.)
 *
 *
 * <h2>Models</h2>
 *
 * <h3>NITableViewModel[.m]</h3>
 *
 * - <span class="apiDiffBugfix">Bugfix</span> Fixed a minor bug related to using nil in Nimbus table view models.
 *
 * <h3>NITableViewModelTests[.m] Added</h3>
 *
 *
 * <h2>Network Image</h2>
 *
 * <h3>NINetworkImageView[.m]</h3>
 *
 * - <span class="apiDiffBugfix">Bugfix</span> Fixed a bug with redirected image URLs not being cached properly (thanks to <a href="http://github.com/aviell">aviell</a>.)
 *
 * <h3>NITableViewModelTests[.m] Added</h3>
 *
 *
 * <h2>Photos</h2>
 *
 * <h3>NIToolbarPhotoViewController[.m]</h3>
 *
 * - <span class="apiDiffBugfix">Bugfix</span> Fixed a crashing bug due to sending dealloc at the wrong time (thanks to <a href="http://github.com/baz">baz</a>.)
 *
 *
 * <h2>Web Controller</h2>
 *
 * <h3>NIWebController[.m]</h3>
 *
 * - <span class="apiDiffBugfix">Bugfix</span> Fixed misc bugs related to web controller action sheets (thanks to <a href="http://github.com/bmeurer">bmeurer</a>.)
 *
 *
 * <h2>Examples</h2>
 *
 * <h3>Basic Attributed Label [added]</h3>
 *
 *
 * <h2>Real Live People Involved in this Release</h2>
 *
 * <div class="contributor_profile" style="padding: 5px;margin: 0 5px;margin-bottom: 20px;border: 1px solid #DDD;background-color: white;float: left;"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/c28f6b282ad61bff6aa9aba06c62ad66?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Roger Chapman</div> 
 * <div class="github"><a href="http://github.com/rogchap">rogchap</a></div> 
 * </div>
 *
 * <div class="contributor_profile" style="padding: 5px;margin: 0 5px;margin-bottom: 20px;border: 1px solid #DDD;background-color: white;float: left;"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/a7acedfd4044ad79252e3b062aef25e7?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Glenn Grant</div> 
 * <div class="github"><a href="http://github.com/alias1">alias1</a></div> 
 * </div>
 *
 * <div class="contributor_profile" style="padding: 5px;margin: 0 5px;margin-bottom: 20px;border: 1px solid #DDD;background-color: white;float: left;"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/ca1536c2ef2e263ed2aec69c1d147677?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Aviel Lazar</div> 
 * <div class="github"><a href="http://github.com/aviell">aviell</a></div> 
 * </div>
 *
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/22f25c7b3f0f15a6854fae62bbd3482f?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Benedikt Meurer</div> 
 * <div class="github"><a href="http://github.com/bmeurer">bmeurer</a></div> 
 * </div>
 *
 * <div class="contributor_profile" style="padding: 5px;margin: 0 5px;margin-bottom: 20px;border: 1px solid #DDD;background-color: white;float: left;"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/ec5d7ba9c004f79817c76146247e787e?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Basil Shkara</div> 
 * <div class="github"><a href="http://github.com/baz">baz</a></div> 
 * </div>
 *
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/f3c8603c353afa79b9f1c77f35efd566?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Jeff Verkoeyen</div> 
 * <div class="github"><a href="http://github.com/jverkoey">jverkoey</a></div> 
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
 *  <div class="name"><a href="https://github.com/nimbusios/Doxygen">Nimbus Doxygen</a></div> 
 * </div>
 *
 * <div class="clearfix"></div>
 */

/**
 * @defgroup Version-7-0 Version 0.7 API Changes
 * @ingroup Version-History
 *
 * Version 0.7.0 of Nimbus was released on August 19, 2011. This major version introduced the new
 * Nimbus @link NimbusModels Models@endlink, a feature that makes building table views a breeze.
 *
 *
 * <h2>Added Frameworks</h2>
 *
 * - @link NimbusModels Models@endlink
 *
 *
 * <h2>Core</h2>
 *
 * <h3>NICommonMetrics[.h]</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>NICellContentPadding()</code>
 *
 * <h3>NIInMemoryCache[.h]</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>@link NIMemoryCache::nameOfLeastRecentlyUsedObject nameOfLeastRecentlyUsedObject@endlink</code> (thanks to <a href="http://github.com/candersonmiller">candersonmiller</a>.)
 * - <span class="apiDiffAdded">Added</span> <code>@link NIMemoryCache::nameOfMostRecentlyUsedObject nameOfMostRecentlyUsedObject@endlink</code> (thanks to <a href="http://github.com/candersonmiller">candersonmiller</a>.)
 *
 * <h2>WebController</h2>
 *
 * <h3>NIWebController[.h]</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>@link NIWebController::shouldPresentActionSheet: shouldPresentActionSheet:@endlink</code> (thanks to <a href="http://github.com/bmeurer">bmeurer</a>.)
 * - <span class="apiDiffFeature">Feature</span> "Copy this URL" option added to the web controller's action sheet. (thanks to <a href="http://github.com/bmeurer">bmeurer</a>.)
 * - <span class="apiDiffFeature">Feature</span> The current web page's URL is shown in the action sheet title. (thanks to <a href="http://github.com/bmeurer">bmeurer</a>.)
 *
 *
 * <h2>Examples</h2>
 *
 * <h3>Model Catalog [added]</h3>
 *
 *
 * <h2>Real Live People Involved in this Release</h2>
 *
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/22f25c7b3f0f15a6854fae62bbd3482f?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Benedikt Meurer</div> 
 * <div class="github"><a href="http://github.com/bmeurer">bmeurer</a></div> 
 * </div>
 *
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/8d33edcb6695ab66b1e48067e4e3723c?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Anderson Miller</div> 
 * <div class="github"><a href="http://github.com/candersonmiller">candersonmiller</a></div> 
 * </div>
 *
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/f3c8603c353afa79b9f1c77f35efd566?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Jeff Verkoeyen</div> 
 * <div class="github"><a href="http://github.com/jverkoey">jverkoey</a></div> 
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
 *  <div class="name"><a href="https://github.com/nimbusios/Doxygen">Nimbus Doxygen</a></div> 
 * </div>
 *
 * <div class="clearfix"></div>
 */

/**
 * @defgroup Version-6-1 Version 0.6.1 API Changes
 * @ingroup Version-6-0
 *
 * Version 0.6.1 of Nimbus was released on August 8, 2011. This minor version introduced the new
 * Nimbus @link NimbusWebController WebController@endlink, a ported version of Three20's
 * TTWebController.
 *
 *
 * <h2>Added Frameworks</h2>
 *
 * - @link NimbusWebController Nimbus WebController@endlink
 *
 * @image html webcontroller-iphone-example1.png "Screenshot of a basic web controller on the iPhone"
 *
 *
 * <h2>Noteworthy Non-API Changes</h2>
 *
 * - Added the Three20 lint tool.
 *   (thanks to <a href="http://github.com/rogchap">rogchap</a>.)
 * - Added migration information from TTWebController to NIWebController.
 *   (thanks to <a href="http://github.com/rogchap">rogchap</a>.)
 * - LICENSE and NOTICE files have been added to the project.
 *
 *
 * <h2>Examples</h2>
 *
 * <h3>Basic Web Controller [added]</h3>
 *
 *
 * <h2>Real Live People Involved in this Release</h2>
 *
 * <div class="contributor_profile" style="padding: 5px;margin: 0 5px;margin-bottom: 20px;border: 1px solid #DDD;background-color: white;float: left;"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/c28f6b282ad61bff6aa9aba06c62ad66?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Roger Chapman</div> 
 * <div class="github"><a href="http://github.com/rogchap">rogchap</a></div> 
 * </div>
 *
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/f3c8603c353afa79b9f1c77f35efd566?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Jeff Verkoeyen</div> 
 * <div class="github"><a href="http://github.com/jverkoey">jverkoey</a></div> 
 * </div>
 *
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/03a8bbdb4e0ca0078241c9b6ab04b906?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">John Wang</div> 
 * <div class="github"><a href="http://github.com/jwang">jwang</a></div> 
 * </div>
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
 *  <div class="name"><a href="https://github.com/nimbusios/Doxygen">Nimbus Doxygen</a></div> 
 * </div>
 *
 * <div class="clearfix"></div>
 */

/**
 * @defgroup Version-6-0 Version 0.6 API Changes
 * @ingroup Version-History
 *
 * Version 0.6.0 of Nimbus was released on August 4, 2011. This major version introduced the new
 * Nimbus @link NimbusInterapp Interapp@endlink, a feature for making it easy to interact with
 * the exposed interfaces of other apps installed on the device.
 *
 *
 * <h2>Minor Releases</h2>
 *
 * - Version @link Version-6-1 0.6.1.0@endlink - Released on August 8, 2011
 *
 *
 * <h2>Added Frameworks</h2>
 *
 * - @link NimbusInterapp Nimbus Interapp@endlink
 *
 *
 * <h2>Noteworthy Non-API Changes</h2>
 *
 * - Xcode 4 sample project have been added
 *   (thanks to <a href="http://github.com/rogchap">rogchap</a>.)
 * - The README and HACKERS files have been updated.
 * - AUTHORS and DONORS have been added to keep track of all the generous contributions to Nimbus.
 * - All Nimbus features have been combined into one Xcode project (one project to rule them all).
 * - Removed the use of the NIMBUS_STATIC_LIBRARY preprocessor macro. This removes the duplication
 *   of all imports throughout the project. I'm now solely recommending that you add Nimbus
 *   directly to your project (instead of as a dependent static library).
 * - Xcode docsets are now available for download. The docsets will automatically update whenever
 *   a new version of Nimbus is released if you subscribe to the RSS feed.
 *
 * @image html docsets1.png "The new Nimbus Xcode docset allows you to Alt+Click any Nimbus class to get detailed documentation."
 *
 * <h2>Subscribing to the Nimbus Docset Feed</h2>
 *
 * Nimbus now provides automatic updates for integrated docsets. To set this up you simply need
 * to add the docset feed URL to Xcode. Follow these basic steps:
 *
 * - Open the Xcode Preferences (Cmd+, while Xcode is focused)
 * - Open the Documentation tab.
 * - Click the plus (+) button to add a new docset feed url.
 * - Paste http://jverkoey.github.com/nimbus/nimbusdocset.atom into the form.
 * - Click Add.
 * - Click the "Get" button next to the Nimbus docset.
 * - Wait a bit while the docset downloads...
 * - Voila! You now have the Nimbus documentation built in to Xcode! Try Alt+Clicking some Nimbus
 *   classes and methods to give it a whirl.
 *
 *
 * <h2>Core</h2>
 *
 * <h3>NICommonMetrics[.h]</h3>
 *
 * - <span class="apiDiffModified">Modified</span> <code>NIStatusBarBoundsChangeAnimationCurve()</code>
 * <table class="modificationtable"><tr><th></th><th>Declaration</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">UIViewAnimationCurve NIStatusBarFrameAnimationCurve()</td></tr> 
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>UIViewAnimationCurve NIStatusBarBoundsChangeAnimationCurve(void)</tt></td></tr></table>
 * - <span class="apiDiffModified">Modified</span> <code>NIStatusBarBoundsChangeAnimationDuration()</code>
 * <table class="modificationtable"><tr><th></th><th>Declaration</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">NSTimeInterval NIStatusBarFrameAnimationDuration()</td></tr> 
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>NSTimeInterval NIStatusBarBoundsChangeAnimationDuration(void)</tt></td></tr></table>
 *
 * <h3>NIDataStructures[.h]</h3>
 *
 * - <span class="apiDiffModified">Modified</span> <code>-[NILinkedList @link NILinkedList::count count@endlink]</code>
 * @htmlonly<table class="modificationtable"><tr><th></th><th>Declaration and Type</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">@property (nonatomic, readonly) unsigned long count</td></tr> 
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>- (NSUInteger)count</tt></td></tr></table>@endhtmlonly
 * - <span class="apiDiffModified">Modified</span> <code>-[NILinkedList @link NILinkedList::firstObject firstObject@endlink]</code>
 * @htmlonly<table class="modificationtable"><tr><th></th><th>Declaration</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">@property (nonatomic, readonly) id firstObject</td></tr> 
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>- (id)firstObject</tt></td></tr></table>@endhtmlonly
 * - <span class="apiDiffModified">Modified</span> <code>-[NILinkedList @link NILinkedList::lastObject lastObject@endlink]</code>
 * @htmlonly<table class="modificationtable"><tr><th></th><th>Declaration</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">@property (nonatomic, readonly) id lastObject</td></tr>
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>- (id)lastObject</tt></td></tr></table>@endhtmlonly
 * - <span class="apiDiffAdded">Added</span> <code>+[NILinkedList @link NILinkedList::linkedListWithArray: linkedListWithArray:@endlink]</code>
 * - <span class="apiDiffAdded">Added</span> <code>-[NILinkedList @link NILinkedList::initWithArray: initWithArray:@endlink]</code>
 * - <span class="apiDiffAdded">Added</span> <code>-[NILinkedList @link NILinkedList::allObjects allObjects@endlink]</code>
 * - <span class="apiDiffAdded">Added</span> <code>-[NILinkedList @link NILinkedList::containsObject: containsObject:@endlink]</code>
 * - <span class="apiDiffAdded">Added</span> <code>-[NILinkedList @link NILinkedList::description description@endlink]</code>
 *
 * <h3>NIDebuggingTools[.h]</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>NIDebugAssertionsShouldBreak</code>
 *
 * <h3>NIError[.h|m] Added</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>NINimbusErrorDomain</code>
 * - <span class="apiDiffAdded">Added</span> <code>NIImageErrorKey</code>
 * - <span class="apiDiffAdded">Added</span> <code>NIImageTooSmall</code>
 * - <span class="apiDiffAdded">Added</span> <code>NINimbusErrorDomainCode</code>
 *
 * <h3>NIFoundationMethods[.h]</h3>
 *
 * - <span class="apiDiffAdded">Added</span> <code>boundf()</code>
 * - <span class="apiDiffAdded">Added</span> <code>boundi()</code>
 *
 * <h3>NIInMemoryCache[.h]</h3>
 *
 * - <span class="apiDiffModified">Modified</span> <code>-[NIMemoryCache @link NIMemoryCache::containsObjectWithName: containsObjectWithName:@endlink]</code>
 * <table class="modificationtable"><tr><th></th><th>Declaration</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">- (BOOL)hasObjectWithName:(NSString *)name</td></tr> 
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>- (BOOL)containsObjectWithName:(NSString *)name</tt></td></tr></table>
 *
 *
 * <h2>Network Image</h2>
 *
 * <h3>NIHTTPImageRequest[.m]</h3>
 *
 * - <span class="apiDiffBugfix">Bugfix</span> Fixed a potential memory leak caused by not releasing the color space when the bitmap failed to be created.
 *
 * <h3>NINetworkImageView[.h]</h3>
 *
 * - <span class="apiDiffModified">Modified</span> <code>-[NINetworkImageView @link NINetworkImageView::setPathToNetworkImage:forDisplaySize:contentMode:cropRect: setPathToNetworkImage:forDisplaySize:contentMode:cropRect:@endlink]</code>
 * <table class="modificationtable"><tr><th></th><th>Declaration</th></tr> 
 * <tr><th>From</th><td class='Declaration' scope="row">- (void)setPathToNetworkImage:(NSString *)pathToNetworkImage cropRect:(CGRect)cropRect forDisplaySize:(CGSize)displaySize contentMode:(UIViewContentMode)contentMode</td></tr> 
 * <tr><th>To</th><td class='Declaration' scope="row"><tt>- (void)setPathToNetworkImage:(NSString *)pathToNetworkImage forDisplaySize:(CGSize)displaySize contentMode:(UIViewContentMode)contentMode cropRect:(CGRect)cropRect</tt></td></tr></table>
 *
 *
 * <h2>Examples</h2>
 *
 * <h3>Interapp Catalog [added]</h3>
 *
 *
 * <h2>Real Live People Involved in this Release</h2>
 *
 * <div class="contributor_profile" style="padding: 5px;margin: 0 5px;margin-bottom: 20px;border: 1px solid #DDD;background-color: white;float: left;"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/c28f6b282ad61bff6aa9aba06c62ad66?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Roger Chapman</div> 
 * <div class="github"><a href="http://github.com/rogchap">rogchap</a></div> 
 * </div>
 * 
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/261d7ac023a174844c46e5f9f7a096b0?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Avi Itskovich</div> 
 * <div class="github"><a href="http://github.com/aitskovi">aitskovi</a></div> 
 * </div>
 *
 * <div class="contributor_profile"> 
 * <img width="135px" height="135px" src="http://www.gravatar.com/avatar/f3c8603c353afa79b9f1c77f35efd566?s=135&amp;d=http://three20.info/gfx/team/silhouette.gif" /> 
 * <div class="name">Jeff Verkoeyen</div> 
 * <div class="github"><a href="http://github.com/jverkoey">jverkoey</a></div> 
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
 * This article has moved to
 * <a href="http://wiki.nimbuskit.info/Three20-Migration-Guide">wiki.nimbuskit.info/Three20-Migration-Guide</a>.
 */

/**
 * @defgroup Add-Nimbus Add Nimbus to your project
 *
 * This article has moved to
 * <a href="http://wiki.nimbuskit.info/Add-Nimbus-to-your-project">wiki.nimbuskit.info/Add-Nimbus-to-your-project</a>.
 */


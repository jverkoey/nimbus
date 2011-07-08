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
 * - Learn how to <a href="http://jverkoey.github.com/nimbus/group___setup.html">add Nimbus to your project</a>.
 * - Check out the README for <a href="https://github.com/jverkoey/nimbus/tree/master/examples/gettingstarted/01-BasicSetup">the introduction sample project</a>.
 * - Follow Nimbus through its <a href="http://jverkoey.github.com/nimbus/group___version-_history.html">version history</a>.
 *
 * <h2>Nimbus' Background</h1>
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
 * <h1>Version History</h1>
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
 *
 * <h2>0.2.1 - Tuesday June 14, 2011</h2>
 *
 * The first feature release of Nimbus.
 *
 * Goal tasks:
 *
 * - Migrate Three20's Navigator to Nimbus (+1)
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
 * @defgroup Setup Adding Nimbus Libraries to Your Project
 *
 * <h1></h1>
 *
 * There are two recommended models for adding Nimbus libraries to your project: as
 * dependent libraries, or by adding the code directly to your project. Each has its
 * advantages and disadvantages, outlined below.
 *
 * <h2>Recommended: add the Nimbus source code to your project</h2>
 *
 * This model involves dragging the source files from each Nimbus library you wish to add
 * into your Xcode project and adding the source files to your application target.
 *
 * Advantages:
 *
 * - Debugging and stepping into Nimbus code is much easier when the source is built in your
 *   project.
 * - You can easily modify the Nimbus source code within your project.
 * - Only one precompiled header needs to be built.
 *
 * Disadvantages:
 *
 * - You will have to actively keep your projects up-to-date with Nimbus by adding and removing
 *   files whenever a Nimbus library changes.
 * - If you have multiple projects then the build products won't be reused, causing some duplicate
 *   build time between different projects.
 *
 * <h2>Add Nimbus components as dependent libraries</h2>
 *
 * Advantages:
 *
 * - Changes to Nimbus' project layout won't require any maintenance on your part because
 *   the library will handle all of Nimbus' building. If a new file is added to a Nimbus library
 *   then your projects will automatically include these by nature of linking to the library.
 * - Build results can be reused between multiple projects. This can lower the overall build time
 *   if you maintain multiple projects.
 *
 * Disadvantages:
 *
 * - Adding libraries to a project can be a pain in the ass and the learning curve is steep if
 *   the automated nimbus script doesn't work for your project.
 * - Finding documentation and setting breakpoints in Nimbus can be frustrating at best.
 * - If you want to browse the Nimbus source you will need to keep multiple Xcode projects open.
 *   This can be very problematic in Xcode 4.
 * - Headers must be protected because they get copied to a separate directory. This can be
 *   frustrating if you want to hack on Nimbus.
 *
 * See examples/launcher/BasicLauncher for an example project that adds the source directly to
 * the project.
 *
 * <h2>Which model should I use?</h2>
 *
 * You must weigh the above pros and cons with your own requirements. Our recommendation is
 * to <b>add the source directly to your project</b>. While this will
 * create a bit more work for you if Nimbus changes drastically down the line, the day-to-day
 * advantages far outweigh the downside of what is realistically a rare event.
 *
 * If you choose to use dependent libraries, please consider using the nimbus script found
 * in nimbus/scripts/. It may be advantageous to you to add nimbus/scripts to your PATH so that
 * you can run nimbus directly.
 *
 * <h2>Example project</h2>
 *
 * Please refer to the <a href="https://github.com/jverkoey/nimbus/tree/master/examples/gettingstarted/01-BasicSetup">getting started project</a>
 * for a walkthrough of adding Nimbus to your project.
 */
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
 * <h1>What is Nimbus?</h1>
 *
 * Nimbus is an iOS framework that grows only as fast as its documentation. Its roots stem
 * from the Three20 framework and much of its code is forked from Three20, though with meticulous
 * care and thought.
 *
 * In short, you'll find a number of features within Nimbus to accelerate your development of
 * iOS applications. Nimbus will be evolving quickly over time so it is likely in your best
 * interest to simply browse the documentation by checking out Nimbus'
 * <a href="modules.html">Modules</a>.
 *
 * If you'd like to get started right away, learn how to <a href="group___setup.html">add
 * Nimbus to your project</a>.
 *
 *
 * <h1>Three20 was garbage though, why would I use Nimbus?</h1>
 *
 * Three20 most certainly has issues. Among them:
 *
 * - Relatively zero documentation.
 * - Spaghetti dependencies.
 * - Suffering from a "kitchen sink" complex.
 * - Complex build structure.
 * - Enormous number of difficult-to-solve bugs.
 * - Low test coverage.
 *
 * But for its weaknesses, Three20 does provide a good deal of value through its feature set. It is
 * used in over 100 apps in the app store by companies such as Facebook, LinkedIn, Posterous,
 * Meetup, and SCVNGR.
 *
 * The goal of Nimbus is to one day provide this same value through its feature set. Along the way,
 * infinitely more value will be provided in better documentation, better test coverage, and
 * a smaller learning curve.
 *
 *
 * <h1>What are the plans for Nimbus?</h1>
 *
 * I'm a strong believer in shipping early, shipping fast, and shipping often. Any other way of
 * being genuinely frustrates me so I hope to apply this to Nimbus.
 *
 * I plan to tackle Nimbus by first building a strong foundation in the Nimbus Core. From there
 * I will branch out and tackle migrating a variety of features over from Three20. Some features
 * on my immediate horizon in increasing order of difficulty:
 *
 * - The Launcher (done!)
 * - Network images.
 * - TTNavigator.
 *
 * For each day that I work on Nimbus I hope to have a pseudo-stable build that I can push out
 * and summarize the changes since the previous day's build. For this reason I will likely use
 * a <b>MAJOR.MINOR.SCORE</b> version model.
 *
 * <b>Major</b> version numbers will be reserved for major milestones in the project (completing a
 * large set of features, for example).
 *
 * <b>Minor</b> version numbers will be reserved for minor milestones in the project (completing a
 * small set of features, for example).
 *
 * <b>Score</b> version numbers will be reserved for stable cuts of Nimbus after individual tasks
 * are completed (fully implementing the Launcher, for example).
 *
 * I'd like to treat the score version number like points from a video game. Finishing an
 * individual task will increase the score for a particular major release, so version 1.130.2
 * indicates "the first major release of Nimbus, 130 tasks tackled, and 2 incremental builds
 * for bugfixes and daily progress since the 130th task was finished". Perhaps there may be some
 * merit in allowing people who complete tasks to earn these points in some sense as well to
 * encourage some friendly competition.
 *
 * <h1>Who's working on Nimbus?</h1>
 *
 * Nimbus was started by me (Jeff Verkoeyen) in June 2011. My background includes over 10 years
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
 * Nimbus. I learned a lot about working with an open source project and community and sincerely
 * hope to carry much of this knowledge over to Nimbus.
 *
 *
 * <h1>So what about everyone who's still using Three20?</h1>
 *
 * My goal with Nimbus is to eventually provide a feature set that contains Three20's. I
 * sincerely hope to make it easy for anyone using Three20 to transition to Nimbus. In the
 * meantime, Three20 will likely stay in a bug-fixing state. The library is stable as it stands
 * so I have every bit of confidence in the community to tackle any bugs as necessary.
 *
 * <h1>Version History</h1>
 *
 * <h2>0.3</h2>
 *
 * Add network images to Nimbus.
 *
 * Goal tasks:
 *
 * - Migrate the new TTNetworkImageView object and the network image stack using ASIHTTPRequest
 *   to Nimbus.
 *
 * Bonus:
 * - Implement tap-and-hold editing on the launcher view.
 * - Implement launcher item state persistence.
 *
 * <h2>0.2 - Tuesday June 14, 2011</h2>
 *
 * The first feature release of Nimbus.
 *
 * Goal tasks:
 *
 * - Migrate Three20's Navigator to Nimbus (+1)
 *
 * <h2>0.1 - Friday June 10, 2011</h2>
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
 * @defgroup Setup Adding Nimbus to Your Project
 *
 * There are two recommended models for adding Nimbus to your project: as dependent libraries, or
 * by adding the code directly to your project. Each has its advantages and disadvantages, outlined
 * below.
 *
 * <h1>Add as a Dependent Library</h1>
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
 * <h1>Add the Source Directly to your Project</h1>
 *
 * Advantages:
 *
 * - Debugging and stepping into Nimbus code is much easier when it exists directly in your
 *   project.
 * - You can modify any Nimbus source file without worrying about whether the header is a copied
 *   header or the original.
 * - Fewer context switches when building the library can lower build times in certain situations.
 *
 * Disadvantages:
 *
 * - If there are any major modifications to Nimbus' project layout then you will have to manually
 *   update your projects.
 * - If you have multiple projects then the build products won't be reused, causing some duplicate
 *   build time.
 *
 * See examples/launcher/BasicLauncher for an example project that adds the source directly to
 * the project.
 *
 * <h1>Which model should I use?</h1>
 *
 * It's entirely up to you to weigh the above pros and cons with your own pros and cons. Based
 * on the pros and cons listed above, it's recommended that you <b>add the source directly to your
 * project</b>. While this will create a bit more work for you if Nimbus changes drastically
 * down the line, the day-to-day advantages far outweigh the downside of what is
 * realistically a rare event.
 *
 * If you choose to use dependent libraries, please consider using the nimbus script found
 * in nimbus/scripts/. It may be advantageous to you to add nimbus/scripts to your PATH so that
 * you can run nimbus directly.
 */
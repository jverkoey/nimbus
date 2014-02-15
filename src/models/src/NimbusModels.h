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

#pragma mark - Nimbus Models

/**
 * @defgroup NimbusModels Nimbus Models
 * @{
 *
 * <div id="github" feature="models"></div>
 *
 * A model is an implementation of a data source protocol.
 *
 * Data sources are required by various UI components throughout UIKit and Nimbus.
 * It can be painful to have to rewrite the same data source logic over and over
 * again. Nimbus models allow you to separate the data source logic from your view
 * controller and recycle common functionality throughout your application. You'll
 * find that your view controller can then focus on the broader implementation details
 * rather than implementing dozens of data source methods.
 *
 * <h2>Vanilla UIKit vs Nimbus Models</h2>
 *
 * If you would like to see an example of Nimbus models being used, check out
 * the ModelCatalog example application.
 */

#pragma mark * Table View Models

/**
 * @defgroup TableViewModels Table View Models
 *
 * Nimbus table view models make building table views remarkably easy. Rather than implement
 * the data source methods in each table view controller, you assign a model to
 * self.tableView.dataSource and only think about row creation.
 *
 * Nimbus table view models implement many of the standard table view data source methods,
 * including methods for section titles, grouped rows, and section indices. By
 * providing this functionality in one object, Nimbus provides much more
 * efficient implementations than one-off implementations that might otherwise
 * be copied from one controller to another.
 *
 * <h2>Creating Generic Static Models</h2>
 *
 * In order to use the Nimbus table view model you create a model, assign
 * it to your table view's data source after the table view has been created, and implement
 * the model delegate to create the table view cells. You can use the
 * @link TableCellFactory Nimbus cell factory@endlink to avoid implementing the model
 * delegate.
 *
 * Below is an example of creating a basic list model:
 *
 * @code
NSArray* tableContents =
 [NSArray arrayWithObjects:
  [NITitleCellObject objectWithTitle:@"Row 1"],
  [NITitleCellObject objectWithTitle:@"Row 2"],
  [NITitleCellObject objectWithTitle:@"Row 3"],
  nil];

_model = [[NITableViewModel alloc] initWithListArray:tableContents
                                            delegate:self];
 * @endcode
 *
 * Below is an example of creating a basic sectioned model:
 *
 * @code
NSArray* tableContents =
 [NSArray arrayWithObjects:
  @"Section Title",
  [NITitleCellObject objectWithTitle:@"Row 1"],
  [NITitleCellObject objectWithTitle:@"Row 2"],

  @"Section Title",
  [NITitleCellObject objectWithTitle:@"Row 3"],
  nil];

_model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                 delegate:self];
 * @endcode
 *
 * Both of the above examples would implement the model delegate like so:
 *
 * @code
- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object {
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"row"];

  if (nil == cell) {
    cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                   reuseIdentifier: @"row"]
            autorelease];
  }

  cell.textLabel.text = [object objectForKey:@"title"];

  return cell;
}
 * @endcode
 *
 * <h2>Creating Forms</h2>
 *
 * Let's say you want to create a form for a user to enter their username and password. You
 * can easily do this with Nimbus using the @link TableCellFactory Nimbus cell factory@endlink
 * and the Nimbus form elements from the @link TableCellCatalog table cell catalog@endlink.
 *
 * @code

NSArray* tableContents =
[NSArray arrayWithObjects:
 @"Sign In",
 [NITextInputFormElement textInputElementWithID:kUsernameField placeholderText:@"Username" value:nil],
 [NITextInputFormElement passwordInputElementWithID:kPasswordField placeholderText:@"Password" value:nil],
 nil];

_model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                 delegate:(id)[NICellFactory class]];
 * @endcode
 *
 * When the user then hits the button to sign in, you can grab the values from the model by using
 * the elementWithID: category method added to NITableViewModel by the form support.
 *
 * @code
NSString* username = [[_model elementWithID:kUsernameField] value];
NSString* password = [[_model elementWithID:kPasswordField] value];
 * @endcode
 *
 * See example: @link ExampleStaticTableModel.m Static Table Model Creation@endlink
 */

#pragma mark * Table Cell Factory

/**
 * @defgroup TableCellFactory Table Cell Factory
 *
 * A table cell factory automatically creates UITableViewCells from objects.
 *
 * The Nimbus table cell factory works by requiring that objects implement a basic protocol,
 * NICellObject, which sets up a binding from the object to a specific cell implementation.
 * This cell implementation can optionally implement the NICell protocol. In practice this is
 * nearly always the case. You then simply use the factory in your table's data source and
 * the factory will handle the rest. This allows you to completely separate presentation from
 * data in your table view controllers.
 *
 * <h2>A Simple Example: A Twitter Application</h2>
 *
 * Let's say you want to build a Twitter news feed. We'll assume you've
 * already figured out the network requests and now have individual tweets itching to be displayed.
 * To use the Nimbus factory you will need two different classes: one for the tweet object
 * and its data, and another for the tweet table view cell. Let's call them Tweet and
 * TweetCell, respectively. You may even already have a Tweet object.
 *
 * <h3>Implement the NICellObject Protocol</h3>
 *
 * You must first implement the NICellObject protocol in your Tweet object. We want to link
 * the TweetCell table view cell to the Tweet object so that the factory can create a TweetCell
 * when it needs to present the Tweet object.
 *
 * @code
@interface Tweet : NSObject <NICellObject> {
// ...
}
@end

@implementation Tweet

- (Class)cellClass {
  return [TweetCell class];
}

@end
 * @endcode
 *
 * Now that we've pointed the Tweet object to the TweetCell class, let's make the
 * table controller use the NICellFactory.
 *
 * <h3>Using the Factory</h3>
 *
 * There are a few ways you can use the factory in your code. We'll walk through increasingly
 * Nimbus-like implementations, starting with a vanilla UIKit implementation.
 *
 * The following vanilla UIKit implementation has the advantage of allowing you to use
 * NICellFactory in your existing code base without requiring a full rewrite of your data
 * source. If you are attempting to switch to a pure Nimbus implementation using the cell factory
 * then this is a good first step because it is the least invasive.
 *
 * @code
- (UITableViewCell *)tableView: (UITableView *)tableView
         cellForRowAtIndexPath: (NSIndexPath *)indexPath {
  // Note: You must fetch the object at this index path somehow. The objectAtIndexPath:
  // is simply an example; replace it with your own implementation.
  id object = [self objectAtIndexPath:indexPath];

  UITableViewCell* cell = [NICellFactory tableViewModel:nil cellForTableView:tableView atIndexPath:indexPath withObject:object];
  if (nil == cell) {
    // Here would be whatever code you were originally using to create cells. nil is only returned
    // when the factory wasn't able to create a cell, likely due to the NICellObject protocol
    // not being implemented for the given object. As you implement these protocols on
    // more objects the factory will automatically start returning the correct cells
    // and you can start removing this special-case logic.
  }
  return cell;
}
 * @endcode
 *
 * This next implementation is what your vanilla data source implementation would look like once
 * you have no more custom cell creation code.
 *
 * @code
- (UITableViewCell *)tableView: (UITableView *)tableView
         cellForRowAtIndexPath: (NSIndexPath *)indexPath {
  // Note: You must fetch the object at this index path somehow. The objectAtIndexPath:
  // is simply an example; replace it with your own implementation.
  id object = [self objectAtIndexPath:indexPath];

  // Only use the factory to create cells now that every object used in this controller
  // implements the factory protocols.
  return [NICellFactory tableViewModel:nil cellForTableView:tableView atIndexPath:indexPath withObject:object];
}
 * @endcode
 *
 * If you are using Nimbus models then your code gets even simpler because the object is passed
 * to your model delegate method.
 *
 * @code
- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object {
  // The model gives us the object, making this much simpler and likely more efficient than the vanilla UIKit implementation.
  return [NICellFactory tableViewModel:tableViewModel cellForTableView:tableView atIndexPath:indexPath withObject:object];
}
 * @endcode
 *
 * And finally, if you require no custom code in your model delegate, the above example can
 * be shortened to a one-liner when you initialize the model:
 *
 * @code
// This is functionally identical to implementing the delegate in this controller and simply
// calling the factory method.
_model.delegate = (id)[NICellFactory class];
 * @endcode
 *
 * <h3>Customizing the Cell</h3>
 *
 * We want to customize the cells as they are presented, otherwise all of the cells will look
 * the same. After our TweetCell object is created in the factory, the factory will call
 * the @link NICell::shouldUpdateCellWithObject: shouldUpdateCellWithObject:@endlink method
 * on the cell, if it is implemented. Remember that cells are reused in table views and that
 * any modification you may make to the cell could still be present the next time this cell
 * is updated with an object.
 *
 * @code
- (BOOL)shouldUpdateCellWithObject:(id)object {
  // We can be rest assured that `object` is a Tweet object because that's how we set up
  // the bindings. If more than one type of object maps to this cell class then we'd have
  // to check the object type accordingly.
  Tweet* tweet = object;
  self.textLabel.text = tweet.text;

  // Returning YES or NO here is intended purely for subclassing purposes. Returning YES means
  // that the object changed the cell in some way.
  return YES;
}
 * @endcode
 *
 * <h3>Conclusions</h3>
 *
 * The Nimbus cell factory can greatly reduce the amount of code you have to write in your
 * table controllers while separating the data from the presentation. You can slowly ease
 * yourself into using the factory if you already have a large existing code base.
 *
 * If you are migrating from Three20, you will find that Nimbus' table factory is very similar
 * to TTTableViewController, though greatly simplified and decoupled from the rest of the Three20
 * ecosystem. Where Three20 provided a tightly integrated solution, Nimbus allows you to plug
 * in the factory where it makes sense.
 */

#pragma mark * Table Cell Catalog

/**
 * @defgroup TableCellCatalog Table Cell Catalog
 *
 * This is a catalog of Nimbus' pre-built cells and objects for use in UITableViews.
 *
 * All of these cells are designed primarily to be used with the
 * @link TableCellFactory Nimbus cell factory@endlink, though it is entirely possible to use
 * the cells in a vanilla UIKit application as well.
 *
 * <h2>Form Element Catalog</h2>
 *
 * Building forms with Nimbus is incredibly easy thanks to the pre-built form elements. The
 * available form elements are listed below.
 *
 * Form elements require an element ID that can be used to differentiate between the form
 * elements, much like in HTML. If you are using the table cell factory then the element ID
 * will be assigned to the cell's view tag and the control tags as well. Let's say you want
 * to add a text input element that is disabled under certain conditions. Your code would look
 * something like the following:
 *
 * @code
// In your model, create an element with the delegate provided.
[NITextInputFormElement elementWithID:kUsernameField placeholderText:@"Username" value:nil delegate:self],

// And then implement the UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if (textField.tag == kUsernameField) {
    return NO;
  }
  return YES;
}
 * @endcode
 *
 * <h3>NITextInputFormElement</h3>
 *
 * @image html NITextInputCellExample1.png "NITextInputFormElement => NITextInputFormElementCell"
 *
 * Example use in a NITableViewModel:
 * @code
// Create a text input field.
[NITextInputFormElement textInputElementWithID:kUsernameField placeholderText:@"Username" value:nil],
// Create a password input field
[NITextInputFormElement passwordInputElementWithID:kPasswordField placeholderText:@"Password" value:nil],
 * @endcode
 *
 * <h3>NISwitchFormElement</h3>
 *
 * @image html NISwitchFormElementCellExample1.png "NISwitchFormElement => NISwitchFormElementCell"
 *
 * Example use in a NITableViewModel:
 * @code
 [NISwitchFormElement switchElementWithID:kPushNotifications labelText:@"Push Notifications" value:NO],
 * @endcode
 *
 */

#pragma mark * Table Cell Backgrounds

/**
 * @defgroup TableCellBackgrounds Table Cell Backgrounds
 *
 * NICellBackground is a tool for creating backgrounds that can be used to customize cells in
 * UITableViews.
 */

#pragma mark * Model Tools

/**
 * @defgroup ModelTools Model Tools
 *
 * Model tools are objects that abstract common functionality used in view controllers.
 *
 * <h2>Radio Groups</h2>
 *
 * One commonly-required feature for table views is radio button functionality. This is useful when
 * you need the user to make a choice from a set of options. Implementing this is trivial with the
 * Nimbus NIRadioGroup object.
 *
 * The radio group object allows you to map a set of table objects to a group of identifiers and
 * then support radio button interactions. You can find a working example of this in the
 * ModelCatalog sample application.
 *
 * Provided below is a quick overview of implementing the iOS Settings app's notifications page.
 *
@code
// We first define the enumeration of identifiers that we will use to map the table objects
// to unique identifiers.
typedef enum {
  AppSortManual,
  AppSortByTime,
} AppSort;

// You will create and retain a radio group object for the lifecycle of your controller.
@property (nonatomic, retain) NIRadioGroup* radioGroup;

- (void)refreshModel {
  id manual = [NITitleCellObject cellWithTitle:@"Manually"];
  id byTime = [NITitleCellObject cellWithTitle:@"By Time"];

  NSArray* contents =
  [NSArray arrayWithObjects:
   @"Sort Apps:",
   manual, byTime,
   nil];

  self.model = [[NITableViewModel alloc] initWithSectionedArray:contents
                                                       delegate:(id)[NICellFactory class]];
  self.tableView.dataSource = self.model;

  self.radioGroup = [[[NIRadioGroup alloc] init] autorelease];

  // Selection notifications are sent through the delegate.
  self.radioGroup.delegate = self;

  // Map the objects to their corresponding identifiers.
  [self.radioGroup mapObject:manual toIdentifier:AppSortManual];
  [self.radioGroup mapObject:byTime toIdentifier:AppSortByTime];

  // Set the initial selection.
  self.radioGroup.selectedIdentifier = AppSortManual;

  // Insert the radio group into the delegate call chain.
  self.tableView.delegate = [self.radioGroup forwardingTo:self.tableView.delegate];

  [self.tableView reloadData];
}

- (void)radioGroup:(NIRadioGroup *)radioGroup didSelectIdentifier:(NSInteger)identifier {
  NSLog(@"Radio group selection changed: %d", identifier);
}
@endcode
 *
 * <h2>Table View Actions</h2>
 *
 * Separating actions from presentation is an important aspect in simplifying table view cell
 * design. It can be tempting to add delegate and selector properties to cells, but this ends up
 * forcing a lot of logic to be written on the cell level so that the cells accurately represent
 * their actionable state.
 *
 * Nimbus provides a solution with NITableViewActions. NITableViewActions manages the cell <=>
 * action mapping by inserting itself in the delegate call chain invocation forwarding. When cells
 * are displayed, their accessoryType and selectionStyle are updated to reflect the actions that
 * have been attached to them. When cells are tapped, the correct set of actions are performed.
 *
 * Below is an example of implementing the "General" page of the Settings app.
 *
@code
// You will create and retain an actions object for the lifecycle of your controller.
@property (nonatomic, retain) NITableViewActions* actions;

- (void)refreshModel {
  id about = [NITitleCellObject cellWithTitle:@"About"];
  id softwareUpdate = [NITitleCellObject cellWithTitle:@"Software Update"];

  NSArray* contents =
  [NSArray arrayWithObjects:
   @"",
   about, softwareUpdate,
   nil];

  self.model = [[NITableViewModel alloc] initWithSectionedArray:contents
                                                       delegate:(id)[NICellFactory class]];
  self.tableView.dataSource = self.model;

  // The controller we provide here will be passed to the action blocks.
  self.actions = [[[NITableViewActions alloc] initWithController:self] autorelease];
 
  [self.actions attachNavigationAction:NIPushControllerAction([AboutViewController class])
                              toObject:about];
  [self.actions attachNavigationAction:NIPushControllerAction([SoftwareUpdateViewController class])
                              toObject:softwareUpdate];

  // Insert the actions into the delegate call chain.
  self.tableView.delegate = [self.actions forwardingTo:self.tableView.delegate];

  [self.tableView reloadData];
}
@endcode
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NITableViewModel.h"
#import "NIMutableTableViewModel.h"
#import "NICellBackgrounds.h"
#import "NICellCatalog.h"
#import "NICellFactory.h"
#import "NIFormCellCatalog.h"
#import "NIRadioGroup.h"
#import "NIRadioGroupController.h"
#import "NITableViewActions.h"

/**@}*/

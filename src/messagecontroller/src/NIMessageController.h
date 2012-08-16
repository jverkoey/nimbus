//
//  Created by Tony Lewis on 02/29/2012.
//  Copyright (c) 2012 Tony Lewis
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
 * A simple message view controller implementation.
 *
 *      @ingroup NimbusMessageController
 *
 *
 * <h2>Subclassing</h2>
 *
 * This view controller implements UIWebViewDelegate. If you want to
 * implement methods of this delegate then you should take care to call the super implementation
 * if necessary. The following UIViewWebDelegate methods have implementations in this class:
 *
 * @code
 * - webView:shouldStartLoadWithRequest:navigationType:
 * - webViewDidStartLoad:
 * - webViewDidFinishLoad:
 * - webView:didFailLoadWithError:
 * @endcode
 *
 * This view controller also implements UIActionSheetDelegate. If you want to implement methods of
 * this delegate then you should take care to call the super implementation if necessary. The
 * following UIActionSheetDelegate methods have implementations in this class:
 *
 * @code
 * - actionSheet:clickedButtonAtIndex:
 * - actionSheet:didDismissWithButtonIndex:
 * @endcode
 *
 * In addition to the above methods of the UIActionSheetDelegate, this view controller also provides
 * the following method, which is invoked prior to presenting the internal action sheet to the user
 * and allows subclasses to customize the action sheet or even reject to display it (and provide their
 * own handling instead):
 *
 * @code
 * - shouldPresentActionSheet:
 * @endcode
 *
 *
 * <h2>Recommended Configurations</h2>
 *
 * <h3>Default</h3>
 *
 * The default settings will create a toolbar with the default tint color, which is normally
 * light blue on the iPhone and gray on the iPad.
 *
 *
 * <h3>Colored Toolbar</h3>
 *
 * The following settings will change the toolbar tint color (in this case black)
 *
 * @code
 *  [webController setToolbarTintColor:[UIColor blackColor]];
 * @endcode
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NSString+NimbusCore.h"
#import "NITableViewModel.h"
#import "NIActivityLabel.h"

@protocol NIMessageControllerDelegate;

@interface NIMessageController : UIViewController
<UITextViewDelegate,UITextFieldDelegate,UITableViewDelegate,NITableViewModelDelegate> {
@protected
    NSMutableArray*   _fieldViews;
    UIScrollView*     _scrollView;
    NSArray*          _fields;
    UITextView*       _textView;
    NSArray*          _initialRecipients;
    
    NIActivityLabel*  _activityView;
    id<NIMessageControllerDelegate> __unsafe_unretained _delegate;    
    
    UILabel* _charLimitLabel;
    NSInteger _maxCharCount;
    NITableViewModel* _dataSource;
    
    NSMutableSet* activeRequests_;
    BOOL _showsRecipientPicker;
    BOOL _isModified;
    BOOL _requireNonEmptyMessageBody;
    int _minMessageTextViewHeight;
}

@property (nonatomic, readonly) UITextView* textView;

@property (nonatomic, unsafe_unretained)   id<NIMessageControllerDelegate> delegate;

/**
 * The datasource used to autocomplete TTMessageRecipientFields. This class is
 * also responsible for determining how cells representing recipients are
 * labeled.
 */
@property (nonatomic, copy) NITableViewModel* dataSource;

/**
 * The operation queue that runs all of the network and processing operations.
 *
 * This is unloaded when the controller's view is unloaded from memory.
 */
//@property (nonatomic, readonly, retain) NSOperationQueue* queue;

/**
 * An array of NIMessageField instances representing the editable fields. These
 * fields are rendered in order using appropriate views for each field type.
 */
@property (nonatomic, copy) NSArray* fields;

/**
 * A convenience property for editing the subject line of the message
 */
@property (nonatomic, copy) NSString* subject;

/**
 * The body of the message. The body is not required for the user to send a
 * message.
 */
@property (nonatomic, copy) NSString* body;

/**
 * Controls whether a contact add button is shown in the views for
 * NIMessageRecipientField instances.
 */
@property (nonatomic) BOOL showsRecipientPicker;

/**
 * Controls whether a view is displayed to track number of characters
 * entered in the message field.
 */
@property (nonatomic) BOOL showsCharacterCounter;

/**
 * The maximum number of characters to allow in the message field.
 */
@property (nonatomic) NSInteger maxCharCount;

/**
 * Indicates if this message has been modified since it was originally
 * shown. If the message has been modified, the user will be asked for
 * confirmation before their cancel request is enacted.
 */
@property (nonatomic, readonly) BOOL isModified;

/**
 * Indicates if the user must enter text in the editor field to be allowed to
 * send the message.
 *
 * @default NO
 */
@property (nonatomic) BOOL requireNonEmptyMessageBody;

/**
 * Initializes the class with an array of recipients. These recipients will
 * be pre-filled in the NIMessageRecipientField's view.
 *
 * If a non-empty recipients array is provided, NIMessageController expects
 * the first field to be an instance of NIMessageRecipientField. You may pass
 * nil if you do not wish to supply initial recipients.
 */
- (id)initWithRecipients:(NSArray*)recipients;

/**
 * Adds the supplied recipient to the field at the index provided. That
 * recipient will be rendered as a cell within that field's view. The cell's
 * label will be determined by asking the datasource for a string label for
 * the recipient object provided.
 *
 * This method is a no-op if the datasource fails to provide a label for the
 * cell, or if the fieldIndex provided does not refer to a
 * TextField.
 */
- (void)addRecipient:(id)recipient forFieldAtIndex:(NSUInteger)fieldIndex;

/**
 * Returns the text value of the field at the supplied index. Passing
 * fields.count returns the body contents.
 *
 * Whitespace has been trimmed from the returned value.
 */
- (NSString*)textForFieldAtIndex:(NSUInteger)fieldIndex;

/**
 * Sets the text value for the field at fieldIndex. Passing fields.count
 * sets the body text.
 */
- (void)setText:(NSString*)text forFieldAtIndex:(NSUInteger)fieldIndex;

/**
 * Returns true if the field at the supplied index is not empty or has
 * only whitespace. Passing fields.count returns true if the body has any
 * text, whitespace included.
 */
- (BOOL)fieldHasValueAtIndex:(NSUInteger)fieldIndex;

/**
 * Returns the UIView instance representing the field at fieldIndex. Passing
 * fields.count returns the view representing the body contents.
 */
- (UIView*)viewForFieldAtIndex:(NSUInteger)fieldIndex;

/**
 * Causes a view used to indicate message activity to be shown or dismissed
 * depending on the value of show. This view obscures the editable field views.
 * It is usually shown while the message is being sent.
 */
- (void)showActivityView:(BOOL)show;

/**
 * Returns the title for the activity view that is shown by showActivityView.
 * By default, the title is "Sending...", but subclasses may override this
 * method to show a different title. The default title has been localized.
 */
- (NSString*)titleForSending;

/**
 * Tells the delegate to send the message.
 */
- (void)send;

/**
 * Cancel the message, but confirm first with the user if necessary.
 */
- (void)cancel:(BOOL)confirmIfNecessary;

/**
 * Confirms with the user that it is ok to cancel.
 */
- (void)confirmCancellation;

/**
 * Sent before the delegate is informed that it should send the message.
 * Subclasses can override this method to implement custom logic.
 */
- (void)messageWillSend:(NSArray*)fields;

/**
 * The user touched the recipient picker button. Subclasses can override
 * this method to implement custom logic.
 */
- (void)messageWillShowRecipientPicker;

/**
 * Sent after the delegate has been informed that it should send the message.
 * Subclasses can override this method to implement custom logic.
 */
- (void)messageDidSend;

/**
 * Determines if the message should cancel without confirming with the user.
 * The default implementation is to allow the user to cancel without
 * confirmation if no required fields have been modified and they have not
 * entered any subject or body text.
 */
- (BOOL)messageShouldCancel;


@end


@protocol NIMessageControllerDelegate <NSObject>
@optional

/**
 * Received when the user touches the send button, indicating they wish to send
 * their message. Implementations should send the message represented by the
 * supplied fields. The fields array contains subclasses of NIMessageField. Its
 * last object is the body of the message, contained within a NIMessageTextField.
 */
- (void)composeController:(NIMessageController*)controller didSendFields:(NSArray*)fields;

/**
 * Received when the user has chosen to cancel creating their message. Upon
 * returning, the NIMessageController will be dismissed. Implementations
 * can use this callback to cleanup any resources.
 */
- (void)composeControllerWillCancel:(NIMessageController*)controller;

/**
 * Received in response to the user touching a contact add button. This method
 * should prepare and present a view for the user to choose a contact. Upon
 * choosing a contact, that contact should be added to the field.
 */
- (void)composeControllerShowRecipientPicker:(NIMessageController*)controller;

@end
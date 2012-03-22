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

#import "NIMessageController.h"
#import "NIMessageRecipientField.h"
#import "NIMessageTextField.h"
#import "NIMessageSubjectField.h"
#import "NIPickerTextField.h"
#import "NITableViewModel+Private.h"
#import "NimbusCore.h"

#import <QuartzCore/QuartzCore.h>

static const CGFloat kPaddingX = 5;
static const CGFloat kPaddingY = 6;
static const CGFloat kMarginX = 5;
static const CGFloat kMarginY = 6;

@interface NIMessageController (Private)

- (void)createFieldViews;
- (void)constrainMessageEditorToText;

@end

@implementation NIMessageController

@synthesize textView    = _textView;

@synthesize fields                      = _fields;
@synthesize isModified                  = _isModified;
@synthesize showsRecipientPicker        = _showsRecipientPicker;
@synthesize showsCharacterCounter       = _showsCharacterCounter;
@synthesize requireNonEmptyMessageBody  = _requireNonEmptyMessageBody;
@synthesize dataSource                  = _dataSource;
@synthesize delegate                    = _delegate;
@synthesize maxCharCount                = _maxCharCount;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _fields = [[NSArray alloc] initWithObjects:
                   [[[NIMessageRecipientField alloc] initWithTitle: NSLocalizedString(@"To:", @"")
                                                          required: YES] autorelease],
                   [[[NIMessageSubjectField alloc] initWithTitle: NSLocalizedString(@"Subject:", @"")
                                                        required: NO] autorelease],
                   nil];
        
        self.title = NSLocalizedString(@"New Message", @"");
        
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithTitle: NSLocalizedString(@"Cancel", @"")
                                                  style: UIBarButtonItemStyleBordered
                                                  target: self
                                                  action: @selector(cancel)] autorelease];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                   initWithTitle: NSLocalizedString(@"Send", @"")
                                                   style: UIBarButtonItemStyleDone
                                                   target: self
                                                   action: @selector(send)] autorelease];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithRecipients:(NSArray*)recipients {
	self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _initialRecipients = [recipients retain];
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)releaseObjects {
    NI_RELEASE_SAFELY(_fieldViews);
    NI_RELEASE_SAFELY(_scrollView);
    NI_RELEASE_SAFELY(_fields);
    NI_RELEASE_SAFELY(_textView);
    NI_RELEASE_SAFELY(_initialRecipients);
    NI_RELEASE_SAFELY(_activityView);
    NI_RELEASE_SAFELY(_delegate);
    NI_RELEASE_SAFELY(_charLimitLabel);
    NI_RELEASE_SAFELY(_dataSource);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [self releaseObjects];
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
    [self cancel:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createFieldViews {
    for (UIView* view in _fieldViews) {
        [view removeFromSuperview];
    }
    
    [_textView removeFromSuperview];
    
    [_fieldViews release];
    _fieldViews = [[NSMutableArray alloc] init];
    
    CGFloat y = 0;
    for (NIMessageField* field in _fields) {
        NIPickerTextField* textField = [field createViewForController:self];
        if (textField) {
            textField.delegate = self;
            textField.font = [UIFont systemFontOfSize:15];
            textField.backgroundColor = [UIColor whiteColor];
            textField.returnKeyType = UIReturnKeyNext;
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [textField sizeToFit];
            y += textField.frame.size.height;
            
            UILabel* label = [[[UILabel alloc] init] autorelease];
            label.text = field.title;
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor colorWithWhite:0.5 alpha:1];
            [label sizeToFit];
            label.frame = CGRectInset(label.frame, -2, 0);
            textField.leftView = label;
            textField.leftViewMode = UITextFieldViewModeAlways;
            
            [_scrollView addSubview:textField];
            [_fieldViews addObject:textField];
            
            UIView* separator = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)] autorelease];
            separator.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
            separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [_scrollView addSubview:separator];
            y += separator.frame.size.height;
        }
    }
    
    [_scrollView addSubview:_textView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutViews {
    CGFloat y = 0;
    
    for (UIView* view in _scrollView.subviews) {
        view.frame = CGRectMake(0, y, self.view.frame.size.width, view.frame.size.height);
        y += view.frame.size.height;
        [_scrollView bringSubviewToFront:view];
    }
    CGRect textViewFrame = _textView.frame;
    if (textViewFrame.size.height == 0) {
        _textView.frame = NIRectContract(_textView.frame, 0,
                                         -((_scrollView.frame.size.height - y)));
        _minMessageTextViewHeight = _textView.frame.size.height;
    } else {
        textViewFrame = CGRectMake(0, _textView.frame.origin.y,
                                   textViewFrame.size.width,
                                   textViewFrame.size.height);
        _textView.frame = textViewFrame;
    }
    _textView.hidden = NO;
    
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, y);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasEnteredText {
    for (int i = 0; i < _fields.count; ++i) {
        NIMessageField* field = [_fields objectAtIndex:i];
        if (field.required) {
            if ([field isKindOfClass:[NIMessageRecipientField class]]) {
                NIPickerTextField* textField = [_fieldViews objectAtIndex:i];
                if (textField.cells.count) {
                    return YES;
                }
                
            } else if ([field isKindOfClass:[NIMessageTextField class]]) {
                UITextField* textField = [_fieldViews objectAtIndex:i];
                if (NIIsStringWithAnyText(textField.text) &&
                    !textField.text.isWhitespaceAndNewlines) {
                    return YES;
                }
            }
        }
    }
    
    return _textView.text.length;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasRequiredText {
    if (_requireNonEmptyMessageBody &&
        (!NIIsStringWithAnyText(_textView.text) &&
         !_textView.text.isWhitespaceAndNewlines)) {
            return NO;
        }
    
    for (int i = 0; i < _fields.count; ++i) {
        NIMessageField* field = [_fields objectAtIndex:i];
        if (field.required) {
            if ([field isKindOfClass:[NIMessageRecipientField class]]) {
                NIPickerTextField* textField = [_fieldViews objectAtIndex:i];
                if (!textField.cells.count) {
                    return NO;
                }
                
            } else if ([field isKindOfClass:[NIMessageTextField class]]) {
                UITextField* textField = [_fieldViews objectAtIndex:i];
                if (!NIIsStringWithAnyText(textField.text) &&
                    !textField.text.isWhitespaceAndNewlines) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateSendCommand {
    self.navigationItem.rightBarButtonItem.enabled = [self hasRequiredText];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextField*)subjectField {
    for (int i = 0; i < _fields.count; ++i) {
        NIMessageField* field = [_fields objectAtIndex:i];
        if ([field isKindOfClass:[NIMessageSubjectField class]]) {
            return [_fieldViews objectAtIndex:i];
        }
    }
    return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTitleToSubject {
    UITextField* subjectField = self.subjectField;
    if (subjectField) {
        self.navigationItem.title = subjectField.text;
    }
    [self updateSendCommand];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)fieldIndexOfFirstResponder {
    NSInteger fieldIndex = 0;
    for (UIView* view in _fieldViews) {
        if ([view isFirstResponder]) {
            return fieldIndex;
        }
        ++fieldIndex;
    }
    
    if (_textView.isFirstResponder) {
        return _fieldViews.count;
    }
    return -1;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFieldIndexOfFirstResponder:(NSInteger)fieldIndex {
    if (fieldIndex < _fieldViews.count) {
        UIView* view = [_fieldViews objectAtIndex:fieldIndex];
        [view becomeFirstResponder];
        
    } else {
        [_textView becomeFirstResponder];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showRecipientPicker {
    [self messageWillShowRecipientPicker];
    
    if ([_delegate respondsToSelector:@selector(composeControllerShowRecipientPicker:)]) {
        [_delegate composeControllerShowRecipientPicker:self];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
    [super loadView];
    
    self.view.frame = [UIScreen mainScreen].applicationFrame;
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizesSubviews = YES;
    
    CGRect scrollViewFrame = NIKeyboardNavigationFrame();
    _scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.delaysContentTouches = YES;
    _scrollView.canCancelContentTouches = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [_textView setScrollsToTop:YES];
    [self.view addSubview:_scrollView];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, 0)];
    [_textView setScrollEnabled:NO];
    [_textView setScrollsToTop:NO];
    [_textView setBackgroundColor:[UIColor clearColor]];
    _textView.font = [UIFont systemFontOfSize:15];
    _textView.showsHorizontalScrollIndicator = NO;
    _textView.delegate = self;
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_textView sizeToFit];
    
    [self createFieldViews];
    [self layoutViews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self releaseObjects];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_initialRecipients) {
        for (id recipient in _initialRecipients) {
            [self addRecipient:recipient forFieldAtIndex:0];
        }
        NI_RELEASE_SAFELY(_initialRecipients);
    }
    
    for (NSInteger i = 0; i < _fields.count+1; ++i) {
        if (![self fieldHasValueAtIndex:i]) {
            UIView* view = [self viewForFieldAtIndex:i];
            [view becomeFirstResponder];
            return;
        }
    }
    [[self viewForFieldAtIndex:0] becomeFirstResponder];
    
    [self updateSendCommand];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //return interfaceOrientation == UIInterfaceOrientationPortrait;
    //return NIIsSupportedOrientation(interfaceOrientation);
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    _scrollView.frame = CGRectMake(_scrollView.frame.origin.x,
                                   _scrollView.frame.origin.y,
                                   _scrollView.frame.size.width,
                                   self.view.frame.size.height - NIKeyboardHeightForOrientation(fromInterfaceOrientation));
    [self layoutViews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    if (textField == self.subjectField) {
        _isModified = YES;
        [NSTimer scheduledTimerWithTimeInterval:0 target:self
                                       selector:@selector(setTitleToSubject) userInfo:nil repeats:NO];
    }
    return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSUInteger fieldIndex = [_fieldViews indexOfObject:textField];
    UIView* nextView = fieldIndex == _fieldViews.count-1 ? _textView
    : [_fieldViews objectAtIndex:fieldIndex+1];
    [nextView becomeFirstResponder];
    return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textField:(NIPickerTextField*)textField didAddCellAtIndex:(NSInteger)cellIndex {
    [self updateSendCommand];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textField:(NIPickerTextField*)textField didRemoveCellAtIndex:(NSInteger)cellIndex {
    [self updateSendCommand];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidResize:(NIPickerTextField*)textField {
    [self layoutViews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollContainerToCursor:(UIScrollView*)scrollView {
    if (_textView.hasText) {
        if (scrollView.contentSize.height > scrollView.frame.size.height) {
            NSRange range = _textView.selectedRange;
            if (range.location == _textView.text.length) {
                [scrollView scrollRectToVisible:CGRectMake(0,scrollView.contentSize.height-1,1,1)
                                       animated:NO];
            }
            
        } else {
            [scrollView scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChange:(UITextView*)textView {
    [self updateSendCommand];
    _isModified = YES;
    if (_showsCharacterCounter) {
        _charLimitLabel.text = [NSString stringWithFormat:@"%i", (_maxCharCount - [textView.text length])];
        if ([textView.text length] > _maxCharCount) {
            _charLimitLabel.textColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
        } else {
            _charLimitLabel.textColor = [[UIColor greenColor] colorWithAlphaComponent:0.6];
        }
    }
    [self constrainMessageEditorToText];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)constrainMessageEditorToText {
    CGFloat oldHeight = _textView.frame.size.height;
    
    CGFloat lineHeight = _textView.font.lineHeight;
    CGFloat minHeight = _minMessageTextViewHeight;
    CGFloat maxWidth = _textView.frame.size.width - 31;
    
    NSString* text = _textView.text;
    if (!text.length) {
        text = @"M";
    }
    
    CGSize textSize = [text sizeWithFont:_textView.font
                       constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                           lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat newHeight = textSize.height;
    if ([text characterAtIndex:text.length-1] == 10) {
        newHeight += lineHeight;
    }
    
    if (newHeight < minHeight) {
        newHeight = minHeight;
    } else {
        newHeight += kPaddingY*2;
    }
    
    int numberOfLines = (int)floor(newHeight / lineHeight);
    
    CGFloat diff = newHeight - oldHeight;
    
    CGSize scrollViewContentSize = _scrollView.contentSize;
    CGRect scrollViewFrame = _scrollView.frame;
    CGRect scrollViewBounds = _scrollView.bounds;
    CGPoint offset = _scrollView.contentOffset;
    CGRect textViewFrame = _textView.frame;
    
    if (oldHeight && diff) {
        if (floor(minHeight / lineHeight) < numberOfLines) {
            _textView.frame = NIRectContract(_textView.frame, 0, -diff);
            [self layoutViews];
            [self scrollContainerToCursor:_scrollView];
        } else {
            _textView.frame = NIRectContract(_textView.frame, 0, -diff);
            [self layoutViews];
            [self scrollContainerToCursor:_scrollView];
            if (newHeight == minHeight) {
                // I'm not sure why we have to do this but the initial scroll back to top does not
                // display the top fields when we completely remove all text from message text view
                [self performSelector:@selector(resetScrollPosition) withObject:nil afterDelay:0.3];
            }
        }
    }
    scrollViewContentSize = _scrollView.contentSize;
    scrollViewFrame = _scrollView.frame;
    scrollViewBounds = _scrollView.bounds;
    offset = _scrollView.contentOffset;
    textViewFrame = _textView.frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)resetScrollPosition {
    [_scrollView scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAlertViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self cancel:NO];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subject {
    for (int i = 0; i < _fields.count; ++i) {
        id field = [_fields objectAtIndex:i];
        if ([field isKindOfClass:[NIMessageSubjectField class]]) {
            UITextField* textField = [_fieldViews objectAtIndex:i];
            return textField.text;
        }
    }
    return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSubject:(NSString*)subject {
    for (int i = 0; i < _fields.count; ++i) {
        id field = [_fields objectAtIndex:i];
        if ([field isKindOfClass:[NIMessageSubjectField class]]) {
            UITextField* textField = [_fieldViews objectAtIndex:i];
            textField.text = subject;
            break;
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)body {
    return _textView.text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBody:(NSString*)body {
    _textView.text = body;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    if (dataSource != _dataSource) {
        [_dataSource release];
        _dataSource = [dataSource retain];
        
        for (UITextField* textField in _fieldViews) {
            if ([textField isKindOfClass:[NIPickerTextField class]]) {
                NIPickerTextField* menuTextField = (NIPickerTextField*)textField;
                menuTextField.dataSource = dataSource;
            }
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFields:(NSArray*)fields {
    if (fields != _fields) {
        [_fields release];
        _fields = [fields retain];
        
        if (_fieldViews) {
            [self createFieldViews];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRecipient:(id)recipient forFieldAtIndex:(NSUInteger)fieldIndex {
    NIPickerTextField* textField = [_fieldViews objectAtIndex:fieldIndex];
    if ([textField isKindOfClass:[NIPickerTextField class]]) {
        for(NSDictionary* item in [[_dataSource.sections objectAtIndex:0] rows]) {
            if ([[item objectForKey:@"title"] isEqualToString:recipient]) {
                [textField addCellWithObject:recipient];
            }
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)textForFieldAtIndex:(NSUInteger)fieldIndex {
    NSString* text = nil;
    if (fieldIndex == _fieldViews.count) {
        text = _textView.text;
        
    } else {
        NIPickerTextField* textField = [_fieldViews objectAtIndex:fieldIndex];
        if ([textField isKindOfClass:[NIPickerTextField class]]) {
            text = textField.text;
        }
    }
    
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceCharacterSet];
    return [text stringByTrimmingCharactersInSet:whitespace];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setText:(NSString*)text forFieldAtIndex:(NSUInteger)fieldIndex {
    if (fieldIndex == _fieldViews.count) {
        _textView.text = text;
        
    } else {
        NIPickerTextField* textField = [_fieldViews objectAtIndex:fieldIndex];
        if ([textField isKindOfClass:[NIPickerTextField class]]) {
            textField.text = text;
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)fieldHasValueAtIndex:(NSUInteger)fieldIndex {
    if (fieldIndex == _fieldViews.count) {
        return _textView.text.length > 0;
        
    } else {
        NIMessageField* field = [_fields objectAtIndex:fieldIndex];
        if ([field isKindOfClass:[NIMessageRecipientField class]]) {
            NIPickerTextField* pickerTextField = [_fieldViews objectAtIndex:fieldIndex];
            return ((NIIsStringWithAnyText(pickerTextField.text) &&
                     !pickerTextField.text.isWhitespaceAndNewlines)
                    || pickerTextField.cellViews.count > 0);
        } else {
            UITextField* textField = [_fieldViews objectAtIndex:fieldIndex];
            return (NIIsStringWithAnyText(textField.text) && !textField.text.isWhitespaceAndNewlines);
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)viewForFieldAtIndex:(NSUInteger)fieldIndex {
    if (fieldIndex == _fieldViews.count) {
        return _textView;
        
    } else {
        return [_fieldViews objectAtIndex:fieldIndex];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)willPostText:(NSString*)text {
    NSString *trimmedString = [text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (NIIsStringWithAnyText(trimmedString) &&
        !trimmedString.isWhitespaceAndNewlines) {
        if ([trimmedString length] > _maxCharCount) {
            UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"")
                                                                 message:NSLocalizedString(@"You can only enter a maximum of 140 characters.", @"")
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
            return NO;
        }
    }
    return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)send {
    NSMutableArray* fields = [[_fields mutableCopy] autorelease];
    for (int i = 0; i < fields.count; ++i) {
        id field = [fields objectAtIndex:i];
        if ([field isKindOfClass:[NIMessageRecipientField class]]) {
            NIPickerTextField* textField = [_fieldViews objectAtIndex:i];
            [(NIMessageRecipientField*)field setRecipients:textField.cells];
            
        } else if ([field isKindOfClass:[NIMessageTextField class]]) {
            UITextField* textField = [_fieldViews objectAtIndex:i];
            [(NIMessageTextField*)field setText:textField.text];
        }
    }
    
    NIMessageTextField* bodyField = [[[NIMessageTextField alloc] initWithTitle:nil
                                                                      required:NO] autorelease];
    bodyField.text = _textView.text;
    [fields addObject:bodyField];
    
    [self showActivityView:YES];
    
    [self messageWillSend:fields];
    
    if ([_delegate respondsToSelector:@selector(composeController:didSendFields:)]) {
        [_delegate composeController:self didSendFields:fields];
    }
    
    [self messageDidSend];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel:(BOOL)confirmIfNecessary {
    if (confirmIfNecessary && ![self messageShouldCancel]) {
        [self confirmCancellation];
        
    } else {
        if ([_delegate respondsToSelector:@selector(composeControllerWillCancel:)]) {
            [_delegate composeControllerWillCancel:self];
        }
        
        [self dismissModalViewControllerAnimated:NO];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)confirmCancellation {
    UIAlertView* cancelAlertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cancel", @"")
                                                               message:NSLocalizedString(@"Are you sure you want to cancel?", @"")
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"Yes", @"")
                                                     otherButtonTitles:NSLocalizedString(@"No", @""), nil] autorelease];
    [cancelAlertView show];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showActivityView:(BOOL)show {
    self.navigationItem.rightBarButtonItem.enabled = !show;
    if (show) {
        if (!_activityView) {
            CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, _scrollView.bounds.size.height);
            _activityView = [[NIActivityLabel alloc] initWithFrame:frame
                                                             style:NIActivityLabelStyleWhiteBox];
            _activityView.text = [self titleForSending];
            _activityView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self.view addSubview:_activityView];
        }
        
    } else {
        [_activityView removeFromSuperview];
        NI_RELEASE_SAFELY(_activityView);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForSending {
    return NSLocalizedString(@"Sending...", @"");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)messageShouldCancel {
    return ![self hasEnteredText] || !_isModified;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)messageWillShowRecipientPicker {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)messageWillSend:(NSArray*)fields {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)messageDidSend {
}

#pragma mark -
#pragma mark NITableViewModelDelegate


/**
 * Fetches a table view cell at a given index path with a given object.
 *
 * The implementation of this method will generally use object to customize the cell.
 */
///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object {
    
    // A pretty standard implementation of creating table view cells follows.
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"row"];
    
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                       reuseIdentifier: @"row"]
                autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [object objectForKey:@"title"];
    
    return cell;
}


@end

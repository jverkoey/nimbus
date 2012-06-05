//
//  NIPostController.m
//
//  Created by Tony Lewis on 4/7/12.
//  Copyright (c) 2012 Taknology, Inc. All rights reserved.
//

#import "NIPostController.h"

static const CGFloat kMarginX = 5;
static const CGFloat kMarginY = 6;

@implementation NIPostController

@synthesize result      = _result;
@synthesize textView    = _textView;
@synthesize originView  = _originView;
@synthesize delegate    = _delegate;
@synthesize maxCharCount = _maxCharCount;
@synthesize titleForActivity = _titleForActivity;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationItem setLeftBarButtonItem:nil];

        self.navigationItem.leftBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Cancel", @"")
                                          style: UIBarButtonItemStyleBordered
                                         target: self
                                         action: @selector(cancel)] autorelease];
        
        self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Done", @"")
                                          style: UIBarButtonItemStyleDone
                                         target: self
                                         action: @selector(post)] autorelease];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithQuery:(NSDictionary*)query {
	self = [self initWithNibName:nil bundle:nil];
    if (self) {
        if (nil != query) {
            if ([query objectForKey:@"delegate"]) {
                _delegate = [query objectForKey:@"delegate"];
            }
            if ([query objectForKey:@"text"]) {
                _defaultText = [[query objectForKey:@"text"] retain];
            }
            if ([query objectForKey:@"rightButtonText"]) {
                self.navigationItem.rightBarButtonItem.title = [query objectForKey:@"rightButtonText"];
            }
            if ([query objectForKey:@"leftButtonText"]) {
                self.navigationItem.leftBarButtonItem.title = [query objectForKey:@"leftButtonText"];
            }            
            
            self.navigationItem.title = [query objectForKey:@"title"];
            
            if ([query objectForKey:@"__target__"]) {
                self.originView = [query objectForKey:@"__target__"];
            }
            NSValue* originRect = [query objectForKey:@"originRect"];
            if (nil != originRect) {
                _originRect = [originRect CGRectValue];
            }
        }
    }
    
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)releaseObjects {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    NI_RELEASE_SAFELY(_result);
    NI_RELEASE_SAFELY(_defaultText);
    NI_RELEASE_SAFELY(_originView);
    NI_RELEASE_SAFELY(_textView);
    NI_RELEASE_SAFELY(_navigationBar);
    NI_RELEASE_SAFELY(_innerView);
    NI_RELEASE_SAFELY(_activityView);
    NI_RELEASE_SAFELY(_charLimitLabel);
    NI_RELEASE_SAFELY(_titleForActivity);
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
- (NSString*)stripWhitespace:(NSString*)text {
    if (nil != text) {
        NSCharacterSet* whitespace = [NSCharacterSet whitespaceCharacterSet];
        return [text stringByTrimmingCharactersInSet:whitespace];
        
    } else {
        return @"";
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showKeyboard {
    UIApplication* app = [UIApplication sharedApplication];
    _originalStatusBarStyle = app.statusBarStyle;
    _originalStatusBarHidden = app.statusBarHidden;
    if (!_originalStatusBarHidden) {
        [app setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
    [app setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    [_textView becomeFirstResponder];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hideKeyboard {
    UIApplication* app = [UIApplication sharedApplication];
    if (!_originalStatusBarHidden) {
        [app setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
    [app setStatusBarStyle:_originalStatusBarStyle animated:YES];
    [_textView resignFirstResponder];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGAffineTransform)transformForOrientation {
    return NIRotateTransformForOrientation(NIInterfaceOrientation());
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showActivity:(NSString*)activityText {
    if (nil == _activityView) {
        _activityView = [[NIActivityLabel alloc] initWithStyle:NIActivityLabelStyleWhiteBezel];
        _activityView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_activityView];
    }
    
    if (nil != activityText) {
        _activityView.text = activityText;
        _activityView.frame = CGRectOffset(CGRectInset(_textView.frame, 13, 13), 2, 0);
        _activityView.hidden = NO;
        _textView.hidden = YES;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
    } else {
        _activityView.hidden = YES;
        _textView.hidden = NO;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutTextEditor {
    CGFloat keyboard = NIKeyboardHeightForOrientation(NIInterfaceOrientation());
    
    self.view.frame = [UIScreen mainScreen].applicationFrame;

    _screenView.frame = CGRectMake(_navigationBar.frame.origin.x,
                                   (_navigationBar.frame.origin.y +
                                   _navigationBar.frame.size.height),
                                   _navigationBar.frame.size.width, 
                                   _innerView.frame.size.height -
                                   (keyboard+_navigationBar.frame.size.height));

    _textView.frame = CGRectMake(kMarginX, kMarginY+_screenView.frame.origin.y,
                                 _screenView.frame.size.width - (kMarginX*2),
                                 (_screenView.frame.size.height - (kMarginY*2)));

    [_charLimitLabel sizeToFit];
    _charLimitLabel.frame = CGRectMake(_textView.frame.size.width - _charLimitLabel.frame.size.width,
                                       (_textView.frame.origin.y + _textView.frame.size.height)-_charLimitLabel.frame.size.height,
                                       _charLimitLabel.frame.size.width, _charLimitLabel.frame.size.height);

    _textView.hidden = NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showAnimationDidStop {
    
    // TODO: Need to figure out how to do this
//    _textView.hidden = NO;
//    [self.superController viewDidDisappear:YES];
    
    if (_charLimitLabel) {
        [_charLimitLabel removeFromSuperview];
        NI_RELEASE_SAFELY(_charLimitLabel);
    }
    _charLimitLabel = [[UILabel alloc] init];
    _charLimitLabel.backgroundColor = [UIColor clearColor];
    _charLimitLabel.text = [NSString stringWithFormat:@"%i", _maxCharCount];

    _charLimitLabel.textColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
    _charLimitLabel.font = [UIFont boldSystemFontOfSize:32.0f];
    _charLimitLabel.textAlignment = UITextAlignmentRight;
    [_charLimitLabel sizeToFit];
    _charLimitLabel.frame = CGRectMake(_textView.frame.size.width - _charLimitLabel.frame.size.width,
                                       (_textView.frame.origin.y + _textView.frame.size.height)-_charLimitLabel.frame.size.height,
                                       _charLimitLabel.frame.size.width, _charLimitLabel.frame.size.height);
    
    [self.view addSubview:_charLimitLabel];
    [self.view bringSubviewToFront:_charLimitLabel];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissAnimationDidStop {
    if ([_delegate respondsToSelector:@selector(postController:didPostText:withResult:)]) {
        [_delegate postController:self didPostText:_textView.text withResult:_result];
    }
    
    NI_RELEASE_SAFELY(_originView);
    [self dismissPopupViewControllerAnimated:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)fadeOut {
    if ([_delegate respondsToSelector:@selector(postController:didPostText:withResult:)]) {
        [_delegate postController:self didPostText:_textView.text withResult:_result];
    }
    _originView.hidden = NO;
    NI_RELEASE_SAFELY(_originView);
//    _backgroundView.hidden = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(fadeAnimationDidStop)];
    [UIView setAnimationDuration:0.3];
    self.view.alpha = 0;
    [UIView commitAnimations];
    
    [self hideKeyboard];
    [self.view removeFromSuperview];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)fadeAnimationDidStop {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissWithCancel {
    if ([_delegate respondsToSelector:@selector(postControllerDidCancel:)]) {
        [_delegate postControllerDidCancel:self];
    }
    
    BOOL animated = YES;
    [self dismissPopupViewControllerAnimated:animated];
    [_textView resignFirstResponder];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissPopupViewControllerAnimated:(BOOL)animated {
    if (animated) {
        [self fadeOut];
        
    } else {
        [self.view removeFromSuperview];
        [self release];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
    [super loadView];

    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.view.frame = [UIScreen mainScreen].applicationFrame;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizesSubviews = YES;
    
    _innerView = [[UIView alloc] init];
    _innerView.backgroundColor = [UIColor clearColor];
    _innerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _innerView.autoresizesSubviews = YES;
    [self.view addSubview:_innerView];
    
    _screenView = [[UIView alloc] init];
    UIEdgeInsets inset = UIEdgeInsetsMake(6, 5, 6, 5);
    CGRect rect = _screenView.frame;
    _screenView.frame = CGRectMake(rect.origin.x+inset.left, rect.origin.y+inset.top,
                                   rect.size.width - (inset.left + inset.right),
                                   rect.size.height - (inset.top + inset.bottom));
    _screenView.layer.cornerRadius = 10.0f;
    _screenView.backgroundColor = [UIColor whiteColor];
    _screenView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _screenView.autoresizesSubviews = YES;
    [self.view addSubview:_screenView];
    
    _textView = [[UITextView alloc] init];
    _textView.delegate = self;
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.textColor = [UIColor blackColor];
    _textView.contentInset = UIEdgeInsetsMake(0, 4, 0, 4);
    _textView.keyboardAppearance = UIKeyboardAppearanceAlert;
    _textView.textColor = [UIColor blackColor];
    _textView.layer.cornerRadius = 10.0f;
    [self.view addSubview:_textView];
    
    _navigationBar = [[UINavigationBar alloc] init];
    _navigationBar.barStyle = UIBarStyleBlackOpaque;
    _navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _navigationBar.autoresizesSubviews = YES;
    [_navigationBar pushNavigationItem:self.navigationItem animated:NO];
    [_innerView addSubview:_navigationBar];
//    _backgroundView = [[UIImageView alloc] initWithFrame:SCREEN_BOUNDS];
//    _backgroundView.image = [UIImage imageNamed:@"backgroundonly"];
//    [self.view insertSubview:_backgroundView atIndex:0];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    //[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.view.transform = [self transformForOrientation];
    self.view.frame = [UIScreen mainScreen].applicationFrame;
    _innerView.frame = self.view.bounds;
    [self layoutTextEditor];
    [UIView commitAnimations];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)rotatingHeaderView {
    return _navigationBar;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    _backgroundView.frame = CGRectMake(0.0f, 0.0f,
//                                       self.view.frame.size.width, 460.0f);
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self releaseObjects];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showInView:(UIView*)view animated:(BOOL)animated {
    [self retain];
    
    UIWindow* window = view.window ? view.window : [UIApplication sharedApplication].keyWindow;
    
    self.view.transform = [self transformForOrientation];
    self.view.frame = [UIScreen mainScreen].applicationFrame;
    [window addSubview:self.view];
    
    if (_defaultText) {
        _textView.text = _defaultText;
        
    } else {
        _defaultText = [_textView.text retain];
    }
    
    _innerView.frame = self.view.bounds;
    [_navigationBar sizeToFit];
    _originView.hidden = YES;
    
    if (animated) {
        _innerView.alpha = 0;
        _navigationBar.alpha = 0;
        _textView.hidden = YES;
        
        CGRect originRect = _originRect;
        if (CGRectIsEmpty(originRect) && _originView) {
            originRect = _originView.frame;
        }
        
        if (!CGRectIsEmpty(originRect)) {
            _screenView.frame = CGRectOffset(originRect, 0, -NIStatusBarHeight());
            
        } else {
            [self layoutTextEditor];
            _screenView.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(showAnimationDidStop)];
        
        _navigationBar.alpha = 1;
        _innerView.alpha = 1;
        
        if (originRect.size.width) {
            [self layoutTextEditor];
            
        } else {
            _screenView.transform = CGAffineTransformIdentity;
        }
        
        [UIView commitAnimations];
        
    } else {
        _innerView.alpha = 1;
        _screenView.transform = CGAffineTransformIdentity;
        [self layoutTextEditor];
        [self showAnimationDidStop];
    }
    
    [self showKeyboard];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAlertViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self dismissWithCancel];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma UITextViewDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChange:(UITextView *)textView {
    _charLimitLabel.text = [NSString stringWithFormat:@"%i", (_maxCharCount - [_textView.text length])];
    if ([textView.text length] > _maxCharCount) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        _charLimitLabel.textColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
    } else {
        _charLimitLabel.textColor = [[UIColor greenColor] colorWithAlphaComponent:0.6];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    if (!NIIsStringWithAnyText(textView.text)
        && !textView.text.isWhitespaceAndNewlines) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextView*)textView {
    if (self.view) {}
    return _textView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UINavigationBar*)navigatorBar {
    if (!_navigationBar) {
        if (self.view) {}
    }
    return _navigationBar;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setOriginView:(UIView*)view {
    if (view != _originView) {
        [_originView release];
        _originView = [view retain];
        _originRect = CGRectZero;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)post {
    BOOL shouldDismiss = [self willPostText:_textView.text];
    if ([_delegate respondsToSelector:@selector(postController:willPostText:)]) {
        shouldDismiss = [_delegate postController:self willPostText:_textView.text];
    }
    
    if (shouldDismiss) {
        [self dismissWithResult:nil animated:YES];
        
    } else {
        [self showActivity:[self titleForActivity]];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
    if (NIIsStringWithAnyText(_textView.text)
        && !_textView.text.isWhitespaceAndNewlines
        && !(_defaultText && [_defaultText isEqualToString:_textView.text])) {
        UIAlertView* cancelAlertView = [[[UIAlertView alloc] initWithTitle:
                                         NSLocalizedString(@"Cancel", @"")
                                                                   message:NSLocalizedString(@"Are you sure you want to cancel?", @"")
                                                                  delegate:self cancelButtonTitle:NSLocalizedString(@"Yes", @"")
                                                         otherButtonTitles:NSLocalizedString(@"No", @""), nil] autorelease];
        [cancelAlertView show];
        
    } else {
        [self dismissWithCancel];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissWithResult:(id)result animated:(BOOL)animated {
    [_result release];
    _result = [result retain];
    
    if (animated) {
        if ([_delegate respondsToSelector:@selector(postController:willAnimateTowards:)]) {
            CGRect rect = [_delegate postController:self willAnimateTowards:_originRect];
            if (!CGRectIsEmpty(rect)) {
                _originRect = rect;
            }
        }
        
        CGRect originRect = _originRect;
        if (CGRectIsEmpty(originRect) && _originView) {
            originRect = _originView.frame;
        }
        
        _originView.hidden = NO;
        _activityView.hidden = YES;
        _textView.hidden = YES;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop)];
        
        if (!CGRectIsEmpty(originRect)) {
            _screenView.frame = CGRectOffset(originRect, 0, -NIStatusBarHeight());
            
        } else {
            _screenView.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
        }
        
        _innerView.alpha = 0;
        _navigationBar.alpha = 0;
        
        [UIView commitAnimations];
        
    } else {
        [self dismissAnimationDidStop];
    }
    
    [self hideKeyboard];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)failWithError:(NSError*)error {
    [self showActivity:nil];
    
    NSString* title = [self titleForError:error];
    if (title.length) {
        UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                                             message:title delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
    }
}


- (BOOL)willPostText:(NSString*)text {
    NSString *trimmedString = [text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (NIIsStringWithAnyText(trimmedString)) {
        if ([trimmedString length] > _maxCharCount) {
            UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"") message:[NSString stringWithFormat:@"You can only enter a maximum of %i characters.", _maxCharCount] delegate:nil cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
            [alertView show];
            return NO;
        }
    }
    return YES;
}

- (NSString*)titleForError:(NSError*)error {
    return nil;
}


@end

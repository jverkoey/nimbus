//
//  NIPostController.h
//
//  Created by Tony Lewis on 4/7/12.
//  Copyright (c) 2012 Taknology, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NIActivityLabel.h"

@protocol NIPostControllerDelegate;

@interface NIPostController : UIViewController
<UITextViewDelegate,NIOperationDelegate> {
    id                _result;
    NSString*         _defaultText;
    NSString*         _titleForActivity;
    CGRect            _originRect;
    UIView*           _originView;
    UIView*           _innerView;
    UINavigationBar*  _navigationBar;
    UIView*           _screenView;
    UITextView*       _textView;
    NIActivityLabel*  _activityView;
    BOOL              _originalStatusBarHidden;
    UIStatusBarStyle  _originalStatusBarStyle;
    id<NIPostControllerDelegate> _delegate;    
    
    UILabel *_charLimitLabel;
//    UIImageView *_backgroundView;
    NSInteger _maxCharCount;
}

@property (nonatomic, retain)   id                result;
@property (nonatomic, readonly) UITextView*       textView;
@property (nonatomic, readonly) UINavigationBar*  navigatorBar;
@property (nonatomic, retain)   UIView*           originView;
@property (nonatomic, retain)   NSString*         titleForActivity;
@property (nonatomic, assign)   NSInteger         maxCharCount;
@property (nonatomic, assign)   id<NIPostControllerDelegate> delegate;

- (id)initWithQuery:(NSDictionary*)query;

/**
 * Posts the text to delegates, who have to actually do something with it.
 */
- (void)post;

/**
 * Cancels the controller, but confirms with the user if they have entered text.
 */
- (void)cancel;

/**
 * Dismisses the controller with a resulting that is sent to the delegate.
 */
- (void)dismissWithResult:(id)result animated:(BOOL)animated;

/**
 * Notifies the user of an error and resets the editor to normal.
 */
- (void)failWithError:(NSError*)error;

/**
 * The users has entered text and posted it.
 *
 * Subclasses can implement this to handle the text before it is sent to the delegate. The
 * default returns NO.
 *
 * @return YES if the controller should be dismissed immediately.
 */
- (BOOL)willPostText:(NSString*)text;

- (NSString*)titleForError:(NSError*)error;

- (void)showInView:(UIView*)view animated:(BOOL)animated;

- (void)hideKeyboard;

- (void)showActivity:(NSString*)activityText;

- (void)layoutTextEditor;

- (void)fadeOut;


@end


@protocol NIPostControllerDelegate <NSObject>
@optional

/**
 * The user has posted text and an animation is about to show the text return to its origin.
 *
 * @return whether to dismiss the controller or wait for the user to call dismiss.
 */
- (BOOL)postController:(NIPostController*)postController willPostText:(NSString*)text;

/**
 * The text will animate towards a rectangle.
 *
 * @return the rect in screen coordinates where the text should animate towards.
 */
- (CGRect)postController:(NIPostController*)postController willAnimateTowards:(CGRect)rect;

/**
 * The text has been posted.
 */
- (void)postController: (NIPostController*)postController
           didPostText: (NSString*)text
            withResult: (id)result;

/**
 * The controller was cancelled before posting.
 */
- (void)postControllerDidCancel:(NIPostController*)postController;

@end
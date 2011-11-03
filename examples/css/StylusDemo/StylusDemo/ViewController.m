//
//  ViewController.m
//  StylusDemo
//
//  Created by Daniel Barden on 11/2/11.
//  Copyright (c) 2011 None. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "NimbusCSS.h"
#import "NIChameleonObserver.h"

static CGFloat squareSize = 200;

@implementation ViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    NI_RELEASE_SAFELY(_dom);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        NIStylesheetCache* stylesheetCache =
        [(AppDelegate *)[UIApplication sharedApplication].delegate stylesheetCache];
        NIStylesheet* stylesheet = [stylesheetCache stylesheetWithPath:@"root/root.styl" loadFromDisk:NO];
        _dom = [[NIDOM alloc] initWithStylesheet:stylesheet];
        
        NIChameleonObserver *chameleon = [(AppDelegate *)[UIApplication sharedApplication].delegate chameleonObserver];
        [chameleon downloadStylesheetWithFilename:@"root/root.styl"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stylesheetDidChange)
                                                     name:NIStylesheetDidChangeNotification
                                                   object:stylesheet];
        self.title = @"Nimbus CSS Demo";
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    CGSize labelSize = CGSizeZero;
    
    if (_testLabel.numberOfLines == 0) {
        labelSize = [_testLabel.text sizeWithFont:_testLabel.font
                                constrainedToSize:CGSizeMake(squareSize - 20, squareSize - 20)
                                    lineBreakMode:_testLabel.lineBreakMode];
    } else {
        labelSize = CGSizeMake(squareSize - 20, _testLabel.numberOfLines * _testLabel.font.lineHeight);
    }
    
    CGSize activitySize = _activityIndicator.frame.size;
    labelSize.height = MIN(squareSize - 40 - activitySize.height - 10, labelSize.height);
    
    _testLabel.frame = CGRectMake(floorf((squareSize - labelSize.width) / 2),
                                  MAX(20 + activitySize.height + 10,
                                      floorf((squareSize - labelSize.height) / 2)),
                                  labelSize.width, labelSize.height);
    
    _activityIndicator.frame = CGRectMake(floorf((squareSize - _activityIndicator.frame.size.width) / 2),
                                          CGRectGetMinY(_testLabel.frame) - 10 - activitySize.height,
                                          activitySize.width, activitySize.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
    [super loadView];
    
    _backgroundView = [[UIView alloc] init];
    UIViewAutoresizing flexibleMargins = (UIViewAutoresizingFlexibleTopMargin
                                          | UIViewAutoresizingFlexibleRightMargin
                                          | UIViewAutoresizingFlexibleLeftMargin
                                          | UIViewAutoresizingFlexibleBottomMargin);
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                          UIActivityIndicatorViewStyleWhiteLarge];
    [_activityIndicator sizeToFit];
    [_activityIndicator startAnimating];
    
    CGSize boundsSize = self.view.bounds.size;
    _backgroundView.frame = CGRectMake(floorf((boundsSize.width - squareSize) / 2),
                                       floorf((boundsSize.height - squareSize) / 2),
                                       squareSize, squareSize);
    
    _testLabel = [[UILabel alloc] init];
    _testLabel.text = @"Chameleon changes skins in real time.\n\nStop compiling.\nStart building.";
    
    _testLabel.autoresizingMask = flexibleMargins;
    _backgroundView.autoresizingMask = flexibleMargins;
    _activityIndicator.autoresizingMask = flexibleMargins;
    
    [self.view addSubview:_backgroundView];
    [_backgroundView addSubview:_activityIndicator];
    [_backgroundView addSubview:_testLabel];
    
    // Register our views with the DOM.
    [_dom registerView:self.view withCSSClass:@"background"];
    [_dom registerView:_testLabel];
    [_dom registerView:_backgroundView withCSSClass:@"noticeBox"];
    
    [self layoutSubviews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
    [_dom unregisterAllViews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stylesheetDidChange {
    [_dom refresh];
    [self layoutSubviews];
}

@end

//
//  AlignmentAttributedLabelViewController.m
//  NimbusCatalog
//
//  Created by Jeroen Trappers on 18/12/12.
//  Copyright (c) 2012 Nimbus. All rights reserved.
//

#import "AlignmentAttributedLabelViewController.h"
#import "NIAttributedLabel.h"

@interface AlignmentAttributedLabelViewController ()

@property (weak, nonatomic) IBOutlet NIAttributedLabel *topLeft;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *top;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *topRight;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *left;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *center;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *right;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *bottom;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *bottomRight;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *bottomLeft;

@end

@implementation AlignmentAttributedLabelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.topLeft.verticalTextAlignment = NIVerticalTextAlignmentTop;
    self.top.verticalTextAlignment = NIVerticalTextAlignmentTop;
    self.topRight.verticalTextAlignment = NIVerticalTextAlignmentTop;
    
    self.left.verticalTextAlignment = NIVerticalTextAlignmentMiddle;
    self.center.verticalTextAlignment = NIVerticalTextAlignmentMiddle;
    self.right.verticalTextAlignment = NIVerticalTextAlignmentMiddle;
    
    self.bottomLeft.verticalTextAlignment = NIVerticalTextAlignmentBottom;
    self.bottom.verticalTextAlignment = NIVerticalTextAlignmentBottom;
    self.bottomRight.verticalTextAlignment = NIVerticalTextAlignmentBottom;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTopLeft:nil];
    [self setTopLeft:nil];
    [self setTop:nil];
    [self setTopRight:nil];
    [self setLeft:nil];
    [self setCenter:nil];
    [self setRight:nil];
    [self setBottom:nil];
    [self setBottomRight:nil];
    [self setBottomLeft:nil];
    [super viewDidUnload];
}
@end

//
//  MainViewController.m
//  BasicMessageController
//
//  Created by Tony Lewis on 2/29/12.
//  Copyright (c) 2012 Taknology, Inc. All rights reserved.
//

#import "MainViewController.h"
#import "NITableViewSearchModel.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    // If you create your views manually, you MUST override this method and use it to create your views.
    // If you use Interface Builder to create your views, then you must NOT override this method.
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    self.view = [[UIView alloc] initWithFrame:appFrame];
	self.view.backgroundColor = [UIColor whiteColor];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Show NIMessageController" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showMessageController:)
     forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(20, 20, appFrame.size.width - 40, 50);
    [self.view addSubview:button];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showMessageController:(id)sender {
    _messageController = [[NIMessageController alloc]
                           initWithRecipients:[NSArray arrayWithObjects:@"Jon Abrams", @"Jeremy Nym", nil]];
    
    if (_messageController) {
        NSArray* tableContents =
        [NSArray arrayWithObjects:
         [NSDictionary dictionaryWithObject:@"Jon Abrams" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Crystal Arbor" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Mike Axiom" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Joey Bannister" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Ray Bowl" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Jane Byte" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"JJ Cranilly" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Jake Klark" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Viktor Krum" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Abraham Kyle" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Mr Larry" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Mo Lundlum" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Carl Nolly" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Jeremy Nym" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 1 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 2 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 3 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 4 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 5 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 6 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 7 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 8 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 9 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 10 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Charles Xavier" forKey:@"title"],
         nil];
        
        // This controller creates the table view cells.
        NITableViewSearchModel* searchModel = [[NITableViewSearchModel alloc] initWithListArray:tableContents
                                                                                       delegate:_messageController];
        
        _messageController.dataSource = searchModel;
        _messageController.delegate = self;
        _messageController.showsRecipientPicker = YES;
        
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:_messageController];
        [self presentModalViewController:navController animated:YES];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NIMessageControllerDelegate
- (void)composeController:(NIMessageController*)controller didSendFields:(NSArray*)fields {
    /*
     _sendTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self
     selector:@selector(sendDelayed:) userInfo:fields repeats:NO];
     */
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)composeControllerDidCancel:(NIMessageController*)controller {
    /*
     [_sendTimer invalidate];
     _sendTimer = nil;
     
     [controller dismissModalViewControllerAnimated:YES];
     */
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)composeControllerShowRecipientPicker:(NIMessageController*)controller {
    SearchViewController* searchViewController = [[SearchViewController alloc] init];
    if (searchViewController) {
        NSArray* tableContents =
        [NSArray arrayWithObjects:
         @"A",
         [NSDictionary dictionaryWithObject:@"Jon Abrams" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Crystal Arbor" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Mike Axiom" forKey:@"title"],
         
         @"B",
         [NSDictionary dictionaryWithObject:@"Joey Bannister" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Ray Bowl" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Jane Byte" forKey:@"title"],
         
         @"C",
         [NSDictionary dictionaryWithObject:@"JJ Cranilly" forKey:@"title"],
         
         @"K",
         [NSDictionary dictionaryWithObject:@"Jake Klark" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Viktor Krum" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Abraham Kyle" forKey:@"title"],
         
         @"L",
         [NSDictionary dictionaryWithObject:@"Mr Larry" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Mo Lundlum" forKey:@"title"],
         
         @"N",
         [NSDictionary dictionaryWithObject:@"Carl Nolly" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Jeremy Nym" forKey:@"title"],
         
         @"O",
         [NSDictionary dictionaryWithObject:@"Number 1 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 2 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 3 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 4 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 5 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 6 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 7 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 8 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 9 Otter" forKey:@"title"],
         [NSDictionary dictionaryWithObject:@"Number 10 Otter" forKey:@"title"],
         
         @"X",
         [NSDictionary dictionaryWithObject:@"Charles Xavier" forKey:@"title"],
         
         nil];
        
        // This controller creates the table view cells.
        SearchTableViewModel* searchModel = [[SearchTableViewModel alloc] initWithSectionedArray:tableContents
                                                                                        delegate:controller];
        
        [searchModel setSectionIndexType:NITableViewModelSectionIndexAlphabetical showsSearch:YES showsSummary:NO];
        searchViewController.model = searchModel;
        searchViewController.title = @"Search for recipient";
        searchViewController.delegate = self;
        UINavigationController* navController = [[UINavigationController alloc] init];
        [navController pushViewController:searchViewController animated:NO];
        [self.modalViewController presentModalViewController:navController animated:YES];
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// SearchTestControllerDelegate
- (void)searchViewController:(SearchViewController*)controller didSelectObject:(id)object {
    [_messageController addRecipient:[object valueForKey:@"title"] forFieldAtIndex:0];
}


@end

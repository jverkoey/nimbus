//
// Copyright 2011-2012 Jeff Verkoeyen
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

#import "PerformanceAttributedLabelViewController.h"
#import "NimbusAttributedLabel.h"

//
// What's going on in this file:
//
// This controller displays a remarkably large label with defered link autodetection. The goal
// of this controller is to demonstrate the performance improvements of offloading automatic link
// detection.
//
// You will find the following Nimbus features used:
//
// [attributedlabel]
// NIAttributedLabel
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
// CoreText.framework
// QuartzCore.framework
//

@interface PerformanceAttributedLabelViewController()
@property (nonatomic, readwrite, retain) NIAttributedLabel* label;
@property (nonatomic, readwrite, retain) UIScrollView* scrollView;
@end

@implementation PerformanceAttributedLabelViewController

@synthesize label = _label;
@synthesize scrollView = _scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Performance";
  }
  return self;
}

- (void)_layoutLabel {
  CGSize size = [self.label sizeThatFits:CGSizeMake(self.view.bounds.size.width - 40, CGFLOAT_MAX)];
  self.label.frame = CGRectMake(20, 0, size.width, size.height);
  self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.label.frame.size.height);
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
  self.label.numberOfLines = 0;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
  self.label.lineBreakMode = UILineBreakModeWordWrap;
#else
  self.label.lineBreakMode = NSLineBreakByWordWrapping;
#endif
  self.label.font = [UIFont fontWithName:@"Optima-Regular" size:20];
  self.label.autoDetectLinks = YES;
  self.label.dataDetectorTypes = NSTextCheckingAllSystemTypes;

  // When we enable defering the link detection is offloaded to a separate thread. This allows
  // the label to display its text immediately and redraw itself once the links have been
  // detected. For the block of text below this ends up displaying the text ~300ms faster on an
  // iPhone 4S than it otherwise would have.
  self.label.deferLinkDetection = YES;

  // Add a ridiculous amount of text to the attributed label.
  // http://hipsteripsum.me/
  self.label.text = @"Echo.com park farm-to-table irony, brooklyn raw denim elit mumblecore sapiente cliche nisi proident. Ennui fingerstache next level portland craft beer carles, leggings nostrud. 3 wolf moon kale chips twee elit, pork belly bicycle rights ut stumptown aesthetic. Culpa cred id beard. Sustainable fugiat aliqua, bespoke ullamco banh mi forage thundercats helvetica non farm-to-table chillwave esse sed organic. Pork belly cray irony, forage eiusmod ethnic hoodie brooklyn PBR cupidatat duis quinoa banh mi gentrify. Craft beer sustainable mlkshk, labore marfa deserunt yr put a bird on it ea aesthetic aute placeat."
  @"Tempor truffaut mumblecore pinterest cred locavore single-origin coffee, authentic pitchfork sapiente lo-fi. Nulla viral next level, consectetur nostrud voluptate ex skateboard butcher. Vice wolf anim etsy mustache. Single-origin coffee artisan 8-bit, minim delectus pariatur esse thundercats keffiyeh. Laboris fugiat swag carles terry richardson cillum, sustainable aute semiotics et. Whatever in irure, qui butcher ethical lo-fi. Trust fund PBR quinoa dolore salvia cosby sweater messenger bag tempor +1, magna lomo."
  @"Culpa flexitarian@gmail.com pour-over, high life PBR quis dreamcatcher tumblr next level. Id gentrify kale chips consectetur minim labore ennui, fixie thundercats mustache banh mi DIY laboris. Small batch carles aute, deserunt pariatur odio raw denim retro do nostrud street art chambray you probably haven't heard of them sed. Photo booth gentrify nihil, delectus retro bespoke ethical pork belly. 8-bit post-ironic mustache odd future umami et. Squid retro mumblecore, keytar sint swag brooklyn skateboard. Mcsweeney's esse fugiat, quinoa sriracha wayfarers tempor ethnic placeat jean shorts narwhal."
  @"Irure leggings nostrud adipisicing enim excepteur. Vinyl marfa labore cray, wes anderson echo park chambray carles retro veniam godard duis sint laborum. Minim ex exercitation pariatur leggings, occaecat aliqua dolore locavore. Est squid deserunt, godard ethical veniam gluten-free wolf aliqua VHS. Dreamcatcher nostrud dolore fap quinoa put a bird on it wayfarers, vinyl nulla. Photo booth farm-to-table enim fixie. Fanny pack beard salvia minim ethical aute, cred officia tofu vegan whatever helvetica mustache messenger bag."
  @"Nisi vegan portland.net assumenda narwhal 8-bit. Adipisicing keytar master cleanse proident, qui marfa wes anderson id gluten-free. Quis put a bird on it american apparel flexitarian bicycle rights cred. Truffaut veniam aliquip deserunt blog dolore. Vice pickled consectetur ad, velit selvage chillwave gluten-free keytar qui forage scenester. Delectus vero eiusmod pour-over occaecat, fanny pack excepteur mixtape. Forage post-ironic qui, assumenda magna gentrify in mcsweeney's banksy mollit eiusmod."
  @"Lomo hella mumblecore nostrud bicycle rights. Ethical hella aesthetic pickled dolore, officia leggings next level delectus. Sunt jean shorts officia shoreditch, biodiesel quinoa Austin keytar helvetica vegan forage bicycle rights cray esse small batch. Incididunt salvia echo park, ea esse synth laborum chillwave hella tempor enim. Vegan cliche incididunt kale chips nostrud terry richardson, mixtape VHS excepteur. Pop-up cosby sweater helvetica do. Viral gentrify brunch kale chips stumptown, tofu truffaut pariatur."
  @"Dolor kale chips ad semiotics, synth dolore labore scenester street art brunch occaecat jean shorts before they sold out echo park. Marfa pop-up quinoa, enim sriracha thundercats mcsweeney's wes anderson bespoke nihil occaecat adipisicing sapiente. Wolf freegan messenger bag lo-fi sartorial deserunt, ex sustainable minim american apparel master cleanse single-origin coffee. Fap sriracha pariatur, id fingerstache commodo culpa flexitarian irony shoreditch aute street art. Officia leggings elit, sapiente mlkshk umami placeat truffaut minim fanny pack. Artisan non sriracha, thundercats reprehenderit stumptown dolor messenger bag quis polaroid scenester officia williamsburg pour-over trust fund. Swag vegan craft beer etsy, seitan pickled commodo banksy wolf vinyl wayfarers marfa nihil brooklyn."
  @"Voluptate trust fund non beard.edu, cardigan pariatur before they sold out id craft beer post-ironic +1 helvetica laborum bespoke. Odd future helvetica keffiyeh, bicycle rights anim american apparel VHS hella magna nostrud tempor williamsburg godard. Et aute aliquip fap. Mixtape anim ennui, cardigan cupidatat velit terry richardson labore cliche food truck keffiyeh enim. Commodo flexitarian ullamco est cillum, 8-bit narwhal butcher four loko art party thundercats jean shorts salvia. In Austin small batch locavore. Farm-to-table DIY assumenda elit sed mlkshk, cray fugiat mcsweeney's minim duis."
  @"Kale chips wolf dreamcatcher scenester ex hella anim ad polaroid artisan. Incididunt vice polaroid cliche ut, viral jean shorts chillwave direct trade gastropub helvetica cupidatat. Art party cupidatat bicycle rights exercitation et elit. Reprehenderit polaroid vero, pariatur wolf semiotics forage ethical pitchfork velit. Jean shorts high life locavore, aliqua excepteur aliquip est ethical. Whatever irony pitchfork, do four loko lomo odio et american apparel. Terry richardson id viral, 3 wolf moon mlkshk nisi sartorial master cleanse officia irure readymade cardigan chambray street art."
  @"Excepteur minim pop-up, craft beer mixtape brooklyn raw denim gentrify brunch sed you probably haven't heard of them cliche voluptate photo booth. Forage marfa laboris portland mustache, reprehenderit wes anderson eu. Master cleanse godard organic post-ironic. Elit +1 est wes anderson qui cliche cardigan, non deserunt godard consectetur photo booth organic forage. Pickled fugiat sint consectetur williamsburg. Butcher sustainable readymade fap chambray, labore letterpress gluten-free 3 wolf moon gentrify vero qui mcsweeney's whatever. Dreamcatcher farm-to-table lo-fi nesciunt magna, hella reprehenderit messenger bag ullamco VHS tofu est.";

  self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
  self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
  self.scrollView.contentInset = UIEdgeInsetsMake(20, 0, 20, 0);
  [self.scrollView addSubview:self.label];
  [self.view addSubview:self.scrollView];

  [self _layoutLabel];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

  // When we rotate the device we need to recalculate how tall the scroll view should be.
  [self _layoutLabel];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // If the controller is presented in landscape mode we need to ensure that we update the layout.
  [self _layoutLabel];
}

@end

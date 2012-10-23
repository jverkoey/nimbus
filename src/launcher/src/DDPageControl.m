//
//  DDPageControl.m
//  DDPageControl
//
//  Created by Damien DeVille on 1/14/11.
//  Copyright 2011 Snappy Code. All rights reserved.
//

#import "DDPageControl.h"


#define kDotDiameter	4.0f
#define kDotSpace		12.0f


@implementation DDPageControl

@synthesize numberOfPages ;
@synthesize currentPage ;
@synthesize hidesForSinglePage ;
@synthesize defersCurrentPageDisplay ;

@synthesize type ;
@synthesize onColor ;
@synthesize offColor ;
@synthesize indicatorDiameter ;
@synthesize indicatorSpace ;

#pragma mark -
#pragma mark Initializers - dealloc

- (id)initWithType:(DDPageControlType)theType
{
	self = [self initWithFrame: CGRectZero] ;
	[self setType: theType] ;
	return self ;
}

- (id)init
{
	self = [self initWithFrame: CGRectZero] ;
	return self ;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame: CGRectZero]))
	{
		self.backgroundColor = [UIColor clearColor] ;
	}
	return self ;
}

- (void)dealloc 
{
	[onColor release], onColor = nil ;
	[offColor release], offColor = nil ;
	
	[super dealloc] ;
}


#pragma mark -
#pragma mark drawRect

- (void)drawRect:(CGRect)rect 
{
	// get the current context
	CGContextRef context = UIGraphicsGetCurrentContext() ;
	
	// save the context
	CGContextSaveGState(context) ;
	
	// allow antialiasing
	CGContextSetAllowsAntialiasing(context, TRUE) ;
	
	// get the caller's diameter if it has been set or use the default one 
	CGFloat diameter = (indicatorDiameter > 0) ? indicatorDiameter : kDotDiameter ;
	CGFloat space = (indicatorSpace > 0) ? indicatorSpace : kDotSpace ;
	
	// geometry
	CGRect currentBounds = self.bounds ;
	CGFloat dotsWidth = self.numberOfPages * diameter + MAX(0, self.numberOfPages - 1) * space ;
	CGFloat x = CGRectGetMidX(currentBounds) - dotsWidth / 2 ;
	CGFloat y = CGRectGetMidY(currentBounds) - diameter / 2 ;
	
	// get the caller's colors it they have been set or use the defaults
	CGColorRef onColorCG = onColor ? onColor.CGColor : [UIColor colorWithWhite: 1.0f alpha: 1.0f].CGColor ;
	CGColorRef offColorCG = offColor ? offColor.CGColor : [UIColor colorWithWhite: 0.7f alpha: 0.5f].CGColor ;
	
	// actually draw the dots
	for (int i = 0 ; i < numberOfPages ; i++)
	{
		CGRect dotRect = CGRectMake(x, y, diameter, diameter) ;
		
		if (i == currentPage)
		{
			if (type == DDPageControlTypeOnFullOffFull || type == DDPageControlTypeOnFullOffEmpty)
			{
				CGContextSetFillColorWithColor(context, onColorCG) ;
				CGContextFillEllipseInRect(context, CGRectInset(dotRect, -0.5f, -0.5f)) ;
			}
			else
			{
				CGContextSetStrokeColorWithColor(context, onColorCG) ;
				CGContextStrokeEllipseInRect(context, dotRect) ;
			}
		}
		else
		{
			if (type == DDPageControlTypeOnEmptyOffEmpty || type == DDPageControlTypeOnFullOffEmpty)
			{
				CGContextSetStrokeColorWithColor(context, offColorCG) ;
				CGContextStrokeEllipseInRect(context, dotRect) ;
			}
			else
			{
				CGContextSetFillColorWithColor(context, offColorCG) ;
				CGContextFillEllipseInRect(context, CGRectInset(dotRect, -0.5f, -0.5f)) ;
			}
		}
		
		x += diameter + space ;
	}
	
	// restore the context
	CGContextRestoreGState(context) ;
}


#pragma mark -
#pragma mark Accessors

- (void)setCurrentPage:(NSInteger)pageNumber
{
	// no need to update in that case
	if (currentPage == pageNumber)
		return ;
	
	// determine if the page number is in the available range
	currentPage = MIN(MAX(0, pageNumber), numberOfPages - 1) ;
	
	// in case we do not defer the page update, we redraw the view
	if (self.defersCurrentPageDisplay == NO)
		[self setNeedsDisplay] ;
}

- (void)setNumberOfPages:(NSInteger)numOfPages
{
	// make sure the number of pages is positive
	numberOfPages = MAX(0, numOfPages) ;
	
	// we then need to update the current page
	currentPage = MIN(MAX(0, currentPage), numberOfPages - 1) ;
	
	// correct the bounds accordingly
	self.bounds = self.bounds ;
	
	// we need to redraw
	[self setNeedsDisplay] ;
	
	// depending on the user preferences, we hide the page control with a single element
	if (hidesForSinglePage && (numOfPages < 2))
		[self setHidden: YES] ;
	else
		[self setHidden: NO] ;
}

- (void)setHidesForSinglePage:(BOOL)hide
{
	hidesForSinglePage = hide ;
	
	// depending on the user preferences, we hide the page control with a single element
	if (hidesForSinglePage && (numberOfPages < 2))
		[self setHidden: YES] ;
}

- (void)setDefersCurrentPageDisplay:(BOOL)defers
{
	defersCurrentPageDisplay = defers ;
}

- (void)setType:(DDPageControlType)aType
{
	type = aType ;
	
	[self setNeedsDisplay] ;
}

- (void)setOnColor:(UIColor *)aColor
{
	[aColor retain] ;
	[onColor release] ;
	onColor = aColor ;
	
	[self setNeedsDisplay] ;
}

- (void)setOffColor:(UIColor *)aColor
{
	[aColor retain] ;
	[offColor release] ;
	offColor = aColor ;
	
	[self setNeedsDisplay] ;
}

- (void)setIndicatorDiameter:(CGFloat)aDiameter
{
	indicatorDiameter = aDiameter ;
	
	// correct the bounds accordingly
	self.bounds = self.bounds ;
	
	[self setNeedsDisplay] ;
}

- (void)setIndicatorSpace:(CGFloat)aSpace
{
	indicatorSpace = aSpace ;
	
	// correct the bounds accordingly
	self.bounds = self.bounds ;
	
	[self setNeedsDisplay] ;
}

- (void)setFrame:(CGRect)aFrame
{
	// we do not allow the caller to modify the size struct in the frame so we compute it
	aFrame.size = [self sizeForNumberOfPages: numberOfPages] ;
	super.frame = aFrame ;
}

- (void)setBounds:(CGRect)aBounds
{
	// we do not allow the caller to modify the size struct in the bounds so we compute it
	aBounds.size = [self sizeForNumberOfPages: numberOfPages] ;
	super.bounds = aBounds ;
}



#pragma mark -
#pragma mark UIPageControl methods

- (void)updateCurrentPageDisplay
{
	// ignores this method if the value of defersPageIndicatorUpdate is NO
	if (self.defersCurrentPageDisplay == NO)
		return ;
	
	// in case it is YES, we redraw the view (that will update the page control to the correct page)
	[self setNeedsDisplay] ;
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
	CGFloat diameter = (indicatorDiameter > 0) ? indicatorDiameter : kDotDiameter ;
	CGFloat space = (indicatorSpace > 0) ? indicatorSpace : kDotSpace ;
	
	return CGSizeMake(pageCount * diameter + (pageCount - 1) * space + 10.0f, MAX(10.0f, diameter + 10.0f)) ;
}


#pragma mark -
#pragma mark Touches handlers

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// get the touch location
	UITouch *theTouch = [touches anyObject] ;
	CGPoint touchLocation = [theTouch locationInView: self] ;
	
	// check whether the touch is in the right or left hand-side of the control
	if (touchLocation.x < (self.bounds.size.width / 2))
		self.currentPage = MAX(self.currentPage - 1, 0) ;
	else
		self.currentPage = MIN(self.currentPage + 1, numberOfPages - 1) ;
	
	// send the value changed action to the target
	[self sendActionsForControlEvents: UIControlEventValueChanged] ;
}

@end
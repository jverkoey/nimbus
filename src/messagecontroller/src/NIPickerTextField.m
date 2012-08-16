//
// Copyright 2009-2011 Facebook
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

#import "NIPickerTextField.h"

// UI
#import "NIPickerViewCell.h"

#import "NimbusCore.h"

static NSString* kEmpty = @" ";
static NSString* kSelected = @"`";

static const CGFloat kCellPaddingY    = 3;
static const CGFloat kPaddingX        = 8;
static const CGFloat kSpacingY        = 6;
static const CGFloat kPaddingRatio    = 1.75;
static const CGFloat kClearButtonSize = 38;
static const CGFloat kMinCursorWidth  = 50;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIPickerTextField


@synthesize cellViews     = _cellViews;
@synthesize selectedCell  = _selectedCell;
@synthesize lineCount     = _lineCount;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    if (self) {
        _cellViews = [[NSMutableArray alloc] init];
        _lineCount = 1;
        _cursorOrigin = CGPointZero;
        
        self.text = kEmpty;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        self.clearButtonMode = UITextFieldViewModeNever;
        self.returnKeyType = UIReturnKeyDone;
        self.enablesReturnKeyAutomatically = NO;
        
        [self addTarget:self action:@selector(textFieldDidEndEditing)
       forControlEvents:UIControlEventEditingDidEnd];
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)layoutCells {
    CGFloat fontHeight = self.font.lineHeight;
    CGFloat lineIncrement = fontHeight + kCellPaddingY*2 + kSpacingY;
    CGFloat marginY = floor(fontHeight/kPaddingRatio);
    CGFloat marginLeft = self.leftView
    ? kPaddingX + self.leftView.frame.size.width + kPaddingX/2
    : kPaddingX;
    CGFloat marginRight = kPaddingX + (self.rightView ? kClearButtonSize : 0);
    
    _cursorOrigin.x = marginLeft;
    _cursorOrigin.y = marginY;
    _lineCount = 1;
    
    if (self.frame.size.width) {
        for (NIPickerViewCell* cell in _cellViews) {
            [cell sizeToFit];
            
            CGFloat lineWidth = _cursorOrigin.x + cell.frame.size.width + marginRight;
            if (lineWidth >= self.frame.size.width) {
                _cursorOrigin.x = marginLeft;
                _cursorOrigin.y += lineIncrement;
                ++_lineCount;
            }
            
            cell.frame = CGRectMake(_cursorOrigin.x, _cursorOrigin.y-kCellPaddingY,
                                    cell.frame.size.width, cell.frame.size.height);
            _cursorOrigin.x += cell.frame.size.width + kPaddingX;
        }
        
        CGFloat remainingWidth = self.frame.size.width - (_cursorOrigin.x + marginRight);
        if (remainingWidth < kMinCursorWidth) {
            _cursorOrigin.x = marginLeft;
            _cursorOrigin.y += lineIncrement;
            ++_lineCount;
        }
    }
    
    return _cursorOrigin.y + fontHeight + marginY;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateHeight {
    CGFloat previousHeight = self.frame.size.height;
    CGFloat newHeight = [self layoutCells];
    if (previousHeight && newHeight != previousHeight) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight);
        [self setNeedsDisplay];
        
        if ([self.delegate respondsToSelector:@selector(textFieldDidResize:)]) {
            [self.delegate performSelector:@selector(textFieldDidResize:) withObject:self];
        }
        
        [self scrollToVisibleLine:YES];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)marginY {
    return floor(self.font.lineHeight/kPaddingRatio);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)topOfLine:(int)lineNumber {
    if (lineNumber == 0) {
        return 0;
        
    } else {
        CGFloat lineHeight = self.font.lineHeight;
        CGFloat lineSpacing = kCellPaddingY*2 + kSpacingY;
        CGFloat marginY = floor(lineHeight/kPaddingRatio);
        CGFloat lineTop = marginY + lineHeight*lineNumber + lineSpacing*lineNumber;
        return lineTop - lineSpacing;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerOfLine:(int)lineNumber {
    CGFloat lineTop = [self topOfLine:lineNumber];
    CGFloat lineHeight = self.font.lineHeight + kCellPaddingY*2 + kSpacingY;
    return lineTop + floor(lineHeight/2);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)heightWithLines:(int)lines {
    CGFloat lineHeight = self.font.lineHeight;
    CGFloat lineSpacing = kCellPaddingY*2 + kSpacingY;
    CGFloat marginY = floor(lineHeight/kPaddingRatio);
    return marginY + lineHeight*lines + lineSpacing*(lines ? lines-1 : 0) + marginY;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)selectLastCell {
    self.selectedCell = [_cellViews objectAtIndex:_cellViews.count-1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    if (_dataSource) {
        [self layoutCells];
        
    } else {
        _cursorOrigin.x = kPaddingX;
        _cursorOrigin.y = [self marginY];
        if (self.leftView) {
            _cursorOrigin.x += self.leftView.frame.size.width + kPaddingX/2;
        }
    }
    
    [super layoutSubviews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
    [self layoutIfNeeded];
    CGFloat height = [self heightWithLines:_lineCount];
    return CGSizeMake(size.width, height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    [super touchesBegan:touches withEvent:event];
    
    if (_dataSource) {
        UITouch* touch = [touches anyObject];
        if (touch.view == self) {
            self.selectedCell = nil;
            
        } else {
            if ([touch.view isKindOfClass:[NIPickerViewCell class]]) {
                self.selectedCell = (NIPickerViewCell*)touch.view;
                [self becomeFirstResponder];
            }
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextField


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setText:(NSString*)text {
    if (_dataSource) {
        [self updateHeight];
    }
    [super setText:text];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)textRectForBounds:(CGRect)bounds {
    if (_dataSource && [self.text isEqualToString:kSelected]) {
        // Hide the cursor while a cell is selected
        return CGRectMake(-10, 0, 0, 0);
        
    } else {
        CGRect frame = CGRectOffset(bounds, _cursorOrigin.x, _cursorOrigin.y);
        frame.size.width -= (_cursorOrigin.x + kPaddingX + (self.rightView ? kClearButtonSize : 0));
        return frame;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    if (self.leftView) {
        return CGRectMake(
                          bounds.origin.x+kPaddingX, self.marginY,
                          self.leftView.frame.size.width, self.leftView.frame.size.height);
        
    } else {
        return bounds;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    if (self.rightView) {
        return CGRectMake(bounds.size.width - kClearButtonSize, bounds.size.height - kClearButtonSize,
                          kClearButtonSize, kClearButtonSize);
        
    } else {
        return bounds;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTSearchTextField


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasText {
    return self.text.length && ![self.text isEqualToString:kEmpty]
    && ![self.text isEqualToString:kSelected];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showSearchResults:(BOOL)show {
    [super showSearchResults:show];
    if (show) {
        [self scrollToEditingLine:YES];
        
    } else {
        [self scrollToVisibleLine:YES];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rectForSearchResults:(BOOL)withKeyboard {
    // TODO: Need to make sure this work
    UIView* superview = self.superviewForSearchResults;
    CGFloat y = superview.frame.origin.y;
    CGFloat visibleHeight = [self heightWithLines:1];
    CGFloat keyboardHeight = withKeyboard ? NIKeyboardHeightForOrientation(NIInterfaceOrientation()) : 0;
    CGFloat tableHeight = [UIScreen mainScreen].applicationFrame.size.height - (y + visibleHeight + keyboardHeight);
    
    return CGRectMake(0, (self.frame.origin.y+self.frame.size.height)-1, superview.frame.size.width, tableHeight+1);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdate:(BOOL)emptyText {
    if (emptyText && !self.hasText && !self.selectedCell && self.cells.count) {
        [self selectLastCell];
        return NO;
        
    } else if (emptyText && self.selectedCell) {
        [self removeSelectedCell];
        [super shouldUpdate:emptyText];
        return NO;
        
    } else if (!emptyText && !self.hasText && self.selectedCell) {
        [self removeSelectedCell];
        [super shouldUpdate:emptyText];
        return YES;
        
    } else {
        return [super shouldUpdate:emptyText];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    id object = [(NITableViewModel*)_searchResults objectAtIndexPath:indexPath];
    [self addCellWithObject:[object valueForKey:@"title"]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIControlEvents


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidEndEditing {
    if (_selectedCell) {
        self.selectedCell = nil;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)cells {
    NSMutableArray* cells = [NSMutableArray array];
    for (NIPickerViewCell* cellView in _cellViews) {
        [cells addObject:cellView.object ? cellView.object : [NSNull null]];
    }
    return cells;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addCellWithObject:(id)object {
    NIPickerViewCell* cell = [[NIPickerViewCell alloc] init];
    
    NSString* label = [NSString stringWithFormat:@"%@", object];
    
    cell.object = object;
    cell.label = label;
    cell.font = self.font;
    [_cellViews addObject:cell];
    [self addSubview:cell];
    
    // Reset text so the cursor moves to be at the end of the cellViews
    self.text = kEmpty;
    
    if ([self.delegate respondsToSelector:@selector(textField:didAddCellAtIndex:)]) {
        [self.delegate performSelector:@selector(textField:didAddCellAtIndex:) withObject:self withObject:[NSNumber numberWithInt:(_cellViews.count-1)]];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeCellWithObject:(id)object {
    for (int i = 0; i < _cellViews.count; ++i) {
        NIPickerViewCell* cell = [_cellViews objectAtIndex:i];
        if (cell.object == object) {
            [_cellViews removeObjectAtIndex:i];
            [cell removeFromSuperview];
            
            if ([self.delegate respondsToSelector:@selector(textField:didRemoveCellAtIndex:)]) {
                [self.delegate performSelector:@selector(textField:didRemoveCellAtIndex:) withObject:self withObject:[NSNumber numberWithInt:i]];
            }
            break;
        }
    }
    
    // Reset text so the cursor oves to be at the end of the cellViews
    self.text = self.text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllCells {
    while (_cellViews.count) {
        NIPickerViewCell* cell = [_cellViews objectAtIndex:0];
        [cell removeFromSuperview];
        [_cellViews removeObjectAtIndex:0];
    }
    
    _selectedCell = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelectedCell:(NIPickerViewCell*)cell {
    if (_selectedCell) {
        _selectedCell.selected = NO;
    }
    
    _selectedCell = cell;
    
    if (_selectedCell) {
        _selectedCell.selected = YES;
        self.text = kSelected;
        
    } else if (self.cells.count) {
        self.text = kEmpty;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeSelectedCell {
    if (_selectedCell) {
        [self removeCellWithObject:_selectedCell.object];
        _selectedCell = nil;
        
        if (_cellViews.count) {
            self.text = kEmpty;
            
        } else {
            self.text = @"";
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollToVisibleLine:(BOOL)animated {
    if (self.editing) {
        UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
        if (scrollView) {
            [scrollView setContentOffset:CGPointMake(0, self.frame.origin.y) animated:animated];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollToEditingLine:(BOOL)animated {
    UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
    if (scrollView) {
        CGFloat offset = _lineCount == 1 ? 0 : [self topOfLine:_lineCount-1];
        [scrollView setContentOffset:CGPointMake(0, self.frame.origin.y+offset) animated:animated];
    }
}


@end

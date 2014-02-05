//
//  NSString+NIStyleable.m
//  PPHCore
//
//  Created by Griffin Schneider on 12/31/13.
//  Copyright 2013 PayPal. All rights reserved.
//

#import "NSString+NIStyleable.h"
#import "NINonEmptyCollectionTesting.h"

@implementation NSString (NIStyleable)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)niSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
  if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
    CGSize retSize = [self boundingRectWithSize:size
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName : font}
                                      context:nil].size;
    // For empty strings, this size has a height equal to the height of one line with the given font. However,
    // the iOS 6 version returns the size (0,0) for the empty string. Zero size makes more sense for the empty
    // string, so make iOS7 do it that way.
    if (!NIIsStringWithAnyText(self)) {
      retSize.height = 0;
    }
    retSize.height = ceilf(retSize.height);
    retSize.width = ceilf(retSize.width);
    return retSize;
  } else {
    return [self sizeWithFont:font constrainedToSize:size];
  }
  
}

@end


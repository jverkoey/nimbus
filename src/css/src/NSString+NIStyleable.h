//
//  NSString+NIStyleable.h
//  PPHCore
//
//  Created by Griffin Schneider on 12/31/13.
//  Copyright 2013 PayPal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NICSSRuleset;
@class NIDOM;

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface NSString (NIStyleable)

- (CGSize)niSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

@end

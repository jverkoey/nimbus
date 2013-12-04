//
//  AppendObjectClassObjectCell2.m
//  NimbusCatalog
//
//  Created by Ryan Wang on 12/4/13.
//  Copyright (c) 2013 Nimbus. All rights reserved.
//

#import "AppendObjectClassObjectCell2.h"
#import "AppendObjectClassObject.h"

@implementation AppendObjectClassObjectCell2

+ (id)cellFromNib {
    UINib *nib = [UINib nibWithNibName:@"AppendObjectClassObjectCell2.AppendObjectClassObject" bundle:nil];
    return [[nib instantiateWithOwner:nil options:nil]lastObject];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (BOOL)shouldAppendObjectClassToReuseIdentifier {
    return YES;
}

- (BOOL)shouldUpdateCellWithObject:(id)object {
    
    AppendObjectClassObject * q = object;
    
    self.titleLabel.text = q.title;
    self.contentLabel.text = q.content;
    
    return YES;
}

+ (BOOL)shouldLoadNib {
    return YES;
}


@end

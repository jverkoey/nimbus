//
//  AppendObjectClassObjectCell.m
//  NimbusCatalog
//
//  Created by Ryan Wang on 12/4/13.
//  Copyright (c) 2013 Nimbus. All rights reserved.
//

#import "AppendObjectClassObjectCell.h"
#import "AppendObjectClassObject.h"

@implementation AppendObjectClassObjectCell

+ (id)cellFromNib {
    
    UINib *nib = [UINib nibWithNibName:@"AppendObjectClassObjectCell.AppendObjectClassObject" bundle:nil];
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

    // Configure the view for the selected state
}


- (BOOL)shouldUpdateCellWithObject:(id)object {
    
    AppendObjectClassObject * q = object;
    
    self.titleLabel.text = q.title;
    self.contentLabel.text = q.content;
    
    return YES;
}

+ (BOOL)shouldAppendObjectClassToReuseIdentifier {
    return YES;
}


+ (BOOL)shouldLoadNib {
    return YES;
}


@end

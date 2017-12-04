//
//  teleCell.m
//  WaterLogging
//
//  Created by 罗 显松 on 2017/12/4.
//  Copyright © 2017年 xsluo. All rights reserved.
//

#import "teleCell.h"

@implementation teleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(instancetype) InitCell{
    return [[[NSBundle mainBundle] loadNibNamed:@"teleCell" owner:nil options:nil] lastObject];
}


@end

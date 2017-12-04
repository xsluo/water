//
//  teleCell.h
//  WaterLogging
//
//  Created by 罗 显松 on 2017/12/4.
//  Copyright © 2017年 xsluo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDMultTableView.h"

@interface teleCell : XDMultTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbTele;
+(instancetype) InitCell;
@end

//
//  MyTextField.m
//  WaterLogging
//
//  Created by 罗 显松 on 2018/4/1.
//  Copyright © 2018年 xsluo. All rights reserved.
//

#import "MyTextField.h"

@implementation MyTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect leftRect = [super leftViewRectForBounds:bounds];
    leftRect.origin.x += 10; //右边偏10
    return leftRect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect rightRect = [super rightViewRectForBounds:bounds];
    rightRect.origin.x -= 10; //左边偏10
    return rightRect;
}


//UITextField 文字与输入框的距离
- (CGRect)textRectForBounds:(CGRect)bounds{
    if (self.leftView) {
        return CGRectInset(bounds, 40, 0);
    }
    return CGRectInset(bounds, 10, 0);
    
}
//控制编辑文本的位置
- (CGRect)editingRectForBounds:(CGRect)bounds{
    if (self.leftView) {
        return CGRectInset(bounds, 40, 0);
    }
    return CGRectInset(bounds, 10, 0);
}

@end

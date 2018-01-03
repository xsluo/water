//
//  ViewController.m
//  StockView
//
//  Created by Jezz on 2017/10/14.
//  Copyright © 2017年 Jezz. All rights reserved.
//

#import "DemoViewController.h"
#import "JJStockView.h"
#import "ModelData.h"
#import "MBProgressHUD/MBProgressHUD.h"

@interface DemoViewController ()<StockViewDataSource,StockViewDelegate>

@property(nonatomic,readwrite,strong)JJStockView* stockView;
@property(nonatomic,strong)NSMutableArray* modelArray;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modelArray = [[NSMutableArray alloc]init];
    //self.navigationItem.title = @"股票表格";
    self.stockView.frame = CGRectMake(0, 80, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-130);
    [self  loadData];
    [self.view addSubview:self.stockView];
}

- (void) loadData{
    [MBProgressHUD showHUDAddedTo:self.stockView animated:YES];
    
    /*接口：http://183.238.82.216:9090/waterlogging/comm/RealTimeData_View/list
     方法：POST
     参数：
     {
     pageSize: 1000,
     sortProperty: "DATA_VALUE_Z",
     sortValue: "desc"
     }*/
    
    // 1.创建请求
    NSURL *url = [NSURL URLWithString:@"http://183.238.82.216:9090/waterlogging/comm/RealTimeData_View/list"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 2.设置请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"ios+android" forHTTPHeaderField:@"User-Agent"];
    
    // 3.设置请求体
    NSDictionary *json = @{
                           @"pageSize" : @"1000",
                           @"sortProperty" : @"DATA_VALUE_Z",
                           @"sortValue" : @"desc"
                           };
    
    //NSData --> NSDictionary
    // NSDictionary --> NSData
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = data;
    
    // 4.发送请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(data){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSMutableArray *arrs = [dic objectForKey:@"content"];
            
            for(NSDictionary *obj in arrs){
                ModelData *model = [[ModelData alloc]init];
                model.number = obj[@"WST_NO"];
                model.time = obj[@"DATA_TIME"];
                model.typevt = obj[@"DATA_TYPE_VT"];
                model.remark = obj[@"REMARK"];
                model.maintence = obj[@"MAINTENCE_PSN"];
                model.telel =obj[@"TELEL"];
                model.mobile =obj[@"MOBILE"];
                model.valuevt =obj[@"DATA_VALUE_VT"];
                model.typez =obj[@"DATA_TYPE_Z"];
                model.valuez =obj[@"DATA_VALUE_Z"];
                model.reporttime =obj[@"REPORT_TIME"];
                model.name =obj[@"WST_Name"];
                model.lat =obj[@"LAT"];
                model.lnt =obj[@"LNT"];
                model.location =obj[@"LOCATION"];
                [self.modelArray addObject:model];
            }
            [MBProgressHUD hideHUDForView:self.stockView animated:YES];
            [self  sortData];
            [self.stockView reloadStockView];
        }
    }];
}

#pragma mark -Sort Data

- (void) sortData{
    if([self.modelArray count]<2){
        return;
    }
    ModelData *modelTemp;
    for(int i=0;i<self.modelArray.count-1;i++){
        for(int j=0;j<self.modelArray.count-i-1;j++){
            ModelData *x = self.modelArray[j];
            ModelData *y = _modelArray[j+1];
            if([x.valuez floatValue]< [y.valuez floatValue]){
                modelTemp = _modelArray[j];
                _modelArray[j] = _modelArray[j+1];
                _modelArray[j+1] = modelTemp;
            }
        }
    }
}

#pragma mark - Stock DataSource

- (NSUInteger)countForStockView:(JJStockView*)stockView{
    //return 30;
    return self.modelArray.count;
}

- (UIView*)titleCellForStockView:(JJStockView*)stockView atRowPath:(NSUInteger)row{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    ModelData *data = [self.modelArray objectAtIndex:row];
    label.text = [NSString stringWithFormat:@"%@",data.name];
    
    label.backgroundColor = row % 2 == 0 ?[UIColor whiteColor] :[UIColor colorWithRed:240.0f/255.0 green:240.0f/255.0 blue:240.0f/255.0 alpha:1.0];
    label.textAlignment = NSTextAlignmentLeft;
    //设置多行显示
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.numberOfLines = 0;
    //设置边框
    label.layer.borderColor = [[UIColor grayColor]CGColor];
    label.layer.borderWidth = 0.5f;
    label.layer.masksToBounds = YES;
    //设置字体大小
    label.font = [UIFont systemFontOfSize:14];
    return label;
}

- (UIView*)contentCellForStockView:(JJStockView*)stockView atRowPath:(NSUInteger)row{

    UIView* bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 620, 60)];
    bg.backgroundColor = row % 2 == 0 ?[UIColor whiteColor] :[UIColor colorWithRed:240.0f/255.0 green:240.0f/255.0 blue:240.0f/255.0 alpha:1.0];
    //for (int i = 0; i < 8; i++) {
        //        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(i * 100, 0, 100, 30)];
        //        [button setTitle:[NSString stringWithFormat:@"内容:%d",i] forState:UIControlStateNormal];
        //        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        //        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        //        button.tag = i;
        //        [bg addSubview:button];
    /*
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(i * 100, 0, 100, 70)];
        label.text = [NSString stringWithFormat:@"内容:%d",i];
        label.textAlignment = NSTextAlignmentCenter;
        [bg addSubview:label];
    }*/
    ModelData *data = [self.modelArray objectAtIndex:row];
    
    UILabel* label0 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 60)];
    label0.text = [NSString stringWithFormat:@"%@",data.time];
    label0.textAlignment = NSTextAlignmentLeft;
    //设置多行显示
    label0.lineBreakMode = NSLineBreakByCharWrapping;
    label0.numberOfLines = 0;
    //设置边框
    label0.layer.borderColor = [[UIColor grayColor]CGColor];
    label0.layer.borderWidth = 0.5f;
    label0.layer.masksToBounds = YES;
    //设置字体大小
    label0.font = [UIFont systemFontOfSize:14];
    [bg addSubview:label0];
    
    UILabel* label1 = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 60, 60)];
    label1.text = [NSString stringWithFormat:@"%@",data.valuez];
    label1.textAlignment = NSTextAlignmentCenter;
    //设置边框
    label1.layer.borderColor = [[UIColor grayColor]CGColor];
    label1.layer.borderWidth = 0.5f;
    label1.layer.masksToBounds = YES;
    //设置字体大小
    label1.font = [UIFont systemFontOfSize:14];
    [bg addSubview:label1];
    
    UILabel* label2 = [[UILabel alloc] initWithFrame:CGRectMake(140, 0, 60, 60)];
    label2.text = [NSString stringWithFormat:@"%@",data.valuevt];
    label2.textAlignment = NSTextAlignmentCenter;
    //设置边框
    label2.layer.borderColor = [[UIColor grayColor]CGColor];
    label2.layer.borderWidth = 0.5f;
    label2.layer.masksToBounds = YES;
    //设置字体大小
    label2.font = [UIFont systemFontOfSize:14];
    [bg addSubview:label2];
    
    UILabel* label3 = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 100, 60)];
    label3.text = [NSString stringWithFormat:@"%@",data.location];
    label3.textAlignment = NSTextAlignmentLeft;
    //设置多行显示
    label3.lineBreakMode = NSLineBreakByCharWrapping;
    label3.numberOfLines = 0;
    //设置边框
    label3.layer.borderColor = [[UIColor grayColor]CGColor];
    label3.layer.borderWidth = 0.5f;
    label3.layer.masksToBounds = YES;
    //设置字体大小
    label3.font = [UIFont systemFontOfSize:14];
    [bg addSubview:label3];
    
    UILabel* label4 = [[UILabel alloc] initWithFrame:CGRectMake(300, 0, 60, 60)];
    label4.text = [NSString stringWithFormat:@"%@",data.maintence];
    label4.textAlignment = NSTextAlignmentCenter;
    //设置边框
    label4.layer.borderColor = [[UIColor grayColor]CGColor];
    label4.layer.borderWidth = 0.5f;
    label4.layer.masksToBounds = YES;
    //设置字体大小
    label4.font = [UIFont systemFontOfSize:14];
    [bg addSubview:label4];
    
    UILabel* label5 = [[UILabel alloc] initWithFrame:CGRectMake(360, 0, 100, 60)];
    label5.text = [NSString stringWithFormat:@"%@",data.telel];
    label5.textAlignment = NSTextAlignmentCenter;
    //设置边框
    label5.layer.borderColor = [[UIColor grayColor]CGColor];
    label5.layer.borderWidth = 0.5f;
    label5.layer.masksToBounds = YES;
    //设置字体大小
    label5.font = [UIFont systemFontOfSize:14];
    [bg addSubview:label5];
    
    UIButton* button0 = [[UIButton alloc] initWithFrame:CGRectMake(460, 0, 80, 60)];
    [button0 setImage:[UIImage imageNamed:@"短信"] forState:UIControlStateNormal];
    //设置边框
    button0.layer.borderColor = [[UIColor grayColor]CGColor];
    button0.layer.borderWidth = 0.5f;
    button0.layer.masksToBounds = YES;
    [button0 addTarget:self action:@selector(sendMsg:) forControlEvents:UIControlEventTouchUpInside];
    [button0 setTag:row];
    [bg addSubview:button0];
    
    UIButton* button1 = [[UIButton alloc] initWithFrame:CGRectMake(540, 0, 80, 60)];
    [button1 setImage:[UIImage imageNamed:@"电话"] forState:UIControlStateNormal];
    //设置边框
    button1.layer.borderColor = [[UIColor grayColor]CGColor];
    button1.layer.borderWidth = 0.5f;
    button1.layer.masksToBounds = YES;
    [button1 addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTag:row];
    [bg addSubview:button1];
    return bg;
}

#pragma mark - Stock Delegate

- (CGFloat)heightForCell:(JJStockView*)stockView atRowPath:(NSUInteger)row{
    return 60.0f;
}

- (UIView*)headRegularTitle:(JJStockView*)stockView{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    label.text = @"站点名称";
    label.backgroundColor = [UIColor colorWithRed:110.0f/255.0 green:210.0f/255.0 blue:255.0f/255.0 alpha:1.0];
    label.textAlignment = NSTextAlignmentCenter;
    //设置字体大小
    label.font = [UIFont systemFontOfSize:14];
    return label;
}

- (UIView*)headTitle:(JJStockView*)stockView{
    NSArray *title = [[NSArray alloc]initWithObjects:@"数据时间",@"水位(m)",@"电压(v)",@"地址",@"联系人",@"联系电话",@"短信",@"电话",nil];
    UIView* bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 620, 40)];
    bg.backgroundColor = [UIColor colorWithRed:110.0f/255.0 green:210.0f/255.0 blue:255.0f/255.0 alpha:1.0];
    /*
    for (int i = 0; i < 8; i++) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(i * 100, 0, 100, 40)];
        label.text = [NSString stringWithFormat:@"%@", [title objectAtIndex:i]];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        //设置字体大小
        label.font = [UIFont systemFontOfSize:14];
        [bg addSubview:label];
    }
     */
    UILabel* label0 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    label0.text = [NSString stringWithFormat:@"%@", [title objectAtIndex:0]];
    label0.textAlignment = NSTextAlignmentCenter;
    //设置字体大小
    label0.font = [UIFont systemFontOfSize:14];
    [bg addSubview:label0];
    
    UILabel* label1 = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 60, 40)];
    label1.text = [NSString stringWithFormat:@"%@", [title objectAtIndex:1]];
    label1.textAlignment = NSTextAlignmentCenter;
    //设置字体大小
    label1.font = [UIFont systemFontOfSize:14];
    [bg addSubview:label1];
    
    UILabel* label2 = [[UILabel alloc] initWithFrame:CGRectMake(140, 0, 60, 40)];
    label2.text = [NSString stringWithFormat:@"%@", [title objectAtIndex:2]];
    label2.textAlignment = NSTextAlignmentCenter;
    //设置字体大小
    label2.font = [UIFont systemFontOfSize:14];
    [bg addSubview:label2];
    
    UILabel* label3 = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 100, 40)];
    label3.text = [NSString stringWithFormat:@"%@", [title objectAtIndex:3]];
    label3.textAlignment = NSTextAlignmentCenter;
    //设置字体大小
    label3.font = [UIFont systemFontOfSize:14];
    [bg addSubview:label3];
    
    UILabel* label4 = [[UILabel alloc] initWithFrame:CGRectMake(300, 0, 60, 40)];
    label4.text = [NSString stringWithFormat:@"%@", [title objectAtIndex:4]];
    label4.textAlignment = NSTextAlignmentCenter;
    //设置字体大小
    label4.font = [UIFont systemFontOfSize:14];
    [bg addSubview:label4];
    
    UILabel* label5 = [[UILabel alloc] initWithFrame:CGRectMake(360, 0, 100, 40)];
    label5.text = [NSString stringWithFormat:@"%@", [title objectAtIndex:5]];
    label5.textAlignment = NSTextAlignmentCenter;
    //设置字体大小
    label5.font = [UIFont systemFontOfSize:14];
    [bg addSubview:label5];
    
    
    UILabel* label6 = [[UILabel alloc] initWithFrame:CGRectMake(460, 0, 80, 40)];
    label6.text = [NSString stringWithFormat:@"%@", [title objectAtIndex:6]];
    label6.textAlignment = NSTextAlignmentCenter;
    //设置字体大小
    label6.font = [UIFont systemFontOfSize:14];
    [bg addSubview:label6];
    
    UILabel* label7 = [[UILabel alloc] initWithFrame:CGRectMake(540, 0, 80, 40)];
    label7.text = [NSString stringWithFormat:@"%@", [title objectAtIndex:7]];
    label7.textAlignment = NSTextAlignmentCenter;
    //设置字体大小
    label7.font = [UIFont systemFontOfSize:14];
    [bg addSubview:label7];
    
    return bg;
}

- (CGFloat)heightForHeadTitle:(JJStockView*)stockView{
    return 40.0f;
}

- (void)didSelect:(JJStockView*)stockView atRowPath:(NSUInteger)row{
    NSLog(@"DidSelect Row:%ld",row);
}

#pragma mark - Button Action

- (void)buttonAction:(UIButton*)sender{
    NSLog(@"Button Row:%ld",sender.tag);
}

#pragma mark - Get

- (JJStockView*)stockView{
    if(_stockView != nil){
        return _stockView;
    }
    _stockView = [JJStockView new];
    _stockView.dataSource = self;
    _stockView.delegate = self;
    return _stockView;
}

#pragma mark --发送短信
-(void)sendMsg:(id)sender{
    UIButton *bt = (UIButton *)sender;
    NSInteger tag = bt.tag;
    ModelData *data = [self.modelArray objectAtIndex:tag];
    if(tag>=0){
        NSString *phone = data.telel;
        NSString *sms = [NSString stringWithFormat:@"sms://%@",phone];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:sms]];
    }
}

#pragma mark --打电话
-(void)call:(id)sender{
    UIButton *bt = (UIButton *)sender;
    NSInteger tag = bt.tag;
    ModelData *data = [self.modelArray objectAtIndex:tag];
    if(tag>=0){
        NSString *phone = data.telel;
        NSString *call = [NSString stringWithFormat:@"tel://%@",phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:call]];
    }
}
@end

//
//  ViewController.m
//  XDMultTableView
//
//  Created by 蔡欣东 on 2016/7/16.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import "ViewController.h"
#import "XDMultTableView.h"
#import "ModelData.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "teleCell.h"

@interface ViewController ()<XDMultTableViewDatasource,XDMultTableViewDelegate>

@property(nonatomic, readwrite, strong)XDMultTableView *tableView;
@property(nonatomic,strong)NSMutableArray* modelArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modelArray = [[NSMutableArray alloc]init];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _tableView = [[XDMultTableView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height-130)];
    //_tableView.openSectionArray = [NSArray arrayWithObjects:@1,@2, nil];
    _tableView.openSectionArray = [NSArray arrayWithObjects:@0,nil];
    _tableView.delegate = self;
    _tableView.datasource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    
    
   // _tableView.autoAdjustOpenAndClose = NO;

    [self.view addSubview:_tableView];
    
    [self  loadData];
    
}

- (void) loadData{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
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
            
            //NSLog(@"%@",arrs);
            /*
             @property (nonatomic,copy)NSString *number;
             @property (nonatomic,copy)NSString *time;
             @property (nonatomic,copy)NSString *typevt;
             @property (nonatomic,copy)NSString *remark;
             @property (nonatomic,copy)NSString *maintence;
             @property (nonatomic,copy)NSString *telel;
             @property (nonatomic,copy)NSString *mobile;
             @property (nonatomic,copy)NSString *valuevt;
             @property (nonatomic,copy)NSString *typez;
             @property (nonatomic,copy)NSString *valuez;
             @property (nonatomic,copy)NSString *reporttime;
             @property (nonatomic,copy)NSString *name;
             @property (nonatomic,copy)NSString *lat;
             @property (nonatomic,copy)NSString *lnt;
             @property (nonatomic,copy)NSString *location;
             */
            
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
            [_tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

#pragma mark - datasource
- (NSInteger)mTableView:(XDMultTableView *)mTableView numberOfRowsInSection:(NSInteger)section{
    if([self.modelArray count]){
        return 9;
    }else{
        return 0;
    }
}

- (void)mTableView:(XDMultTableView *)maTbleView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor whiteColor];
}

/*
 - (XDMultTableViewCell *)mTableView:(XDMultTableView *)mTableView
 cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 static NSString *cellIdentifier = @"cell";
 UITableViewCell *cell = [mTableView dequeueReusableCellWithIdentifier:cellIdentifier];
 if (cell == nil)
 {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
 }
 UIView *view = [[UIView alloc] initWithFrame:cell.bounds] ;
 view.layer.backgroundColor  = [UIColor whiteColor].CGColor;
 view.layer.masksToBounds    = YES;
 view.layer.borderWidth      = 0.3;
 view.layer.borderColor      = [UIColor lightGrayColor].CGColor;
 
 cell.backgroundView = view;
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 
 return cell;
 }
 */

- (NSInteger)numberOfSectionsInTableView:(XDMultTableView *)mTableView{
    if([self.modelArray count] == 0){
        return 6;
    }
    else{
        return [_modelArray count];
    }
}

-(UIView *)mTableView:(XDMultTableView *)mTableView viewForHeaderInSection:(NSInteger)section{
    UIView *titleView = [[UIView alloc] init];
    titleView.backgroundColor = [UIColor grayColor];
    titleView.frame = CGRectMake(20, 0, self.view.frame.size.width, 80);
    
    if([self.modelArray count]){
        ModelData *model = (ModelData *)[self.modelArray objectAtIndex:section];
        
        UILabel *labe1 = [[UILabel alloc]init];
        labe1.frame = CGRectMake(20, 10, self.view.frame.size.width, 20);
        labe1.text =  [NSString stringWithFormat:@"站点：%@", model.name] ;
        [titleView addSubview:labe1];
        
        UILabel *labe2 = [[UILabel alloc]init];
        labe2.frame = CGRectMake(20, 30, self.view.frame.size.width, 20);
        labe2.text = [NSString stringWithFormat:@"时间：%@", model.time];
        [titleView addSubview:labe2];
        
        UILabel *labe3 = [[UILabel alloc]init];
        labe3.frame = CGRectMake(20, 50, self.view.frame.size.width, 20);
        labe3.text = [NSString stringWithFormat:@"负责人：%@", model.maintence];
        [titleView addSubview:labe3];
        
        UILabel *labe4 = [[UILabel alloc]init];
        labe4.frame = CGRectMake(200, 30, self.view.frame.size.width, 20);
        labe4.text = [NSString stringWithFormat:@"水位：%@", model.valuez];
        [titleView addSubview:labe3];
    }
    return titleView;
}

-(XDMultTableViewCell  *)mTableView:(XDMultTableView *)mTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* name = @"cell";
    //static NSString* teleName = @"teleCell";
    
    UITableViewCell* cell = [mTableView dequeueReusableCellWithIdentifier:name];
    //teleCell* cellT = (teleCell *)[mTableView dequeueReusableCellWithIdentifier:teleName];
    
    /*
    if(cellT == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:teleName owner:self options:nil];
        cell = [nib objectAtIndex:0];
        if([_modelArray count]){
            ModelData *model = (ModelData *)[self.modelArray objectAtIndex:[indexPath section]];
        }
    }
    
    if([indexPath row] == 8){
        return cellT;
    }
     */
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]init];
        //cell.textLabel.text = self.rowsInSectionArray[indexPath.section][indexPath.row];
        if([_modelArray count]){
            ModelData *model = (ModelData *)[self.modelArray objectAtIndex:[indexPath section]];
            switch ([indexPath row]) {
                case 0:
                    cell.textLabel.text = [NSString stringWithFormat:@"站点编号:%@",model.number];
                    break;
                case 1:
                    cell.textLabel.text = [NSString stringWithFormat:@"站点名称:%@",model.name];
                    break;
                case 2:
                    cell.textLabel.text = [NSString stringWithFormat:@"站点地址:%@",model.location];
                    break;
                case 3:
                    cell.textLabel.text = [NSString stringWithFormat:@"数据时间:%@",model.time];
                    break;
                case 4:
                    cell.textLabel.text = [NSString stringWithFormat:@"水位:%@",model.valuez];
                    break;
                case 5:
                    cell.textLabel.text = [NSString stringWithFormat:@"电压:%@",model.valuevt];
                    break;
                case 6:
                    cell.textLabel.text = [NSString stringWithFormat:@"责任人:%@",model.maintence];
                    break;
                case 7:
                    cell.textLabel.text = [NSString stringWithFormat:@"手机:%@",model.mobile];
                    break;
                case 8:
                    cell.textLabel.text = [NSString stringWithFormat:@"电话:%@",model.telel];
                    break;
                default:
                    break;
            }
        }
    }
    return cell;
}

-(NSString *)mTableView:(XDMultTableView *)mTableView titleForHeaderInSection:(NSInteger)section{
    return @"我是头部";
}


#pragma mark - delegate
- (CGFloat)mTableView:(XDMultTableView *)mTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

- (CGFloat)mTableView:(XDMultTableView *)mTableView heightForHeaderInSection:(NSInteger)section{
    return 80;
}


- (void)mTableView:(XDMultTableView *)mTableView willOpenHeaderAtSection:(NSInteger)section{
    NSLog(@"即将展开");
}


- (void)mTableView:(XDMultTableView *)mTableView willCloseHeaderAtSection:(NSInteger)section{
    NSLog(@"即将关闭");
}

- (void)mTableView:(XDMultTableView *)mTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击cell");
}

@end

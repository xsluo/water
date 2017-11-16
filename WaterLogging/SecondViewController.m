//
//  ThirdViewController.m
//  WaterLogging
//
//  Created by 罗 显松 on 2017/11/15.
//  Copyright © 2017年 xsluo. All rights reserved.
//

#import "SecondViewController.h"
#import "ModelData.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"


@interface SecondViewController ()<NSXMLParserDelegate>
@property(nonatomic,strong)NSMutableArray* modelArray;
@property(nonatomic,strong)NSMutableArray* currentArray;
// 行数据
@property(nonatomic,strong)NSMutableArray* rowsInSectionArray;

@property (nonatomic,strong) NSMutableString *outStr;
@property (nonatomic,strong) NSArray *test;
@property(nonatomic,assign)NSInteger lastIndex;
@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation SecondViewController
{
    UITableView* _tableView;
    BOOL* _isExpand;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.outStr = [[NSMutableString alloc]init];
    self.modelArray = [[NSMutableArray alloc]init];
    
    self.currentArray = [[NSMutableArray alloc]init];
    self.rowsInSectionArray = [[NSMutableArray alloc]init];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    //self.photoArray = @[@"yangyang.jpg",@"高圆圆.jpg",@"佟丽娅.jpg",@"yangyang.jpg",@"高圆圆.jpg",@"佟丽娅.jpg"];
    
    _isExpand = 0;
    
    //加载数据
    [self  loadData];
    //加载表视图
    [self createTableView];
    [self initWithArray];
}

- (void) loadData{
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
               // NSLog(@"%d", data.length);
               // NSString *outString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
               // NSLog(@"%@",outString);
                //self.outStr = [NSMutableString stringWithFormat:@"%@",outString];
               
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
                self.currentArray = self.modelArray;
                [_tableView reloadData];
            }
        }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 创建talbeView
- (void)createTableView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    //_tableView.bounces = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

#pragma  mark UITableViewDataSource代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.currentArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return   [self.currentArray[section] count];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* name = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:name];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]init];
        cell.textLabel.text = self.rowsInSectionArray[indexPath.section][indexPath.row];
    }
    return cell;
    /*
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
    
    return cell;
     */
}

#pragma  mark UITableDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return  0.1f;
}

/*
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%c",'A'+(int)section];
}
*/

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, self.view.frame.size.width, 80);
    
    
    // 此方法利用缓存，比较耗费内存，不释放
  //  [btn setBackgroundImage:[UIImage imageNamed:_photoArray[section]] forState:UIControlStateNormal];
    
    /*
    ModelData *model = (ModelData *)[self.modelArray objectAtIndex:section];
    
    [btn.titleLabel setNumberOfLines:0];
    NSString *title = [NSString stringWithFormat:@"站点:%@\n时间:%@  水位:%@\n负责人:%@",model.name,model.time,model.valuez,model.maintence];
    
    [btn setTitle:title forState:UIControlStateNormal];
     */
    [btn setBackgroundColor:[UIColor grayColor]];
    btn.tag = section;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


/**
 *  单击SectionHeader时候触发（核心逻辑）
 *
 *  @param btn <#btn description#>
 */
- (void)btnClick:(UIButton*)btn
{
    if ([_modelArray[btn.tag]count] > 0 ) {
        [_modelArray[_lastIndex] removeAllObjects];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:_lastIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else
    {
        // 通过不断删除和添加来实现展开和收起
        [[_modelArray objectAtIndex:_lastIndex] removeAllObjects];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:_lastIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.modelArray[btn.tag] addObjectsFromArray:self.rowsInSectionArray[btn.tag]];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:btn.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_tableView setContentOffset:CGPointMake(0, _lastIndex*40) animated:YES];
        _lastIndex = btn.tag;
        [_tableView setContentOffset:CGPointMake(0, 200*btn.tag) animated:YES];
    }
    
}


#pragma mark 初始化数组数值

- (void)initWithArray
{
    for (int i = 'A'; i <= 'X'; i++) {
        NSMutableArray* array = [[NSMutableArray alloc]init];
        for (int j = 0; j< 9; j++) {
            NSString* string = [NSString stringWithFormat:@"%c%d",i,j];
            [array addObject:string];
        }
        [[self rowsInSectionArray] addObject:array];
        
        NSMutableArray* sections = [[NSMutableArray alloc]init];
        [self.currentArray addObject:sections];
    }
}

#pragma mark 懒加载
- (NSMutableArray *)currentArray
{
    if (_currentArray == nil) {
        _currentArray = [[NSMutableArray alloc]init];
    }
    return  _currentArray;
}

//
- (NSMutableArray *)rowsInSectionArray
{
    if (!_rowsInSectionArray) {
        _rowsInSectionArray = [[NSMutableArray alloc]init];
    }
    return _rowsInSectionArray;
}

- (NSArray *)test
{
    if (_test) {
        _test = [[NSArray alloc]init];
    }
    return _test;
}

@end

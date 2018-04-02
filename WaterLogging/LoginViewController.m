//
//  LoginViewController.m
//  WaterLogging
//
//  Created by 罗 显松 on 2018/4/1.
//  Copyright © 2018年 xsluo. All rights reserved.
//

#import "LoginViewController.h"
#import "MyTextField.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import<CommonCrypto/CommonDigest.h>

@interface LoginViewController ()<UITextFieldDelegate>
@property (nonatomic,strong) NSString *responsString;
@property (nonatomic,strong) NSString *currentElementName;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITextField *textName = [self.view viewWithTag:1];
    textName.borderStyle = UITextBorderStyleRoundedRect;
    textName.borderStyle =UITextBorderStyleLine;
    textName.layer.borderWidth =2;
    textName.layer.borderColor = [UIColor whiteColor].CGColor;
    textName.layer.masksToBounds = YES;
    textName.layer.cornerRadius = 22;
    textName.font = [UIFont fontWithName:@"Arial" size:19.0f];
    textName.textColor = [UIColor colorWithRed:12.0/255 green:120.0/255 blue:226.0/255 alpha:1];
    UIImageView * person = [[UIImageView  alloc]initWithFrame:CGRectMake(22,0, 40, textName.frame.size.height)];//只有宽度起到了作用
    person.image = [UIImage imageNamed:@"person"];
    person.contentMode = UIViewContentModeScaleToFill;
    textName.leftView = person;
    person.backgroundColor = [UIColor colorWithRed:187.0/255 green:227.0/255 blue:254.0/255 alpha:1.0];
    textName.leftViewMode = UITextFieldViewModeAlways;
    
    UITextField *textPass = [self.view viewWithTag:2];
    /*
     MyTextField *textPass = [[MyTextField alloc]init];
     textPass.placeholder = @"密码";
     [self.view addSubview:textPass];
     textPass.translatesAutoresizingMaskIntoConstraints = NO;
     
     */
    textPass.borderStyle = UITextBorderStyleRoundedRect;
    textPass.borderStyle =UITextBorderStyleLine;
    textPass.secureTextEntry = YES;
    textPass.layer.borderWidth =2;
    textPass.layer.borderColor = [UIColor whiteColor].CGColor;
    textPass.layer.masksToBounds = YES;
    textPass.layer.cornerRadius = 22;
    textPass.font = [UIFont fontWithName:@"Arial" size:19.0f];
    textPass.textColor = [UIColor colorWithRed:12.0/255 green:120.0/255 blue:226.0/255 alpha:1.0];
    UIImageView * lock = [[UIImageView  alloc]initWithFrame:CGRectMake(22,0, 40, textName.frame.size.height   )];//只有宽度起到了作用
    lock.image = [UIImage imageNamed:@"lock"];
    textPass.leftView = lock;
    lock.backgroundColor = [UIColor colorWithRed:187.0/255 green:227.0/255 blue:254.0/255 alpha:1.0];
    textPass.leftViewMode = UITextFieldViewModeAlways;
    
    UIButton *btLogin = [self.view viewWithTag:3];
    btLogin.layer.masksToBounds = YES;
    btLogin.layer.cornerRadius = 22;
    
    textName.delegate = self;
    textPass.delegate = self;
}

# pragma mark - 协议方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)endEdit:(id)sender {
    UITextField *textName = [self.view viewWithTag:1];
    UITextField *textPass = [self.view viewWithTag:2];
    [textName resignFirstResponder];
    [textPass resignFirstResponder];
}

- (IBAction)Login:(id)sender {
    UITextField *textName = [self.view viewWithTag:1];
    UITextField *textPass = [self.view viewWithTag:2];
    
    if([textName.text isEqual:@""] ||[textPass.text isEqual:@""]){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"用户名或密码不能为空";
        hud.label.textColor = [UIColor redColor];
        [hud hideAnimated:YES afterDelay:2];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *urlString = @"http://183.238.82.216:9090/waterlogging/login";
    NSLog(@"login ......");
    NSURL *URL = [[NSURL alloc]initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:URL cachePolicy:(NSURLRequestUseProtocolCachePolicy) timeoutInterval:30];
    request.HTTPMethod = @"POST";
    
    // 2.设置请求头和请求体
    NSString *boundary = @"HS23dsdf435Sdfasd23A4dfDF43SABC";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:@"ios+android" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"HS23dsdf435Sdfasd23A4dfDF43SABC" forHTTPHeaderField:@"boundary"];
    
    //NSLog(@"request---------%@",request.allHTTPHeaderFields);
    
    NSMutableData *bodydata = [self buildBody];
    
    //3 session
    //NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:bodydata completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"data value %@",dataString);
        //  开始解析
        /*
         NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
         xmlParser.delegate = self;
         [xmlParser parse];
         */
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"code is----------%@",dict[@"code"]);
    }];
    //5 resume
    [task resume];
    
    //[self ResetController];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(NSMutableData *) buildBody{
    UITextField *textName = [self.view viewWithTag:1];
    UITextField *textPass = [self.view viewWithTag:2];
    
    NSMutableString *bodyStr = [NSMutableString string];
    NSString *boundary = @"HS23dsdf435Sdfasd23A4dfDF43SABC";
    
    NSMutableData *bodyData = [NSMutableData data];
    
    //1 用户名
    [bodyStr appendFormat:@"--%@\r\n",boundary];//\n:换行 \n:切换到行首
    [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"userName\""];
    [bodyStr appendFormat:@"\r\n\r\n"];
    [bodyStr appendFormat:@"%@\r\n",textName.text];
    
    //2 密码
    NSString *strMD5 = [self md5:textPass.text];
    
    [bodyStr appendFormat:@"--%@\r\n",boundary];//\n:换行 \n:切换到行首
    [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"password\""];
    [bodyStr appendFormat:@"\r\n\r\n"];
    //[bodyStr appendFormat:@"%@\r\n",textPass.text];
    [bodyStr appendFormat:@"%@\r\n",strMD5];
    NSLog(@"md5----%@",strMD5);
    
    //startData
    NSData *startData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [bodyData appendData:startData];
    
    //--endStr--
    NSString *endStr = [NSString stringWithFormat:@"\r\n--%@--\r\n",boundary];
    NSData *endData = [endStr dataUsingEncoding:NSUTF8StringEncoding];
    [bodyData appendData:endData];
    //NSLog(@"%@",endStr);
    
    NSString *str = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    NSLog(@"===bodyData==%@",str);
    
    return bodyData;
}

# pragma mark - 协议方法


- (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );   // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

- (IBAction)login1:(id)sender {
    
    /*接口：http://183.238.82.216:9090/waterlogging/comm/RealTimeData_View/list
     方法：POST
     参数：
     {
     pageSize: 1000,
     sortProperty: "DATA_VALUE_Z",
     sortValue: "desc"
     }*/
    
    //[self.modelArray removeAllObjects];
    
    // 1.创建请求
    NSURL *url = [NSURL URLWithString:@"http://183.238.82.216:9090/waterlogging/login"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 2.设置请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"ios+android" forHTTPHeaderField:@"User-Agent"];
    
    // 3.设置请求体
    /*
     NSDictionary *json = @{
     @"userName" : @"hjc",
     @"password" : @"81dc9bdb52d04dc20036dbd8313ed055",
     };*/
    UITextField *textName = [self.view viewWithTag:1];
    UITextField *textPass = [self.view viewWithTag:2];
    
    if([textName.text isEqual:@""] ||[textPass.text isEqual:@""]){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"用户名或密码不能为空";
        hud.label.textColor = [UIColor redColor];
        [hud hideAnimated:YES afterDelay:2];
        //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        return;
    }
    
    
    NSString *md5String = [self md5:textPass.text];
    
    NSDictionary *json = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"userName",@"userName",@"password",@"password", nil];
    [json setValue:textName.text forKey:@"userName"];
    [json setValue:md5String forKey:@"password"];
    
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = data;
    
    // 4.发送请求
    
    NSMutableString *code = [[NSMutableString alloc]initWithString:@""];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(data){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            [code appendFormat:@"%@" ,[dic objectForKey:@"code"]];
            
            NSLog(@"code++++++%@",code);
            
            dispatch_async(dispatch_get_main_queue(),^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if([code isEqualToString:@"1"]){
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    //hud.label.font = [UIFont fontWithName:@"font" size:40];
                    hud.label.text = @"登录成功！";
                    hud.label.textColor = [UIColor redColor];
                    [hud hideAnimated:YES afterDelay:3];
                    [self performSegueWithIdentifier:@"open" sender:nil];
                }else{
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = @"用户名或密码错误";
                    hud.label.textColor = [UIColor redColor];
                    [hud hideAnimated:YES afterDelay:2];
                }
            });
        }
    }];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

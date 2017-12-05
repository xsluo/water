//
//  SecondViewController.m
//  WaterLogging
//
//  Created by 罗 显松 on 2017/12/3.
//  Copyright © 2017年 xsluo. All rights reserved.
//

#import "SecondViewController.h"
#import  "AFNetworking.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MBProgressHUD/MBProgressHUD.h"
#import <Foundation/Foundation.h>

@interface SecondViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,NSXMLParserDelegate,UITextViewDelegate,UITextFieldDelegate>
@property int fwidth;  //屏幕宽度
@property int fheight;  //屏幕高度

@property (weak, nonatomic)  UITextField *contactName;
@property (weak, nonatomic)  UITextField *contactPhone;
@property (weak, nonatomic)  UITextView *content;
@property (weak, nonatomic)  UIButton *upButton;
@property (nonatomic,strong) NSString *photoUrl;
@property UIImagePickerController *imagePickerController;
@property (strong,nonatomic)  UIImageView *imageView;
@property (strong,nonatomic)  NSData *fileData;
@property (nonatomic,strong) NSString *responsString;
@property (nonatomic,strong) NSString *currentElementName;
@property (nonatomic,retain) UIView *scrollView;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    //self.imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.imagePickerController.allowsEditing = YES;
    
    self.imageView = [[UIImageView alloc]init];
    self.photoUrl = [[NSString alloc]init];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.upButton = [self.scrollView viewWithTag:103];
    self.upButton.userInteractionEnabled = NO; //没有照片按钮不可用
    
    self.content.delegate = self;
    self.view.userInteractionEnabled = YES;

    
    self.fwidth = self.view.frame.size.width;
    self.fheight = self.view.frame.size.height;
    
    // Do any additional setup after loading the view.
    #pragma mark - 添加滚动视图
    // frame中的size指UIScrollView的可视范围
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 80, _fwidth, _fheight-130);
    scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    #pragma mark - 定义界面
    UIFont *font = [UIFont systemFontOfSize:20];

    //1.添加图片
    UILabel *lbAddPic = [[UILabel alloc]initWithFrame:CGRectMake(16, 10, 120, 40)];
    lbAddPic.font = font;
    lbAddPic.text = @"添加图片";
    [scrollView addSubview:lbAddPic];

    // 2.创建图片按钮
    //UIImage *imageAdd = [UIImage imageNamed:@"upload2.png"];
    UIButton *btAddpic = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [btAddpic setFrame:CGRectMake(20, 40, 60, 60)];
    [btAddpic setTag:101];
    self.upButton.userInteractionEnabled = NO;
    [btAddpic addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:btAddpic];
    
    // 3.设置scrollView的属性
    // 设置UIScrollView的滚动范围（内容大小）
    scrollView.contentSize = CGSizeMake(_fwidth, _fheight+100);
                              
    // 4.隐藏滚动条
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    

    UILabel *lbName = [[UILabel alloc]initWithFrame:CGRectMake(16, 100, 120, 40)];
    lbName.text = @"联系人";
    lbName.font = font;
    [scrollView addSubview:lbName];
    
    UITextField *tfName = [[UITextField alloc]initWithFrame:CGRectMake(110, 100, _fwidth-126, 40)];
    tfName.text = @"";
    tfName.placeholder = @"请输入联系人";
    tfName.font = font;
    tfName.returnKeyType = UIReturnKeyDone;
    tfName.delegate = self;
    tfName.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:0.5];
    [tfName setTag:201];
    self.contactName = tfName;
    [scrollView addSubview:tfName];
    

    UILabel *lbPhone = [[UILabel alloc]initWithFrame:CGRectMake(16, 160, 120, 40)];
    lbPhone.text = @"联系电话";
    lbPhone.font = font;
    [scrollView addSubview:lbPhone];
    
    UITextField *tfPhone = [[UITextField alloc]initWithFrame:CGRectMake(110, 160, _fwidth-126, 40)];
    tfPhone.text = @"";
    tfPhone.placeholder = @"请输入联系电话";
    tfPhone.font = font;
    tfPhone.keyboardType= UIKeyboardTypePhonePad;
    tfPhone.returnKeyType = UIReturnKeyDone;
    tfPhone.delegate = self;
    tfPhone.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:0.5];
    [tfPhone setTag:202];
    self.contactPhone = tfPhone;
    [scrollView addSubview:tfPhone];

    
    UILabel *lbContent = [[UILabel alloc]initWithFrame:CGRectMake(16, 220, 120, 40)];
    lbContent.text = @"输入内容";
    lbContent.font = font;
    [scrollView addSubview:lbContent];
    
    UILabel *lbLeft = [[UILabel alloc]initWithFrame:CGRectMake(110, 220, _fwidth-126, 40)];
    lbLeft.text = @"还可以输入120字";
    lbLeft.font = font;
    lbLeft.textColor = [UIColor colorWithRed:21.0/255 green:116.0/255 blue:204.0/255 alpha:0.5];
    [lbLeft setTag:203];
    [scrollView addSubview:lbLeft];
    
    UITextView *tvContent = [[UITextView alloc]initWithFrame:CGRectMake(16, 270, _fwidth-32, 100)];
    tvContent.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:0.5];

    tvContent.font = font;
    tvContent.returnKeyType = UIReturnKeyDone;
    tvContent.delegate = self;
    [tvContent setTag:204];
    self.content = tvContent;
    [scrollView addSubview:tvContent];
    
    UIButton  *btSubmit =  [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btSubmit setFrame:CGRectMake(_fwidth/2-60, 390, 120, 40)];
    [btSubmit setTitle:@"提交" forState:UIControlStateNormal];
    btSubmit.titleLabel.font = font;
    btSubmit.backgroundColor = [UIColor colorWithRed:21.0/255 green:116.0/255 blue:204.0/255 alpha:0.5];
    btSubmit.clipsToBounds=YES;
    btSubmit.layer.cornerRadius=5;
    [btSubmit addTarget:self action:@selector(upLoad:) forControlEvents:UIControlEventTouchUpInside];
    self.upButton = btSubmit;
    [scrollView addSubview:btSubmit];
 }

- (void)textViewDidBeginEditing:(UITextView *)textView {
    //self.content.text = @"";
    self.content.textColor = [UIColor blackColor];
}

- (void)textViewDidChange:(UITextView *)textView{
    NSInteger count = textView.text.length;
    NSInteger left = 120-count;
    UILabel *lbLeft = [self.scrollView viewWithTag:203];
    lbLeft.text = [NSString stringWithFormat:@"(还可以输入%ld字)",(long)left];
}

//限制字符数
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if([text isEqualToString:@""]){
        return YES;
    }
    if(range.location>=120){
        return NO;
    }else
    {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)endEdit:(id)sender {
    [self.contactPhone resignFirstResponder];
    [self.contactName resignFirstResponder];
    [self.content resignFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 拍照
- (void) takePhoto:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择图片"  message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    UIAlertAction *Cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *Shoot = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        //拍照
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        //相机类型（拍照、录像...）字符串需要做相应的类型转换
        self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        //设置摄像头模式（拍照、录制视频）
        self.imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }];
    
    UIAlertAction *Album = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        //相册
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //设置选择后的图片可被编辑
        self.imagePickerController.allowsEditing = YES;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }];
    
    [alertController addAction:Cancel];
    [alertController addAction:Shoot];
    [alertController addAction:Album];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 拍照完毕，保存图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    //判断资源类型
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        
        UIImageView *imageV = [[UIImageView alloc] init];
        imageV.frame = CGRectMake(16, 10, 80, 80);
        imageV.backgroundColor = [UIColor grayColor];
        imageV.image = info[UIImagePickerControllerEditedImage];
        [imageV setTag:107];
        
        [self.scrollView addSubview:imageV];//把对象添加到控制器中
        self.imageView = imageV;
        
        //压缩图片
        self.fileData = [[NSData alloc]init];
        self.fileData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
        
        //如果是拍照，保存图片至相册
        if(self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera){
            UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
        
        UIButton *btAdd = (UIButton * )[self.scrollView viewWithTag:101];
        CGRect rect = btAdd.frame;
        if(rect.origin.x < 100){
            rect.origin.x += 100;
            rect.origin.y -= 20;
        }
        btAdd.frame = rect;
        self.upButton.userInteractionEnabled = YES;
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -图片保存完毕的回调
- (void) image: (UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInf{
    
}

#pragma mark - 文件上传
- (void)upLoad:(id)sender {
    
    if([self.contactName.text isEqual:@""] ||[self.contactPhone.text isEqual:@""]){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"姓名或电话号码不能为空";
        hud.label.textColor = [UIColor redColor];
        [hud hideAnimated:YES afterDelay:2];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *urlString = @"http://183.238.82.216:9090/waterlogging/android/upload/save";
    NSLog(@"upload--");
    NSURL *URL = [[NSURL alloc]initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:URL cachePolicy:(NSURLRequestUseProtocolCachePolicy) timeoutInterval:30];
    request.HTTPMethod = @"POST";
    
    // 2.设置请求头和请求体
    NSString *boundary = @"HS23dsdf435Sdfasd23A4dfDF43SA";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:@"ios+android" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"HS23dsdf435Sdfasd23A4dfDF43SA" forHTTPHeaderField:@"boundary"];
    
    //NSLog(@"request---------%@",request.allHTTPHeaderFields);
    
    NSMutableData *bodydata = [self buildBody];
    
    //3 session
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:bodydata completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"data++++++++++++++++++++++%@",dataString);
        //NSLog(@"response======================= %@",response);
        //NSLog(@"error----------------------%@",error);
        //  开始解析
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
        xmlParser.delegate = self;
        [xmlParser parse];
    }];
    //5 resume
    [task resume];
    
    UITextField *name = [self.scrollView viewWithTag:201];
    UITextField *phone = [self.scrollView viewWithTag:202];
    UILabel *remain = [self.scrollView viewWithTag:203];
    UITextView *content = [self.scrollView viewWithTag:204];
    name.text = @"";
    phone.text = @"";
    remain.text = @"还可输入120字";
    content.text = @"";
    
    
    UIImageView *imageV = [self.scrollView viewWithTag:107];
    [imageV removeFromSuperview];
    
    UIButton *btAdd = (UIButton * )[self.scrollView viewWithTag:101];
    CGRect rect = btAdd.frame;
    if(rect.origin.x >100){
        rect.origin.x -= 100;
        rect.origin.y += 20;
    }
    btAdd.frame = rect;

    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(NSMutableData *)buildBody{
    
    NSMutableString *bodyStr = [NSMutableString string];
    NSString *boundary = @"HS23dsdf435Sdfasd23A4dfDF43SA";
    
    //1 pic
    /*
     --AaB03x
     Content-disposition: form-data; name="pic"; filename="file"
     Content-Type: application/octet-stream
     */
    //获取系统时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYMMddHHmmss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    
    NSString *appendfile = [[NSString alloc]initWithFormat:@"Content-disposition: form-data; name=\"pic\"; filename=\"%@.jpg\"",dateTime];
    
    //1 姓名
    [bodyStr appendFormat:@"--%@\r\n",boundary];//\n:换行 \n:切换到行首
    [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"reportor\""];
    [bodyStr appendFormat:@"\r\n\r\n"];
    [bodyStr appendFormat:@"%@\r\n",self.contactName.text];
    
    //2 电话
    [bodyStr appendFormat:@"--%@\r\n",boundary];//\n:换行 \n:切换到行首
    [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"phone\""];
    [bodyStr appendFormat:@"\r\n\r\n"];
    [bodyStr appendFormat:@"%@\r\n",self.contactPhone.text];
    
    //3 内容
    [bodyStr appendFormat:@"--%@\r\n",boundary];//\n:换行 \n:切换到行首
    [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"reportContent\""];
    [bodyStr appendFormat:@"\r\n\r\n"];
    [bodyStr appendFormat:@"%@\r\n",self.content.text];
    
    //4 图片
    [bodyStr appendFormat:@"--%@\r\n",boundary];
    [bodyStr appendFormat:@"%@", appendfile];
    [bodyStr appendFormat:@"\r\n"];
    //[bodyStr appendFormat:@"Content-Type: application/octet-stream"];
    [bodyStr appendFormat:@"Content-Type: application/jpg"];
    [bodyStr appendFormat:@"\r\n\r\n"];
    
    // [bodyStr appendFormat:@"--%@--\r\n",boundary];//\n:换行 \n:切换到行首
    
    NSMutableData *bodyData = [NSMutableData data];
    NSLog(@"%@",bodyStr);
    //(1)startData
    NSData *startData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [bodyData appendData:startData];
    
    //(2)pic
    NSData *picdata  = self.fileData;
    NSLog(@"length----------------%lu",(unsigned long)picdata.length);
    [bodyData appendData:picdata];
    
    //(3)--Str--
    NSString *endStr = [NSString stringWithFormat:@"\r\n--%@--\r\n",boundary];
    NSData *endData = [endStr dataUsingEncoding:NSUTF8StringEncoding];
    [bodyData appendData:endData];
    return bodyData;
}

# pragma mark - 协议方法

// 开始
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    self.responsString = [[NSString alloc]init];
}

// 获取节点头
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    self.currentElementName = elementName;
    if ([elementName isEqualToString:@"msg"]) {
        self.responsString = [[NSString alloc] init];
    }
}

// 获取节点的值 (这个方法在获取到节点头和节点尾后，会分别调用一次)
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSLog(@"value : %@", string);
    if ([_currentElementName isEqualToString:@"msg"]) {
        self.responsString = string;
        if([string isEqualToString:@"保存成功"]){
            self.responsString = @"提交成功";
        }
    }
}

// 获取节点尾
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    _currentElementName = nil;
    NSLog(@"end element :%@", elementName);
}
// 结束
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    //  [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"结果" message:self.responsString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 检测上传进度
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    float progress = (float)totalBytesSent / totalBytesExpectedToSend;
    NSLog(@"%f %@", progress, [NSThread currentThread]);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"完成");
}

@end

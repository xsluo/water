//
//  SecondViewController.m
//  WaterLogging
//
//  Created by 罗 显松 on 2017/12/3.
//  Copyright © 2017年 xsluo. All rights reserved.
//

#import "UploadViewController.h"
#import  "AFNetworking.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MBProgressHUD/MBProgressHUD.h"
#import <Foundation/Foundation.h>

@interface UploadViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,NSXMLParserDelegate,UITextViewDelegate,UITextFieldDelegate>
@property NSInteger fwidth;  //屏幕宽度
@property NSInteger fheight;  //屏幕高度
@property NSInteger offsetx;  //水平偏移
@property NSInteger offsety;  //垂直偏移

@property (weak, nonatomic)  UITextField *contactName;
@property (weak, nonatomic)  UITextField *contactPhone;
@property (weak, nonatomic)  UITextView *content;
@property (nonatomic,strong) NSString *photoUrl;
@property UIImagePickerController *imagePickerController;
@property (strong,nonatomic) UIImageView *imageView;
@property (strong,nonatomic) NSData *fileData;
@property (nonatomic,strong) NSString *responsString;
@property (nonatomic,strong) NSString *currentElementName;
@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonnull,retain) NSMutableArray *pictures;

@end

@implementation UploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    
    self.imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.imagePickerController.allowsEditing = YES;
    
    self.imageView = [[UIImageView alloc]init];
    self.photoUrl = [[NSString alloc]init];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.content.delegate = self;
    self.view.userInteractionEnabled = YES;
    
    self.pictures = [[NSMutableArray alloc] init];
    
    
    self.fwidth = self.view.frame.size.width;
    self.fheight = self.view.frame.size.height;
    self.offsetx = 0;
    
    // Do any additional setup after loading the view.
#pragma mark - 添加滚动视图
    // frame中的size指UIScrollView的可视范围
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 80, _fwidth, _fheight-130);
    scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
#pragma mark - 定义界面
    UIFont *font = [UIFont systemFontOfSize:20]; //字体大小
    
    //1.添加图片
    UILabel *lbAddPic = [[UILabel alloc]initWithFrame:CGRectMake(16, 20, 120, 40)];
    lbAddPic.font = font;
    lbAddPic.text = @"添加图片";
    [lbAddPic setTag:100];
    [scrollView addSubview:lbAddPic];
    
    // 2.创建图片按钮
    
    UIButton *btAddpic = [UIButton buttonWithType:UIButtonTypeContactAdd];
    NSInteger picx = (self.view.frame.size.width-48)/5;
    [btAddpic setFrame:CGRectMake(28, 50, picx-16, picx-16)];
    [btAddpic setTag:101];
    [btAddpic setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    [btAddpic addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:btAddpic];
    
    // 3.设置scrollView的属性
    // 设置UIScrollView的滚动范围（内容大小）
    scrollView.contentSize = CGSizeMake(_fwidth, _fheight + 50);
    
    // 4.隐藏滚动条
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    
    UILabel *lbName = [[UILabel alloc]initWithFrame:CGRectMake(16, 120, 120, 40)];
    lbName.text = @"联系人";
    lbName.font = font;
    [lbName setTag:201];
    [scrollView addSubview:lbName];
    
    UITextField *tfName = [[UITextField alloc]initWithFrame:CGRectMake(110, 120, _fwidth-126, 40)];
    tfName.text = @"";
    tfName.placeholder = @"请输入联系人";
    tfName.font = font;
    tfName.returnKeyType = UIReturnKeyDone;
    tfName.delegate = self;
    tfName.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:0.5];
    [tfName setTag:202];
    self.contactName = tfName;
    [scrollView addSubview:tfName];
    
    UILabel *lbPhone = [[UILabel alloc]initWithFrame:CGRectMake(16, 180, 120, 40)];
    lbPhone.text = @"联系电话";
    lbPhone.font = font;
    [lbPhone setTag:203];
    [scrollView addSubview:lbPhone];
    
    UITextField *tfPhone = [[UITextField alloc]initWithFrame:CGRectMake(110, 180, _fwidth-126, 40)];
    tfPhone.text = @"";
    tfPhone.placeholder = @"请输入联系电话";
    tfPhone.font = font;
    tfPhone.keyboardType= UIKeyboardTypePhonePad;
    tfPhone.returnKeyType = UIReturnKeyDone;
    tfPhone.delegate = self;
    tfPhone.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:0.5];
    [tfPhone setTag:204];
    self.contactPhone = tfPhone;
    [scrollView addSubview:tfPhone];
    
    UILabel *lbContent = [[UILabel alloc]initWithFrame:CGRectMake(16, 240, 120, 40)];
    lbContent.text = @"输入内容";
    lbContent.font = font;
    [lbContent setTag:205];
    [scrollView addSubview:lbContent];
    
    UILabel *lbLeft = [[UILabel alloc]initWithFrame:CGRectMake(110, 240, _fwidth-126, 40)];
    lbLeft.text = @"还可以输入120字";
    lbLeft.font = font;
    lbLeft.textColor = [UIColor colorWithRed:21.0/255 green:116.0/255 blue:204.0/255 alpha:0.5];
    [lbLeft setTag:206];
    [scrollView addSubview:lbLeft];
    
    UITextView *tvContent = [[UITextView alloc]initWithFrame:CGRectMake(16, 290, _fwidth-32, 120)];
    tvContent.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:0.5];
    
    tvContent.font = font;
    tvContent.returnKeyType = UIReturnKeyDone;
    tvContent.delegate = self;
    [tvContent setTag:207];
    self.content = tvContent;
    [scrollView addSubview:tvContent];
    
    //“提交“按钮
    UIButton  *btSubmit =  [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btSubmit setFrame:CGRectMake(_fwidth/2-120, 430, 100, 40)];
    [btSubmit setTitle:@"提交" forState:UIControlStateNormal];
    [btSubmit setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    btSubmit.titleLabel.font = font;
    btSubmit.backgroundColor = [UIColor colorWithRed:21.0/255 green:116.0/255 blue:204.0/255 alpha:0.7];
    btSubmit.clipsToBounds=YES;
    btSubmit.layer.cornerRadius=5;
    [btSubmit addTarget:self action:@selector(upLoad:) forControlEvents:UIControlEventTouchUpInside];
    [btSubmit setTag:208];
    [scrollView addSubview:btSubmit];
    
    //“取消”按钮
    UIButton  *btCancel =  [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btCancel setFrame:CGRectMake(_fwidth/2+20, 430, 100, 40)];
    [btCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btCancel setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    btCancel.titleLabel.font = font;
    btCancel.backgroundColor = [UIColor colorWithRed:21.0/255 green:116.0/255 blue:204.0/255 alpha:0.7];
    btCancel.clipsToBounds=YES;
    btCancel.layer.cornerRadius=5;
    [btCancel addTarget:self action:@selector(ResetController) forControlEvents:UIControlEventTouchUpInside];
    [btCancel setTag:209];
    [scrollView addSubview:btCancel];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    //self.content.text = @"";
    self.content.textColor = [UIColor blackColor];
}

- (void)textViewDidChange:(UITextView *)textView{
    NSInteger count = textView.text.length;
    NSInteger left = 120-count;
    UILabel *lbLeft = [self.scrollView viewWithTag:206];
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
- (void)takePhoto:(id)sender {
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
    
    self.fileData = [[NSData alloc]init];
    //压缩图片
    self.fileData = UIImageJPEGRepresentation(info[UIImagePickerControllerEditedImage], 0.2);
    [self.pictures addObject:self.fileData];
    
    NSInteger k = [self.pictures count];
    
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    //判断资源类型
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        UIImageView *imageV = [[UIImageView alloc] init];
        int picx = (self.view.frame.size.width-48)/5;   //单张图片宽度
        self.offsety = picx;
        
        if(k<6){
            imageV.frame = CGRectMake(16+picx*(k-1)+4*(k-1), 20, picx, picx);
        }else{
            imageV.frame = CGRectMake(16+picx*(k-6)+4*(k-6), 30+picx, picx, picx);
        }
        
        UIButton *btDel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        btDel.backgroundColor = [UIColor colorWithRed:255.0/255 green:0.0/255 blue:0.0/255 alpha:0.7];
        btDel.titleLabel.textColor = [UIColor whiteColor];
        [btDel setTitle:@"一" forState:UIControlStateNormal];
        [btDel setFrame:CGRectMake(picx/2+4, -4, picx/2, picx/2)];
        btDel.titleLabel.font = [UIFont systemFontOfSize: 20.0];
        [btDel setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        btDel.layer.cornerRadius = picx/4.0;
        btDel.layer.masksToBounds = picx/4.0;
        
        //btSubmit.titleLabel.font = font;
        
        [btDel addTarget:self action:@selector(delPic:) forControlEvents:UIControlEventTouchUpInside];
        [imageV addSubview:btDel];
        
        imageV.backgroundColor = [UIColor grayColor];
        imageV.image = info[UIImagePickerControllerEditedImage];
        [imageV setTag:300+k];
        [imageV setUserInteractionEnabled:YES];
        
        [self.scrollView addSubview:imageV];//把对象添加到控制器中
        
        self.imageView = imageV;
        
        // self.fileData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
        
        //如果是拍照，保存图片至相册
        if(self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera){
            UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
        
        //更新添加按钮位置
        UIButton *btAdd = (UIButton * )[self.scrollView viewWithTag:101];
        CGRect rect = btAdd.frame;
        if(k==9){
            [btAdd setHidden:YES];
        }
        if(k==1){
            UIView *lbAddPic = [self.scrollView viewWithTag:100];
            [lbAddPic setHidden:YES];  //隐藏文字
            rect.origin.x = picx + 22;
            rect.origin.y = 22;
        }else if(k==5){
            rect.origin.x = 18;
            rect.origin.y += picx+10;
            [self updateLayout];
        }else{
            rect.origin.x += picx+4;
        }
        btAdd.frame = rect;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 删除图片
-(void)delPic:(id)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除图片" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //取消:style:UIAlertActionStyleCancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    //确定
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
        UIButton *btDel = (UIButton*)sender;
        UIView *imageView = [btDel superview];
        UIView *scrollView = [imageView superview];
        
        int k = (int)imageView.tag - 301;
        [self.pictures removeObjectAtIndex:k];
        
        [imageView removeFromSuperview];
        
        int picx = (self.view.frame.size.width-48)/5;   //单张图片宽度ƒ
        
        //NSLog(@"-------picture count %lu",(unsigned long)[self.pictures count]);
        for (int i=k+1; i<=[self.pictures count]; i++) {
            int tag = 301+i;
            UIView *v = [scrollView viewWithTag:tag];
            CGRect rect = v.frame;
            if(tag!=306){
                rect.origin.x -=picx +4;
                v.frame = rect;
                [v setTag:tag-1];
            }
            else{
                rect.origin.y -=picx +10;
                rect.origin.x +=4*(picx +4);
                v.frame = rect;
                [v setTag:tag-1];
            }
        }
        
        UIButton *btAdd = (UIButton*)[scrollView viewWithTag:101];
        CGRect rect = btAdd.frame;
        if([self.pictures count] !=4){
            rect.origin.x -=picx+4;
        }else{
            rect.origin.y -= picx+10;
            rect.origin.x += 4*(picx+4);
            [self updateLayout1];
        }
        btAdd.frame = rect;
    }];
    [alertController addAction:OKAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)delPic1:(id)sender{
    UIButton *btDel = (UIButton*)sender;
    UIView *imageView = [btDel superview];
    UIView *scrollView = [imageView superview];
    /*ƒ
     for(int i=301;i<301+[self.pictures count];i++){
     
     }*/
    
    int k = (int)imageView.tag - 301;
    [self.pictures removeObjectAtIndex:k];
    
    [imageView removeFromSuperview];
    
    int picx = (self.view.frame.size.width-48)/5;   //单张图片宽度ƒ
    
    //NSLog(@"-------picture count %lu",(unsigned long)[self.pictures count]);
    for (int i=k+1; i<=[self.pictures count]; i++) {
        int tag = 301+i;
        UIView *v = [scrollView viewWithTag:tag];
        CGRect rect = v.frame;
        if(tag!=306){
            rect.origin.x -=picx +4;
            v.frame = rect;
            [v setTag:tag-1];
        }
        else{
            rect.origin.y -=picx +10;
            rect.origin.x +=4*(picx +4);
            v.frame = rect;
            [v setTag:tag-1];
        }
    }
    
    UIButton *btAdd = (UIButton*)[scrollView viewWithTag:101];
    CGRect rect = btAdd.frame;
    if([self.pictures count] !=4){
        rect.origin.x -=picx+4;
    }else{
        rect.origin.y -= picx+10;
        rect.origin.x += 4*(picx+4);
        [self updateLayout1];
    }
    btAdd.frame = rect;
}


#pragma mark - 修改控件位置
//控件下移
- (void)updateLayout{
    for(int i=0;i<9;i++){
        UIView *control = [self.scrollView viewWithTag:201+i];
        CGRect rect = control.frame;
        rect.origin.y += self.offsety + 10;
        control.frame = rect;
    }
}

//控件上移
-(void)updateLayout1{
    for(int i=0;i<9;i++){
        UIView *control = [self.scrollView viewWithTag:201+i];
        CGRect rect = control.frame;
        rect.origin.y -= self.offsety + 10;
        control.frame = rect;
    }
}

#pragma mark -图片保存完毕的回调
- (void) image: (UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInf{
}

#pragma mark - 文件上传
- (void)upLoad:(id)sender {
    if([self.contactName.text isEqual:@""] ||[self.contactPhone.text isEqual:@""]||[self.content.text isEqualToString:@""]){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"联系人、联系电话和输入内容不能为空";
        hud.label.textColor = [UIColor redColor];
        [hud hideAnimated:YES afterDelay:2];
        return;
    }
    
    //if(self.imageView.image == nil){
    if([self.pictures count] == 0){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"照片不能为空";
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
    //NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:bodydata completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"data value %@",dataString);
        //  开始解析
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
        xmlParser.delegate = self;
        [xmlParser parse];
    }];
    //5 resume
    [task resume];
    
    [self ResetController];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)ResetController{
    
    UITextField *name = [self.scrollView viewWithTag:202];
    UITextField *phone = [self.scrollView viewWithTag:204];
    UILabel *remain = [self.scrollView viewWithTag:206];
    UITextView *content = [self.scrollView viewWithTag:207];
    name.text = @"";
    phone.text = @"";
    remain.text = @"还可输入120字";
    content.text = @"";
    UIView *lbAddPic = [self.scrollView viewWithTag:100];
    [lbAddPic setHidden:NO];
    UIView *btAddpic = [self.scrollView viewWithTag:101];
    NSInteger picx = (self.view.frame.size.width-48)/5;
    [btAddpic setFrame:CGRectMake(28, 52, picx-16, picx-16)];
    
    NSInteger k = [self.pictures count];
    for(int i=301;i<=300+k;i++){
        UIView *imageView = [self.scrollView viewWithTag:i];
        [imageView removeFromSuperview];
    }
    
    if([self.pictures count] >= 5){
        self.offsety = self.offsety*(-1)  - 20;
        [self updateLayout];
    }
    [self.pictures removeAllObjects];
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
}


-(NSMutableData *)buildBody{
    
    NSMutableString *bodyStr = [NSMutableString string];
    NSString *boundary = @"HS23dsdf435Sdfasd23A4dfDF43SA";
    
    //获取系统时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYMMddHHmmss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    
    /*
     NSString *appendfile = [[NSString alloc]initWithFormat:@"Content-disposition: form-data; name=\"pic\"; filename=\"%@.jpg\"",dateTime];
     */
    
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
    
    NSMutableData *bodyData = [NSMutableData data];
    
    //startData
    NSData *startData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [bodyData appendData:startData];
    
    //4 图片
    for(int i=0;i<[self.pictures count];i++){
        [bodyStr setString:@""];
        [bodyStr appendFormat:@"\r\n--%@\r\n",boundary];
        NSString *appendfile = [[NSString alloc]initWithFormat:@"Content-disposition: form-data; name=\"pic%d\"; filename=\"%@%d.jpg\"",i,dateTime,i];
        [bodyStr appendFormat:@"%@", appendfile];
        [bodyStr appendFormat:@"\r\n"];
        [bodyStr appendFormat:@"Content-Type: image/jpg"];
        [bodyStr appendFormat:@"\r\n\r\n"];
        
        NSData *strData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
        [bodyData appendData:strData];
        
        NSData *picdata  = [self.pictures objectAtIndex:i];
        [bodyData appendData:picdata];
        
        //NSString *mystr = @"这里是图片";
        //NSData *pic = [mystr dataUsingEncoding:NSUTF8StringEncoding];
        //[bodyData appendData:pic];
        //NSLog(@"%d and bodystr:%@",i,bodyStr);
        //NSLog(@"%@",bodyStr);
        
    }
    
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
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    //hud.label.font = [UIFont fontWithName:@"font" size:40];
    hud.label.text = @"信息上传成功！";
    hud.label.textColor = [UIColor redColor];
    [hud hideAnimated:YES afterDelay:3];
}

#pragma mark - 检测上传进度
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    float progress = (float)totalBytesSent / totalBytesExpectedToSend;
    NSLog(@"%f %@---@@@@@----", progress, [NSThread currentThread]);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"完成");
}

@end

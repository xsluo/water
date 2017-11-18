//
//  SecondViewController.m
//  WaterLogging
//
//  Created by 罗 显松 on 2017/11/15.
//  Copyright © 2017年 xsluo. All rights reserved.
//

#import "ThirdViewController.h"
#import  "AFNetworking.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ThirdViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *contactName;
@property (weak, nonatomic) IBOutlet UITextField *contactPhone;
@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (nonatomic,strong) NSString *photoUrl;
@property UIImagePickerController *imagePickerController;
@property (strong,nonatomic)  UIImageView *imageView;
@property (strong,nonatomic)  NSData *fileData;
@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.imagePickerController.allowsEditing = YES;

    self.imageView = [[UIImageView alloc]init];
    self.photoUrl = [[NSString alloc]init];
    // Do any additional setup after loading the view, typically from a nib.
    self.upButton.userInteractionEnabled = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePhoto:(id)sender {
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

//  拍照完毕，保存图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    //判断资源类型
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        
        UIImageView *imageV = [[UIImageView alloc] init];
        imageV.frame = CGRectMake(20, 100, 100, 100);
        imageV.backgroundColor = [UIColor grayColor];
        imageV.image = info[UIImagePickerControllerEditedImage];
        [self.view addSubview:imageV];//把对象添加到控制器中
        self.imageView = imageV;
        
        //压缩图片
        //NSData *fileData = UIImageJPEGRepresentation(self.imageView.image, 1.0);
        self.fileData = [[NSData alloc]init];
        self.fileData = UIImageJPEGRepresentation(self.imageView.image, 1.0);
        
        //如果是拍照，保存图片至相册
        if(self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera){
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
        
        //上传图片
        //[self uploadImageWithData:fileData];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 图片保存完毕的回调
- (void) image: (UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInf{
    UIButton *btAdd = (UIButton * )[self.view viewWithTag:101];
    CGRect rect = btAdd.frame;
    if(rect.origin.x < 100){
         rect.origin.x += 120;
        rect.origin.y -= 20;
    }
    btAdd.frame = rect;
}

#pragma mark 文件上传
- (IBAction)upLoad:(id)sender {
    
    
}


    /*
//得到图片或者视频后, 调用该代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //在这个方法里我们可以进行图片的修改, 保存, 或者视频的保存
    // UIImagePickerControllerOriginalImage 原始图片
    // UIImagePickerControllerEditedImage 编辑后图片
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    
    NSString *imageDocPath = [self getImageSavePath];//保存
    self.photoUrl = imageDocPath;
    NSLog(@"imageDocPath == %@", imageDocPath);
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
//当用户取消相册时, 调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
//在这里创建一个路径，用来在照相的代理方法里作为照片存储的路径
-(NSString *)getImageSavePath{
    //获取存放的照片
    //获取Documents文件夹目录
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    //指定新建文件夹路径
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"PhotoFile"];
    return imageDocPath;
}

*/
   /*
    
- (IBAction)upLoad:(id)sender {
    
    //1.创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //2.上传文件,在这里我们还要求传别的参数，用字典保存一下，不需要的童鞋可以省略此步骤
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.contactName,@"name",self.contactPhone,@"phone",self.content,@"content", nil];
    
    
    NSString *urlString = @"http://183.238.82.216:9090/waterlogging/android/upload/save";
    
    
    //post请求
    [manager POST:urlString parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        // 在网络开发中，上传文件时，是文件不允许被覆盖，文件重名
        // 要解决此问题，
        // 可以在上传时使用当前的系统事件作为文件名
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        formatter.dateFormat            = @"yyyyMMddHHmmss";
        NSString *str                         = [formatter stringFromDate:[NSDate date]];
        NSString *fileName               = [NSString stringWithFormat:@"%@.png", str];
        
        
        /*
         此方法参数
         1. 要上传的[二进制数据]
         2. 我这里的imgFile是对应后台给你url里面的图片参数，别瞎带。
         3. 要保存在服务器上的[文件名]
         4. 上传文件的[mimeType]
    
     //   [formData appendPartWithFileData:imageData name:@"imgFile" fileName:fileName mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //打印下上传进度
        NSLog(@"%lf",1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //请求成功
        NSLog(@"请求成功：%@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //请求失败
        NSLog(@"请求失败：%@",error);
    }];
    
}
*/










@end

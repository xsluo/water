//
//  FirstViewController.m
//  WaterLogging
//
//  Created by 罗 显松 on 2017/11/15.
//  Copyright © 2017年 xsluo. All rights reserved.
//

#import "FirstViewController.h"
#import <WebKit/WebKit.h>
#import "MBProgressHUD/MBProgressHUD.h"

@interface FirstViewController ()<WKUIDelegate,WKNavigationDelegate>
@property(nonatomic,retain) WKWebView *homeWeb;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.homeWeb = [[WKWebView alloc] initWithFrame:CGRectMake(0,80, self.view.frame.size.width,self.view.frame.size.height-130)];
    self.homeWeb.scrollView.backgroundColor = [UIColor whiteColor];
    self.homeWeb.UIDelegate = self;
    self.homeWeb.navigationDelegate = self;
    [self.view addSubview:self.homeWeb];
    
    NSURL *url = [NSURL URLWithString:@"http://183.238.82.216:9090/watermobile?user=app"];
    NSURLRequest *request = [ NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    [self.homeWeb loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"网络连接失败";
    [hud showAnimated:YES];
}

@end

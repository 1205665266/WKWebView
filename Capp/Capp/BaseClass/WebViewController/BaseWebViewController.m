//
//  BaseWebViewController.m
//  Capp
//
//  Created by apple on 2017/10/18.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "BaseWebViewController.h"
#import "WYWebProgressLayer.h"
#import "UIView+Frame.h"
#import <WebKit/WebKit.h>

@interface BaseWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@end

@implementation BaseWebViewController
{
    WKWebView *_webView;
    WYWebProgressLayer *_progressLayer; ///< 网页加载进度条
}

- (void)dealloc {
    
    [_progressLayer closeTimer];
    [_progressLayer removeFromSuperlayer];
    _progressLayer = nil;
    NSLog(@"web 走了 dealloc");
    //这里remove掉 添加的js标识
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"Share"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"Camera"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //技术文档
    //    http://www.jianshu.com/p/6ba2507445e4
    //    http://blog.csdn.net/shenhuaikun/article/details/61916761
    //    http://www.jianshu.com/p/ab58df0bd1a1
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = self.titleStr;
    [self setupUI];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"左白色箭头"] imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)] style:(UIBarButtonItemStyleDone) target:self action:@selector(leftBarButtonAction)];
    
}

-(void)leftBarButtonAction
{
    if (_webView.canGoBack) {
        [_webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setupUI {
    
    //进度条
    _progressLayer = [WYWebProgressLayer new];
    _progressLayer.frame = CGRectMake(0, 42, SCREEN_WIDTH, 2);
    [self.navigationController.navigationBar.layer addSublayer:_progressLayer];
    
    
    //webView部分
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    //这里add 添加的js标识  用于处理接受的js通知做判断
    [userContentController addScriptMessageHandler:self name:@"Camera"];
    [userContentController addScriptMessageHandler:self name:@"Share"];
    configuration.userContentController = userContentController;
    
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 40.0;
    configuration.preferences = preferences;
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64) configuration:configuration];
    
    //加载URL  显示进度条
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
        [_webView loadRequest:request];
    
    //js交互
//    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"WKWebViewMessageHandler" ofType:@"html"];
//    NSString *fileURL = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
//    [_webView loadHTMLString:fileURL baseURL:baseURL];
    
    _webView.backgroundColor = [UIColor lightGrayColor];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    [self.view addSubview:_webView];
    [_webView setOpaque:NO];
}

#pragma mark <WKNavigationDelegate>   WKWebView代理方法
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    [_progressLayer startLoad];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [_progressLayer finishedLoad];
    //自动获取  webView的title
    self.navigationItem.title = webView.title;
}

//页面加载失败时 调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [_progressLayer finishedLoad];
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"=======接收到服务器跳转请求之后调用======");
}

/**
 *  在发送请求之前，决定是否跳转
 *
 *  @param webView          实现该代理的webview
 *  @param navigationAction 当前navigation
 *  @param decisionHandler  是否调转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"````````````在发送请求之前，决定是否跳转```````````");
    NSLog(@"IP地址=======%@", navigationAction.request.URL.host.lowercaseString);
    NSLog(@"======request.URL.absoluteString---%@",navigationAction.request.URL.absoluteString);
    NSLog(@"======request.description(str)---%@",navigationAction.request.description);
    if ([navigationAction.request.URL.absoluteString containsString:@"collectionStore"]) {//
        
        //在这里做特定的操作
        decisionHandler(WKNavigationActionPolicyCancel);
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

/**
 *  在收到响应后，决定是否跳转
 *
 *  @param webView            实现该代理的webview
 *  @param navigationResponse 当前navigation
 *  @param decisionHandler    是否跳转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSLog(@"============在收到响应后，决定是否跳转========");
    NSLog(@"IP地址=======%@", navigationResponse.response.URL.host.lowercaseString);
    NSLog(@"request.URL.absoluteString---%@",navigationResponse.response.URL.absoluteString);
    NSLog(@"request.description(str)---%@",navigationResponse.response.description);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"message.name:%@", message.name);
    NSLog(@"message.body:%@", message.body);
    //JS调用OC方法
    
    //message.boby就是JS里传过来的参数
    NSLog(@"body:%@",message.body);//body是个字典
    
    //根据添加的js标识   做特定的操作
    if ([message.name isEqualToString:@"Share"]) {
        // 将结果返回给js  oc调用js
        //注:shareResult('%@')", @"message传到OC成功,oc传数据给js"
        //shareResult是js的方法名
        // ('%@') 是 传给js的参数
        NSString *returnJSStr = [NSString stringWithFormat:@"shareResult('%@','%@','%@')", @"分享成功,oc传数据给js", @"哈哈哈", @"qwer"];
        [_webView evaluateJavaScript:returnJSStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            
            NSLog(@"oc调用js回调,,result==%@,error==%@", result, error);
        }];
    }
    if ([message.name isEqualToString:@"Camera"]) {
        NSString *returnJSStr = [NSString stringWithFormat:@"cameraResult('%@')", @"调用相册成功,oc传数据给js"];
        [_webView evaluateJavaScript:returnJSStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            
            NSLog(@"oc调用js回调,,result==%@,error==%@", result, error);
        }];
    }
}




@end









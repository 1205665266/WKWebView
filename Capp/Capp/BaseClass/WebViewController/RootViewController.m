//
//  RootViewController.m
//  Capp
//
//  Created by apple on 2018/1/11.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "RootViewController.h"
#import "BaseWebViewController.h"
#import "WKWebViewBridgeController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    [button setTitle:@"不用三方" forState:(UIControlStateNormal)];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(100, 220, 100, 100)];
    button1.backgroundColor = [UIColor lightGrayColor];
    [button1 addTarget:self action:@selector(button1Action) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button1];
    [button1 setTitle:@"三方" forState:(UIControlStateNormal)];
}

-(void)buttonAction
{
    BaseWebViewController *VC = [[BaseWebViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)button1Action
{
    WKWebViewBridgeController *VC = [[WKWebViewBridgeController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
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

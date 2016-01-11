//
//  ViewController.m
//  XMNTextFieldExample
//
//  Created by ChenMaolei on 15/12/16.
//  Copyright © 2015年 XMFraker. All rights reserved.
//

#import "ViewController.h"

#import "XMNAnimTextFiled.h"

#import <objc/runtime.h>

@interface ViewController ()

@property (nonatomic, strong) CAShapeLayer *layer;

@property (nonatomic, weak)   XMNAnimTextFiled *usernameTF;
@property (nonatomic, weak)   XMNAnimTextFiled *passwordTF;


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    XMNAnimTextFiled *usernameTF = [[XMNAnimTextFiled alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width - 40, 70)];
    [usernameTF setPlaceHolderText:@"请输入用户名"];
    usernameTF.text = @"username";
    [self.view addSubview:self.usernameTF = usernameTF];
    
    
    XMNAnimTextFiled *passwordTF = [[XMNAnimTextFiled alloc] initWithFrame:CGRectMake(20, 200, self.view.frame.size.width - 40, 70)];
    [passwordTF setTipsIcon:[UIImage imageNamed:@"invisible_icon"]];
    [passwordTF setPlaceHolderIcon:[UIImage imageNamed:@"1"]];
    [passwordTF setPlaceHolderText:@"请输入密码"];
    [passwordTF setInputType:XMNAnimTextFieldInputTypePassword];
    [self.view addSubview:self.passwordTF = passwordTF];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"登录" forState:UIControlStateNormal];
    [button sizeToFit];
    [button setBackgroundColor:[UIColor greenColor]];
    button.layer.cornerRadius = 4.0f;
    button.layer.borderWidth = 1.0f;
    [button setFrame:CGRectMake(32, 300, self.view.frame.size.width - 64, 40)];
    [button addTarget:self action:@selector(_loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)_loginAction {
    if (self.usernameTF.text.length == 0 ) {
        self.usernameTF.state = XMNAnimTextFieldStateError;
        return;
    }
    if (self.passwordTF.text.length == 0 || !([self.usernameTF.text isEqualToString:@"username"] && [self.passwordTF.text isEqualToString:@"password"])) {
        self.passwordTF.state = XMNAnimTextFieldStateError;
        return;
    }
    self.usernameTF.state = self.passwordTF.state = XMNAnimTextFieldStateNormal;
    NSLog(@"success login : username:%@\npassword:%@",self.usernameTF.text,self.passwordTF.text);
}

@end

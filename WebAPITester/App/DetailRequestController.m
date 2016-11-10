//
//  DetailRequestController.m
//  WebAPITester
//
//  Created by cloudtech on 11/8/16.
//  Copyright © 2016 wonder. All rights reserved.
//

#import "DetailRequestController.h"
#import "CCAccountManager.h"

@interface DetailRequestController ()

@property (weak, nonatomic) IBOutlet UITextView *consoleTextView;

@property (nonatomic, strong) NSDictionary *requestPackage;
@property (nonatomic, strong) NSDictionary *responsePackage;


@end

@implementation DetailRequestController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"============ %@ ============",self.testPackage);
    self.requestPackage = self.testPackage[@"request"];
    self.responsePackage = self.testPackage[@"response"][@"obj"];
    NSString *title = self.requestPackage[@"title"];
    self.title = title;

    [self refrestConsole];
    
    UIBarButtonItem *reTestBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reTestButtonAction)];
    self.navigationItem.rightBarButtonItem = reTestBarItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)refrestConsole {
    NSString *title = self.requestPackage[@"title"];
    NSString *method = self.requestPackage[@"method"];
    NSString *url = self.requestPackage[@"url"];
    NSDictionary *params = self.requestPackage[@"params"];
    
    NSMutableString *consoleText = [NSMutableString stringWithFormat:@"Request－－－》\n"];
    [consoleText appendString:[NSString stringWithFormat:@"title:\n%@\n",title]];
    [consoleText appendString:[NSString stringWithFormat:@"method:\n%@\n",method]];
    [consoleText appendString:[NSString stringWithFormat:@"url:\n%@\n",url]];
    [consoleText appendString:[NSString stringWithFormat:@"params:\n%@\n",params]];
    
    [consoleText appendString:[NSString stringWithFormat:@"\nResponse－－－》\n"]];
    
    
    NSError *error = self.testPackage[@"response"][@"err"];
    NSString *state = self.testPackage[@"response"][@"state"];
    
    [consoleText appendString:[NSString stringWithFormat:@"json:\n%@\n",self.responsePackage]];
    [consoleText appendString:[NSString stringWithFormat:@"state:\n%@\n",[state isEqualToString:@"YES"]?@"SUCESS":@"FAIL"]];
    [consoleText appendString:[NSString stringWithFormat:@"err:\n%@\n",error]];
    self.consoleTextView.text = consoleText;
}

- (void)reTestButtonAction {
    
    NSString *method = self.requestPackage[@"method"];
    NSString *url = self.requestPackage[@"url"];
    NSDictionary *params = self.requestPackage[@"params"];
    
    if ([[method lowercaseString] isEqualToString:@"post"]) {
        __weak __typeof(self) weakSelf = self;
        
        [[CCAccountManager shareManager] postCCParams:params toURL:[self.baseURL stringByAppendingString:url] success:^(NSURLSessionDataTask *task, id responseObject) {
            weakSelf.responsePackage = @{@"state": @"YES",@"obj":responseObject};
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            weakSelf.responsePackage = @{@"state": @"NO",@"err":error};
        }];
        
    }else {
        
    }
}

@end

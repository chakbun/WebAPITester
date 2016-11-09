//
//  DetailRequestController.m
//  WebAPITester
//
//  Created by cloudtech on 11/8/16.
//  Copyright © 2016 wonder. All rights reserved.
//

#import "DetailRequestController.h"

@interface DetailRequestController ()
@property (weak, nonatomic) IBOutlet UITextView *consoleTextView;


@end

@implementation DetailRequestController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"============ %@ ============",self.testPackage);
    
    NSDictionary *requestPackage = self.testPackage[@"request"];
    NSString *title = requestPackage[@"title"];
    self.title = title;
    NSString *method = requestPackage[@"method"];
    NSString *url = requestPackage[@"url"];
    NSDictionary *params = requestPackage[@"params"];
    
    NSMutableString *consoleText = [NSMutableString stringWithFormat:@"Request－－－》\n"];
    [consoleText appendString:[NSString stringWithFormat:@"title:%@\n",title]];
    [consoleText appendString:[NSString stringWithFormat:@"method:%@\n",method]];
    [consoleText appendString:[NSString stringWithFormat:@"url:%@\n",url]];
    [consoleText appendString:[NSString stringWithFormat:@"params:%@\n",params]];

    [consoleText appendString:[NSString stringWithFormat:@"Response－－－》\n"]];

    
    NSDictionary *responsePackage = self.testPackage[@"response"][@"obj"];
    NSError *error = self.testPackage[@"response"][@"err"];
    NSString *state = self.testPackage[@"response"][@"state"];
    
    [consoleText appendString:[NSString stringWithFormat:@"obj:%@\n",responsePackage]];
    [consoleText appendString:[NSString stringWithFormat:@"state:%@\n",[state isEqualToString:@"YES"]?@"SUCESS":@"FAIL"]];
    [consoleText appendString:[NSString stringWithFormat:@"err:%@\n",error]];
    self.consoleTextView.text = consoleText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

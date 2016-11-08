//
//  ViewController.m
//  WebAPITester
//
//  Created by cloudtech on 11/1/16.
//  Copyright © 2016 wonder. All rights reserved.
//

#import "ViewController.h"
#import "CCAccountManager.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *apisTableView;

@property (nonatomic, strong) NSMutableDictionary *apiPackages;

@property (nonatomic, strong) NSArray *apis;

@property (nonatomic, strong) NSMutableDictionary *apiTestResult;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"api list";
    self.apiTestResult  = [NSMutableDictionary dictionary];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars =NO;
        self.modalPresentationCapturesStatusBarAppearance =NO;
        self.navigationController.navigationBar.translucent =NO;
    }
    
    self.apiPackages = [CCAccountManager shareManager].apiConfigDictionary;
    self.apis = self.apiPackages[@"apis"];
    [self reTestButtonAction];
    
    UIBarButtonItem *reTestBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reTestButtonAction)];
    self.navigationItem.rightBarButtonItem = reTestBarItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)reTestButtonAction {
    [self.apiTestResult removeAllObjects];
    NSString *baseURL = self.apiPackages [@"baseUrl"]?:@"";
    for(int i = 0; i < self.apis.count; i++) {
        NSDictionary *requestPackage = self.apis[i];
        NSDictionary *params = requestPackage[@"params"];
        NSString *url = requestPackage[@"url"];
        NSString *method = requestPackage[@"method"];
        if ([[method lowercaseString] isEqualToString:@"post"]) {
            __weak __typeof(self) weakSelf = self;
            
            [[CCAccountManager shareManager] postCCParams:params toURL:[baseURL stringByAppendingString:url] success:^(NSURLSessionDataTask *task, id responseObject) {
                [weakSelf.apiTestResult setObject:@"YES" forKey:[NSString stringWithFormat:@"row_%i",(int)i]];
                [weakSelf.apisTableView reloadData];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [weakSelf.apiTestResult setObject:@"NO" forKey:[NSString stringWithFormat:@"row_%i",(int)i]];
                [weakSelf.apisTableView reloadData];
            }];
        }else {
            
        }
    }
}


#pragma mark - TabelView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apis.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *requestPackage = self.apis[indexPath.row];
    NSString *title = requestPackage[@"title"];
    static NSString *CELL_ID_4_REUSE = @"api_item";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_4_REUSE];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CELL_ID_4_REUSE];
    }
    NSString *resultFlag = self.apiTestResult[[NSString stringWithFormat:@"row_%i",(int)indexPath.row]];
    if (resultFlag) {
        if ([resultFlag boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else {
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
        }
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = title;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

@end

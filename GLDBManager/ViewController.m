//
//  ViewController.m
//  GLDBManager
//
//  Created by guanglong on 16/7/19.
//  Copyright © 2016年 bjhl. All rights reserved.
//

#import "ViewController.h"
#import "TTDBManager.h"
#import "Feed.h"
#import "TTDBManager.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSArray* feedList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self getFeedList];
    
    NSArray* arr = @[@"fasfsdf", @"asdfqeqwepijj", @"ouophphfda990"];
    NSString* json = arr.yy_modelToJSONString;
    NSLog(@"json:%@", json);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFeedList
{
    Feed* feed0 = [Feed new]; feed0.itemId = @"101"; feed0.title = @"first"; feed0.id = @"888";
    Rss* rss00 = [Rss new]; rss00.title = @"hah"; rss00.content = @"asdf家啊"; rss00.rssId = @"001";
    Rss* rss01 = [Rss new]; rss01.title = @"laladfa"; rss01.content = @"90jjijiasasdf家啊"; rss01.rssId = @"002";
    Rss* rss02 = [Rss new]; rss02.title = @"89jijo"; rss02.content = @"1加速iasasdf家啊"; rss02.rssId = @"003";
    Info* info0 = [Info new]; info0.id = 987890; info0.name = @"gsx"; info0.age = @(2); info0.height = 120.3;
    feed0.rsses = @[rss00, rss01, rss02]; feed0.infooo = info0;
    
    Feed* feed1 = [Feed new]; feed1.itemId = @"102"; feed1.title = @"second"; feed1.id = @"999";
    Rss* rss10 = [Rss new]; rss10.title = @"jijo"; rss10.content = @"asdf家啊"; rss10.rssId = @"101";
    Rss* rss11 = [Rss new]; rss11.title = @"908jiad"; rss11.content = @"joidfaojdf90jjijiasasdf家啊"; rss11.rssId = @"102";
    Rss* rss12 = [Rss new]; rss12.title = @"0jjfda"; rss12.content = @"uoojo1加速iasasdf家啊"; rss12.rssId = @"103";
    Info* info1 = [Info new]; info1.id = 987891; info1.name = @"uaa"; info1.age = @(11); info1.height = 49.5;
    feed1.rsses = @[rss10, rss11, rss12]; feed1.infooo = info1;
    
    feedList = @[feed0, feed1];
}

- (IBAction)saveBtnPressed:(id)sender
{
//    if ([[TTDBManager shareInstance] insertData:feedList.firstObject]) {
//        NSLog(@"save OK");
//    }
//    else {
//        NSLog(@"save fail!");
//    }
    
    if ([[TTDBManager shareInstance] insertDatas:feedList]) {
        NSLog(@"save OK");
    }
    else {
        NSLog(@"save fail!");
    }
}

- (IBAction)updateBtnPressed:(id)sender
{
    NSDictionary* updateInfo = @{@"title":@"好好照顾自己，也学轻轻的睡去哈哈哈啥哈哈史蒂夫哈哈谁都会发生地方"};
    BOOL success = [[TTDBManager shareInstance] updateInTable:@"Feed" withUpdateInfo:updateInfo where:@"where itemId='101'"];
    if (success) {
        NSLog(@"update OK");
    }
    else {
        NSLog(@"update fail!");
    }
}

- (IBAction)queryBtnPressed:(id)sender
{
    NSArray* arr1 = [[TTDBManager shareInstance] queryFromTable:@"Feed" concernedColumns:nil where:nil];
    NSLog(@"%@", arr1.yy_modelDescription);
}

- (IBAction)deleteBtnPressed:(id)sender
{
    BOOL success = [[TTDBManager shareInstance] deleteFromTable:@"Feed" where:@"where itemId>'101' and id>'998'"];
    if (success) {
        NSLog(@"delete OK");
    }
    else {
        NSLog(@"delete fail!");
    }
}

@end

//
//  XWHomeViewController.m
//  DSTStarter
//
//  Created by 熊伟 on 2017/10/5.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "XWHomeViewController.h"
#import "XWServerManagerViewController.h"
#import "XWMainConfigViewController.h"
#import "XWWorldConfigViewController.h"
#import "XWModSettingViewController.h"
#import "Utils.h"


@interface XWHomeViewController ()
@property (weak) IBOutlet NSTabView *mainTabView;

@property (nonatomic, strong) XWMainConfigViewController *mainConfig;
@property (nonatomic, strong) XWServerManagerViewController *serverManager;
@property (nonatomic, strong) XWWorldConfigViewController *worldConfig;
@property (nonatomic, strong) XWModSettingViewController *modeSetting;

@end

@implementation XWHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * lastSaveSlot = [[NSUserDefaults standardUserDefaults] valueForKey:userDefaultSaveSlotKey];
    NSString * saveSlotPath = [Utils saveSlotPath:lastSaveSlot];
    NSData * serverConfigModelData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/ServerConfig.bear",saveSlotPath]];
    if (serverConfigModelData) {
        [[XWMainConfigurationModel defaultModel]loadFromLocalModel:[XWMainConfigurationModel yy_modelWithJSON:serverConfigModelData]];
    }

    //基本设置
    NSTabViewItem *basicSettingWindow = [self.mainTabView.tabViewItems objectAtIndex:0];
    self.mainConfig = [[XWMainConfigViewController alloc] initWithNibName:@"XWMainConfigViewController" bundle:nil];
    [basicSettingWindow setView:self.mainConfig.view];
    
    //基本设置
    NSTabViewItem *worldSettingWindow = [self.mainTabView.tabViewItems objectAtIndex:1];
    self.worldConfig = [[XWWorldConfigViewController alloc] initWithNibName:@"XWWorldConfigViewController" bundle:nil];
    [worldSettingWindow setView:self.worldConfig.view];

    //模组设置
    NSTabViewItem *modSettingWindow = [self.mainTabView.tabViewItems objectAtIndex:2];
    self.modeSetting = [[XWModSettingViewController alloc]initWithNibName:@"XWModSettingViewController" bundle:nil];
    [modSettingWindow setView:self.modeSetting.view];
    
    //服务器管理
    NSTabViewItem *serverManagerWindow = [self.mainTabView.tabViewItems objectAtIndex:3];
    self.serverManager = [[XWServerManagerViewController alloc] initWithNibName:@"XWServerManagerViewController" bundle:nil];
    [serverManagerWindow setView:self.serverManager.view];
    
    
}

@end

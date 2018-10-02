//
//  AppDelegate.m
//  DSTStarter
//
//  Created by 熊伟 on 2017/10/5.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "AppDelegate.h"
#import "XWHomeViewController.h"
#import "XWMainConfigurationModel.h"
#import "Utils.h"


@interface AppDelegate ()
@property (nonatomic, strong) NSWindowController *rootWindowController;
@property (nonatomic, strong) NSWindow *rootWindow;
@property (nonatomic, strong) XWHomeViewController *homeViewController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.homeViewController = [[XWHomeViewController alloc]initWithNibName:@"XWHomeViewController" bundle:[NSBundle mainBundle]];
    self.rootWindow = [NSWindow windowWithContentViewController:self.homeViewController];
    [self.rootWindow makeKeyWindow];
    _rootWindow.title = @"BearDSTStarter";
    self.rootWindowController = [[NSWindowController alloc]initWithWindow:self.rootWindow];
    [self.rootWindowController showWindow:nil];
}

-(void)applicationWillTerminate:(NSNotification *)notification {
    //保存最后使用的存档名
    NSString * currentSaveSlot = [[XWMainConfigurationModel defaultModel] saveSlotName];
    [[NSUserDefaults standardUserDefaults] setObject:currentSaveSlot forKey:userDefaultSaveSlotKey];
    //将配置模型存到本地
    NSData * data = [[XWMainConfigurationModel defaultModel] yy_modelToJSONData];
    [data writeToFile:[NSString stringWithFormat:@"%@/ServerConfig.bear",Utils.currentSaveSlotPath] atomically:YES];
}


@end

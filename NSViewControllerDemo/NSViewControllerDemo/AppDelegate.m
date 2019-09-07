//
//  AppDelegate.m
//  NSViewControllerDemo
//
//  Created by 熊伟 on 2019/9/7.
//  Copyright © 2019 熊伟. All rights reserved.
//

#import "AppDelegate.h"
#import "FJViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) FJViewController *homeVC;
@property (nonatomic, strong) NSWindow * rootWindow;
@property (nonatomic, strong) NSWindowController *rootWindowController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    // self define init
    self.homeVC = [[FJViewController alloc] initWithFrame:NSMakeRect(100, 100, 500, 500)];
//    self.homeVC.view;
    
    // supe init
//    self.homeVC = [FJViewController new];
//    self.homeVC.view;
//    self.homeVC.view;
//    self.homeVC.view;
//    NSView * vcView = [[NSView alloc] initWithFrame:NSMakeRect(100, 100, 500, 500)];
//    self.homeVC.view = vcView;
    
    self.rootWindow = [NSWindow windowWithContentViewController:self.homeVC];
    self.rootWindowController = [[NSWindowController alloc] initWithWindow:self.rootWindow];
    
    [self.rootWindow makeKeyWindow];
    self.rootWindow.title = @"Bearger";
    [self.rootWindow center];
    [self.rootWindowController showWindow:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end

//
//  AppDelegate.m
//  MenuDemo
//
//  Created by 熊伟 on 2019/9/5.
//  Copyright © 2019 熊伟. All rights reserved.
//

#import "AppDelegate.h"
#import "FJViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) FJViewController *homeVC;
@property (nonatomic, strong) NSWindow * rootWindow;
@property (nonatomic, strong) NSWindowController *rootWindowController;
@property (nonatomic, strong) NSStatusItem * statusItem;

@property (nonatomic, strong) NSPopover *popover;
@end

@implementation AppDelegate
- (IBAction)testClick:(id)sender {
    
    NSLog(@"hello bearger");
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.image = [NSImage imageNamed:@"statuBarIcon"];
    self.statusItem.button.toolTip = @"statusItem";
    self.statusItem.button.highlighted = YES;
    [self.statusItem.button setAction:@selector(popoverSwitch)];
    
    NSMenu *subMenu = [[NSMenu alloc] initWithTitle:@"Load_TEXT"];
    [subMenu addItemWithTitle:@"Load1"action:@selector(click:) keyEquivalent:@"E"];
    [subMenu addItemWithTitle:@"Load2"action:@selector(click:) keyEquivalent:@"R"];
    self.statusItem.menu = subMenu;
    
//    if (!_popover) {
//        _popover = [[NSPopover alloc] init];
//        _popover.contentViewController = [[FJViewController alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
//        _popover.behavior = NSPopoverBehaviorApplicationDefined;
//        [_popover setAnimates:NO];
//    }
    
    [self.popover showRelativeToRect:NSZeroRect ofView:self.statusItem.button preferredEdge:NSRectEdgeMinY];
    
    
    self.homeVC = [[FJViewController alloc] initWithFrame:NSMakeRect(100, 100, 500, 500)];
    
    self.rootWindow = [NSWindow windowWithContentViewController:self.homeVC];
    self.rootWindowController = [[NSWindowController alloc]initWithWindow:self.rootWindow];
    
    [self.rootWindow makeKeyWindow];
    self.rootWindow.title = @"Menu Lab";
    [self.rootWindow center];
    [self.rootWindowController showWindow:nil];
    
}

-(void)popoverSwitch {
    if (_popover.isShown) {
        [_popover close];
    }
    else {
        [self.popover showRelativeToRect:NSZeroRect ofView:self.statusItem.button preferredEdge:NSRectEdgeMinY];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


-(NSMenu *)applicationDockMenu:(NSApplication *)sender {
    NSMenu * menu = [[NSMenu alloc]initWithTitle:@"Menu"];
    NSMenuItem * item1 = [[NSMenuItem alloc]initWithTitle:@"菜单1"
                                                   action:@selector(click:)
                                            keyEquivalent:@""];
    item1.target = self;
    
    NSMenuItem * item2 = [[NSMenuItem alloc]initWithTitle:@"菜单2"
                                                   action:@selector(click:)
                                            keyEquivalent:@""];
    item2.target = self;
    
    NSMenuItem * item3 = [[NSMenuItem alloc]initWithTitle:@"菜单3"
                                                   action:@selector(click:)
                                            keyEquivalent:@""];
    
    NSMenu * subMenu = [[NSMenu alloc]initWithTitle:@"subMenu"];
    NSMenuItem * item31 = [[NSMenuItem alloc]initWithTitle:@"菜单31"
                                                    action:@selector(click:)
                                             keyEquivalent:@""];
    item31.target = self;
    
    [subMenu addItem:item31];
    NSMenuItem * item32 = [[NSMenuItem alloc]initWithTitle:@"菜单32"
                                                    action:@selector(click:)
                                             keyEquivalent:@""];
    item32.target = self;
    
    [subMenu addItem:item32];
    
    [menu addItem:item1];
    [menu addItem:item2];
    [menu addItem:item3];
    [menu setSubmenu:subMenu forItem:item3];
    return menu;
}

-(void)click:(NSMenu*)sender {
    NSLog(@"%@", sender.title);
}


@end

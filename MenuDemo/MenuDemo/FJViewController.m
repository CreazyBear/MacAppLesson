//
//  FJViewController.m
//  MenuDemo
//
//  Created by 熊伟 on 2019/9/5.
//  Copyright © 2019 熊伟. All rights reserved.
//

#import "FJViewController.h"

@interface FJViewController ()
@property (nonatomic, strong) NSView *subView;
@end

@implementation FJViewController

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super init];
    if (self) {
        NSView * vcView = [[NSView alloc] initWithFrame:frame];
        self.view = vcView;
        
        NSMenu * menu = [[NSMenu alloc]initWithTitle:@"Menu"];
        NSMenuItem * item1 = [[NSMenuItem alloc]initWithTitle:@"菜单1" action:@selector(click:) keyEquivalent:@""];
        item1.target = self;
        NSMenuItem * item2 = [[NSMenuItem alloc]initWithTitle:@"菜单2" action:@selector(click:) keyEquivalent:@""];
        item2.target = self;
        NSMenuItem * item3 = [[NSMenuItem alloc]initWithTitle:@"菜单3" action:@selector(click:) keyEquivalent:@""];
        NSMenu * subMenu = [[NSMenu alloc]initWithTitle:@"subMenu"];
        NSMenuItem * item4 = [[NSMenuItem alloc]initWithTitle:@"菜单4" action:@selector(click:) keyEquivalent:@""];
        item4.target = self;
        [subMenu addItem:item4];
        [menu addItem:item1];
        [menu addItem:item2];
        [menu addItem:item3];
        [menu setSubmenu:subMenu forItem:item3];
        [self.view setMenu:menu];
    }
    return self;
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    
    self.subView = [[NSView alloc] initWithFrame:NSMakeRect(10, 10, 50, 50)];
    [self.subView setWantsLayer:YES];
    self.subView.layer.backgroundColor = [NSColor redColor].CGColor;

    
    NSMenu * menu = [[NSMenu alloc]initWithTitle:@"Menu"];
    NSMenuItem * item1 = [[NSMenuItem alloc]initWithTitle:@"菜单1111" action:@selector(click:) keyEquivalent:@""];
    item1.target = self;
    NSMenuItem * item2 = [[NSMenuItem alloc]initWithTitle:@"菜单2111" action:@selector(click:) keyEquivalent:@""];
    item2.target = self;
    NSMenuItem * item3 = [[NSMenuItem alloc]initWithTitle:@"菜单3111" action:@selector(click:) keyEquivalent:@""];
    NSMenu * subMenu = [[NSMenu alloc]initWithTitle:@"subMenu"];
    NSMenuItem * item4 = [[NSMenuItem alloc]initWithTitle:@"菜单4111" action:@selector(click:) keyEquivalent:@""];
    item4.target = self;
    [subMenu addItem:item4];
    [menu addItem:item1];
    [menu addItem:item2];
    [menu addItem:item3];
    [menu setSubmenu:subMenu forItem:item3];
    [self.subView setMenu:menu];
    [self.view addSubview:self.subView];
}

-(void)viewDidAppear {
    [super viewDidAppear];
}

-(void)viewDidDisappear {
    [super viewDidDisappear];
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)click:(NSMenu*)sender {
    NSLog(@"%@", sender.title);
}


@end

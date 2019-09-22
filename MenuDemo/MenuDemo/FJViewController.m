//
//  FJViewController.m
//  MenuDemo
//
//  Created by 熊伟 on 2019/9/5.
//  Copyright © 2019 熊伟. All rights reserved.
//

#import "FJViewController.h"

@interface FJViewController ()<NSToolbarDelegate>
@property (nonatomic, strong) NSView *subView;
@end

@implementation FJViewController

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super init];
    if (self) {
//        NSView * vcView = [[NSView alloc] initWithFrame:frame];
//        self.view = vcView;
        
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
    
    [self setUpToolbar];
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

-(void)loadView {
    NSView * vcView = [[NSView alloc] initWithFrame:NSMakeRect(10, 10, 500, 500)];
    self.view = vcView;
}

-(void)click:(NSMenu*)sender {
    NSLog(@"%@", sender.title);
}

- (void)setUpToolbar {
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"AppToolbar"];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setAutosavesConfiguration:NO];
    [toolbar setDisplayMode:NSToolbarDisplayModeLabelOnly];
    [toolbar setSizeMode:NSToolbarSizeModeSmall];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [self.view.window setToolbar:toolbar];
}

#pragma mark - NSToolbarDelegate
//所有的item 标识
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return @[@"FontSetting",@"Save"];
}

//实际显示的item 标识
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return @[@"FontSetting",@"Save"];
}

//根据item 标识 返回每个具体的NSToolbarItem对象实例

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    
    NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    
    if ([itemIdentifier isEqualToString:@"FontSetting"]) {
        [toolbarItem setLabel:@"Font"];
        [toolbarItem setPaletteLabel:@"Font"];
        [toolbarItem setToolTip:@"Font Setting"];
        [toolbarItem setImage:[NSImage imageNamed:@"FontSetting"]];
        toolbarItem.tag = 1;
        
    }
    else if ([itemIdentifier isEqualToString:@"Save"]) {
        [toolbarItem setLabel:@"Save"];
        [toolbarItem setPaletteLabel:@"Save"];
        [toolbarItem setToolTip:@"Save File"];
        [toolbarItem setImage:[NSImage imageNamed:@"Save"]];
        toolbarItem.tag = 2;
    }
    else {
        toolbarItem = nil;
    }
    
    [toolbarItem setMinSize:CGSizeMake(25, 25)];
    [toolbarItem setMaxSize:CGSizeMake(100, 100)];
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(toolbarItemClicked:)];
    return toolbarItem;
}

-(void)toolbarItemClicked:(id)sender {
    
}



@end

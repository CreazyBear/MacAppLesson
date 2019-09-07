//
//  FJRootViewController.m
//  NSViewControllerDemo
//
//  Created by 熊伟 on 2019/9/7.
//  Copyright © 2019 熊伟. All rights reserved.
//

#import "FJViewController.h"

@interface FJViewController ()<NSTableViewDelegate,NSTableViewDataSource>
@property (nonatomic, assign) CGRect initFrame;
@property (nonatomic, strong) NSTableView *tableView;
@end

@implementation FJViewController

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super init];
    if (self) {
        self.initFrame = frame;
    }
    return self;
}

- (void)loadView {
    if (CGRectIsNull(self.initFrame) || CGRectIsEmpty(self.initFrame) || CGRectIsInfinite(self.initFrame)) {
        self.initFrame = CGRectMake(0, 0, 100, 100);
    }
    NSView * vcView = [[NSView alloc] initWithFrame:self.initFrame];
    self.view = vcView;
    
    NSScrollView * tableContainer = [[NSScrollView alloc] initWithFrame:self.view.bounds];
    self.tableView = [[NSTableView alloc] initWithFrame:self.view.bounds];
    NSTableColumn * column1 = [[NSTableColumn alloc] initWithIdentifier:@"Col1"];
    [column1 setWidth:self.view.frame.size.width];
    [self.tableView addTableColumn:column1];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [tableContainer setDocumentView:self.tableView];
    [tableContainer setHasVerticalScroller:YES];
    [self.view addSubview:tableContainer];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear {
    [super viewWillAppear];
}

-(void)viewDidAppear {
    [super viewDidAppear];
}

-(void)viewWillDisappear {
    [super viewWillDisappear];
}

-(void)viewDidDisappear {
    [super viewDidDisappear];
}

#pragma mark - NSTableViewDelegate,NSTableViewDataSource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 111;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSView * v = [tableView makeViewWithIdentifier:NSStringFromClass(self.class) owner:self];
    if (!v) {
        v = [NSView new];
    }
    NSTextField * t = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, self.view.frame.size.width, 20)];
    t.textColor = [NSColor blackColor];
    t.stringValue = [NSString stringWithFormat:@"%ld",row];
    [v addSubview:t];
    return v;
}

@end

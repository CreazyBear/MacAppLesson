//
//  AppDelegate.m
//  CBGClipboard
//
//  Created by Bear on 2017/8/23.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "AppDelegate.h"
#import "CBGPasteboardItem.h"
#import "CBGPasteboardHelper.h"
#import <CoreData/CoreData.h>
#import "CBGDateBaseManager.h"
#import "NSDate+Utilities.h"
#import "CBGPreferenceController.h"
#import "CBGPreferenceViewController.h"
#import "NSTimer+CBGExtension.h"
#import "CBGFileManager.h"
#import "NSImage+CBGExtension.h"
#import <ServiceManagement/ServiceManagement.h>


@interface AppDelegate ()

@property (weak) IBOutlet NSMenu *menu;

@property (strong, nonatomic) NSStatusItem *statusBar;

@property (nonatomic, strong) NSPasteboard * pboard;

@property (nonatomic, strong) NSTimer * timer;

@property (strong, nonatomic) NSMutableArray<CBGPasteboardItem*> * pasteboardItemsArray;

@property (nonatomic, strong) NSPasteboardItem *lastPasteboardItemTemp;

@property (nonatomic, strong) CBGPreferenceController *preferenceController;

@property (nonatomic, strong) CBGPreferenceViewController *preferenceViewController;

@property (nonatomic, assign) NSInteger maxCount;

@property (nonatomic, assign) NSInteger showTime;

@property (nonatomic, assign) NSInteger fontSize;

@property (nonatomic, assign) NSInteger MaxVisibleChars;

@end

@implementation AppDelegate


#pragma mark - AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupDBManager];
    [self setupStatueBar];
    [self setupPasteBoard];
    [self setupInitData];
    [self setupInitMenuItems];
    [self setupObserverTimer];
    [self setupNotificationCenter];
    [self promptToAddLoginItems];
    
}



- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - getter and setter
-(NSMutableArray<CBGPasteboardItem *> *)pasteboardItemsArray
{
    if (!_pasteboardItemsArray) {
        _pasteboardItemsArray = [NSMutableArray array];
    }
    return _pasteboardItemsArray;
}

#pragma mark - setup
-(void)setupNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMaxCountChangeNotification:)
                                                 name:CBGMAXCOUNTCHANGENOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleShowTimeChangeNotification:)
                                                 name:CBGSHOWTIMECHANGENOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleClearDataNotification:)
                                                 name:CBGCLEARDATANOTIFICATION
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleChangeFontSize:)
                                                 name:CBGCHANGEFONTSIZENOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleChangeLineCharNum:)
                                                 name:CBGCHANGELINECHARATORNUMNOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleStartLaunch:)
                                                 name:CBGSTARTLAUNCHNOTIFICATION
                                               object:nil];
}

-(void)promptToAddLoginItems
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"CBGClipboardFirstLaunch"])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"CBGClipboardFirstLaunch"];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"开机启动CBG？"];
        [alert setInformativeText:@"您可以设置中修改。"];
        [alert addButtonWithTitle:@"好的"];
        [alert addButtonWithTitle:@"不用了"];
        NSInteger answer = [alert runModal];
        if (answer == NSAlertSecondButtonReturn)
        {
            if (!SMLoginItemSetEnabled((__bridge CFStringRef)@"com.crazybear.CBGClipboardHelper", NO)) {
                NSLog(@"Setting Was Not Successful");
            }
        }
        else if(answer == NSAlertFirstButtonReturn)
        {
            if (!SMLoginItemSetEnabled((__bridge CFStringRef)@"com.crazybear.CBGClipboardHelper", YES)) {
                NSLog(@"Setting Was Not Successful");
            }
        }
    }
}


-(void)setupInitData
{
    [CBGFileManager createCBGDocument];
    
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    [defaultValues setValue:[NSNumber numberWithInteger:13] forKey:CBGFONTSIZE];
    [defaultValues setValue:[NSNumber numberWithInteger:60] forKey:CBGLINECHARATORNUM];
    [defaultValues setValue:[NSNumber numberWithInteger:10] forKey:CBGMAXCOUNT];
    [defaultValues setValue:[NSNumber numberWithInteger:1] forKey:CBGSHOWTIME];
    [defaultValues setValue:[NSNumber numberWithInteger:0] forKey:CBGSTARTLAUNCH];
    [defaultValues setValue:[NSNumber numberWithInteger:1] forKey:@"CBGClipboardFirstLaunch"];
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];

    self.maxCount = [[NSUserDefaults standardUserDefaults] integerForKey:CBGMAXCOUNT];
    self.showTime = [[NSUserDefaults standardUserDefaults] integerForKey:CBGSHOWTIME];
    self.fontSize = [[NSUserDefaults standardUserDefaults] integerForKey:CBGFONTSIZE];
    self.MaxVisibleChars = [[NSUserDefaults standardUserDefaults] integerForKey:CBGLINECHARATORNUM];
    self.pasteboardItemsArray = [[CBGDateBaseManager sharedInstance]fetchPasteboardItemWithMaxCount:self.maxCount];
}

-(void)setupInitMenuItems
{
    NSInteger orginMenuItemCount = self.menu.itemArray.count;
    for (int i = 0 ; i < orginMenuItemCount - 3; i++) {
        [self.menu removeItemAtIndex:0];
    }
    [self.pasteboardItemsArray enumerateObjectsUsingBlock:^(CBGPasteboardItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addMenuItem:obj atIndex:self.menu.itemArray.count - 3];
    }];
}


-(void)setupDBManager
{
    [CBGDateBaseManager sharedInstance];
}


-(void)setupStatueBar
{
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusBar.title = @"CBG";
    self.statusBar.menu = self.menu;
    self.statusBar.highlightMode = YES;
}

-(void)setupPasteBoard
{
    self.pboard = [NSPasteboard generalPasteboard];
}

-(void)setupObserverTimer
{
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self.timer fire];
}

#pragma mark - action
-(void)handleStartLaunch:(NSNotification*)notify
{
     NSInteger startLaunchOption = [[[notify userInfo] objectForKey:CBGSTARTLAUNCH] integerValue];
    if (startLaunchOption == 0)
    {
        if (!SMLoginItemSetEnabled((__bridge CFStringRef)@"com.crazybear.CBGClipboardHelper", NO)) {
            NSLog(@"Setting Was Not Successful");
        }
    }
    else
    {
        if (!SMLoginItemSetEnabled((__bridge CFStringRef)@"com.crazybear.CBGClipboardHelper", YES)) {
            NSLog(@"Setting Was Not Successful");
        }
    }
}

-(void)handleChangeFontSize:(NSNotification*)notify
{
    self.fontSize = [[[notify userInfo] objectForKey:CBGFONTSIZE] integerValue];
    [self setupInitMenuItems];

}

-(void)handleChangeLineCharNum:(NSNotification*)notify
{
    self.MaxVisibleChars = [[[notify userInfo] objectForKey:CBGLINECHARATORNUM] integerValue];
    [self setupInitMenuItems];

}


-(void)handleClearDataNotification:(NSNotification*)notify
{
    [self.timer pause];
    [self.pasteboardItemsArray removeAllObjects];
    for (NSInteger i = self.menu.itemArray.count-4 ; i >= 0; i--) {
        [self.menu removeItemAtIndex:i];
    }
    [self.timer play];

}

-(void)handleShowTimeChangeNotification:(NSNotification*)notify
{
    self.showTime = [[[notify userInfo] objectForKey:CBGSHOWTIME] integerValue];
    [self setupInitMenuItems];
}


-(void)handleMaxCountChangeNotification:(NSNotification*)notify
{
    NSNumber * maxCount = [[notify userInfo] objectForKey:CBGMAXCOUNT];
    NSInteger maxCountInt = maxCount.integerValue;
    self.maxCount = maxCountInt;
    if (self.pasteboardItemsArray.count > maxCountInt)
    {
        [self.timer pause];
        [self.pasteboardItemsArray removeObjectsInRange:NSMakeRange(maxCountInt, self.pasteboardItemsArray.count-maxCountInt)];
        for (NSInteger i = self.menu.itemArray.count-4 ; i > self.menu.itemArray.count-4-maxCountInt; i--) {
            [self.menu removeItemAtIndex:i];
        }
        [self.timer play];
    }
    else
    {
        self.pasteboardItemsArray = [[CBGDateBaseManager sharedInstance]fetchPasteboardItemWithMaxCount:self.maxCount];
        [self setupInitMenuItems];
    }
}

- (IBAction)showPreferencePanel:(id)sender
{
    // Is preferenceController nil?
    if (!_preferenceController) {
        
        CBGPreferenceViewController * vc = [[CBGPreferenceViewController alloc]initWithNibName:@"CBGPreferenceViewController" bundle:nil];
        _preferenceController = [[CBGPreferenceController alloc] initWithWindowNibName:@"CBGPreferenceController"];
        [_preferenceController setContentViewController:vc];
    }
    [_preferenceController showWindow:self];
}


- (void)timerFire:(id)sender
{
    NSPasteboardItem * pboardItem = [[_pboard pasteboardItems] lastObject];
    if (!_lastPasteboardItemTemp || _lastPasteboardItemTemp != pboardItem)
    {
        if (!pboardItem)
        {
            return;
        }
        _lastPasteboardItemTemp = pboardItem;
        CBGPasteboardItem * item = [CBGPasteboardHelper transferNSPasteboard];
        if ([item.type isEqualToString: NSPasteboardTypeString]) {
            if([item.content isEqualToString:self.pasteboardItemsArray.firstObject.content])
            {
                return;
            }
        }
        
        [self.pasteboardItemsArray insertObject:item atIndex:0];
        [[CBGDateBaseManager sharedInstance]savePasteboardItem:item];
        [self addMenuItem:item atIndex:0];
        
        if (self.pasteboardItemsArray.count > self.maxCount)
        {
            [self.pasteboardItemsArray removeLastObject];
            [self.menu removeItemAtIndex:self.menu.itemArray.count-4];
        }
    }
}


- (void)addMenuItem:(CBGPasteboardItem *) item atIndex:(NSInteger)index
{
    
    NSMenuItem * menuItem = [[NSMenuItem alloc] initWithTitle:@"" action:@selector(menuItemSelect:) keyEquivalent:@""];
    [self.menu insertItem:menuItem atIndex:index];
    [menuItem setToolTip:item.content];
    NSDate * time = item.time;
    NSString * content = item.content;
    NSString * type = item.type;
    
    NSString * timeStr = nil;
    NSString * hourFormat = time.hour>9 ? @"%ld" : @"0%ld";
    NSString * dayFormat = time.day>9 ? @"%ld" : @"0%ld";
    NSString * minuteFormat = time.minute>9 ? @"%ld" : @"0%ld";
    NSString * monthFormat = time.month>9 ? @"%ld" : @"0%ld";
    NSString * yearFormat = time.year>9 ? @"%ld" : @"0%ld";
    
    if ([time isToday])
    {
        NSString * formatter = [NSString stringWithFormat:@"%@:%@",hourFormat,minuteFormat];
        timeStr = [NSString stringWithFormat:formatter,time.hour,time.minute];
    }
    else if([time isThisMonth])
    {
        NSString * formatter = [NSString stringWithFormat:@"%@:%@",dayFormat,hourFormat];
        timeStr = [NSString stringWithFormat:formatter,time.day,time.hour];
    }
    else if([time isThisYear])
    {
        NSString * formatter = [NSString stringWithFormat:@"%@:%@",monthFormat,dayFormat];
        timeStr = [NSString stringWithFormat:formatter,time.month,time.day];
    }
    else
    {
        NSString * formatter = [NSString stringWithFormat:@"%@:%@",yearFormat,monthFormat];
        timeStr = [NSString stringWithFormat:formatter,time.year,time.month];
    }
    
    dispatch_block_t setMenuPropsBlock = ^{
        NSString * stringContent = (NSString*)content;
        NSString * stringDetail = [content substringToIndex:MIN(self.MaxVisibleChars,stringContent.length)];
        if (!stringDetail || stringDetail.length <= 0 ) {
            stringDetail = @"【图片】";
        }
        NSString * stringTail = (stringContent.length <= self.MaxVisibleChars) ? @"" : @"...";
        if (self.showTime)
        {
            menuItem.title = [NSString stringWithFormat:@"【%@】 %@%@", timeStr, stringDetail, stringTail];
        }
        else
        {
            menuItem.title = [NSString stringWithFormat:@" %@%@", stringDetail, stringTail];
        }
        
        NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc]initWithString:menuItem.title];
        [attributeString addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:self.fontSize] range:NSMakeRange(0, menuItem.title.length)];
        [menuItem setAttributedTitle:attributeString];
    
    };
    
    
    if ([type isEqualToString:NSPasteboardTypeString])
    {
        setMenuPropsBlock();
    }
    else if([type isEqualToString:NSPasteboardTypeCBGImage])
    {
        setMenuPropsBlock();
        if (item.contentUrls && item.contentUrls.count > 0)
        {
            NSString * imgPathString = item.contentUrls[0];
            NSData * imageData = [NSData dataWithContentsOfFile:imgPathString];
            NSImage * image = [[NSImage alloc]initWithData:imageData];
            image = [image imageWithTargetHeight:100];
            [menuItem setImage:image];
        }
    }
}


- (void)menuItemSelect:(id)sender
{
    NSInteger selectedIndex = [self.menu.itemArray indexOfObject:sender];
    CBGPasteboardItem * selectedItem = [self.pasteboardItemsArray objectAtIndex:selectedIndex];
    [self.pasteboardItemsArray removeObjectAtIndex:selectedIndex];
    [[CBGDateBaseManager sharedInstance]deleteItem:selectedItem];
    [self.menu removeItemAtIndex:selectedIndex];
    NSPasteboard * pboard = [NSPasteboard generalPasteboard];
    [pboard clearContents];
    if ([selectedItem.type isEqualToString: NSPasteboardTypeString])
    {
        NSPasteboardItem * pboardItem = [[NSPasteboardItem alloc] init];
        NSString * strContent = selectedItem.content;
        [pboardItem setString:strContent forType:NSPasteboardTypeString];
        [pboard writeObjects:@[pboardItem]];
    }
    else if([selectedItem.type isEqualToString:NSPasteboardTypeCBGPath] ||
            [selectedItem.type isEqualToString:NSPasteboardTypeMIX])
    {
        NSPasteboardItem * pboardItem = [[NSPasteboardItem alloc] init];
        NSString * strContent = [selectedItem.contentUrls componentsJoinedByString:@"\r"];
        [pboardItem setString:strContent forType:NSPasteboardTypeString];
        [pboard writeObjects:@[pboardItem]];
    }
    else if([selectedItem.type isEqualToString:NSPasteboardTypeCBGImage])
    {
        if (selectedItem.contentUrls && selectedItem.contentUrls.count == 1)
        {
            NSPasteboardItem * pboardItem = [[NSPasteboardItem alloc] init];
            NSData * imageData = [NSData dataWithContentsOfFile:selectedItem.contentUrls[0]];
            [pboardItem setData:imageData  forType:NSPasteboardTypePNG];
            [pboard writeObjects:@[pboardItem]];
        }
        else
        {
            NSPasteboardItem * pboardItem = [[NSPasteboardItem alloc] init];
            NSString * strContent = [selectedItem.contentUrls componentsJoinedByString:@"\r"];
            [pboardItem setString:strContent forType:NSPasteboardTypeString];
            [pboard writeObjects:@[pboardItem]];
        }
    }

}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    
    NSManagedObjectContext *context = [CBGDateBaseManager sharedInstance].persistentContainer.viewContext;
    if (![context commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (!context.hasChanges) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![context save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertSecondButtonReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}



@end

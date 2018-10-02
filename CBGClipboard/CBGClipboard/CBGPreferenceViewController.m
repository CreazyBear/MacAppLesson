//
//  CBGPreferenceViewController.m
//  CBGClipboard
//
//  Created by 熊伟 on 2017/8/26.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "CBGPreferenceViewController.h"
#import "CBGDateBaseManager.h"

NSString * const CBGMAXCOUNTCHANGENOTIFICATION = @"CBGMAXCOUNTCHANGENOTIFICATION";
NSString * const CBGSHOWTIMECHANGENOTIFICATION = @"CBGSHOWTIMECHANGENOTIFICATION";
NSString * const CBGCLEARDATANOTIFICATION = @"CBGCLEARDATANOTIFICATION";
NSString * const CBGCHANGEFONTSIZENOTIFICATION = @"CBGCHANGEFONTSIZENOTIFICATION";
NSString * const CBGCHANGELINECHARATORNUMNOTIFICATION = @"CBGCHANGELINECHARATORNUMNOTIFICATION";
NSString * const CBGSTARTLAUNCHNOTIFICATION = @"CBGSTARTLAUNCHNOTIFICATION";

NSString * const CBGMAXCOUNT = @"maxCountNumber";
NSString * const CBGSHOWTIME = @"CBGSHOWTIME";
NSString * const CBGFONTSIZE = @"CBGFONTSIZE";
NSString * const CBGLINECHARATORNUM = @"CBGLINECHARATORNUM";
NSString * const CBGSTARTLAUNCH =  @"CBGSTARTLAUNCH";

@interface CBGPreferenceViewController ()<NSTextFieldDelegate>
@property (weak) IBOutlet NSButton *showTimeCheckBox;
@property (weak) IBOutlet NSButton *startLaunchCheckbox;
@property (weak) IBOutlet NSTextField *maxCountTextField;
@property (weak) IBOutlet NSSlider *fontSizeSlider;
@property (weak) IBOutlet NSSlider *lineCharatorNumSlider;

@end

@implementation CBGPreferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSInteger maxCount = [[NSUserDefaults standardUserDefaults] integerForKey:CBGMAXCOUNT];
    [self.maxCountTextField setStringValue:[NSString stringWithFormat:@"%ld",maxCount]];
    
    NSInteger showTimeState = [[NSUserDefaults standardUserDefaults] integerForKey:CBGSHOWTIME];
    [self.showTimeCheckBox setState:showTimeState];
    
    NSInteger startLaunchState = [[NSUserDefaults standardUserDefaults] integerForKey:CBGSTARTLAUNCH];
    [self.startLaunchCheckbox setState:startLaunchState];
    
    
}

-(void)viewWillDisappear
{
    NSInteger maxCount = [_maxCountTextField.stringValue integerValue];
    if (maxCount < 10)
    {
        maxCount = 10;
    }
    else if (maxCount > 100)
    {
        maxCount = 100;
    }
    [self.maxCountTextField setStringValue:[NSString stringWithFormat:@"%ld",maxCount]];
    NSDictionary * data = @{CBGMAXCOUNT:[NSNumber numberWithInteger:maxCount]};
    [[NSNotificationCenter defaultCenter] postNotificationName:CBGMAXCOUNTCHANGENOTIFICATION object:self userInfo:data];
    NSInteger oldMaxCount = [[NSUserDefaults standardUserDefaults] integerForKey:CBGMAXCOUNT];
    if (oldMaxCount == maxCount) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:maxCount forKey:CBGMAXCOUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)controlTextDidChange:(NSNotification *)obj
{
    NSString * textContent = self.maxCountTextField.stringValue;
    if (!textContent || textContent.length == 0) {
        return;
    }
    if ([textContent hasPrefix:@"0"]) {
        [self showAlert];
        return;
    }
    NSRegularExpression * expression = [[NSRegularExpression alloc]initWithPattern:@"[1-9]+"
                                                                           options:(NSRegularExpressionCaseInsensitive)
                                                                             error:nil];
    NSTextCheckingResult * result =  [expression firstMatchInString:textContent options:NSMatchingWithTransparentBounds range:NSMakeRange(0, textContent.length)];
    
    if (!result || NSEqualRanges(result.range, NSMakeRange(NSNotFound, 0))) {
        [self showAlert];
        [self.maxCountTextField setStringValue:@""];
        return;
    }
    
}



-(void)showAlert
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"~敬告~"];
    [alert setInformativeText:@"请输入数字，大小在10到100之间"];
    [alert addButtonWithTitle:@"知道了"];
    [alert runModal];
}

- (IBAction)changeStartLaunch:(id)sender {
    NSInteger state = [self.startLaunchCheckbox state];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:CBGSTARTLAUNCH] == state) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:state forKey:CBGSTARTLAUNCH];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSDictionary * data = @{CBGSTARTLAUNCH:[NSNumber numberWithInteger:state]};
    [[NSNotificationCenter defaultCenter] postNotificationName:CBGSTARTLAUNCHNOTIFICATION object:self userInfo:data];
}

- (IBAction)changeShowTime:(id)sender {
    
    NSInteger state = [self.showTimeCheckBox state];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:CBGSHOWTIME] == state) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:state forKey:CBGSHOWTIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSDictionary * data = @{CBGSHOWTIME:[NSNumber numberWithInteger:state]};
    [[NSNotificationCenter defaultCenter] postNotificationName:CBGSHOWTIMECHANGENOTIFICATION object:self userInfo:data];

}
- (IBAction)changeFontSize:(id)sender {
    NSInteger fontSize = self.fontSizeSlider.integerValue;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:CBGFONTSIZE] == fontSize) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:fontSize forKey:CBGFONTSIZE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSDictionary * data = @{CBGFONTSIZE:[NSNumber numberWithInteger:fontSize]};
    [[NSNotificationCenter defaultCenter] postNotificationName:CBGCHANGEFONTSIZENOTIFICATION
                                                        object:self
                                                      userInfo:data];
}

- (IBAction)changeLineCharactorNum:(id)sender
{
    NSInteger lineCharNum = self.lineCharatorNumSlider.integerValue;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:CBGLINECHARATORNUM] == lineCharNum) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:lineCharNum forKey:CBGLINECHARATORNUM];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSDictionary * data = @{CBGLINECHARATORNUM:[NSNumber numberWithInteger:lineCharNum]};
    [[NSNotificationCenter defaultCenter] postNotificationName:CBGCHANGELINECHARATORNUMNOTIFICATION
                                                        object:self
                                                      userInfo:data];
}

- (IBAction)clearAllHistoryData:(id)sender
{
    [[CBGDateBaseManager sharedInstance]deleteAllItems];
    [[NSNotificationCenter defaultCenter] postNotificationName:CBGCLEARDATANOTIFICATION object:self userInfo:nil];
}

@end

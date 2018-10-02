//
//  XWWorldConfigViewController.m
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/9.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import "XWWorldConfigViewController.h"
#import "XWMainConfigurationModel.h"
#import "XWWorldSettingRowModel.h"
#import "NSString+Extension.h"
#import <MLHudAlert.h>
#import "Utils.h"
#import "XWWorldSettingSelectionCell.h"

@interface XWWorldConfigViewController ()<XWWorldSettingSelectionCellDelegate>
@property (weak) IBOutlet NSTableView *worldList;
@property (weak) IBOutlet NSTableView *settingList;

@property (nonatomic, strong) NSMutableArray<XWWorldSettingRowModel*> *forestSettings;
@property (nonatomic, strong) NSMutableArray<XWWorldSettingRowModel*> *caveSettings;

@property (nonatomic, strong) XWWorldListManager *worldListManager;
@property (nonatomic, strong) XWSettingListManager *settingManager;

@property (nonatomic, assign) NSInteger currentSelectWorldIndex;

@end

@implementation XWWorldConfigViewController

-(void)awakeFromNib{
    [self.settingList registerNib:[[NSNib alloc] initWithNibNamed:@"XWWorldSettingSelectionCell" bundle:nil] forIdentifier:@"worldSettingValueCell"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.forestSettings = [NSMutableArray new];
    self.caveSettings = [NSMutableArray new];
    
    self.worldListManager = [XWWorldListManager new];
    self.worldListManager.context = self;
    self.worldList.delegate = self.worldListManager;
    self.worldList.dataSource = self.worldListManager;
    
    self.settingManager = [XWSettingListManager new];
    self.settingManager.context = self;
    self.settingList.delegate = self.settingManager;
    self.settingList.dataSource = self.settingManager;
    
    [self setupForestSettingArray];
    [self setupCaveSettingArray];
    
    self.currentSelectWorldIndex = -1;
    
}

- (IBAction)save:(id)sender {

    if (![Utils checkConfigModel]) {
        [MLHudAlert alertWithWindow:self.view.window type:(MLHudAlertTypeError) message:@"基本设置缺失"];
        return;
    }
    
    NSError * error;
    NSString * forestSettingModelPath = [[NSBundle mainBundle]pathForResource:@"forestLevelDataOverride" ofType:@"txt"];
    NSString * forestSettingModelContent = [NSString stringWithContentsOfFile:forestSettingModelPath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        [MLHudAlert alertWithWindow:self.view.window type:(MLHudAlertTypeError) message:@"读取forestLevelDataOverride出错"];
        return;
    }
    
    NSString * caveSettingModelPath = [[NSBundle mainBundle]pathForResource:@"caveLevelDataOverride" ofType:@"txt"];
    NSString * caveSettingModelContent = [NSString stringWithContentsOfFile:caveSettingModelPath encoding:NSUTF8StringEncoding error:nil];
    if (error) {
        [MLHudAlert alertWithWindow:self.view.window type:(MLHudAlertTypeError) message:@"读取caveLevelDataOverride出错"];
        return;
    }
    
    __block NSError * writeFileError;
    [[XWMainConfigurationModel defaultModel].worlds enumerateObjectsUsingBlock:^(XWWorldModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [Utils createDirectoryAtPath:obj.worldPath];
        NSMutableString * worldConfig = @"".mutableCopy;
        NSUInteger maxLine = obj.worldSettings.count;
        [obj.worldSettings enumerateObjectsUsingBlock:^(XWWorldSettingRowModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString * settingLine;
            if (idx == maxLine -1) {
                settingLine = [NSString stringWithFormat:@"%@=\"%@\"",obj.name_en,obj.settedValue];
            }
            else {
                settingLine = [NSString stringWithFormat:@"%@=\"%@\",\n",obj.name_en,obj.settedValue];
            }
            [worldConfig appendString:settingLine];
        }];
        
        if (obj.worldType == XWWorldTypeOver) {
            NSString * configContent = [forestSettingModelContent stringByReplacingOccurrencesOfString:@"BearReplaceMark" withString:worldConfig];
            [configContent writeToFile:[NSString stringWithFormat:@"%@/leveldataoverride.lua",obj.worldPath] atomically:YES encoding:NSUTF8StringEncoding error:&writeFileError];
        }
        else {
            NSString * configContent = [caveSettingModelContent stringByReplacingOccurrencesOfString:@"BearReplaceMark" withString:worldConfig];
            [configContent writeToFile:[NSString stringWithFormat:@"%@/leveldataoverride.lua",obj.worldPath] atomically:YES encoding:NSUTF8StringEncoding error:&writeFileError];
        }
        
        
        NSFileManager * fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath:[NSString stringWithFormat:@"%@/modoverrides.lua",obj.worldPath]]){
            NSString * content =@"return {}";
            [content writeToFile:[NSString stringWithFormat:@"%@/modoverrides.lua",obj.worldPath] atomically:YES encoding:NSUTF8StringEncoding error:&writeFileError];
        }
        
        if (writeFileError) {
            *stop = YES;
            [MLHudAlert alertWithWindow:self.view.window type:(MLHudAlertTypeError) message:@"写入LevelDataOverride出错"];
        }
    }];
    
    NSData * data = [[XWMainConfigurationModel defaultModel] yy_modelToJSONData];
    [data writeToFile:[NSString stringWithFormat:@"%@/ServerConfig.bear",Utils.currentSaveSlotPath] atomically:YES];
}

- (IBAction)deleteSelectedWorld:(id)sender {
    NSUInteger index = [self.worldList selectedRow];
    [Utils deleteDirectoryAtPath:[XWMainConfigurationModel defaultModel].worlds[index].worldPath];
    [[XWMainConfigurationModel defaultModel].worlds removeObjectAtIndex:index];
    [self.worldList reloadData];
}

- (IBAction)addOverWorld:(id)sender {
    
    XWWorldModel * worldModel = [XWWorldModel new];
    worldModel.worldPath = [NSString stringWithFormat:@"%@/World%ld",[Utils currentSaveSlotPath],[XWMainConfigurationModel defaultModel].worlds.count];
    if ([XWMainConfigurationModel defaultModel].worlds.count == 0) {
        worldModel.isMaster = YES;
    }
    else {
        worldModel.isMaster = NO;
    }
    worldModel.name = [NSString stringWithFormat:@"World%ld",[XWMainConfigurationModel defaultModel].worlds.count];
    worldModel.worldId = [NSString stringWithFormat:@"10000%ld",[XWMainConfigurationModel defaultModel].worlds.count];
    worldModel.worldType = XWWorldTypeOver;
    [self.forestSettings enumerateObjectsUsingBlock:^(XWWorldSettingRowModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XWWorldSettingRowModel * row = obj.mutableCopy;
        [worldModel.worldSettings addObject:row];
    }];
    [[XWMainConfigurationModel defaultModel].worlds addObject:worldModel];
    [self.worldList reloadData];
}

- (IBAction)addCave:(id)sender {
    XWWorldModel * worldModel = [XWWorldModel new];
    worldModel.worldPath = [NSString stringWithFormat:@"%@/World%ld",[Utils currentSaveSlotPath],[XWMainConfigurationModel defaultModel].worlds.count];
    if ([XWMainConfigurationModel defaultModel].worlds.count == 0) {
        worldModel.isMaster = YES;
    }
    else {
        worldModel.isMaster = NO;
    }
    worldModel.name = [NSString stringWithFormat:@"World%ld",[XWMainConfigurationModel defaultModel].worlds.count];
    worldModel.worldId = [NSString stringWithFormat:@"10000%ld",[XWMainConfigurationModel defaultModel].worlds.count];
    worldModel.worldType = XWWorldTypeCave;
    [self.caveSettings enumerateObjectsUsingBlock:^(XWWorldSettingRowModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XWWorldSettingRowModel * row = obj.mutableCopy;
        [worldModel.worldSettings addObject:row];
    }];
    [[XWMainConfigurationModel defaultModel].worlds addObject:worldModel];
    [self.worldList reloadData];
}

#pragma mark - prepare data
-(void)setupForestSettingArray {
    NSString * forestSettingPath = [[NSBundle mainBundle] pathForResource:@"forestsettings" ofType:@"txt"];
    NSString * forestSettingContent = [NSString stringWithContentsOfFile:forestSettingPath encoding:NSUTF8StringEncoding error:nil];
    if ([forestSettingContent fj_isNilOrEmpty]) {
        [MLHudAlert alertWithWindow:self.view.window type:(MLHudAlertTypeError) message:@"读取地上世界设置模板出错"];
        return;
    }
    NSArray<NSString*> * forestSettingLines = [forestSettingContent componentsSeparatedByString:@"\n"];
    [forestSettingLines enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //loop#环状地形#default#misc#forest#loop_descriptions
        NSArray * lineItems = [obj componentsSeparatedByString:@"#"];
        if (lineItems.count<6) {
            
        }
        else {
            XWWorldSettingRowModel * model = [XWWorldSettingRowModel new];
            model.name_ch = lineItems[1];
            model.name_en = lineItems[0];
            model.settedValue = lineItems[2];
            model.worldType = lineItems[4];
            model.selections = [Utils valueForKey:lineItems.lastObject];
            [self.forestSettings addObject:model];
        }
    }];
}

-(void)setupCaveSettingArray {
    NSString * caveSettingPath = [[NSBundle mainBundle] pathForResource:@"cavesettings" ofType:@"txt"];
    NSString * caveSettingContent = [NSString stringWithContentsOfFile:caveSettingPath encoding:NSUTF8StringEncoding error:nil];
    if ([caveSettingContent fj_isNilOrEmpty]) {
        [MLHudAlert alertWithWindow:self.view.window type:(MLHudAlertTypeError) message:@"读取地下世界设置模板出错"];
        return;
    }
    NSArray<NSString*> * caveSettingLines = [caveSettingContent componentsSeparatedByString:@"\n"];
    [caveSettingLines enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //loop#环状地形#default#misc#forest#loop_descriptions
        NSArray * lineItems = [obj componentsSeparatedByString:@"#"];
        if (lineItems.count<6) {
            
        }
        else {
            XWWorldSettingRowModel * model = [XWWorldSettingRowModel new];
            model.name_ch = lineItems[1];
            model.name_en = lineItems[0];
            model.settedValue = lineItems[2];
            model.worldType = lineItems[4];
            model.selections = [Utils valueForKey:lineItems.lastObject];
            [self.caveSettings addObject:model];
        }
    }];
}

#pragma mark - XWWorldSettingSelectionCellDelegate
-(void)changeWorldSettingValue:(NSString *)newValue forKey:(NSString *)key {
    [[XWMainConfigurationModel defaultModel].worlds[_currentSelectWorldIndex].worldSettings enumerateObjectsUsingBlock:^(XWWorldSettingRowModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name_en isEqualToString:key]) {
            obj.settedValue = newValue;
        }
    }];
}


@end

@interface XWWorldListManager()

@end

@implementation XWWorldListManager
-(void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self.context.settingList reloadData];
    self.context.currentSelectWorldIndex = self.context.worldList.selectedRow;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [XWMainConfigurationModel defaultModel].worlds.count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
           row:(NSInteger)row {
    NSString *columnIdentifier = [tableColumn identifier];
    if ([columnIdentifier isEqualToString:@"id"]) {
        
        return [XWMainConfigurationModel defaultModel].worlds[row].name;
    }
    else {
        XWWorldType worldType = [XWMainConfigurationModel defaultModel].worlds[row].worldType;
        NSString * columnContent = @"";
        switch (worldType) {
            case XWWorldTypeCave:
                columnContent = [NSString stringWithFormat:@"地下世界"];
                break;
            case XWWorldTypeOver:
                columnContent = [NSString stringWithFormat:@"地上世界"];
                break;
            default:
                break;
        }
        return columnContent;
    }
}
@end


@interface XWSettingListManager()

@end

@implementation XWSettingListManager
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (self.context.worldList.selectedRow == -1) {
        return 0;
    }
    switch ([XWMainConfigurationModel defaultModel].worlds[self.context.worldList.selectedRow].worldType) {
        case XWWorldTypeOver:
            return self.context.forestSettings.count;
            break;
        case XWWorldTypeCave:
            return self.context.caveSettings.count;
            break;
        default:
            return 0;
            break;
    }
}

-(NSView *)tableView:(NSTableView *)tableView
  viewForTableColumn:(NSTableColumn *)tableColumn
                 row:(NSInteger)row {
    NSString *columnIdentifier = [tableColumn identifier];
    XWWorldType worldType = [XWMainConfigurationModel defaultModel].worlds[self.context.worldList.selectedRow].worldType;
    if ([columnIdentifier isEqualToString:@"worldSettingKey"]) {
        
        NSString * columnContent = @"";
        switch (worldType) {
            case XWWorldTypeCave:
                columnContent = self.context.caveSettings[row].name_ch;
                break;
            case XWWorldTypeOver:
                columnContent = self.context.forestSettings[row].name_ch;
                break;
            default:
                break;
        }

        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"worldSettingKeyCell" owner:self];
        [cellView.textField setStringValue:columnContent];
        return cellView;
    }
    else {
        if (self.context.currentSelectWorldIndex == -1) {
            return nil;
        }
        XWWorldSettingSelectionCell *cellView = [tableView makeViewWithIdentifier:@"worldSettingValueCell" owner:self];
        cellView.delegate = self.context;
        [cellView bindData:[XWMainConfigurationModel defaultModel].worlds[self.context.currentSelectWorldIndex].worldSettings[row]];
        return cellView;
    }
}
@end





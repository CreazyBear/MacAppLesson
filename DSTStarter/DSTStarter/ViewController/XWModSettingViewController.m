//
//  XWModSettingViewController.m
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/10.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import "XWModSettingViewController.h"
#import "XWMainConfigurationModel.h"
#import "Utils.h"
#import "NSString+Extension.h"
#import <MLHudAlert.h>
#import <LuaScriptCore.h>
#import "XWModModel.h"
#import "XWWorldSettingSelectionCell.h"
#import "XWCheckboxCell.h"
#import <MLHudAlert.h>

@interface XWModSettingViewController ()<XWWorldSettingSelectionCellDelegate,XWCheckboxCellDelegate>

@property (nonatomic, strong) NSString *pathToServerMod;
@property (nonatomic, strong) NSString *pathToClientMod;

@property (nonatomic, strong) LSCContext *luaContext;

@property (nonatomic, strong) NSMutableArray<XWModModel*> *modDataSource;
@property (weak) IBOutlet NSTableView *modSetList;
@property (weak) IBOutlet NSTableView *modList;
@property (unsafe_unretained) IBOutlet NSTextView *modInfoTextView;

@property (nonatomic, strong) XWModListManager *modManager;
@property (nonatomic, strong) XWModSetManager *modSetManager;

@property (nonatomic, strong) XWModModel *selectedMod;
@end

@implementation XWModSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self configPath];
    self.luaContext = [[LSCContext alloc]init];
    self.modDataSource = [NSMutableArray new];
    self.modManager = [XWModListManager new];
    self.modManager.context = self;
    self.modList.delegate = self.modManager;
    self.modList.dataSource = self.modManager;
    
    self.modSetManager = [XWModSetManager new];
    self.modSetManager.context = self;
    self.modSetList.delegate = self.modSetManager;
    self.modSetList.dataSource = self.modSetManager;
    
    [self loadMod];
    
}

-(void)awakeFromNib{
    [self.modSetList registerNib:[[NSNib alloc] initWithNibNamed:@"XWWorldSettingSelectionCell" bundle:nil] forIdentifier:@"worldSettingValueCell"];
    
    [self.modList registerNib:[[NSNib alloc]initWithNibNamed:@"XWCheckboxCell" bundle:nil] forIdentifier:@"XWCheckboxCell"];
}


-(void)configPath {
    NSArray * pathComponent = [Utils.documentPath componentsSeparatedByString:@"/"];
    NSString * pathToDSTApp = @"/";
    
    if (pathComponent.count < 3 ) {
        [MLHudAlert alertWithWindow:self.view.window type:(MLHudAlertTypeError) message:@"解析Mod路径失败"];
        return;
    }
    
    pathToDSTApp = [pathToDSTApp stringByAppendingPathComponent:pathComponent[1]];
    pathToDSTApp = [pathToDSTApp stringByAppendingPathComponent:pathComponent[2]];
    
    self.pathToServerMod = [pathToDSTApp stringByAppendingString:@"/Library/Application Support/Steam/steamapps/common/Don't Starve Together Dedicated Server/dontstarve_dedicated_server_nullrenderer.app/Contents/mods"];
    self.pathToClientMod = [pathToDSTApp stringByAppendingString:@"/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods"];
}

-(void)loadMod {
    NSError * error;
    NSFileManager * fm = [NSFileManager defaultManager];
    NSArray * fileArray = [fm contentsOfDirectoryAtPath:self.pathToServerMod error:&error];
    if (error) {
        [MLHudAlert alertWithWindow:self.view.window type:(MLHudAlertTypeError) message:@"读取Mods文件夹失败"];
        return;
    }
    self.modDataSource = [XWMainConfigurationModel defaultModel].modList;
    [fileArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isDirectory;
        [fm fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",self.pathToServerMod,obj] isDirectory:&isDirectory];
        if (isDirectory) {
            XWModModel * model = [XWModModel new];
            model.path = [NSString stringWithFormat:@"%@/%@",self.pathToServerMod,obj];
            model.folderName = obj;
            model.doneAnalyse = NO;
            model.isEnabled = NO;
            __block BOOL hasMod = NO;
            [self.modDataSource enumerateObjectsUsingBlock:^(XWModModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.folderName isEqualToString:model.folderName]) {
                    hasMod = YES;
                    * stop = YES;
                }
            }];
            if (!hasMod) {
                [self.modDataSource addObject:model];
            }
        }
    }];
    
    [self.modDataSource enumerateObjectsUsingBlock:^(XWModModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.doneAnalyse = NO;
    }];

    [self.modList reloadData];
    
    
}

- (IBAction)copyFromClient:(id)sender {

    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error;
    [fm removeItemAtPath:self.pathToServerMod error:nil];
    [fm copyItemAtPath:self.pathToClientMod toPath:self.pathToServerMod error:&error];
    if (error) {
        [MLHudAlert alertWithWindow:self.view.window type:(MLHudAlertTypeError) message:@"拷贝Mod失败"];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadMod];
    });
}

-(void)handleChangeSelectedMod {
    NSInteger index = self.modList.selectedRow;
    if (index != -1) {
        
        XWModModel * model = self.modDataSource[index];
        if (!model.doneAnalyse) {
            NSString * pathToModInfo = [NSString stringWithFormat:@"%@/modinfo.lua",model.path];
            NSFileManager * fm = [NSFileManager defaultManager];
            if (![fm fileExistsAtPath:pathToModInfo]) {
                return;
            }
            LSCContext * luaContext;
            if (!model.context) {
                model.context = [[LSCContext alloc]init];
                luaContext = model.context;
            }
            [luaContext evalScriptFromFile:pathToModInfo];
            model.name = [luaContext getGlobalForName: @"name"].toString;
            model.version = [luaContext getGlobalForName: @"version"].toString;
            model.modDescription = [luaContext getGlobalForName: @"description"].toString;
            model.author = [luaContext getGlobalForName: @"author"].toString;
            model.forumthread = [luaContext getGlobalForName: @"forumthread"].toString;
            model.api_version = [luaContext getGlobalForName: @"api_version"].toString;
            model.dst_compatible = [luaContext getGlobalForName: @"dst_compatible"].toString;
            model.dont_starve_compatible = [luaContext getGlobalForName: @"dont_starve_compatible"].toString;
            model.reign_of_giants_compatible = [luaContext getGlobalForName: @"reign_of_giants_compatible"].toString;
            model.all_clients_require_mod = [luaContext getGlobalForName: @"all_clients_require_mod"].toString;
            model.client_only_mod = [luaContext getGlobalForName: @"client_only_mod"].toString;
            model.server_only_mod = [luaContext getGlobalForName: @"server_only_mod"].toString;
            model.icon_atlas = [luaContext getGlobalForName: @"icon_atlas"].toString;
            model.icon = [luaContext getGlobalForName: @"icon"].toString;
            model.configuration_options = [luaContext getGlobalForName: @"configuration_options"].toArray;
            model.configItems = [NSMutableDictionary new];
            if (!model.configResults) {
                model.configResults = [NSMutableDictionary new];
            }
            model.configDefault = [NSMutableDictionary new];
            if ([model.configuration_options isKindOfClass:[NSArray class]]) {
                [model.configuration_options enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSArray * options = [obj valueForKey:@"options"];
                    NSString * name = [obj valueForKey:@"name"];
                    if (![name fj_isNilOrEmpty]) {
                        if (options) {
                            [model.configItems setValue:options forKey:name];
                        }
                        id defaultSelection = [obj valueForKey:@"default"];
                        [model.configDefault setValue:defaultSelection forKey:name];
                        
                    }
                }];
            }
            model.configNames = model.configItems.allKeys;
            model.doneAnalyse = YES;
        }
        
        self.selectedMod = model;
        self.modInfoTextView.string = [NSString stringWithFormat:@"名字：\t%@\n描述：\t%@\n需要所有玩家安装：\t%@\n",model.name,model.modDescription,model.all_clients_require_mod];
        [self.modSetList reloadData];
    }
}

- (IBAction)save:(id)sender {
    
    //TODO:modoverrides.lua
    __block NSMutableString * modoverrides = [@"return {\n" mutableCopy];
    [self.modDataSource enumerateObjectsUsingBlock:^(XWModModel * _Nonnull modelObj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([modelObj isEnabled]) {
            
            __block NSMutableString * configuration_options_str = [NSMutableString new];
            [modelObj.configResults enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                
                id defaultValue = [modelObj.configDefault valueForKey:key];
                if ([defaultValue isKindOfClass:[NSString class]]) {
                    NSString *line = [NSString stringWithFormat:@"%@=\"%@\",",key,obj];
                    [configuration_options_str appendString:line];
                }
                else {
                    NSString *line = [NSString stringWithFormat:@"%@= %@ ,",key,obj];
                    [configuration_options_str appendString:line];
                }
            }];
            NSString * line = [NSString stringWithFormat:@"[\"%@\"] = {configuration_options = {%@}, enabled = true },\n",modelObj.folderName,configuration_options_str];
            [modoverrides appendString:line];
        }
    }];
    
    [modoverrides appendString:@"\n}"];
    [[XWMainConfigurationModel defaultModel].worlds enumerateObjectsUsingBlock:^(XWWorldModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * pathToModOverridesLua = [NSString stringWithFormat:@"%@/modoverrides.lua",obj.worldPath];
        NSError * error;
        [modoverrides writeToFile:pathToModOverridesLua atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            [MLHudAlert alertWithWindow:self.view.window type:(MLHudAlertTypeError) message:@"写入modoverrides.lua出错"];
            *stop = YES;
        }
    }];
    
    NSData * data = [[XWMainConfigurationModel defaultModel] yy_modelToJSONData];
    [data writeToFile:[NSString stringWithFormat:@"%@/ServerConfig.bear",Utils.currentSaveSlotPath] atomically:YES];
    
}

-(void)changeEnabled:(BOOL)enabled forKey:(NSString *)key {
    [self.modDataSource enumerateObjectsUsingBlock:^(XWModModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.folderName isEqualToString:key]) {
            obj.isEnabled = enabled;
        }
    }];
}

-(void)changeWorldSettingValue:(NSString*)newValue forKey:(NSString*)key {
    [self.selectedMod.configResults setValue:newValue forKey:key];
}

@end



@implementation XWModListManager
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.context.modDataSource.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *columnIdentifier = [tableColumn identifier];
    if ([columnIdentifier isEqualToString:@"modNameKey"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"modNameKeyCell" owner:self];
        [cellView.textField setStringValue:self.context.modDataSource[row].folderName];
        return cellView;
    }
    else {
        XWCheckboxCell *cellView = [tableView makeViewWithIdentifier:@"XWCheckboxCell" owner:self];
        cellView.delegate = self.context;
        [cellView bindDataWithKey:self.context.modDataSource[row].folderName hasEnabled:self.context.modDataSource[row].isEnabled];
        return cellView;

    }
}




-(void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self.context handleChangeSelectedMod];
}

@end


@implementation XWModSetManager
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.context.selectedMod.configNames.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *columnIdentifier = [tableColumn identifier];
    if ([columnIdentifier isEqualToString:@"modSetKey"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"modSetKeyCell" owner:self];
        [cellView.textField setStringValue:self.context.selectedMod.configNames[row]];
        return cellView;
    }
    else {
        XWWorldSettingSelectionCell *cellView = [tableView makeViewWithIdentifier:@"worldSettingValueCell" owner:self];
        cellView.delegate = self.context;
        [cellView bindModSetData:self.context.selectedMod withOptionName:self.context.selectedMod.configNames[row]];
        return cellView;
    }
}


@end





















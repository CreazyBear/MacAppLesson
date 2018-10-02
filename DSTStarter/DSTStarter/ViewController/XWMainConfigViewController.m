//
//  XWMainConfigViewController.m
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/8.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import "XWMainConfigViewController.h"
#import "Utils.h"
#import "NSString+Extension.h"

@interface XWMainConfigViewController ()
@property (weak) IBOutlet NSPopUpButton *slotList;
@property (weak) IBOutlet NSTextField *saveSlotText;
@property (weak) IBOutlet NSTextField *roomName;
@property (weak) IBOutlet NSPopUpButton *gameStyle;
@property (weak) IBOutlet NSPopUpButton *gameModel;
@property (weak) IBOutlet NSPopUpButton *pvp;
@property (weak) IBOutlet NSPopUpButton *connectModel;
@property (weak) IBOutlet NSTextField *roomDesc;
@property (weak) IBOutlet NSTextField *roomNum;
@property (weak) IBOutlet NSTextField *roomPassport;
@property (weak) IBOutlet NSButton *addSlotButton;
@end

@implementation XWMainConfigViewController

-(void)viewDidLoad {
    
    [self.slotList setTarget:self];
    [self.slotList setAction:@selector(handleChangeSlot)];
    NSMutableArray * slots = [[[NSUserDefaults standardUserDefaults] valueForKey:userDefaultSaveSlotListKey] mutableCopy];
    NSMutableArray * deleteSlots = [NSMutableArray new];
    [slots enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:[Utils saveSlotPath:obj]]) {
            [self.slotList addItemWithTitle:obj];
        }
        else {
            [deleteSlots addObject:obj];
        }
    }];
    
    [self.slotList selectItemWithTitle:[XWMainConfigurationModel defaultModel].saveSlotName];
    
    if (deleteSlots.count > 0) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"not (self in %@)",deleteSlots];
        [slots filterUsingPredicate:predicate];
        [[NSUserDefaults standardUserDefaults]setValue:slots forKey:userDefaultSaveSlotListKey];
    }
    
    if ([[XWMainConfigurationModel defaultModel]loaded]) {
        [self mapModelToView];
    }
    
    NSFileManager * fm = [NSFileManager defaultManager];
    if (![[XWMainConfigurationModel defaultModel].saveSlotName fj_isNilOrEmpty] &&
        [fm fileExistsAtPath:[Utils currentSaveSlotPath]]) {
        self.saveSlotText.enabled = NO;
    }
    else{
        self.addSlotButton.enabled = NO;
    }
    
}

-(void)mapModelToView {
    XWMainConfigurationModel * model = [XWMainConfigurationModel defaultModel];
    [self.saveSlotText setStringValue:model.saveSlotName];
    [self.roomName setStringValue:model.roomName];
    [self.gameStyle selectItemAtIndex:[Utils.styleName indexOfObject:model.gameStyle]];
    [self.gameModel selectItemAtIndex:[Utils.modeName indexOfObject:model.gameModel]];
    [self.pvp selectItemAtIndex:[model.pvp isEqualToString:@"false"]?0:1];
    [self.connectModel selectItemAtIndex:model.connectModel ? 0:1];
    [self.roomDesc setStringValue:model.roomDesc];
    [self.roomNum setStringValue:model.roomNum];
    [self.roomPassport setStringValue:model.roomPassport];

}

-(void)handleChangeSlot {
    NSString * newSlotName = self.slotList.selectedItem.title;
    if (![newSlotName isEqualToString:self.saveSlotText.stringValue]) {
        [[NSUserDefaults standardUserDefaults]setValue:newSlotName forKey:userDefaultSaveSlotKey];
        if (![[XWMainConfigurationModel defaultModel].saveSlotName fj_isNilOrEmpty]) {
            [Utils createSaveSlotWithName:[XWMainConfigurationModel defaultModel].saveSlotName];
            NSData * data = [[XWMainConfigurationModel defaultModel] yy_modelToJSONData];
            [data writeToFile:[NSString stringWithFormat:@"%@/ServerConfig.bear",Utils.currentSaveSlotPath] atomically:YES];
        }
        [[XWMainConfigurationModel defaultModel].worlds removeAllObjects];
        
        NSString * saveSlotPath = [Utils saveSlotPath:newSlotName];
        NSData * serverConfigModelData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/ServerConfig.bear",saveSlotPath]];
        if (serverConfigModelData) {
            [[XWMainConfigurationModel defaultModel]loadFromLocalModel:[XWMainConfigurationModel yy_modelWithJSON:serverConfigModelData]];
            [self mapModelToView];
        }
        
    }
}

- (IBAction)newSaveSlot:(id)sender {
    if (![[XWMainConfigurationModel defaultModel].saveSlotName fj_isNilOrEmpty]) {
        [Utils createSaveSlotWithName:[XWMainConfigurationModel defaultModel].saveSlotName];
        NSData * data = [[XWMainConfigurationModel defaultModel] yy_modelToJSONData];
        [data writeToFile:[NSString stringWithFormat:@"%@/ServerConfig.bear",Utils.currentSaveSlotPath] atomically:YES];
    }
    [[XWMainConfigurationModel defaultModel].worlds removeAllObjects];
    [self.saveSlotText setStringValue:@""];
    self.saveSlotText.enabled = YES;
    self.addSlotButton.enabled = NO;
}


- (IBAction)onSaveButtonClicked:(id)sender {
    
    if ([self.saveSlotText.stringValue fj_isNilOrEmpty]) {
        return;
    }
    
    NSMutableArray * slots = [[[NSUserDefaults standardUserDefaults] valueForKey:userDefaultSaveSlotListKey] mutableCopy];
    if (!slots) {
        slots = [NSMutableArray new];
    }
    [slots addObject:self.saveSlotText.stringValue];
    
    [[NSUserDefaults standardUserDefaults]setValue:slots forKey:userDefaultSaveSlotListKey];
    [[NSUserDefaults standardUserDefaults]setValue:self.saveSlotText.stringValue forKey:userDefaultSaveSlotKey];
    
    [Utils createSaveSlotWithName:self.saveSlotText.stringValue];
    
    NSString * emptyListContent = @"";
    NSFileManager * fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:[NSString stringWithFormat:@"%@/adminlist.txt",Utils.currentSaveSlotPath]]) {
        [emptyListContent writeToFile:[NSString stringWithFormat:@"%@/adminlist.txt",Utils.currentSaveSlotPath]
                           atomically:YES
                             encoding:NSUTF8StringEncoding
                                error:nil];
    }
    if (![fm fileExistsAtPath:[NSString stringWithFormat:@"%@/blocklist.txt",Utils.currentSaveSlotPath]]) {
        [emptyListContent writeToFile:[NSString stringWithFormat:@"%@/blocklist.txt",Utils.currentSaveSlotPath]
                           atomically:YES
                             encoding:NSUTF8StringEncoding
                                error:nil];
    }
    
    XWMainConfigurationModel * configModel = [XWMainConfigurationModel defaultModel];
    
    configModel.saveSlotName = self.saveSlotText.stringValue;
    
    configModel.roomName = self.roomName.stringValue;
    
    configModel.gameStyle = Utils.styleName[[self.gameStyle indexOfSelectedItem]];
    
    configModel.gameModel = Utils.modeName[[self.gameModel indexOfSelectedItem]];
    
    configModel.pvp = [self.pvp indexOfSelectedItem] == 0 ? @"false":@"true";
    
    configModel.connectModel = ([self.connectModel indexOfSelectedItem] == 0);
    
    configModel.roomDesc = self.roomDesc.stringValue;
    
    configModel.roomNum = self.roomNum.stringValue;
    
    configModel.roomPassport = self.roomPassport.stringValue;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:finishedBasicConfigNotification object:nil];
    
    self.addSlotButton.enabled = YES;
    
    self.saveSlotText.enabled = NO;
    
    [self.slotList addItemWithTitle:self.saveSlotText.stringValue];
    
    if (![[XWMainConfigurationModel defaultModel].saveSlotName fj_isNilOrEmpty]) {
        [Utils createSaveSlotWithName:[XWMainConfigurationModel defaultModel].saveSlotName];
        NSData * data = [[XWMainConfigurationModel defaultModel] yy_modelToJSONData];
        [data writeToFile:[NSString stringWithFormat:@"%@/ServerConfig.bear",Utils.currentSaveSlotPath] atomically:YES];
    }
    [self.slotList selectItemWithTitle:[XWMainConfigurationModel defaultModel].saveSlotName];
    
}

@end

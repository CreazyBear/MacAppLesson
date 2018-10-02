//
//  XWServerManagerViewController.m
//  DSTStarter
//
//  Created by 熊伟 on 2017/10/5.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "XWServerManagerViewController.h"
#import "STPrivilegedTask.h"
#import <MLHudAlert.h>
#import "Utils.h"
#import "XWMainConfigurationModel.h"
#import "XWMainConfigViewController.h"
#import "NSString+Extension.h"
#import "XWUserInfoModel.h"

@interface XWServerManagerViewController ()
@property (weak) IBOutlet NSButton *reset;
@property (weak) IBOutlet NSButton *saveProgress;
@property (weak) IBOutlet NSButton *connectWorld;

@property (nonatomic, assign) BOOL startState;

@property (weak) IBOutlet NSButton *startServerButton;
@property (nonatomic, strong) NSMutableArray *portArray;


@property (weak) IBOutlet NSTableView *playerList;
@property (weak) IBOutlet NSTableView *managerList;
@property (weak) IBOutlet NSTableView *blockList;
@property (weak) IBOutlet NSTextField *commandText;


@property (strong) NSMutableArray<XWUserInfoModel*> * playerListDataSource;
@property (strong) NSMutableArray<XWUserInfoModel*> * adminListDataSource;
@property (strong) NSMutableArray<XWUserInfoModel*> * blockListDataSource;

@property (strong) XWPlayerListManager *playerManager;
@property (strong) XWAdminListManager *adminManager;
@property (strong) XWBlockListManager *blockManager;

@end

@implementation XWServerManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.portArray = [NSMutableArray new];
    self.playerListDataSource = [NSMutableArray new];
    self.adminListDataSource = [NSMutableArray new];
    self.blockListDataSource = [NSMutableArray new];
    
    self.playerManager = [XWPlayerListManager new];
    self.playerManager.context = self;
    self.playerList.delegate = self.playerManager;
    self.playerList.dataSource = self.playerManager;
    
    self.adminManager = [XWAdminListManager new];
    self.adminManager.context = self;
    self.managerList.delegate = self.adminManager;
    self.managerList.dataSource = self.adminManager;
    
    self.blockManager = [XWBlockListManager new];
    self.blockManager.context = self;
    self.blockList.delegate = self.blockManager;
    self.blockList.dataSource = self.blockManager;
    
    [self.managerList setDoubleAction:@selector(doubleClickAdminAction:)];
    [self.blockList setDoubleAction:@selector(doubleClickBlockAction:)];
    
    
}

-(void)viewWillAppear {
    [super viewWillAppear];
    self.startState = YES;
    [self.blockListDataSource removeAllObjects];
    [self.adminListDataSource removeAllObjects];
    [self setupDataSource];
}

-(void)setupDataSource {
    [self setupAdminDataSource];
    [self setupBlockDataSource];
}

-(void)setupAdminDataSource {
    NSString * adminContent = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/adminlist.txt",Utils.currentSaveSlotPath] encoding:NSUTF8StringEncoding error:nil];
    [[adminContent componentsSeparatedByString:@"\n"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj fj_isNilOrEmpty]) {
            XWUserInfoModel * user = [XWUserInfoModel new];
            user.identity = obj;
            [self.adminListDataSource addObject:user];
        }
    }];
}

-(void)setupBlockDataSource {
    NSError * error;
    NSString * blockContent = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/blocklist.txt",Utils.currentSaveSlotPath] encoding:NSWindowsCP1252StringEncoding error:&error];
    
    [[blockContent componentsSeparatedByString:@"\n"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if (![obj fj_isNilOrEmpty]) {
            XWUserInfoModel * user = [XWUserInfoModel new];
            user.identity = obj;
            [self.blockListDataSource addObject:user];
        }
    }];
}

- (IBAction)startServer:(id)sender {

    if(![Utils checkConfigModel]) {
        [MLHudAlert alertWithWindow:self.view.window type:(MLHudAlertTypeError) message:@"基本设置缺失"];
        return;
    }
    //创建token文件
    [self createClusterTokenfileIfNeeded];
    [self createClusterIniFile];
    [self createWorldServerIni];
    if(self.startState){
        self.startServerButton.enabled = NO;
        [self createWorld];
    }
}

- (IBAction)closeServer:(id)sender {
    
    [[XWMainConfigurationModel defaultModel].worlds enumerateObjectsUsingBlock:^(XWWorldModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.writeHandle closeFile];
        [obj.task terminate];
        
    }];
    [self.portArray removeAllObjects];
    self.startServerButton.enabled = YES;
}

-(void)createWorldServerIni {
    
    __block NSError * error;
    
    [[XWMainConfigurationModel defaultModel].worlds enumerateObjectsUsingBlock:^(XWWorldModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * serverIniContent;
        if (obj.isMaster) {
            serverIniContent = [NSString stringWithFormat:@"[NETWORK]\nserver_port = %d\n[SHARD]\nis_master = true",[self getValidPort]];
        }
        else {
            serverIniContent = [NSString stringWithFormat:@"[NETWORK]\nserver_port = %d\n[SHARD]\nis_master = false\nname = %@\nid = %@\n[STEAM]\nmaster_server_port = 27017\nauthentication_port = 8767\n",[self getValidPort],obj.name,obj.worldId];
        }
        [serverIniContent writeToFile:[NSString stringWithFormat:@"%@/server.ini",obj.worldPath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            *stop = YES;
            self.startState = NO;
        }
    }];
}

-(void)createClusterIniFile {
    
    XWMainConfigurationModel * configModel = [XWMainConfigurationModel defaultModel];
    
    NSString * clusterIniModelPath = [[NSBundle mainBundle]pathForResource:@"cluster" ofType:@"txt"];
    NSString * clusterIniContent = [NSString stringWithContentsOfFile:clusterIniModelPath encoding:NSUTF8StringEncoding error:nil];
    clusterIniContent = [clusterIniContent stringByReplacingOccurrencesOfString:@"xw_game_mode" withString: configModel.gameModel];
    clusterIniContent = [clusterIniContent stringByReplacingOccurrencesOfString:@"xw_max_players" withString: configModel.roomNum];
    clusterIniContent = [clusterIniContent stringByReplacingOccurrencesOfString:@"xw_pvp" withString: configModel.pvp];
    clusterIniContent = [clusterIniContent stringByReplacingOccurrencesOfString:@"xw_offline_cluster" withString: configModel.connectModel?@"false":@"true"];
    clusterIniContent = [clusterIniContent stringByReplacingOccurrencesOfString:@"xw_cluster_description" withString: configModel.roomDesc];
    clusterIniContent = [clusterIniContent stringByReplacingOccurrencesOfString:@"xw_cluster_name" withString: configModel.roomName];
    clusterIniContent = [clusterIniContent stringByReplacingOccurrencesOfString:@"xw_cluster_intention" withString: configModel.gameStyle];
    clusterIniContent = [clusterIniContent stringByReplacingOccurrencesOfString:@"xw_cluster_password" withString: configModel.roomPassport];
    
    int masterPort = [self getValidPort];
    if (masterPort<=-1) {
        [MLHudAlert alertWithWindow:self.view.window type:(MLHudAlertTypeError) message:@"请求端口失败"];
        return;
    }
    configModel.masterPort = [NSString stringWithFormat:@"%d",masterPort];
    clusterIniContent = [clusterIniContent stringByReplacingOccurrencesOfString:@"xw_master_port" withString: configModel.masterPort];
    
    NSError * error;
    NSString *clusterIniPath = [NSString stringWithFormat:@"%@/cluster.ini",[Utils saveSlotPath:[XWMainConfigurationModel defaultModel].saveSlotName]];
    [clusterIniContent writeToFile:clusterIniPath atomically:YES encoding:(NSUTF8StringEncoding) error:&error];
    if (error) {
        [MLHudAlert alertWithWindow:self.view.window type:(MLHudAlertTypeError) message:@"创建Cluster.ini文件失败"];
    }
}

-(int)getValidPort {
    int port = -1;
    for (int i = 11000; i < 65535; i++) {
        int startPosition = i;
        if (self.portArray.count > 0) {
            startPosition = [self.portArray.lastObject intValue] + 1;
        }
        port = [Utils getFreePort2:startPosition];
        if (![self.portArray containsObject:[NSNumber numberWithInt:port]]) {
            [self.portArray addObject:[NSNumber numberWithInt:port]];
            break;
        }
    }
    return port;
}

/**
 创建Token文件
 */
- (void)createClusterTokenfileIfNeeded {
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString *tokenPath = [NSString stringWithFormat:@"%@/cluster_token.txt",[Utils saveSlotPath:[XWMainConfigurationModel defaultModel].saveSlotName]];
    if(![fm fileExistsAtPath:tokenPath]){
        [fm createDirectoryAtPath:[Utils documentPath] withIntermediateDirectories:YES attributes:nil error:nil];
        NSString * token = @"xyXThBqSds+ku7ObcWRS1gbH/GlXdtKZ";
        NSData * data = [NSData dataWithBytes:[token UTF8String] length:strlen([token UTF8String])];
        if(![fm createFileAtPath:tokenPath contents:data attributes:nil]){
            [MLHudAlert alertWithWindow:self.view.window type:MLHudAlertTypeError message:@"创建Token失败~!"];
            self.startState = NO;
        }
    }
}

- (void)createWorld {
    
    [[XWMainConfigurationModel defaultModel].worlds enumerateObjectsUsingBlock:^(XWWorldModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSTask *worldtask = [[NSTask alloc] init];
        worldtask.launchPath = @"/bin/sh";
        if ([XWMainConfigurationModel defaultModel].connectModel) {
            worldtask.arguments = @[@"start.sh", [XWMainConfigurationModel defaultModel].saveSlotName, @" ", obj.name];
        }
        else {
            worldtask.arguments = @[@"start.sh", [XWMainConfigurationModel defaultModel].saveSlotName, @"-offline", obj.name];
        }
        worldtask.currentDirectoryPath = [[NSBundle  mainBundle] resourcePath];
        NSPipe *inputPipe = [NSPipe pipe];
        [worldtask setStandardInput:inputPipe];
        obj.writePipe = inputPipe;
        obj.writeHandle = [inputPipe fileHandleForWriting];
        
        obj.task = worldtask;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [worldtask launch];
            [worldtask waitUntilExit];
        });
    }];
}

- (IBAction)sendCommand:(id)sender {
    [[XWMainConfigurationModel defaultModel].worlds enumerateObjectsUsingBlock:^(XWWorldModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        const char * commandLine = [[NSString stringWithFormat:@"%@\r\n",self.commandText.stringValue] UTF8String];
        [obj.writeHandle writeData:[NSData dataWithBytes:commandLine length:strlen(commandLine)]];
    }];
}

- (IBAction)refreshPlayerList:(id)sender {
    
    NSString * timeStamp = [NSString stringWithFormat:@"%f",[[NSDate new]timeIntervalSince1970]];
    [self.playerListDataSource removeAllObjects];
    [self.playerList reloadData];
    
    [[XWMainConfigurationModel defaultModel].worlds enumerateObjectsUsingBlock:^(XWWorldModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * command = [NSString stringWithFormat:@"print(\"%@\") c_listallplayers() print(\"%@\")",timeStamp,timeStamp];
        const char * commandLine = [[NSString stringWithFormat:@"%@\r\n",command] UTF8String];
        [obj.writeHandle writeData:[NSData dataWithBytes:commandLine length:strlen(commandLine)]];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSString * path = [NSString stringWithFormat:@"%@/server_log.txt",[XWMainConfigurationModel defaultModel].worlds[0].worldPath];
        NSString * serverLog = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray * timeStampArray =[serverLog componentsSeparatedByString:timeStamp];
        if (timeStampArray.count>4) {
            NSString * playerListStr = [serverLog componentsSeparatedByString:timeStamp][3];
            NSArray * playerLists = [playerListStr componentsSeparatedByString:@"\n"];
            [playerLists enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj containsString:@"("] && [obj containsString:@")"]) {
                    NSArray * userInfo = [[obj componentsSeparatedByString:@"("][1] componentsSeparatedByString:@")"];
                    XWUserInfoModel * model = [XWUserInfoModel new];
                    model.name = userInfo[1];
                    model.identity = userInfo[0];
                    [self.playerListDataSource addObject:model];
                }
            }];
            [self.playerList reloadData];
        }
    });
}

-(void)doubleClickAdminAction:(NSTableView*)sender {
    
    NSInteger index = [self.managerList selectedRow];
    [self.adminListDataSource removeObjectAtIndex:index];
    [self.managerList reloadData];
    [self saveAdminDataSourceToFile];
}

-(void)saveAdminDataSourceToFile {
    NSMutableString * newContent = [@"" mutableCopy];
    [self.adminListDataSource enumerateObjectsUsingBlock:^(XWUserInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [newContent appendString:obj.identity];
        [newContent appendString:@"\n"];
    }];
    
    [newContent writeToFile:[NSString stringWithFormat:@"%@/adminlist.txt",Utils.currentSaveSlotPath]
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:nil];

}

-(void)doubleClickBlockAction:(NSTableView*)sender {
    NSInteger index = [self.blockList selectedRow];
    [self.blockListDataSource removeObjectAtIndex:index];
    [self.blockList reloadData];
    [self saveBlockDataToFile];
}

-(void)saveBlockDataToFile {
    NSMutableString * newContent = [@"" mutableCopy];
    [self.blockListDataSource enumerateObjectsUsingBlock:^(XWUserInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [newContent appendString:obj.identity];
        [newContent appendString:@"\n"];
    }];
    
    [newContent writeToFile:[NSString stringWithFormat:@"%@/blocklist.txt",Utils.currentSaveSlotPath]
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:nil];

}

- (IBAction)addAdmin:(id)sender {
    XWUserInfoModel * selectUser = self.playerListDataSource[[self.playerList selectedRow]];
    [self.adminListDataSource addObject:selectUser];
    [self saveAdminDataSourceToFile];
    [self.managerList reloadData];
}

- (IBAction)addBlock:(id)sender {
    XWUserInfoModel * selectUser = self.playerListDataSource[[self.playerList selectedRow]];
    NSString * cmd = [NSString stringWithFormat:@"TheNet:Kick('%@') TheNet:Ban('%@')",selectUser.identity,selectUser.identity];
    [self excuteCommand:cmd];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupBlockDataSource];
        [self.blockList reloadData];
    });
}

-(void)excuteCommand:(NSString*)command {
    [[XWMainConfigurationModel defaultModel].worlds enumerateObjectsUsingBlock:^(XWWorldModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        const char * commandLine = [[NSString stringWithFormat:@"%@\r\n",command] UTF8String];
        [obj.writeHandle writeData:[NSData dataWithBytes:commandLine length:strlen(commandLine)]];
    }];

}

- (IBAction)resetAction:(id)sender {
    [self excuteCommand:@"c_regenerateworld()"];
}

- (IBAction)saveProgressAction:(id)sender {
    [self excuteCommand:@"c_save()"];
}
- (IBAction)connectWorldAction:(id)sender {
    
    NSString * timeStamp = [NSString stringWithFormat:@"%f",[[NSDate new]timeIntervalSince1970]];

    __block NSString * command;
    [[XWMainConfigurationModel defaultModel].worlds enumerateObjectsUsingBlock:^(XWWorldModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        command = [NSString stringWithFormat:@"print(\"%@\") local x,y,z = c_find(\"multiplayer_portal\").Transform:GetWorldPosition() print(x,y,z) print(\"%@\")",timeStamp,timeStamp];
        const char * commandLine = [[NSString stringWithFormat:@"%@\r\n",command] UTF8String];
        [obj.writeHandle writeData:[NSData dataWithBytes:commandLine length:strlen(commandLine)]];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSString * path = [NSString stringWithFormat:@"%@/server_log.txt",[XWMainConfigurationModel defaultModel].worlds[0].worldPath];
        NSString * serverLog = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray * timeStampArray =[serverLog componentsSeparatedByString:command];
        if (timeStampArray.count>=2) {
            NSString * positionStr = [serverLog componentsSeparatedByString:command][1];
            NSArray * outPut = [positionStr componentsSeparatedByString:timeStamp];
            if (outPut.count >= 2) {
                NSString * str = outPut[1];
                NSArray * positionArray = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                NSString * px = positionArray[2];
                NSString * pz = positionArray[4];
                
                NSMutableArray * worldsId = [NSMutableArray new];
                __block XWWorldModel * masterWorld;
                [[XWMainConfigurationModel defaultModel].worlds enumerateObjectsUsingBlock:^(XWWorldModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (!obj.isMaster) {
                        [worldsId addObject:obj.worldId];
                    }
                    else {
                        masterWorld = obj;
                    }
                }];
                
                [worldsId enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSInteger x = px.integerValue + 10 * idx;
                    NSInteger z = pz.integerValue + 10 * idx;
                    
                    NSString * command = [NSString stringWithFormat:@"local pll = c_spawn(\"cave_entrance\") pll.Transform:SetPosition(%ld, 0, %ld) portal.components.worldmigrator.linkedWorld = \"%@\"\r\n",x,z,obj];
                    const char * commandLine = [command UTF8String];
                    [masterWorld.writeHandle writeData:[NSData dataWithBytes:commandLine length:strlen(commandLine)]];
                }];
            }
        }
    });
}
- (IBAction)rollBackAction:(id)sender {
    [self excuteCommand:@"c_rollback(1)"];
}

@end

@interface XWPlayerListManager()
@end

@implementation XWPlayerListManager
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.context.playerListDataSource.count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [NSString stringWithFormat:@"%@:%@",self.context.playerListDataSource[row].name,self.context.playerListDataSource[row].identity];
}
@end


@interface XWAdminListManager()

@end

@implementation XWAdminListManager
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.context.adminListDataSource.count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [NSString stringWithFormat:@"%@",self.context.adminListDataSource[row].identity];
}

@end

@interface XWBlockListManager()

@end

@implementation XWBlockListManager
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.context.blockListDataSource.count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [NSString stringWithFormat:@"%@",self.context.blockListDataSource[row].identity];
}
@end

















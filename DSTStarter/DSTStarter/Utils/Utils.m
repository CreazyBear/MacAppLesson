//
//  Utils.m
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/8.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import "Utils.h"
#import <MLHudAlert.h>
#import <arpa/inet.h>
#import "XWMainConfigurationModel.h"
#import "NSString+Extension.h"
#import <sys/socket.h>
#import <netdb.h>

@implementation Utils
+(NSArray *)freqency_descriptions {
    return  @[@"never",@"rare",@"default",@"often",@"always"];
}

+(NSArray *)starting_swaps_descriptions {
    return @[@"classic",@"default",@"highly",@"random"];
}

+(NSArray *)swaps_descriptions {
    return  @[@"default",@"none",@"few",@"normal",@"many",@"max"];
}

+(NSArray *)speed_descriptions {
    return @[@"veryslow",@"slow",@"default",@"fast",@"veryfast"];;
}

+(NSArray *)day_descriptions {
    return  @[@"default",@"longday",@"longdusk",@"longnight",@"noday",@"nodusk",@"nonight",@"onlyday",@"onlydusk",@"onlynight"];
}

+(NSArray *)season_length_descriptions {
    return  @[@"noseason",@"veryshortseason",@"shortseason",@"default",@"longseason",@"verylongseason",@"random"];
}

+(NSArray *)season_start_descriptions {
    return @[@"default",@"winter",@"spring",@"summer",@"autumnorspring",@"winterorsummer",@"random"];
}

+(NSArray *)size_descriptions {
    return @[@"small",@"medium",@"default",@"huge"];
}

+(NSArray *)branching_descriptions {
    return @[@"never",@"least",@"default",@"most"];
}

+(NSArray *)loop_descriptions {
    return @[@"never",@"default",@"always"];
}

+(NSArray *)other_descriptions {
    return @[@"caves",@"default",@"plus",@"darkness"];
}

+(NSArray *)complexity_descriptions {
     return @[@"verysimple",@"simple",@"default",@"complex",@"verycomplex"];
}

+(NSArray *)specialevent_descriptions {
    return @[@"none",@"default",@"hallowed_nights",@"winters_feast",@"year_of_the_gobbler"];
}

+(NSArray *)default_descripitions {
    return @[@"default",@"cave_default"];
}

+(NSArray *)disease_descriptions {
    return @[@"none",@"random",@"long",@"default",@"short"];
}

+(NSArray *)petrification_descriptions {
    return @[@"none",@"few",@"default",@"many",@"max"];
}

//eg:Users/xiongwei/Documents/Klei/DoNotStarveTogether
+(NSString *)documentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *documentPath = [NSString stringWithFormat:@"%@/Klei/DoNotStarveTogether",docDir];
    return documentPath;
}

+(NSString*)saveSlotPath:(NSString*)saveSlotName {
    return [NSString stringWithFormat:@"%@/%@",[self documentPath],saveSlotName];
}

+(NSString*)currentSaveSlotPath {
    return [NSString stringWithFormat:@"%@/%@",[self documentPath],[XWMainConfigurationModel defaultModel].saveSlotName];
}

+(NSArray *)styleName {
    return @[@"cooperative",@"social",@"competitive",@"madness"];
}

+(NSArray *)modeName {
    return @[@"survival",@"wilderness",@"endless"];
}

+(void)createSaveSlotWithName:(NSString*)slotName {
    NSString * fullPath = [NSString stringWithFormat:@"%@/%@",[self documentPath],slotName];
    NSFileManager * fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:fullPath]) {
        NSError * error;
        [fm createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&error];
        if(error) {
            [MLHudAlert alertWithWindow:[NSApplication sharedApplication].keyWindow type:(MLHudAlertTypeError) message:@"创建存档目录失败"];
        }
    }
}

+(void)createDirectoryAtPath:(NSString*)path {

    NSFileManager * fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:path]) {
        NSError * error;
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if(error) {
            [MLHudAlert alertWithWindow:[NSApplication sharedApplication].keyWindow type:(MLHudAlertTypeError) message:@"创建目录失败"];
        }
    }
}

+(void)deleteDirectoryAtPath:(NSString*)path {
    NSFileManager * fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:path error:nil];
}

+(int)getFreePort1 {
    int port = 0;
    int fd = -1;
    //    socklen_t = 0;
    port = -1;
    
#ifndef AF_IPV6
    struct sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    sin.sin_family = AF_INET;
    sin.sin_port = htons(0);
    sin.sin_addr.s_addr = htonl(INADDR_ANY);
    
    fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    if(fd < 0){
        printf("socket() error:%s\n", strerror(errno));
        return -1;
    }
    if(bind(fd, (struct sockaddr *)&sin, sizeof(sin)) != 0)
    {
        printf("bind() error:%s\n", strerror(errno));
        close(fd);
        return -1;
    }
    
    socklen_t len = sizeof(sin);
    if(getsockname(fd, (struct sockaddr *)&sin, &len) != 0)
    {
        printf("getsockname() error:%s\n", strerror(errno));
        close(fd);
        return -1;
    }
    
    port = sin.sin_port;
    if(fd != -1)
        close(fd);
    
#else
    struct sockaddr_in6 sin6;
    memset(&sin6, 0, sizeof(sin6));
    sin.sin_family = AF_INET6;
    sin.sin_port = htons(0);
    sin6.sin_addr.s_addr = htonl(IN6ADDR_ANY);
    
    fd = socket(AF_INET6, SOCK_STREAM, IPPROTO_TCP);
    
    if(fd < 0){
        printf("socket() error:%s\n", strerror(errno));
        return -1;
    }
    
    if(bind(fd, (struct sockaddr *)&sin6, sizeof(sin6)) != 0)
    {
        printf("bind() error:%s\n", strerror(errno));
        close(fd);
        return -1;
    }
    
    len = sizeof(sin6);
    if(getsockname(fd, (struct sockaddr *)&sin6, &len) != 0)
    {
        printf("getsockname() error:%s\n", strerror(errno));
        close(fd);
        return -1;
    }
    
    port = sin6.sin6_port;
    
    if(fd != -1)
        close(fd);
    
#endif
    return port;
}

+(int)getFreePort2:(int)startPosition {
    int    listenfd;
    struct sockaddr_in     servaddr;
    
    //创建 socket
    if( (listenfd = socket(AF_INET, SOCK_STREAM, 0)) == -1 ){
        printf("create socket error: %s(errno: %d)\n",strerror(errno),errno);
        return -1;
    }
    
    for (int i = startPosition; i<65535; i++) {
        //初始化ip地址
        memset(&servaddr, 0, sizeof(servaddr));
        servaddr.sin_family = AF_INET;
        servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
        servaddr.sin_port = htons(i);
        
        //绑定 网址端口
        if( bind(listenfd, (struct sockaddr*)&servaddr, sizeof(servaddr)) == -1){
            printf("bind socket error: %s(errno: %d)\n",strerror(errno),errno);
            continue;
        }
        else{
            close(listenfd);
            return i;
        }
    }
    return -1;
    
}

+(BOOL)checkConfigModel {
    XWMainConfigurationModel * configModel = [XWMainConfigurationModel defaultModel];
    if([configModel.saveSlotName fj_isNilOrEmpty]) {
        return NO;
    }
    
    if ([configModel.roomName fj_isNilOrEmpty]) {
        return NO;
    }
    
    if ([configModel.roomNum fj_isNilOrEmpty]) {
        return NO;
    }
    return YES;
}

@end

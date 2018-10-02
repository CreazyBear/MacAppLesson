//
//  CBGFileManager.m
//  CBGClipboard
//
//  Created by 熊伟 on 2017/8/26.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "CBGFileManager.h"

@implementation CBGFileManager
+(void)createCBGDocument
{
    NSString * documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    
    NSError * createPathError;
    NSString * filePath = [NSString stringWithFormat:@"%@/CBGPasteboard",documentPath];
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&createPathError];
    
    if (createPathError)
    {
        NSLog(@"%@",createPathError);
    }

}



@end

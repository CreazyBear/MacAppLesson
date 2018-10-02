//
//  XWCheckboxCell.m
//  DSTStarter
//
//  Created by 熊伟 on 2018/2/11.
//  Copyright © 2018年 Bear. All rights reserved.
//

#import "XWCheckboxCell.h"

@interface XWCheckboxCell()
@property (weak) IBOutlet NSButton *checkBox;
@property (nonatomic, strong) NSString *key;
@end

@implementation XWCheckboxCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)bindDataWithKey:(NSString*)key hasEnabled:(BOOL)isEnabled{
    self.key = key;
    [self.checkBox setTarget:self];
    [self.checkBox setAction:@selector(handleAction:)];
    [self.checkBox setState:isEnabled];
}

-(void)handleAction:(NSPopUpButton *)popBtn {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(changeEnabled:forKey:)]) {
        [self.delegate changeEnabled:self.checkBox.state forKey:self.key];
    }
}
@end

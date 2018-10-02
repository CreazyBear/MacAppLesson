//
//  ViewController.m
//  SpeakLine
//
//  Created by 熊伟 on 2017/8/18.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()<NSSpeechSynthesizerDelegate,NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextFieldCell *textField;
@property (weak) IBOutlet NSButton *stopButton;
@property (nonatomic, strong) NSSpeechSynthesizer *speechSynth;
@property (nonatomic, strong) NSArray *voices;
@end


@implementation ViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonStartSetup];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self commonStartSetup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonStartSetup];
    }
    return self;
}

- (void)awakeFromNib
{
    // When the table view appears on screen, the default voice
    // should be selected
    NSString *defaultVoice = [NSSpeechSynthesizer defaultVoice];
    NSInteger defaultRow = [_voices indexOfObject:defaultVoice];
    NSIndexSet *indices = [NSIndexSet indexSetWithIndex:defaultRow];
    [_tableView selectRowIndexes:indices byExtendingSelection:NO];
    [_tableView scrollRowToVisible:defaultRow];
}

- (void)commonStartSetup{
    self.speechSynth = [[NSSpeechSynthesizer alloc]initWithVoice:nil];
    self.speechSynth.delegate = self;
    self.voices = [NSSpeechSynthesizer availableVoices];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_stopButton addObserver:self forKeyPath:@"enabled" options:(NSKeyValueObservingOptionNew) context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    
}





- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (IBAction)stopIt:(id)sender {
    NSLog(@"stopping");
    [_speechSynth stopSpeaking];
    [_stopButton setEnabled:NO];
    [_startButton setEnabled:YES];
    [_tableView setEnabled:YES];
}

- (IBAction)sayIt:(id)sender {

    NSString *string = [_textField stringValue];
    if ([string length] == 0) {
        return; }
    [_speechSynth startSpeakingString:string];
    NSLog(@"Have started to say: %@", string);
    [_stopButton setEnabled:YES];
    [_startButton setEnabled:NO];
    [_tableView setEnabled:NO];
}


#pragma mark - NSSpeechSynthesizerDelegate

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)finishedSpeaking{
    NSLog(@"complete = %d", finishedSpeaking);
    [_stopButton setEnabled:NO];
    [_startButton setEnabled:YES];
    [_tableView setEnabled:YES];
    
}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender willSpeakWord:(NSRange)characterRange ofString:(NSString *)string{
    
    
}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender willSpeakPhoneme:(short)phonemeOpcode{
    
}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didEncounterErrorAtIndex:(NSUInteger)characterIndex ofString:(NSString *)string message:(NSString *)message NS_AVAILABLE_MAC(10_5){
    
}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didEncounterSyncMessage:(NSString *)message NS_AVAILABLE_MAC(10_5){
    
}

#pragma mark - NSTableViewDelegate,NSTableViewDataSource
- (id)tableView:(NSTableView *)tv
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    NSString *v = [_voices objectAtIndex:row];
    NSDictionary *dict = [NSSpeechSynthesizer attributesForVoice:v]; return [dict objectForKey:NSVoiceName];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.voices.count;
    
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger row = [_tableView selectedRow];
    if (row == 1) {
        return;
    }
    NSString *selectedVoice = [_voices objectAtIndex:row];
    [_speechSynth setVoice:selectedVoice];
    NSLog(@"new voice = %@", selectedVoice);
}




@end

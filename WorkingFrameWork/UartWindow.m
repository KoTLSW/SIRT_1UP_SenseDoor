//
//  UartWindow.m
//  BCM
//
//  Created by mini on 18/6/13.
//  Copyright © 2018年 macjinlongpiaoxu. All rights reserved.
//

#import "UartWindow.h"
#import "SerialPort.h"
#import "Param.h"
#import "GetTimeDay.h"
@interface UartWindow ()

@end

@implementation UartWindow
{
    IBOutlet NSTextView *backStringTextView;

    IBOutlet NSPopUpButton *fixPortName;
    
    SerialPort * serialPort;
    
    NSString * fixturePortName;
    NSString * fixturePortName_e;
    NSString * fixturePortName_A;
    NSString * fixturePortName_B;
    NSString * fixturePortName_C;
    NSString * fixtureportName_D;
    NSString * fixturePortName_E;
    NSString * fixturePortName_F;
    
    NSString * fixturePortName_A_e;
    NSString * fixturePortName_B_e;
    NSString * fixturePortName_C_e;
    NSString * fixtureportName_D_e;
    NSString * fixturePortName_E_e;
    NSString * fixturePortName_F_e;
    BOOL isNameDefault;
    Param * param;
}

-(id)init
{
    self = [super initWithWindowNibName:@"UartWindow"];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    param=[[Param alloc]init];
    [param ParamRead:@"Param"];

    serialPort=[[SerialPort alloc]init];
    fixturePortName_A=param.Fix1[@"fixture_uart_port_name"];
    fixturePortName_B=param.Fix2[@"fixture_uart_port_name"];
    fixturePortName_C=param.Fix3[@"fixture_uart_port_name"];
    fixtureportName_D=param.Fix4[@"fixture_uart_port_name"];
    fixturePortName_E=param.Fix5[@"fixture_uart_port_name"];
    fixturePortName_F=param.Fix6[@"fixture_uart_port_name"];

    fixturePortName_A_e=param.Fix1[@"fixture_uart_port_name_e"];
    fixturePortName_B_e=param.Fix2[@"fixture_uart_port_name_e"];
    fixturePortName_C_e=param.Fix3[@"fixture_uart_port_name_e"];
    fixtureportName_D_e=param.Fix4[@"fixture_uart_port_name_e"];
    fixturePortName_E_e=param.Fix5[@"fixture_uart_port_name_e"];
    fixturePortName_F_e=param.Fix6[@"fixture_uart_port_name_e"];
    
    BOOL isConnect=[serialPort Open:fixturePortName_A];
    if (isConnect)
    {
        isNameDefault=YES;
    }
    else
    {
        isNameDefault=NO;
    }
    
    
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)connectFixture:(NSButton *)sender
{
    if ([sender.title containsString:@"连接治具"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DisConnectFixture_A_Notification" object:nil];
        [NSThread sleepForTimeInterval:1];
        BOOL isConnect = [serialPort Open:fixturePortName];
        if (!isConnect)
        {
            isConnect = [serialPort Open:fixturePortName_e];
        }
        if (isConnect)
        {
            sender.title=@"断开连接";
        }
    }
    else
    {
        [serialPort Close];
        [NSThread sleepForTimeInterval:1];
        sender.title=@"连接治具";
    }
}
- (IBAction)chooseFixtureName:(NSPopUpButton *)sender
{
    if ([sender.title containsString:@"Fix-A"])
    {
        fixturePortName=fixturePortName_A;
        fixturePortName_e=fixturePortName_A_e;
    }
//    else if ([sender.title containsString:@"Fix-B"])
//    {
//        fixturePortName=fixturePortName_B;
//        fixturePortName_e=fixturePortName_B_e;
//    }
//    else if ([sender.title containsString:@"Fix-C"])
//    {
//        fixturePortName=fixturePortName_C;
//        fixturePortName_e=fixturePortName_C_e;
//    }
//    else if ([sender.title containsString:@"Fix-D"])
//    {
//        fixturePortName=fixtureportName_D;
//        fixturePortName_e=fixtureportName_D_e;
//    }
//    else if ([sender.title containsString:@"Fix-E"])
//    {
//        fixturePortName=fixturePortName_E;
//        fixturePortName_e=fixturePortName_E_e;
//    }
//    else if ([sender.title containsString:@"Fix-F"])
//    {
//        fixturePortName=fixturePortName_F;
//        fixturePortName_e=fixturePortName_F_e;
//    }
}

- (IBAction)sendComand:(NSPopUpButton *)sender
{
    [serialPort WriteLine:sender.title];
    [NSThread sleepForTimeInterval:0.5];
    NSString * backStr=[serialPort ReadExisting];
    [self UpdateTextView:backStr andClear:NO andTextView:backStringTextView];
}

- (IBAction)exitWindow:(NSButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReConnectFixture_A_Notification" object:nil];

    [self.window orderOut:self];
}

//更新upodateView
-(void)UpdateTextView:(NSString*)strMsg andClear:(BOOL)flagClearContent andTextView:(NSTextView *)textView
{
    if (flagClearContent)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [textView setString:@""];
                       });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                               NSString * messageString = [NSString stringWithFormat:@"%@: %@\n",[[GetTimeDay shareInstance] getFileTime],strMsg];
                               NSRange range = NSMakeRange([textView.textStorage.string length] , messageString.length);
                               [textView insertText:messageString replacementRange:range];
                               
                           
                           [textView setTextColor:[NSColor redColor]];
                       });
    }
}


@end

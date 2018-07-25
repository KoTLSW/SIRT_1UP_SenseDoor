//
//  ViewController.m
//  WorkingFrameWork
//
//  Created by mac on 2017/10/27.
//  Copyright © 2017年 macjinlongpiaoxu. All rights reserved.
//

#import "ViewController.h"
#import "Table.h"
#import "Plist.h"
#import "Param.h"
#import "TestAction.h"
#import "MKTimer.h"
#import "AppDelegate.h"
#import "Folder.h"
#import "GetTimeDay.h"
#import "FileCSV.h"
#import "visa.h"
#import "SerialPort.h"
#import "Common.h"
#import "MK_FileTXT.h"
#import "MK_FileFolder.h"

//文件名称
NSString * param_Name = @"Param";

@interface ViewController()<NSTextFieldDelegate>
{
    Table * tab1;
    
    Folder   * fold;
    FileCSV  * csvFile;
    
    Plist * plist;
    Param * param;
    NSArray    *   itemArr1;
    
    TestAction * action1;
    TestAction * action2;
    TestAction * action3;
    TestAction * action4;
    TestAction * action5;
    TestAction * action6;

    
    //定时器相关
     MKTimer * mkTimer;
     int      ct_cnt;                  //记录cycle time定时器中断的次数
    //耗材使用次数统计
    
    NSInteger PCBA_Count;
    NSInteger W_IN_Count;
    NSInteger W_OUT_Count;
    NSInteger AIR_IN_Count;
    NSInteger Okins_Count;
    NSInteger LH_Count;
    NSInteger RZLT_Count;
    NSInteger SUS_Count;
    NSInteger W_Model_Count;
    
    IBOutlet NSTextField *PCBA_Label;
    IBOutlet NSTextField *W_IN_Label;
    IBOutlet NSTextField *W_OUT_Label;
    IBOutlet NSTextField *AIR_IN_Label;
    IBOutlet NSTextField *Okins_Label;
    IBOutlet NSTextField *LH_Label;
    IBOutlet NSTextField *RZLT_Label;
    IBOutlet NSTextField *SUS_Label;
    IBOutlet NSTextField *W_Model_Label;
    
    IBOutlet NSTextField *PCBA_TF;
    IBOutlet NSTextField *W_IN_TF;
    IBOutlet NSTextField *W_OUT_TF;
    IBOutlet NSTextField *AIR_IN_TF;
    IBOutlet NSTextField *Okins_TF;
    IBOutlet NSTextField *LH_TF;
    IBOutlet NSTextField *RZLT_TF;
    IBOutlet NSTextField *SUS_TF;
    IBOutlet NSTextField *W_Model_TF;
    
    
    IBOutlet NSTextField *clearCOunt_TF;
    IBOutlet NSButton *clearBtn;
    IBOutlet NSButton *exitEditBtn;
    
    
    IBOutlet NSTextField *NS_TF1;                     //产品1输入框
    IBOutlet NSTextField *NS_TF2;                     //产品2输入框
    IBOutlet NSTextField *NS_TF3;                     //产品3输入框
    IBOutlet NSTextField *NS_TF4;                     //产品4输入框
    IBOutlet NSTextField *NS_TF5;
    IBOutlet NSTextView *Log_View;                    //Log日志
    IBOutlet NSTextField *NS_TF6;
    
    IBOutlet NSTextField *  Status_TF;                //显示状态栏
    IBOutlet NSTextField *  testFieldTimes;           //时间显示输入框
    IBOutlet NSTextField *  humiture_TF;              //温湿度显示lable
    IBOutlet NSTextField *  TestCount_TF;             //测试的次数
    IBOutlet NSButton    *  IsUploadPDCA_Button;      //上传PDCA的按钮
    IBOutlet NSButton    *  IsUploadSFC_Button;       //上传SFC的按钮
    IBOutlet NSPopUpButton *product_Type;             //产品的类型
    IBOutlet NSTextField *  Version_TF;               //软件版本
    IBOutlet NSTextField *one_air_TF;
    IBOutlet NSTextField *two_air_TF;
    IBOutlet NSTextField *water_in_TF;
    IBOutlet NSButton *makesure_button;
    
    
    __weak IBOutlet NSButton *isAutoRange;
    __weak IBOutlet NSButton *singleTest;
    __weak IBOutlet NSButton *singleTest_1;
    __weak IBOutlet NSButton *singleTest_2;
    __weak IBOutlet NSButton *singleTest_3;
    __weak IBOutlet NSButton *singleTest_4;
    __weak IBOutlet NSButton *singleTest_5;
    __weak IBOutlet NSButton *singleTest_6;
    
    IBOutlet NSTextView *A_LOG_TF;
    IBOutlet NSTextView *B_LOG_TF;
    IBOutlet NSTextView *C_LOG_TF;
    IBOutlet NSTextView *D_LOG_TF;
    IBOutlet NSTextView *E_LOG_TF;
    IBOutlet NSTextView *F_LOG_TF;
    IBOutlet NSButton      *startbutton;
    
    __weak IBOutlet NSButton *resetBtn;
    //定义对应的布尔变量 判断index=101-104是否均执行
    BOOL isFix_A_Done;
    BOOL isFix_B_Done;
    BOOL isFix_C_Done;
    BOOL isFix_D_Done;
    BOOL isFix_E_Done;
    BOOL isFix_F_Done;

    BOOL isFinish;
    
    NSString * noticeStr_A;
    NSString * noticeStr_B;
    NSString * noticeStr_C;
    NSString * noticeStr_D;
    NSString * noticeStr_E;
    NSString * noticeStr_F;
    
    
    int index;
    //创建相关的属性
    NSString * foldDir;
    AppDelegate  * app;
    
    
    //测试结束通知中返回的对象===数据中含有P代表成功，含有F代表失败
    NSString             * notiString;
    NSMutableString      * notiAppendingString;//拼接的字符串
    
    //产品通过的的次数和测试的总数
    int                   passNum;     //通过的测试次数
    int                   totalNum;    //通过的测试总数
    int                   fix_A_num;
    int                   fix_B_num;
    int                   fix_C_num;
    int                   fix_D_num;
    int                   fix_E_num;
    int                   fix_F_num;


   
    //增加无限循环限制设定
    NSString *sw_org;
    NSString *foldDir_tmp;
    
    NSString *day_T;
    NSInteger controlLog;
    
    
    SerialPort  * serialport;
    NSString * fixture_uart_port_name;
    NSString * fixture_uart_port_name_e;
    NSString * fixture_uart_port_name_act;

    SerialPort  * serialportA;
    BOOL isWaterBegined;
    NSThread *MonitorThread;
    NSString *backString_ABoard;
}

@end

@implementation ViewController


//软件测试整个流程  //door close--->SN---->config-->监测start--->下压气缸---->抛出SN-->直接运行


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCountTimes];
    day_T=[[GetTimeDay shareInstance] getCurrentDay];
    
    backString_ABoard=[[NSString alloc]init];
    isWaterBegined=NO;
    controlLog=0;
    isFix_A_Done=NO;
    isFix_B_Done=NO;
    isFix_C_Done=NO;
    isFix_D_Done=NO;
    isFix_E_Done=NO;
    isFix_F_Done=NO;
    isFinish=NO;
    
    noticeStr_A=[[NSString alloc]init];
    noticeStr_B=[[NSString alloc]init];
    noticeStr_C=[[NSString alloc]init];
    noticeStr_D=[[NSString alloc]init];
    noticeStr_E=[[NSString alloc]init];
    noticeStr_F=[[NSString alloc]init];
    
    NS_TF1.stringValue=@"1111";
    NS_TF2.stringValue=@"2222";
    NS_TF3.stringValue=@"3333";
    NS_TF4.stringValue=@"4444";
    NS_TF5.stringValue=@"5555";
    NS_TF6.stringValue=@"6666";
    
    //整型变量定义区
    index    = 0;
    passNum  = 0;
    totalNum = 0;
    
    fix_A_num = 0;
    fix_B_num = 0;
    fix_C_num = 0;
    fix_D_num = 0;
    fix_E_num = 0;
    fix_F_num = 0;

    
    serialportA  =  [[SerialPort alloc]init];
    plist = [Plist shareInstance];
    param = [[Param alloc]init];
    [param ParamRead:param_Name];
    
    [Version_TF setStringValue:param.sw_ver];
    sw_org=param.sw_ver;
    
    foldDir_tmp=param.foldDir;
    //第一响应
    [NS_TF1 acceptsFirstResponder];
    
    //加载界面
    itemArr1 = [plist PlistRead:@"Crown_Station" Key:@"AllItems"];
    tab1 = [[Table  alloc]init:Tab1_View DisplayData:itemArr1];
    
    
     notiAppendingString = [[NSMutableString alloc]initWithCapacity:10];
    
    
    
    //开启定时器
    mkTimer = [[MKTimer alloc]init];
    //获取测试Fail的全局变量
    app = [NSApplication sharedApplication].delegate;
    
    MonitorThread=[[NSThread alloc]initWithTarget:self selector:@selector(MonitorThread) object:nil];
    //创建总文件
    fold    = [[Folder alloc]init];
    csvFile = [[FileCSV alloc]init];
    
    
    //监听测试结束，重新等待SN
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectSnChangeNoti:) name:@"SNChangeNotice" object:nil];
    
    //监听A结束
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TestAEndNoti:) name:@"TestAend" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DisConnectFixture_A_Noti:) name:@"DisConnectFixture_A_Notification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReConnectFixture_A_Noti:) name:@"ReConnectFixture_A_Notification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WaterOffFinished_Noti:) name:@"waterOffFinished" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WaterBegin_Noti:) name:@"waterBegin" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginWindow:) name:@"TestUnLimit_Notification" object:nil];
    
    //将参数传入TestAction中，开启线程
    [self reloadPlist];
    
    //开启线程，扫描SN，和 获取温湿度消息
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^(void){
        
         [self Working];
        
    });

//    [MonitorThread start];
    
    // Do any additional setup after loading the view.
}



-(void)LoginWindow:(NSNotification *)noti
{
    clearCOunt_TF.hidden=NO;
    clearBtn.hidden=NO;
    exitEditBtn.hidden=NO;
}



-(void)reloadPlist
{
    action1 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix1 withFileDir:foldDir withType:1];
    action1.resultTF = DUT_Result1_TF;//显示结果的lable
    action1.Log_View  = A_LOG_TF;
    action1.dutTF    = NS_TF1;
    action1.isCancel=NO;
    [action1 setFoldDir:foldDir];
    [action1 setCsvTitle:plist.titile];
    [action1 setSw_ver:param.sw_ver];
    [action1 setSw_name:param.sw_name];

}


-(void)reloadPlistWithSingleTestState
{
    if (singleTest_1.state)
    {
        action1 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix1 withFileDir:foldDir withType:1];
        action1.resultTF = DUT_Result1_TF;//显示结果的lable
        action1.Log_View  = A_LOG_TF;
        action1.dutTF    = NS_TF1;
        action1.isCancel=NO;
        [action1 setFoldDir:foldDir];
        [action1 setCsvTitle:plist.titile];
        [action1 setSw_ver:param.sw_ver];
        [action1 setSw_name:param.sw_name];
        action1.dut_sn=[NS_TF1 stringValue];
        action1.isAuto=isAutoRange.state;
    }
        
}



- (IBAction)clearCountBtnAction:(NSButton *)sender {
    
    //PCBA
    if ([[clearCOunt_TF.stringValue uppercaseString] containsString:@"PCBA"])
    {
        PCBA_TF.stringValue=@"0";
        [self saveMaintainLogWithString:@"PCBA" AndCount:PCBA_Count];
        PCBA_Count=0;
        PCBA_Label.backgroundColor=[NSColor greenColor];
        PCBA_Label.textColor=[NSColor whiteColor];
    }
    
    //进气阀-进水
    if ([[clearCOunt_TF.stringValue uppercaseString] containsString:@"SMC_W_IN"])
    {
        W_IN_TF.stringValue=@"0";
        [self saveMaintainLogWithString:@"SMC_W_IN" AndCount:W_IN_Count];
        W_IN_Count=0;
        W_IN_Label.backgroundColor=[NSColor greenColor];
        W_IN_Label.textColor=[NSColor whiteColor];
    }
    
    //进气阀-排水
    if ([[clearCOunt_TF.stringValue uppercaseString] containsString:@"SMC_W_OUT"])
    {
        W_OUT_TF.stringValue=@"0";
        [self saveMaintainLogWithString:@"SMC_W_OUT" AndCount:W_OUT_Count];
        W_OUT_Count=0;
        W_OUT_Label.backgroundColor=[NSColor greenColor];
        W_OUT_Label.textColor=[NSColor whiteColor];
    }
    
    //进气阀-进气
    if ([[clearCOunt_TF.stringValue uppercaseString] containsString:@"SMC_AIR_IN"])
    {
        AIR_IN_TF.stringValue=@"0";
        [self saveMaintainLogWithString:@"SMC_AIR_IN" AndCount:AIR_IN_Count];
        AIR_IN_Count=0;
        AIR_IN_Label.backgroundColor=[NSColor greenColor];
        AIR_IN_Label.textColor=[NSColor whiteColor];
    }
    
    //Okins
    if ([[clearCOunt_TF.stringValue uppercaseString] containsString:@"OKINS"])
    {
        Okins_TF.stringValue=@"0";
        [self saveMaintainLogWithString:@"Okins" AndCount:Okins_Count];
        Okins_Count=0;
        Okins_Label.backgroundColor=[NSColor greenColor];
        Okins_Label.textColor=[NSColor whiteColor];
    }
    
    //LH
    if ([[clearCOunt_TF.stringValue uppercaseString] containsString:@"LH"])
    {
        LH_TF.stringValue=@"0";
        [self saveMaintainLogWithString:@"LH" AndCount:LH_Count];
        LH_Count=0;
        LH_Label.backgroundColor=[NSColor greenColor];
        LH_Label.textColor=[NSColor whiteColor];
    }
    
    //蠕动管
    if ([[clearCOunt_TF.stringValue uppercaseString] containsString:@"RZLT"])
    {
        RZLT_TF.stringValue=@"0";
        [self saveMaintainLogWithString:@"RZLT" AndCount:RZLT_Count];
        RZLT_Count=0;
        RZLT_Label.backgroundColor=[NSColor greenColor];
        RZLT_Label.textColor=[NSColor whiteColor];
    }
    
    //SUS
    if ([[clearCOunt_TF.stringValue uppercaseString] containsString:@"SUS"])
    {
        SUS_TF.stringValue=@"0";
        [self saveMaintainLogWithString:@"SUS" AndCount:SUS_Count];
        SUS_Count=0;
        SUS_Label.backgroundColor=[NSColor greenColor];
        SUS_Label.textColor=[NSColor whiteColor];
    }
    
    //进水模组
    if ([[clearCOunt_TF.stringValue uppercaseString] containsString:@"W_MODEL"])
    {
        W_Model_TF.stringValue=@"0";
        [self saveMaintainLogWithString:@"W_Model" AndCount:W_Model_Count];
        W_Model_Count=0;
        W_Model_Label.backgroundColor=[NSColor greenColor];
        W_Model_Label.textColor=[NSColor whiteColor];
    }
    
    [self saveCountLogWithString];
    clearCOunt_TF.stringValue=@"";
}


- (IBAction)exitEditBtnAction:(NSButton *)sender {
    sender.hidden=YES;
    clearCOunt_TF.hidden=YES;
    clearBtn.hidden=YES;
}


- (IBAction)start_Action:(id)sender //发送通知开始测试
{
    
    startbutton.enabled = NO;
    
}


- (IBAction)singleTest:(NSButton *)sender
{
    NSLog(@"sender.state==%ld",(long)sender.state);

    if (sender.state)
    {
        singleTest_1.enabled=YES;
        singleTest_2.enabled=YES;
        singleTest_3.enabled=YES;
        singleTest_4.enabled=YES;
        singleTest_5.enabled=YES;
        singleTest_6.enabled=YES;
    }
    else
    {
        singleTest_1.enabled=NO;
        singleTest_2.enabled=NO;
        singleTest_3.enabled=NO;
        singleTest_4.enabled=NO;
        singleTest_5.enabled=NO;
        singleTest_6.enabled=NO;
    }
}

- (IBAction)singleTest_1:(NSButton *)sender
{
    if (sender.state == 0)
    {
        action1.isCancel=YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelCurrentThread" object:@""];
        
    }
    else
    {
        //将参数传入TestAction中，开启线程
        action1 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix1 withFileDir:foldDir withType:1];
        action1.resultTF = DUT_Result1_TF;//显示结果的lable
        action1.Log_View  = A_LOG_TF;
        action1.dutTF    = NS_TF1;
        action1.isCancel=NO;
        [action1 setFoldDir:foldDir];
        [action1 setCsvTitle:plist.titile];
        [action1 setSw_ver:param.sw_ver];
        [action1 setSw_name:param.sw_name];
        action1.dut_sn = [NS_TF1 stringValue];

    }

}
- (IBAction)singleTest_2:(NSButton *)sender
{

    if (!sender.state)
    {
        action2.isCancel=YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelCurrentThread" object:@""];

    }
    else
    {
        action2 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix2 withFileDir:foldDir withType:2];
        action2.resultTF = DUT_Result2_TF;//显示结果的lable
        action2.Log_View = B_LOG_TF;
        action2.dutTF    = NS_TF2;
        action2.isCancel=NO;
        [action2 setFoldDir:foldDir];
        [action2 setCsvTitle:plist.titile];
        [action2 setSw_ver:param.sw_ver];
        [action2 setSw_name:param.sw_name];
        action2.dut_sn = [NS_TF2 stringValue];

    }

}
- (IBAction)singleTest_3:(NSButton *)sender
{

    if (!sender.state)
    {
        action3.isCancel=YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelCurrentThread" object:@""];

    }
    else
    {
        action3 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix3 withFileDir:foldDir withType:3];
        action3.resultTF = DUT_Result3_TF;//显示结果的lable
        action3.Log_View = C_LOG_TF;
        action3.dutTF    = NS_TF3;
        action3.isCancel=NO;
        [action3 setFoldDir:foldDir];
        [action3 setCsvTitle:plist.titile];
        [action3 setSw_ver:param.sw_ver];
        [action3 setSw_name:param.sw_name];
        action3.dut_sn = [NS_TF3 stringValue];



    }

}
- (IBAction)singleTest_4:(NSButton *)sender
{

    if (!sender.state)
    {
        action4.isCancel=YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelCurrentThread" object:@""];

    }
    else
    {
        action4 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix4 withFileDir:foldDir withType:4];
        action4.resultTF = DUT_Result4_TF;//显示结果的lable
        action4.Log_View = D_LOG_TF;
        action4.dutTF    = NS_TF4;
        action4.isCancel=NO;
        [action4 setFoldDir:foldDir];
        [action4 setCsvTitle:plist.titile];
        [action4 setSw_ver:param.sw_ver];
        [action4 setSw_name:param.sw_name];
        action4.dut_sn = [NS_TF4 stringValue];

    }

}

- (IBAction)singleTest_5:(NSButton *)sender
{
    
    if (!sender.state)
    {
        action5.isCancel=YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelCurrentThread" object:@""];
        
    }
    else
    {
        action5 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix5 withFileDir:foldDir withType:5];
        action5.resultTF = DUT_Result5_TF;//显示结果的lable
        action5.Log_View = E_LOG_TF;
        action5.dutTF    = NS_TF5;
        action5.isCancel=NO;
        [action5 setFoldDir:foldDir];
        [action5 setCsvTitle:plist.titile];
        [action5 setSw_ver:param.sw_ver];
        [action5 setSw_name:param.sw_name];
        action5.dut_sn = [NS_TF5 stringValue];

        
    }
    
}



- (IBAction)singleTest_6:(NSButton *)sender
{
    
    if (!sender.state)
    {
        action6.isCancel=YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelCurrentThread" object:@""];
        
    }
    else
    {
        action6 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix6 withFileDir:foldDir withType:6];
        action6.resultTF = DUT_Result6_TF;//显示结果的lable
        action6.Log_View = E_LOG_TF;
        action6.dutTF    = NS_TF6;
        action6.isCancel=NO;
        [action6 setFoldDir:foldDir];
        [action6 setCsvTitle:plist.titile];
        [action6 setSw_ver:param.sw_ver];
        [action6 setSw_name:param.sw_name];
        action6.dut_sn = [NS_TF6 stringValue];

        
    }
    
}




#pragma mark=======================通知
//=============================================
-(void)selectSnChangeNoti:(NSNotification *)noti
{
     notiString = noti.object;
     totalNum++;
    
    if ([noti.object containsString:@"1"]) {
        
        fix_A_num = 101;
        noticeStr_A=noti.object;
        [notiAppendingString appendString:noti.object];
        NSLog(@"fixture_A 测试已经完成了");
    }
    if ([noti.object containsString:@"2"]) {
        
        fix_B_num = 102;
        noticeStr_B=noti.object;
        [notiAppendingString appendString:noti.object];

        NSLog(@"fixture_B 测试已经完成了");
    }
    if ([noti.object containsString:@"3"]) {
        
        fix_C_num = 103;
        noticeStr_C=noti.object;
        [notiAppendingString appendString:noti.object];

        NSLog(@"fixture_C 测试已经完成了");
    }
    if ([noti.object containsString:@"4"]) {
        
        fix_D_num = 104;
        noticeStr_D=noti.object;
        [notiAppendingString appendString:noti.object];

        NSLog(@"fixture_D 测试已经完成了");
    }
    if ([noti.object containsString:@"5"]) {
        
        fix_E_num = 105;
        noticeStr_E=noti.object;
        [notiAppendingString appendString:noti.object];
        
        NSLog(@"fixture_E 测试已经完成了");
    }
    if ([noti.object containsString:@"6"]) {
        
        fix_F_num = 106;
        noticeStr_F=noti.object;
        [notiAppendingString appendString:noti.object];
        
        NSLog(@"fixture_F 测试已经完成了");
    }
    
    //软件测试结束
    if (([notiAppendingString containsString:@"1"] || singleTest_1.state==0)&&([notiAppendingString containsString:@"2"] || singleTest_2.state==0)&&([notiAppendingString containsString:@"3"] || singleTest_3.state==0)&&([notiAppendingString containsString:@"4"] || singleTest_4.state==0)&&([notiAppendingString containsString:@"5"] || singleTest_5.state==0)&&([notiAppendingString containsString:@"6"] || singleTest_6.state==0)) {
        
        index = 107;
        notiAppendingString = [NSMutableString stringWithFormat:@""];
    }

}



#pragma mark------------重新设置放水和空气的时间
- (IBAction)resetAirandWater_action:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kResetAirAndWaterTime object:[NSString stringWithFormat:@"%@=%@=%@",[one_air_TF.stringValue length]>0?one_air_TF.stringValue:0,[water_in_TF.stringValue length]>0?water_in_TF.stringValue:0,[two_air_TF.stringValue  length]>0?two_air_TF.stringValue:0]];
    
}

- (IBAction)isAutoRange:(NSButton *)sender
{
    
}

- (IBAction)resetBtn:(NSButton *)sender
{
    if (index!=1000)
    {
        [mkTimer endTimer];
        [serialportA WriteLine:@"Fixture valve up"];
        index=0;
        return;
    }
    sender.enabled=NO;
    [serialportA Close];
    [NSThread sleepForTimeInterval:0.1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"threadReset" object:@""];

}

-(void)WaterOffFinished_Noti:(NSNotification *)noti
{
    [mkTimer endTimer];
    [serialportA Open:fixture_uart_port_name_act];
    [serialportA WriteLine:@"Fixture valve up"];
    [NSThread sleepForTimeInterval:0.5];
    
    [Status_TF setStringValue:@"请重启软件测试..."];
    [Status_TF setBackgroundColor:[NSColor yellowColor]];
    index=1000;
}

-(void)WaterBegin_Noti:(NSNotification *)noti
{
    isWaterBegined=YES;
}

-(void)DisConnectFixture_A_Noti:(NSNotification *)noti
{
    [serialportA Close];
    index=1000;
}

-(void)ReConnectFixture_A_Noti:(NSNotification *)noti
{
    index=0;
}







//去掉回显
-(NSString *)backtringCut:(NSString *)backStr
{
    NSString *str;
    NSArray *arr=[backStr componentsSeparatedByString:@"\r\n"];
    if (arr.count>1) {
        
         str=arr[1];
    }
    else
    {
        str=@"";
    }
    return str;
}



-(void)MonitorThread
{
    while ([[NSThread currentThread] isCancelled]==NO)
    {
        [NSThread sleepForTimeInterval:0.5];
        if ([serialportA IsOpen])
        {
            backString_ABoard=[serialportA ReadExisting];
            if (![backString_ABoard isEqualToString:@""])
            {
                NSLog(@"主线程：%@",backString_ABoard);
            }
            if ([backString_ABoard containsString:@"scram on"] || [backString_ABoard containsString:@"End"])
            {
                [self UpdateTextView:@"接收到中断" andClear:NO andTextView:Log_View];
                [mkTimer endTimer];
                [serialportA Close];
                [NSThread sleepForTimeInterval:0.5];
                index=0;
            }
            else if([backString_ABoard containsString:@"Start"])
            {
                startbutton.enabled=NO;
                [self UpdateTextView:@"双启动开始" andClear:NO andTextView:Log_View];
            }
            else if ([backString_ABoard containsString:@">>OK Fixture valve down"])
            {
                [serialportA Close];
                [NSThread sleepForTimeInterval:0.5];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NSThreadStart_Notification" object:@""];
            }
            else
            {
                
            }

        }
        
    }
}



//=============================================


-(void)Working
{
    while ([[NSThread currentThread] isCancelled]==NO) //线程未结束一直处于循环状态
    {
#pragma mark-------------//index=0,连接治具A
        if (index==0)
        {
            [NSThread sleepForTimeInterval:0.1];
            fixture_uart_port_name=param.Fix1[@"fixture_uart_port_name"];
            fixture_uart_port_name_e=param.Fix1[@"fixture_uart_port_name_e"];
            BOOL isCollect = [serialportA Open:fixture_uart_port_name];
            fixture_uart_port_name_act=fixture_uart_port_name;
            if (!isCollect)
            {
                isCollect = [serialportA Open:fixture_uart_port_name_e];
                fixture_uart_port_name_act=fixture_uart_port_name_e;
            }
            if (isCollect)
            {
                NSLog(@"index= 0,连接治具%@",fixture_uart_port_name_act);
                [self UpdateTextView:@"index=0,治具已经连接" andClear:NO andTextView:Log_View];
                index =1;
            }
            if (param.isDebug)
            {
                index=1;
            }
            
        }
        
#pragma mark-------------//index=1,输入 SN
        if (index == 1) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [Status_TF setStringValue:@"index=1,请输入 SN!"];
                [Status_TF setBackgroundColor:[NSColor greenColor]];
                resetBtn.enabled=YES;
            });
            [NSThread sleepForTimeInterval:0.3];
            if (controlLog==0)
            {
                [self UpdateTextView:@"index=1,请输入SN" andClear:NO andTextView:Log_View];
            }
            controlLog=1;
             dispatch_sync(dispatch_get_main_queue(), ^{
                if (([NS_TF1.stringValue length]==17 ||[NS_TF1.stringValue length]==4 || singleTest_1.state==0)&&([NS_TF2.stringValue length]==17 ||[NS_TF2.stringValue length]==4 || singleTest_2.state==0)&&([NS_TF3.stringValue length]==17 ||[NS_TF3.stringValue length]==4 || singleTest_3.state==0)&&([NS_TF4.stringValue length]==17 ||[NS_TF4.stringValue length]==4 || singleTest_4.state==0) &&([NS_TF5.stringValue length]==17 ||[NS_TF5.stringValue length]==4 || singleTest_5.state==0) &&([NS_TF6.stringValue length]==17 ||[NS_TF6.stringValue length]==4 || singleTest_6.state==0) && !(singleTest_1.state==0 && singleTest_2.state==0 && singleTest_3.state==0 && singleTest_4.state==0 && singleTest_5.state==0 && singleTest_6.state==0))
                {
                    
                    startbutton.enabled = YES;
                    [NSThread sleepForTimeInterval:0.2];
                    index = 2;
                    
                }
                
            });
        }
        
        
        
#pragma mark-------------//index=2,点击“开始”进行测试
        if (index == 2) { //判断当前配置文件和changeID等配置
            
            [NSThread sleepForTimeInterval:0.1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [Status_TF setStringValue:@"index=2,请点击“开始”进行测试!"];
                [Status_TF setBackgroundColor:[NSColor greenColor]];
            });
            [self UpdateTextView:@"index=2,请点击“开始”进行测试!" andClear:NO andTextView:Log_View];
            index = 3;
            
        }
        
#pragma mark-------------//index=3,治具下压，进入子线程测试
        if (index == 3)
        {
            
            [NSThread sleepForTimeInterval:0.2];
            if (startbutton.enabled == NO)
            {
                
                while (1)
                {
                    if (param.isDebug)
                    {
                        break;
                    }
                    [serialportA WriteLine:@"Are You Ready"];
                    [NSThread sleepForTimeInterval:0.5];
                    NSString * backStr=[serialportA ReadExisting];
                    if ([[backStr uppercaseString] containsString:@"READY OK\r\n"])
                    {
                        [self UpdateTextView:@"index=3,屏蔽箱门已关上!" andClear:NO andTextView:Log_View];
                        break;
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [Status_TF setStringValue:@"index=3,请关上屏蔽箱门..."];
                            [Status_TF setBackgroundColor:[NSColor yellowColor]];
                        });
                    }
                }
                [self countChange];
                action1.dut_sn = [NS_TF1 stringValue];
                action1.isAuto=isAutoRange.state;
                
                [tab1 ClearTable]; //清理界面
                [testFieldTimes setStringValue:@"0"];
                [mkTimer setTimer:0.1];
                [mkTimer startTimerWithTextField:testFieldTimes];
                ct_cnt = 1;

               
                [serialportA WriteLine:@"Fixture valve down"];
                [NSThread sleepForTimeInterval:2];
                [serialportA ReadExisting];
                [NSThread sleepForTimeInterval:0.1];
                [serialportA Close];
                [NSThread sleepForTimeInterval:0.5];
                [self creat_TotalFile];
                dispatch_async(dispatch_get_main_queue(), ^{

                    [Status_TF setStringValue:@"index=3,测试中..."];
                    [Status_TF setBackgroundColor:[NSColor greenColor]];
                    [self showCountTimes];
                    [self saveCountLogWithString];

                });
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NSThreadStart_Notification" object:@""];
                index = 1000;
            }
        }
        

        
#pragma mark-------------//index=101,A治具测试结束，发送指令信号灯
        if (fix_A_num == 101) {
            
            isFix_A_Done=YES;
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"治具A测试完毕，灯光操作完成");
            fix_A_num = 0;
            noticeStr_A=@"";
            
        }
        
        
#pragma mark-------------//index=102,B治具测试结束，发送指令信号灯
        if (fix_B_num == 102) {
            
            isFix_B_Done=YES;
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"102--passnum=%d",passNum);
            NSLog(@"治具B测试完毕，灯光操作完成");
            fix_B_num =0;
            noticeStr_B=@"";
            
        }
        
#pragma mark-------------//index=103,C治具测试结束，发送指令信号灯
        if (fix_C_num == 103) {
            
            isFix_C_Done=YES;
            [NSThread sleepForTimeInterval:0.1];
             NSLog(@"103--passnum=%d",passNum);
            NSLog(@"治具C测试完毕，灯光操作完成");
            fix_C_num = 0;
            noticeStr_C=@"";
            
        }
        
        
#pragma mark-------------//index=104,D治具测试结束，发送指令信号灯
        if (fix_D_num == 104) { //扫描SN
            
            isFix_D_Done=YES;
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"治具D测试完毕，灯光操作完成");
            fix_D_num = 0;
            noticeStr_D=@"";
            
        }
        
#pragma mark-------------//index=105,E治具测试结束，发送指令信号灯
        if (fix_E_num == 105) { //扫描SN
            
            isFix_E_Done=YES;
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"105--passnum=%d",passNum);
            NSLog(@"治具E测试完毕，灯光操作完成");
            fix_E_num = 0;
            noticeStr_E=@"";
            
        }
        
#pragma mark-------------//index=106,F治具测试结束，发送指令信号灯
        if (fix_F_num == 106) { //扫描SN
            
            isFix_F_Done=YES;
            [NSThread sleepForTimeInterval:0.1];
            NSLog(@"106--passnum=%d",passNum);
            NSLog(@"治具F测试完毕，灯光操作完成");
            fix_F_num = 0;
            noticeStr_F=@"";
            
        }
  
#pragma mark-------------//index=105,所有软件测试结束
        if (index == 107 || isFinish)
        {
            [NSThread sleepForTimeInterval:0.1];
            controlLog=0;
            if (!isFix_A_Done && singleTest_1.state==1)
            {
                index=101;
                isFinish=YES;
            }
            else if (!isFix_B_Done && singleTest_2.state==1)
            {
                index=102;
                isFinish=YES;
            }
            else if (!isFix_C_Done && singleTest_3.state==1)
            {
                index=103;
                isFinish=YES;
            }
            else if (!isFix_D_Done && singleTest_4.state==1)
            {
                index=104;
                isFinish=YES;
            }
            else if (!isFix_E_Done && singleTest_5.state==1)
            {
                index=105;
                isFinish=YES;
            }
            else if (!isFix_F_Done && singleTest_6.state==1)
            {
                index=106;
                isFinish=YES;
            }
            else
            {
                isWaterBegined=NO;
                
                [serialportA Open:fixture_uart_port_name_act];
                    isFix_A_Done=NO;
                    isFix_B_Done=NO;
                    isFix_C_Done=NO;
                    isFix_D_Done=NO;
                    isFix_E_Done=NO;
                    isFix_F_Done=NO;
                    isFinish    =NO;
                
                [NSThread sleepForTimeInterval:0.5];
                [serialportA WriteLine:@"Fixture valve up"];
                [NSThread sleepForTimeInterval:0.5];
                [serialportA Close];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Status_TF setStringValue:@"index=3,测试结束！"];
                    [Status_TF setBackgroundColor:[NSColor greenColor]];
                    
                    [TestCount_TF setStringValue:[NSString stringWithFormat:@"%d/%d",app.passNum,totalNum]];
                    //========定时器结束========
                    [mkTimer endTimer];
                    ct_cnt = 0;
                    makesure_button.enabled = YES;
                    one_air_TF.enabled = YES;
                    two_air_TF.enabled = YES;
                    water_in_TF.enabled = YES;
                    
                    
                    
                });


                index = 0;
            }
            
            
        }
        
        

        
        
#pragma mark-------------//index=1000,测试结束
        if (index == 1000)
        { //等待测试结束，并返回测试的结果
            [NSThread sleepForTimeInterval:0.5];
        }

   
    }
    
    
}






//创建A,B,C,D治具对应的文件ABCD
-(void)creat_TotalFile
{
    
    
    NSString  *  day = [[GetTimeDay shareInstance] getCurrentDay];
    
    foldDir = [NSString stringWithFormat:@"%@/%@/%@_%@",foldDir_tmp,day,param.sw_name,param.sw_ver];
 
 
    [action1 setFoldDir:foldDir];
    [action2 setFoldDir:foldDir];
    [action3 setFoldDir:foldDir];
    [action4 setFoldDir:foldDir];
    [action5 setFoldDir:foldDir];
    [action6 setFoldDir:foldDir];

    
    
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@.csv",foldDir,day]];
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_A.csv",foldDir,day]];
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_B.csv",foldDir,day]];
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_C.csv",foldDir,day]];
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_D.csv",foldDir,day]];
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_E.csv",foldDir,day]];
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_F.csv",foldDir,day]];
    
   
    
}


/**
 *  生成文件
 *
 *  @param fileString 文件的地址
 */
-(void)createFileWithstr:(NSString *)fileString
{
    while (YES) {
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileString]) {
            break;
        }
        else
        {
            
            [fold Folder_Creat:foldDir];
            [csvFile CSV_Open:fileString];
            [csvFile CSV_Write:plist.titile];
        }
        
    }

}





#pragma mark 控制光标 成为第一响应者

-(void)controlTextDidChange:(NSNotification *)obj{
    
    NSTextField *tf = (NSTextField *)obj.object;
    
    if (tf.tag == 6) {
        
        [tf setEditable:YES];
    }
    
    if (tf.stringValue.length == 4) {
        
        NSTextField *nextTF = [self.view viewWithTag:tf.tag+1];
        
        if (nextTF) {
            
            
            if (nextTF.tag == 6) {
                
                [nextTF setEditable:YES];
                
            }
            [tf resignFirstResponder];
            [nextTF becomeFirstResponder];
            
        }
        if (tf.tag == 6 ) {
            
            [tf setEditable:NO];
            
        }
    }
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
                           if ([[textView string]length]>0)
                           {
                               NSString * messageString = [NSString stringWithFormat:@"%@: %@\n",[[GetTimeDay shareInstance] getFileTime],strMsg];
                               NSRange range = NSMakeRange([textView.textStorage.string length] , messageString.length);
                               [textView insertText:messageString replacementRange:range];
                               
                           }
                           else
                           {
                                NSString * messageString = [NSString stringWithFormat:@"%@: %@\n",[[GetTimeDay shareInstance] getFileTime],strMsg];
                               [textView setString:[NSString stringWithFormat:@"%@\n",messageString]];
                           }
                           
                               [textView setTextColor:[NSColor redColor]];
                           
                       });
    }
}









-(void)viewWillDisappear
{
    if (action1 != nil) {
        
        [action1 threadEnd];
        action1 = nil;
    }
    if (action2 != nil) {
        
        [action2 threadEnd];
        action2 = nil;
    }
    if (action3 != nil) {
        
        [action3 threadEnd];
        action3 = nil;
    }
    if (action4 != nil) {
        
        [action4 threadEnd];
        action4 = nil;
    }
    if (action5 != nil) {
        
        [action5 threadEnd];
        action5 = nil;
    }
    if (action6 != nil) {
        
        [action6 threadEnd];
        action6 = nil;
    }
    [NSThread sleepForTimeInterval:1];
    exit(1);
}

-(void)viewDidDisappear
{
    exit(0);
}

-(void)initCountTimes
{
    NSString *strRead=[[MK_FileTXT shareInstance] TXT_ReadFromPath:@"/vault/EW_Count_Log/EW_Count_Log.txt"];
    
    if (strRead.length > 8)
    {
        NSLog(@"log 文件存在");
        NSArray *dataArr=[strRead componentsSeparatedByString:@","];
        PCBA_Count=[dataArr[0] integerValue];
        W_IN_Count=[dataArr[1] integerValue];
        W_OUT_Count=[dataArr[2] integerValue];
        AIR_IN_Count=[dataArr[3] integerValue];
        Okins_Count=[dataArr[4] integerValue];
        LH_Count=[dataArr[5] integerValue];
        RZLT_Count=[dataArr[6] integerValue];
        SUS_Count=[dataArr[7] integerValue];
        W_Model_Count=[dataArr[8] integerValue];
        
    }
    else
    {
        NSLog(@"log 文件不存在");
        PCBA_Count=0;
        W_IN_Count=0;
        W_OUT_Count=0;
        AIR_IN_Count=0;
        Okins_Count=0;
        LH_Count=0;
        RZLT_Count=0;
        SUS_Count=0;
        W_Model_Count=0;
    }
    [self showCountTimes];
    
    
}

-(void)showCountTimes
{
    
    PCBA_TF.stringValue=[NSString stringWithFormat:@"%ld",PCBA_Count];
    W_IN_TF.stringValue=[NSString stringWithFormat:@"%ld",W_IN_Count];
    W_OUT_TF.stringValue=[NSString stringWithFormat:@"%ld",W_OUT_Count];
    AIR_IN_TF.stringValue=[NSString stringWithFormat:@"%ld",AIR_IN_Count];
    Okins_TF.stringValue=[NSString stringWithFormat:@"%ld",Okins_Count];
    LH_TF.stringValue=[NSString stringWithFormat:@"%ld",LH_Count];
    RZLT_TF.stringValue=[NSString stringWithFormat:@"%ld",RZLT_Count];
    SUS_TF.stringValue=[NSString stringWithFormat:@"%ld",SUS_Count];
    W_Model_TF.stringValue=[NSString stringWithFormat:@"%ld",W_Model_Count];

    
    //PCBA
    if (PCBA_Count > 69000 && PCBA_Count < 70000)
    {
        PCBA_Label.backgroundColor=[NSColor yellowColor];
        PCBA_Label.textColor=[NSColor blackColor];
    }
    else if (PCBA_Count >= 70000)
    {
        PCBA_Label.backgroundColor=[NSColor redColor];
    }
    else
    {
        PCBA_Label.backgroundColor=[NSColor greenColor];
    }
    
    
    //单向阀-进水
    if (W_IN_Count > 19000 && W_IN_Count < 20000)
    {
        W_IN_Label.backgroundColor=[NSColor yellowColor];
        W_IN_Label.textColor=[NSColor blackColor];
    }
    else if (W_IN_Count > 20000)
    {
        W_IN_Label.backgroundColor=[NSColor redColor];
    }
    else
    {
        W_IN_Label.backgroundColor=[NSColor greenColor];
    }
    
    
    //单向阀-出水
    if (W_OUT_Count > 19000 && W_OUT_Count < 20000)
    {
        W_OUT_Label.backgroundColor=[NSColor yellowColor];
        W_OUT_Label.textColor=[NSColor blackColor];
    }
    else if (W_OUT_Count > 20000)
    {
        W_OUT_Label.backgroundColor=[NSColor redColor];
    }
    else
    {
        W_OUT_Label.backgroundColor=[NSColor greenColor];
    }
    
    
    //单向阀-进气
    if (AIR_IN_Count > 19000 && AIR_IN_Count < 20000)
    {
        AIR_IN_Label.backgroundColor=[NSColor yellowColor];
        AIR_IN_Label.textColor=[NSColor blackColor];
    }
    else if (AIR_IN_Count > 20000)
    {
        AIR_IN_Label.backgroundColor=[NSColor redColor];
    }
    else
    {
        AIR_IN_Label.backgroundColor=[NSColor greenColor];
    }
    
    
    
    //Okins
    if (Okins_Count > 2800 && Okins_Count < 3000)
    {
        Okins_Label.backgroundColor=[NSColor yellowColor];
        Okins_Label.textColor=[NSColor blackColor];
    }
    else if (Okins_Count > 3000)
    {
        Okins_Label.backgroundColor=[NSColor redColor];
    }
    else
    {
        Okins_Label.backgroundColor=[NSColor greenColor];
    }
    
    
    //LH
    if (LH_Count > 29000 && LH_Count < 30000)
    {
        LH_Label.backgroundColor=[NSColor yellowColor];
        LH_Label.textColor=[NSColor blackColor];
    }
    else if (LH_Count > 30000)
    {
        LH_Label.backgroundColor=[NSColor redColor];
    }
    else
    {
        LH_Label.backgroundColor=[NSColor greenColor];
    }
    
    
    //RZLT
    if (RZLT_Count > 19000 && RZLT_Count < 20000)
    {
        RZLT_Label.backgroundColor=[NSColor yellowColor];
        RZLT_Label.textColor=[NSColor blackColor];
    }
    else if (RZLT_Count > 20000)
    {
        RZLT_Label.backgroundColor=[NSColor redColor];
    }
    else
    {
        RZLT_Label.backgroundColor=[NSColor greenColor];
    }
    
    
    //SUS
    if (SUS_Count > 19000 && SUS_Count < 20000)
    {
        SUS_Label.backgroundColor=[NSColor yellowColor];
        SUS_Label.textColor=[NSColor blackColor];
    }
    else if (SUS_Count > 20000)
    {
        SUS_Label.backgroundColor=[NSColor redColor];
    }
    else
    {
        SUS_Label.backgroundColor=[NSColor greenColor];
    }
    
    
    //Model
    if (W_Model_Count > 14000 && W_Model_Count < 15000)
    {
        W_Model_Label.backgroundColor=[NSColor yellowColor];
        W_Model_Label.textColor=[NSColor blackColor];
    }
    else if (W_Model_Count > 15000)
    {
        W_Model_Label.backgroundColor=[NSColor redColor];
    }
    else
    {
        W_Model_Label.backgroundColor=[NSColor greenColor];
    }
    
    
    
}

-(void)saveCountLogWithString
{
    NSString *string=[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@\n",PCBA_TF.stringValue,W_IN_TF.stringValue,W_OUT_TF.stringValue,AIR_IN_TF.stringValue,Okins_TF.stringValue,LH_TF.stringValue,RZLT_TF.stringValue,SUS_TF.stringValue,W_Model_TF.stringValue];
    NSString * logPath=@"/vault/EW_Count_Log";
    [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:logPath];
    [[MK_FileTXT shareInstance] createOrFlowTXTFileWithFolderPath:logPath FileName:@"EW_Count_Log" Content:string];
}

-(void)saveMaintainLogWithString:(NSString *)string AndCount:(NSInteger)count
{
    NSString *str=[NSString stringWithFormat:@"%@ 进行了更换，更换前使用次数为%ld",string,count];
    NSString * logPath=@"/vault/SIRT_Maintain_Log";
    
    [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:logPath];
    
    [[MK_FileTXT shareInstance] createOrFlowTXTFileWithFolderPath:logPath FileName:@"SIRT_Maintain_Log" Content:str];
}

-(void)countChange
{
    if (singleTest_1.state==1)
    {
        PCBA_Count++;
        W_IN_Count++;
        W_OUT_Count++;
        AIR_IN_Count++;
        Okins_Count++;
        LH_Count++;
        RZLT_Count++;
        SUS_Count++;
        W_Model_Count++;
    }
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end

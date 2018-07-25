//
//  TestAction.m
//  WorkingFrameWork
//
//  Created by mac on 2017/10/27.
//  Copyright © 2017年 macjinlongpiaoxu. All rights reserved.
//

#import "TestAction.h"
#import "AppDelegate.h"


#define SNChangeNotice  @"SNChangeNotice"
NSString  *param_path=@"Param";

@interface TestAction ()
{

    
    //************ testItems ************
    double num;
    NSString        *agilentReadString;
    NSString        *SonTestDevice;
    NSString        *SonTestName;
    NSString        *testResultStr;                           //测试结果
    NSMutableArray  *testResultArr;                           // 返回的结果数组

    
    NSThread        * thread;                                   //开启的线程
    AgilentB2987A   * agilentB2987A;                            //静电计
    SerialPort      * serialport;                               //串口通讯类
    Plist           * plist;                                    //plist文件处理类
    Param           * param;                                    // param参数类
    
    
    
    int        delayTime;
    int        index;                                         // 测试流程下标
    int        item_index;                                    // 测试项下标
    int        row_index;                                     // table 每一行下标
    Item     * testItem;                                      //测试项
    Item     * showItem;                                      //显示的测试项
    
    
    NSString * fixtureBackString;                             //治具返回来的数据
    NSString * testvalue;                                   //测试项的字符串
   
    
    AppDelegate  * app;                                       //存储测试的次数
    Folder       * fold;                                      //文件夹的类
    FileCSV      * csv_file;                                  //csv文件的类
    FileCSV      * total_file;                                //写csv总文件
    FileTXT      * txt_file;                                  //txt文件
    
    //************* timer *************
    NSString            * start_time;                         //启动测试的时间
    NSString            * end_time;                           //结束测试的时间
    GetTimeDay          * timeDay;                            //创建日期类
    int                  one_airtime;                         //进气时间
    int                  water_time;                          //进水时间
    int                  two_airtime;                         //排水时间，即第二次进气时间
    
    
    //csv数据相关处理
    NSMutableArray * ItemArr;                                 //存测试对象的数组
    NSMutableArray * TestValueArr;                            //存储测试结果的数组
    NSMutableString     * txtContentString;                   //打印txt文件中的log
    NSMutableString     * listFailItemString;                 //测试失败的项目
    NSMutableString     * ErrorMessageString;                 //失败测试项的原因
    
    BOOL       PF;
    //存储生成文件的具体地址
    NSString   * eachCsvDir;
    int          fix_type;
    
    
    //处理SFC相关的类
    NSString               * FixtureID;                         //治具的ID
    
    NSString               * itemResult;

    BOOL                     isAgilentConnect;
    BOOL                     isAlreadyStart;
    BOOL                     isFixtureConnect;
    BOOL isReceiveSuccessed;
}
@end

@implementation TestAction

/**相关的说明
  1.Fixture ID 返回的值    Fixture ID?\r\nEW011X*_*\r\n       其中x代表治具中A,B,C,D

 
 
*/





-(id)initWithTable:(Table *)tab withFixDic:(NSDictionary *)fix withFileDir:foldDir withType:(int)type_num
{
    if (self =[super init]) {
        
        isReceiveSuccessed=NO;
        //设置默认时间
        one_airtime = 2;
        water_time  = 15;
        two_airtime = 10;
        
        self.tab =tab;
        fix_type = type_num;
        
        index = 1000;
        item_index   = 0;
        row_index    = 0;
        isAgilentConnect=NO;
        isAlreadyStart=NO;
        isFixtureConnect=NO;
        PF = YES;
        
        //初始化各类数组和可变字符串
        ItemArr =      [[NSMutableArray alloc]initWithCapacity:10];
        TestValueArr = [[NSMutableArray alloc] initWithCapacity:10];
        txtContentString=[[NSMutableString alloc]initWithCapacity:10];
        listFailItemString=[[NSMutableString alloc]initWithCapacity:10];
        ErrorMessageString=[[NSMutableString alloc]initWithCapacity:10];
        testResultArr=[[NSMutableArray alloc] initWithCapacity:10];
        
        param = [[Param alloc]init];
        [param ParamRead:param_path];
        plist = [Plist shareInstance];
        
        //初始化各种串口
        timeDay     =  [GetTimeDay shareInstance];
        serialport  =  [[SerialPort alloc]init];
        [serialport setTimeout:1 WriteTimeout:1];
        
        agilentB2987A=[[AgilentB2987A alloc]init];
        
        //初始化文件的类
        csv_file  = [[FileCSV alloc] init];
        [csv_file addGlobalLock];
        txt_file  = [[FileTXT  alloc]init];
        total_file= [[FileCSV alloc] init];
        [total_file addGlobalLock];
        fold     =  [[Folder  alloc] init];
        
        
        //初始化各种数据及其设备消息
        self.fixture_uart_port_name = [fix objectForKey:@"fixture_uart_port_name"];
        self.fixture_uart_port_name_e = [fix objectForKey:@"fixture_uart_port_name_e"];

        self.fixture_uart_baud      = [fix objectForKey:@"fixture_uart_baud"];
        self.instr_2987             = [fix objectForKey:@"b2987_adress"];
        
        //检测开启软件测试的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NSThreadStart_Notification:) name:@"NSThreadStart_Notification" object:nil];
        
        

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelCurrentThread:) name:@"cancelCurrentThread"
                                                   object:nil];
        
        //监测进水，排水，进气时间的改变
        [[NSNotificationCenter  defaultCenter] addObserver:self selector:@selector(resettimeAction:) name:kResetAirAndWaterTime object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reset_Notification:) name:@"threadReset" object:nil];

        
        //获取全局变量
        app = [NSApplication sharedApplication].delegate;
        thread = [[NSThread alloc]initWithTarget:self selector:@selector(TestAction) object:nil];
        [thread start];
    }
    
    return self;
}




-(void)TestAction
{
    NSInteger count=0;
    while ([[NSThread currentThread] isCancelled]==NO) //线程未结束一直处于循环状态
    {
        
#pragma mark--------index=0 连接治具
        if (index == 0) {
            
            
            if (param.isDebug) {
                 NSLog(@"%@==index= 0,连接治具%@,debug模式中",[NSThread currentThread],self.fixture_uart_port_name);
                [txtContentString appendFormat:@"%@:index=0,进入debug模式\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=0,进入debug模式" andClear:YES andTextView:self.Log_View];
                 index =1;
                switch (fix_type)
                {
                    case 1:
                        FixtureID=@"EW002-A";
                        break;
                    case 2:
                        FixtureID=@"EW002-B";
                        break;
                    case 3:
                        FixtureID=@"EW002-C";
                        break;
                    case 4:
                        FixtureID=@"EW002-D";
                        break;
                    case 5:
                        FixtureID=@"EW002-E";
                        break;
                    case 6:
                        FixtureID=@"EW002-F";
                        break;

                        
                    default:
                        break;
                }
            }
            else
            {
                
                BOOL isCollect = [serialport Open:self.fixture_uart_port_name];
                
                NSLog(@"self.fixture_uart_port_name=%@",self.fixture_uart_port_name);
                if (!isCollect)
                {
                    isCollect = [serialport Open:self.fixture_uart_port_name_e];
                    self.fixture_uart_port_name=self.fixture_uart_port_name_e;
                }
                if (isCollect) {
                     //发送指令获取ID的值
                    [NSThread sleepForTimeInterval:0.5];
                    [serialport WriteLine:@"fixture read id"];
                    [NSThread sleepForTimeInterval:0.8];
                     NSString *backStr = [serialport ReadExisting];
                    FixtureID=backStr;
                    if (count > 0)
                    {
                        [self UpdateTextView:nil andClear:YES andTextView:self.Log_View];
                    };
                    count++;
                    if (fix_type==1 && [FixtureID containsString:@"EW"])
                    {
                        FixtureID=[FixtureID componentsSeparatedByString:@"\r\n"].lastObject;
                    }
                    else
                    {
                        if ([FixtureID containsString:@"\r\n"])
                        {
                            FixtureID=[FixtureID componentsSeparatedByString:@"\r\n"][1];
                        }
                    }
                     NSLog(@"index= 0,连接治具%@",self.fixture_uart_port_name);
                    [txtContentString appendFormat:@"%@:index=0,治具已经连接\n",[timeDay getFileTime]];
                    [self UpdateTextView:@"index=0,治具已经连接" andClear:NO andTextView:self.Log_View];
                    isFixtureConnect=YES;
                    index =1;
                }
            }
            
           
        }
        
#pragma mark--------index=1 连接LCR表4980 和 静电仪器2987A
        if (index == 1) {
            
            if (param.isDebug) {
                
                NSLog(@"index= 1,仿仪器出口已连接%@,debug模式中",self.instrument_name);
                [txtContentString appendFormat:@"%@:index=1,debug模式中\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=1,进入debug模式\n" andClear:NO andTextView:self.Log_View];
                index =2;
            }
            else
            {
               
                
                BOOL is_JDY_Collect = [agilentB2987A Find:self.instr_2987 andCommunicateType:AgilentB2987A_CommunicateType_DEFAULT]&&[agilentB2987A OpenDevice:self.instr_2987 andCommunicateType:AgilentB2987A_CommunicateType_DEFAULT];
                
                
                if (is_JDY_Collect)
                {
                     NSLog(@"index= 1,仿仪器出口已连接%@",self.instrument_name);
                     [txtContentString appendFormat:@"%@:index=1,测试仪器已连接\n",[timeDay getFileTime]];
                     [self UpdateTextView:@"index=1,测试仪器已连接" andClear:NO andTextView:self.Log_View];
                    isAgilentConnect=YES;
                    index=2;
                    
                    if (isAlreadyStart)
                    {
                        index=2;
                    }
                }
                
                
                
            }
        }
#pragma mark--------index=2 获取输入框中的SN
        if (index == 2) {
             NSLog(@"index =2,等待SN");
            isAlreadyStart=YES;
            if (isFixtureConnect || param.isDebug)
            {
                if (isAgilentConnect || param.isDebug)
                {
                    if (_dut_sn.length == 4||_dut_sn.length==17)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.resultTF setStringValue:@"--"];
                            [self.resultTF setTextColor:[NSColor greenColor]];
                            NSLog(@"%d",fix_type);
                        });
                        
                        NSLog(@"index= 2,检测SN,并打印SN的值%@",_dut_sn);
                        index =3;
                        //启动测试的时间,csv里面用
                        start_time = [[GetTimeDay shareInstance] getFileTime];
                        [txtContentString appendFormat:@"%@:index=2,SN已经检验成功\n",[timeDay getFileTime]];
                        [self UpdateTextView:@"index=2,SN已经检验成功" andClear:NO andTextView:self.Log_View];
                        
                    }
                }
                else
                {
                    [self UpdateTextView:@"index=1,安捷伦仪器连接失败!" andClear:NO andTextView:self.Log_View];
                    index=1;
                }

            }
            else
            {
                [self UpdateTextView:@"index=0,治具连接失败！" andClear:NO andTextView:self.Log_View];
                index=0;
            }
        }
        
#pragma mark--------index=3 检测SN是否上传
        if (index == 3)
        {
            if (param.isDebug)
            {
                NSLog(@"index = 3,检测SN是否上传,debug");
                [txtContentString appendFormat:@"%@:index=3,debug模式\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=3,进入debug模式,检测SN上传" andClear:NO andTextView:self.Log_View];
                
                index = 4;
            }
            else
            {
                index = 4;
                [txtContentString appendFormat:@"%@:index=3,SN检验成功\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=3,SN检验成功" andClear:NO andTextView:self.Log_View];
                
            }
        }
        
        
#pragma mark--------index=4 进入正常测试中
        if (index == 4) {
            
            
            NSLog(@"index= 4,进入测试%@",self.fixture_uart_port_name);
            [txtContentString appendFormat:@"%@:index=4,正式进入测试\n",[timeDay getFileTime]];
            NSLog(@"打印tab中数组中的值%lu",(unsigned long)[self.tab.testArray count]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"waterBegin" object:@""];
            testItem = [[Item alloc]initWithItem:self.tab.testArray[item_index]];
            
            BOOL isPass =[self TestItem:testItem];
            
            if (isPass) {//测试成功
                itemResult = @"PASS";
                [self UpdateTextView:[NSString stringWithFormat:@"index=4:%@ 测试OK",testItem.testName] andClear:NO andTextView:self.Log_View];
                
            }
            else//测试结果失败
            {
                 itemResult = @"FAIL";
                 [self UpdateTextView:[NSString stringWithFormat:@"index=4:%@ 测试NG",testItem.testName] andClear:NO andTextView:self.Log_View];
                 [self UpdateTextView:[NSString stringWithFormat:@"FailItem:%@\n",testItem.testName] andClear:NO andTextView:self.Fail_View];
            }
    
            [testResultArr addObject:itemResult];

            //刷新界面
            [txtContentString appendFormat:@"%@:index=4,准备刷新界面\n",[timeDay getFileTime]];
            [self.tab flushTableRow:testItem RowIndex:row_index with:fix_type];
            [txtContentString appendFormat:@"%@:index=4,刷新界面成功\n",[timeDay getFileTime]];

            
            item_index++;
            row_index++;
            //走完测试流程,进入下一步
            if (item_index == [self.tab.testArray count])
            {
                //给设备复位
                [txtContentString appendFormat:@"%@:index=4,测试项测试结束\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=4,测试项测试结束" andClear:NO andTextView:self.Log_View];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //遍历测试结果,输出总测试结果
                    NSLog(@"%@",testResultArr);
                    NSLog(@"%@",self.fixture_uart_port_name);
                    for (int i = 0; i< testResultArr.count; i++)
                    {
                        if ([testResultArr[i] containsString:@"FAIL"])
                        {
                            PF=NO;
                            break;
                        }
                        else
                        {
                            PF=YES;
                        }
                    }
                    

                });

                index = 5;
                [agilentB2987A CloseDevice];
                [serialport Close];
            }
            
        }
        
#pragma mark--------index=5 生成本地数据
        if (index == 5) {
           //测试结束的时间,csv里面用
                 end_time = [[GetTimeDay shareInstance] getFileTime];
                //===============================
                [NSThread sleepForTimeInterval:0.1];
                /********生成总文件************/
            

            NSString   * totalCSV = [self backTotalFilePath];
            
            NSString   * total_day=[NSString stringWithFormat:@"%@/%@.csv",self.foldDir,[timeDay getCurrentDay]];
                if (total_file!=nil) {
                    
                    [total_file CSV_Open:totalCSV];
                    [txtContentString appendFormat:@"%@:index=5,打开总csv文件->%@\n",[timeDay getFileTime],totalCSV];
                    [self SaveCSV:total_file withBool:NO];
                    [txtContentString appendFormat:@"%@:index=5,添加数据到totalCSV文件->%@\n",[timeDay getFileTime],totalCSV];
                    [self UpdateTextView:@"index=5,往总文件中添加数据" andClear:NO andTextView:self.Log_View];
                    
                    [total_file CSV_Open:total_day];
                    
                    [self SaveCSV:total_file withBool:NO];
                    
                }
            
            @synchronized (self)
            {
                //生成单个产品的value值csv文件
                [NSThread sleepForTimeInterval:0.1];
                eachCsvDir = [NSString stringWithFormat:@"%@/%@",self.foldDir,self.dut_sn];
                [fold Folder_Creat:eachCsvDir];
                NSString * eachCsvFile = [NSString stringWithFormat:@"%@/%@.csv",eachCsvDir,self.dut_sn];
                if (csv_file!=nil)
                {
                    BOOL need_title = [csv_file CSV_Open:eachCsvFile];
                    [self SaveCSV:csv_file withBool:!need_title];
                    [txtContentString appendFormat:@"%@:index=5,生成单个csv文件%@\n",[timeDay getFileTime],eachCsvFile];
                    [self UpdateTextView:@"index=5,生成单个CSV文件" andClear:NO andTextView:self.Log_View];
                }
                
                
            }
            
            
            //生成log文件
            NSString * logFile = [NSString stringWithFormat:@"%@/log.txt",eachCsvDir];
            if (txt_file!=nil)
            {
                
                [txt_file TXT_Open:logFile];
                [txt_file TXT_Write:txtContentString];
            }
            
            
            
            
           //===============================
            NSLog(@"index= 5,本地数据生成完成%@",self.fixture_uart_port_name);
            [self UpdateTextView:@"index=5,本地数据生成完成" andClear:NO andTextView:self.Log_View];
            index = 6;
        }
        

#pragma mark--------index=6 将结果显示在界面上
        //将结果显示在界面上
        if (index == 6)
        {
            //清空字符串
            txtContentString =[[NSMutableString alloc]initWithCapacity:10];
            listFailItemString = [[NSMutableString alloc]initWithCapacity:10];
            ErrorMessageString = [[NSMutableString alloc]initWithCapacity:10];
            [testResultArr removeAllObjects];
            [ItemArr removeAllObjects];
            [TestValueArr removeAllObjects];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.resultTF setStringValue:PF?@"PASS":@"FAIL"];
               if (PF)
               {
                    [self.resultTF setTextColor:[NSColor greenColor]];
                   app.passNum++;
                   [[NSNotificationCenter defaultCenter] postNotificationName:SNChangeNotice object:[NSString stringWithFormat:@"%dP",fix_type]];
               }
                else
                {
                
                    [self.resultTF setTextColor:[NSColor redColor]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SNChangeNotice object:[NSString stringWithFormat:@"%dF",fix_type]];
                    
                }
                
            });
            
            index = 7;
        }
#pragma mark--------index=7 刷新结果，重新等待SN
        //刷新结果，重新等待SN
        if (index == 7)
        {
            
            //清空SN
             _dut_sn=@"";
            index = 1000;
            isAlreadyStart=NO;
            isAgilentConnect=NO;
            item_index =0;
            row_index = 0;
            
        }
#pragma mark--------index=1000
        if (index == 1000)
        {
            [NSThread sleepForTimeInterval:0.5];
        }
        

    }
}


//================================================
//测试项指令解析
//================================================
-(BOOL)TestItem:(Item*)testitem
{
    BOOL ispass=NO;
    NSDictionary  * dict;
    NSString      * subTestDevice;
    NSString      * subTestName;
    double          DelayTime;
    NSString      * startTime;
    NSString      * endTime;
    NSString        *subTestCommand;

    startTime = [timeDay getCurrentSecond];
    
    for (int i=0; i<[testitem.testAllCommand count]; i++)
    {
        dict =[testitem.testAllCommand objectAtIndex:i];
        subTestDevice = dict[@"TestDevice"];
        subTestCommand=dict[@"TestCommand"];
        subTestName=dict[@"TestName"];
        DelayTime = [dict[@"TestDelayTime"] floatValue]/1000.0;
        
       
        
        //治具中收发指令
        if ([subTestDevice isEqualToString:@"Fixture"])
        {
          [self UpdateTextView:[NSString stringWithFormat:@"subTestDevice%@====subTestCommand:%@\n",subTestDevice,subTestCommand] andClear:NO andTextView:self.Log_View];
            
           int indexTime = 0;
            while (YES) {
                
                [txtContentString appendFormat:@"%@:index=4,%@治具发送指令->%@\n",[timeDay getFileTime],self.fixture_uart_port_name,subTestCommand];
                
                
                 [serialport WriteLine:subTestCommand];
                
                 [NSThread sleepForTimeInterval:0.4];
                 fixtureBackString = [serialport ReadExisting];
                
                if (fix_type!=1)
                {
                    [self UpdateTextView:[NSString stringWithFormat:@"fixtureBackString:%@\n",fixtureBackString] andClear:NO andTextView:self.Log_View];
                    
                    [txtContentString appendFormat:@"%@:index=4,%@治具接收返回值->%@\n",[timeDay getFileTime],self.fixture_uart_port_name,fixtureBackString];
                }
                
                
                if (fix_type==1)
                {
                    if (isReceiveSuccessed)
                    {
                        isReceiveSuccessed=NO;
                        break;
                    }
                }
                else
                {
                    if ([fixtureBackString containsString:@">>OK"])
                    {
                        break;
                    }
                }
                
                if (indexTime>=3 && !param.isDebug) {
                    
                    break;
                }
                
                indexTime++;
                break;//
                
            }
        }

        //静电仪
        else if ([subTestDevice isEqualToString:@"Agilent"])
        {
            
            

            if ([subTestCommand containsString:@"RES"])
            {
               [agilentB2987A SetMessureMode:AgilentB2987A_RES andCommunicateType:AgilentB2987A_CommunicateType_DEFAULT IsAutoRange:_isAuto];
                
                [self UpdateTextView:@"index=4，B2987A 设置电阻测试模式！\n" andClear:NO andTextView:self.Log_View];
                [txtContentString appendFormat:@"%@:index=4，B2987A 设置电阻测试模式\n！",[timeDay getFileTime]];

            }
            else if([subTestCommand containsString:@"Read"])
            {
                [txtContentString appendFormat:@"%@:index=4，B2987A 读取电阻测试值！\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=4，B2987A 读取电阻测试值！" andClear:NO andTextView:self.Log_View];

                    [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_CommunicateType_DEFAULT];
                    [NSThread sleepForTimeInterval:0.5];
                    agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_CommunicateType_DEFAULT];
                    
                    NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                    num = [arrResult[0] floatValue];
            }
            else
            {
                NSLog(@"Other situation");
            }
        }
        
        
        
        
        //延迟时间
        else if ([subTestDevice isEqualToString:@"SW"])
        {
            
            
            [self UpdateTextView:[NSString stringWithFormat:@"index=4,软件延时%.1fs\n",DelayTime] andClear:NO andTextView:self.Log_View];
            
            if (!param.isDebug)
            {
                NSLog(@"软件休眠时间");
                [NSThread sleepForTimeInterval:DelayTime];
                [txtContentString appendFormat:@"%@:index=4,软件延时%.1fs\n",[timeDay getFileTime],DelayTime];
            }

        }
        else
        {
            NSLog(@"其它的情形");
        }
        
    }
    
    
#pragma mark--------对数据进行处理
    if ([testitem.units containsString:@"GOhm"])    //GOhm
    {
               testvalue = [NSString stringWithFormat:@"%.3f",num*1E-9];
        
    }
    else
    {
        NSLog(@"Other test Item");
    
    }
    

#pragma mark--------对测试项进行赋值
 
    
    
   
    
//判断值得大小
#pragma mark--------对测试出来的结果进行判断和赋值
    //上下限值对比
    if ((fabs([testvalue floatValue])>=[testitem.min floatValue]&&fabs([testvalue floatValue])<=[testitem.max floatValue]) || ([testitem.max isEqualToString:@"--"]&&fabs([testvalue floatValue])>=[testitem.min floatValue]) || ([testitem.max isEqualToString:@"--"] && [testitem.min isEqualToString:@"--"]) || ([testitem.min isEqualToString:@"--"]&&fabs([testvalue floatValue])<=[testitem.max floatValue]))
    {
        if (fix_type == 1) {
            testitem.value1 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result1 = @"PASS";
        }
        else if (fix_type == 2)
        {
            testitem.value2 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result2 = @"PASS";
        }
        else if (fix_type == 3)
        {
            testitem.value3 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result3 = @"PASS";
        }
        else if (fix_type == 4)
        {
            testitem.value4 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result4 = @"PASS";
        }
        else if (fix_type == 5)
        {
            testitem.value5 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result5 = @"PASS";
        }
        else if (fix_type == 6)
        {
            testitem.value6 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result6 = @"PASS";
        }
        
        testitem.messageError=nil;
        ispass = YES;
    }
    else
    {
        if (fix_type == 1) {
            testitem.value1 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result1 = @"FAIL";
        }
        else if (fix_type == 2)
        {
            testitem.value2 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result2 = @"FAIL";
        }
        else if (fix_type == 3)
        {
            testitem.value3 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result3 = @"FAIL";
        }
        else if (fix_type == 4)
        {
            testitem.value4 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result4 = @"FAIL";
        }
        else if (fix_type == 5)
        {
            testitem.value5 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result5 = @"FAIL";
        }
        else if (fix_type == 6)
        {
            testitem.value6 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result6 = @"FAIL";
        }
        testitem.messageError=[NSString stringWithFormat:@"%@ Fail",testitem.testName];
        ispass = NO;
        PF = NO;
    }
    
    //对时间进行赋值
    endTime = [timeDay getCurrentSecond];
    testitem.startTime = startTime;
    testitem.endTime   = endTime;
    
    
    
    
    //处理相关的测试项
    [TestValueArr addObject:testvalue];
    [ItemArr addObject:testitem];      //将测试项加入数组中

    return ispass;
}


//================================================
//保存csv
//================================================
-(void)SaveCSV:(FileCSV *)csvFile withBool:(BOOL)need_title
{
    NSString *line   =  @"";
    NSString * result=  @"";
    NSString * value =  @"";
    
    
    
    for(int i=0;i<[ItemArr count];i++)
    {
        Item *testitem=ItemArr[i];
        
        if (fix_type == 1) {result = testitem.result1,value =testitem.value1;}
        if (fix_type == 2) {result = testitem.result1,value =testitem.value2;}
        if (fix_type == 3) {result = testitem.result1,value =testitem.value3;}
        if (fix_type == 4) {result = testitem.result1,value =testitem.value4;}
        if (fix_type == 5) {result = testitem.result1,value =testitem.value5;}
        if (fix_type == 6) {result = testitem.result1,value =testitem.value6;}
        
        if(testitem.isTest)  //需要测试的才需要上传
        {
            if((testitem.isShow == YES)&&(testitem.isTest))    //需要显示并且需要测试的才保存
            {
                
                if (i == [ItemArr count] - 1)
                {
                    line=[line stringByAppendingString:[NSString stringWithFormat:@"%@\n",value]];

                }
                else
                {
                    line=[line stringByAppendingString:[NSString stringWithFormat:@"%@,",value]];
                }
            }
        }
    }
    
    
    NSString *test_result;
    if (PF)
    {
        test_result = @"PASS";
    }
    else
    {
        test_result = @"FAIL";
    }
    //line字符串前面增加SN和测试结果
    NSString *  contentString = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@",start_time,end_time,param.sw_ver,self.dut_sn,test_result,FixtureID,line];
    

   if(need_title == YES)[csvFile CSV_Write:self.csvTitle];
    
    [csvFile CSV_Write:contentString];
    
    
    
}


//================================================
//保存csv
//================================================
-(void)SaveTimeCSV
{
    NSString * line   = @"";
    NSString * result = @"";
    NSString * value  = @"";
    
    for(int i=0;i<[ItemArr count];i++)
    {
        Item *testitem=ItemArr[i];
        
        float time = ([testitem.endTime floatValue]-[testitem.startTime floatValue])/1000.0;
        
        if (fix_type == 1) {result = testitem.result1,value   =testitem.value1;}
        if (fix_type == 2) {result = testitem.result1,value   =testitem.value2;}
        if (fix_type == 3) {result = testitem.result1,value =testitem.value3;}
        if (fix_type == 4) {result = testitem.result1,value  =testitem.value4;}
        if (fix_type == 5) {result = testitem.result1,value =testitem.value5;}
        if (fix_type == 6) {result = testitem.result1,value  =testitem.value6;}
        
        line=[line stringByAppendingString:[NSString stringWithFormat:@"\n%@,%@,%@,%@,%@,%f\n",testitem.testName,result,testitem.min,value,testitem.max,time]];
        
        
    }
    
    NSString  * contentString = [NSString stringWithFormat:@"%@,%@,SN:%@\nTestName,Pass/Fail,Min Limit,Value,Max,Single Time,%@",self.sw_name,self.sw_ver,self.dut_sn,line];
    
    [csv_file CSV_Write:contentString];
    
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

-(void)setCsvTitle:(NSString *)csvTitle
{
    _csvTitle = csvTitle;
}

-(void)setDut_sn:(NSString *)dut_sn
{
    _dut_sn = dut_sn;
}

-(void)setFoldDir:(NSString *)foldDir
{
    _foldDir = foldDir;
}

-(void)threadEnd
{
    [thread cancel];
    [agilentB2987A CloseDevice];
    [serialport Close];
    
    agilentB2987A = nil;
    serialport = nil;
}

-(void)reset_Notification:(NSNotification *)noti
{
    [thread cancel];
    [serialport Open:_fixture_uart_port_name];
    [NSThread sleepForTimeInterval:0.1];
    [serialport WriteLine:@"Water in off"];
    NSLog(@"Water in off");
    [NSThread sleepForTimeInterval:0.5];
    [serialport WriteLine:@"Air in on"];
    NSLog(@"Air in on");
    [NSThread sleepForTimeInterval:1];

    [serialport WriteLine:@"Air in off"];
    NSLog(@"Air in off");
    [NSThread sleepForTimeInterval:0.5];
    [serialport Close];
    [NSThread sleepForTimeInterval:0.1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"waterOffFinished" object:@""];
//    agilentB2987A = nil;
//    serialport = nil;
//    [thread cancel];
//    thread = nil;



}

-(void)cancelCurrentThread:(NSNotification *)noti
{
    
    if (self.isCancel)
    {
        [thread cancel];
        thread = nil;
        [agilentB2987A CloseDevice];
        [serialport Close];
        
        agilentB2987A = nil;
        serialport = nil;
    }
    

}

-(void)NSThreadStart_Notification:(NSNotification *)noti
{
    index = 0;

}


#pragma make-----------设置时间
-(void)resettimeAction:(NSNotification *)noti
{
    NSString  * timestring = noti.object;
    
    NSArray  * array = [timestring componentsSeparatedByString:@"="];
    
    one_airtime = [[array objectAtIndex:0] intValue]==0?[[array objectAtIndex:0] intValue]:one_airtime;
    water_time = [[array objectAtIndex:1] intValue]==0?[[array objectAtIndex:1] intValue]:water_time;
    two_airtime = [[array objectAtIndex:2] intValue]==0?[[array objectAtIndex:2] intValue]:two_airtime;
}



#pragma mark----PDCA相关
//================================================
//上传pdca
//================================================
-(void)UploadPDCA
{

}


#pragma mark-----------------多次测试和的值
-(void)add_RFixture_Value_To_Sum_Testname:(NSString *)testname RFixture:(double)RFixture
{

}



#pragma mark----------------GΩ情况下调用方法，testname为测试项的名称
-(void)storeValueToDic_with_name:(NSString *)testname
{

}


#pragma mark----------------MΩ情况下调用的方法，
-(void)storeValueToDic_With_Item:(Item *)item
{
 
}


#pragma mark-------------返回总文件
-(NSString *)backTotalFilePath
{
    if (fix_type==1)
    {
        
       return [NSString stringWithFormat:@"%@/%@_A.csv",self.foldDir,[timeDay getCurrentDay]];
    }
    else if (fix_type==2)
    {
       return [NSString stringWithFormat:@"%@/%@_B.csv",self.foldDir,[timeDay getCurrentDay]];
    }
    else if (fix_type==3)
    {
       return [NSString stringWithFormat:@"%@/%@_C.csv",self.foldDir,[timeDay getCurrentDay]];
    }
    else if (fix_type==4)
    {
       return [NSString stringWithFormat:@"%@/%@_D.csv",self.foldDir,[timeDay getCurrentDay]];
    }
    else if (fix_type==5)
    {
        return [NSString stringWithFormat:@"%@/%@_E.csv",self.foldDir,[timeDay getCurrentDay]];
    }
    else
    {
        return [NSString stringWithFormat:@"%@/%@_F.csv",self.foldDir,[timeDay getCurrentDay]];
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
                               [textView setString:[NSString stringWithFormat:@"%@",strMsg]];
                           }
                           
                           [textView setTextColor:[NSColor redColor]];
                       });
    }
}






@end

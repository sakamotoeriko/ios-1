//
//  AppDelegate.m
//  CarApp
//
//  Created by Leno on 13-9-12.
//  Copyright (c) 2013年 Leno. All rights reserved.
//

#import "AppDelegate.h"

#import "StartViewController.h"
#import "User.h"

#import "SetProfileViewController.h"
#import "GroupChatViewController.h"
#import "XmppManager.h"

#import "ForgetPassWordViewController.h"
#import "changePassWordViewController.h"
#import "EditRouteViewController.h"

#import "MapViewController.h"
#import "CustomStatueBar.h"
#import "LogInViewController.h"

#import "APService.h"
#import "UmengUtil.h"
#import "Utility_DeviceIdentification.h"

#import "PhpTestTableViewController.h"
#import "ProfileViewController.h"

@implementation AppDelegate

@synthesize mainVC = _mainVC;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    self.mainVC = [[MainViewController alloc] init];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[NSUserDefaults standardUserDefaults]setValue:@"Leno" forKey:@"InstCarUserName"];

    //驱动xmpp
    [[XmppManager sharedInstance] setupStream];
    
    //初始化网络状态监控
    [NetTool checkNetworkChange];
    
    [self setupKindOfThirdKey];
    
    [self setupJpushServer:launchOptions];
    
    _statueBar = [[CustomStatueBar alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
    //判断是否已经进入过应用
    bool everEntered = [[NSUserDefaults standardUserDefaults]boolForKey:@"AlreadyEnterApp"];
    User *user = [User shareInstance];

//    ProfileViewController * profileVC = [[ProfileViewController alloc]init];
//    profileVC.uid = [User shareInstance].userId;
//    profileVC.state = 2;
//    UINavigationController *profileNav = [[UINavigationController alloc]initWithRootViewController:profileVC];
//    [profileVC release];
//    [profileNav setNavigationBarHidden:YES];
//    self.window.rootViewController = profileNav;
    
//    PhpTestTableViewController *phpTestTableVC = [[PhpTestTableViewController alloc]init];
//    self.window.rootViewController = phpTestTableVC;
    //密码是否保存了
    if (!everEntered) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"AlreadyEnterApp"];
        StartViewController * startVC = [[StartViewController alloc] init];
        UINavigationController * navi = [[UINavigationController alloc]initWithRootViewController:startVC];
        [navi setNavigationBarHidden:YES];
        self.window.rootViewController = navi;
    }
    else
        if (user.isSavePwd != YES) {
            LogInViewController * logInVC = [[LogInViewController alloc]init];
            UINavigationController*nav = [[UINavigationController alloc]initWithRootViewController:logInVC];
            [nav setNavigationBarHidden:YES animated:NO];
            [nav setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            [[AppDelegate shareDelegate].window setRootViewController:nav];
        }
        else{

            [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            UINavigationController * navi = [[UINavigationController alloc]initWithRootViewController:self.mainVC];
            self.mainVC.firstEnter = NO;
//            [self.mainVC enterView];
            self.window.rootViewController = navi;
        }
    
    [self.window makeKeyAndVisible];
    return YES;
}

+(AppDelegate *)shareDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

-(void)setupKindOfThirdKey
{
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:kBaiDuMapKey  generalDelegate:nil];
    if (!ret) {
        DLog(@"manager start failed!");
    }
    else
    {
        DLog(@"BaiduMap_version:----");
    }
    //友盟key
    [UmengUtil setAnalyticsAppkey];
    
    //设置openuuid
    [[User shareInstance]setOpenuuid:[Utility_DeviceIdentification keyChain]];
}

-(void)setupJpushServer:(NSDictionary *)launchOptions
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self selector:@selector(networkDidSetup:) name:kAPNetworkDidSetupNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidClose:) name:kAPNetworkDidCloseNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidRegister:) name:kAPNetworkDidRegisterNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidLogin:) name:kAPNetworkDidLoginNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kAPNetworkDidReceiveMessageNotification object:nil]; //非apns
    
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // Required
    [APService
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert)];
    // Required
    [APService setupWithOption:launchOptions];
    
}

#pragma mark - Jpush State
- (void)networkDidSetup:(NSNotification *)notification {
    DLog(@"已连接");
}

- (void)networkDidClose:(NSNotification *)notification {
    DLog(@"未连接。。。");
}

- (void)networkDidRegister:(NSNotification *)notification {
    DLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification {
    DLog(@"已登录");
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    
    NSDictionary * userInfo = [notification userInfo];
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    DLog(@"%@",[NSString stringWithFormat:@"收到消息\ndate:%@\ntitle:%@\ncontent:%@", [dateFormatter stringFromDate:[NSDate date]],title,content]);
    
//    [_statueBar showStatusMessage:title];
}

- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {
    DLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}


#pragma mark - remotePushDelegate
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required 更新deviceToken
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    DLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Required
    [APService handleRemoteNotification:userInfo];
}

//avoid compile error for sdk under 7.0
#ifdef __IPHONE_7_0
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
}
#endif

#pragma mark - systemDelegate
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    DLog(@"pplicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    DLog(@"applicationDidEnterBackground");
    //清除应用推送数字
    [application setApplicationIconBadgeNumber:0];
//    [[XmppManager sharedInstance]disconnect];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    DLog(@"applicationWillEnterForeground");
    //清除应用推送数字
    [application setApplicationIconBadgeNumber:0];
//    if ([User shareInstance].isSavePwd) {
//        [[LocationServer shareInstance] startLocation];
//        [[XmppManager sharedInstance] connect];
//    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    DLog(@"applicationDidBecomeActive");
    //清除应用推送数字
    [application setApplicationIconBadgeNumber:0];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DLog(@"applicationWillTerminate");
}

-(void)dealloc
{
    
}

@end

//
//  AppDelegate.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "AppDelegate.h"
#import "TNavigationController.h"
#import "ConversationController.h"
#import "SettingController.h"
#import "TUIKit.h"
#import "THeader.h"
#import "TAlertView.h"

@interface AppDelegate () <TAlertViewDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onForceOffline:) name:TUIKitNotification_TIMUserStatusListener object:nil];
    
    //sdkAppId 填写自己控制台申请的sdkAppid
    if (sdkAppid == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demo尚未配置SdkAppid，请前往IM控制台创建应用，获取SdkAppid，然后在工程 Appdelegate 头文件里面配置" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }else if (sdkAccountType == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demo尚未配置AccountType，请前往IM控制台创建应用，获取AccountType，然后在工程 Appdelegate 头文件里面配置" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        [[TUIKit sharedInstance] initKit:sdkAppid accountType:sdkAccountType withConfig:[TUIKitConfig defaultConfig]];
    }
    
    NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_User];
    //NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_Pwd];
    NSString *userSig = [[NSUserDefaults standardUserDefaults] objectForKey:Key_UserInfo_Sig];
    if(identifier.length != 0){
        __weak typeof(self) ws = self;
        [[TUIKit sharedInstance] loginKit:identifier userSig:userSig succ:^{
            ws.window.rootViewController = [self getMainController];
        } fail:^(int code, NSString *msg) {
            ws.window.rootViewController = [self getLoginController];
        }];
    }
    else{
        _window.rootViewController = [self getLoginController];
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

void uncaughtExceptionHandler(NSException*exception){
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@",[exception callStackSymbols]);
    // Internal error reporting
}

- (UIViewController *)getLoginController{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LoginController *login = [board instantiateViewControllerWithIdentifier:@"LoginController"];
    return login;
}

- (UITabBarController *)getMainController{
    TTabBarController *tbc = [[TTabBarController alloc] init];
    NSMutableArray *items = [NSMutableArray array];
    TTabBarItem *msgItem = [[TTabBarItem alloc] init];
    msgItem.title = @"消息";
    msgItem.selectedImage = [UIImage imageNamed:TUIKitResource(@"message_pressed")];
    msgItem.normalImage = [UIImage imageNamed:TUIKitResource(@"message_normal")];
    msgItem.controller = [[TNavigationController alloc] initWithRootViewController:[[ConversationController alloc] init]];
    [items addObject:msgItem];
    
    TTabBarItem *setItem = [[TTabBarItem alloc] init];
    setItem.title = @"设置";
    setItem.selectedImage = [UIImage imageNamed:TUIKitResource(@"setting_pressed")];
    setItem.normalImage = [UIImage imageNamed:TUIKitResource(@"setting_normal")];
    setItem.controller = [[TNavigationController alloc] initWithRootViewController:[[SettingController alloc] init]];
    [items addObject:setItem];
    tbc.tabBarItems = items;
    
    return tbc;
}

- (void)onForceOffline:(NSNotification *)notification
{
    TAlertView *alert = [[TAlertView alloc] initWithTitle:@"账号在其他终端登录"];
    alert.delegate = self;
    [alert showInWindow:self.window];
}

- (void)didConfirmInAlertView:(TAlertView *)alertView
{
    self.window.rootViewController = [self getLoginController];
}
@end

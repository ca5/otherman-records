//
//  AppDelegate.m
//  OthermanRecords
//
//  Created by Ca5 on 13/02/04.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "AppDelegate.h"
#import "Setting.h"
#import "Favorite.h"
#import <AudioToolbox/AudioServices.h>


@implementation AppDelegate

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //album test
    [[Album getInstance:self] load];
    [[Track getInstance:self] load];
    
    //[[StreamingPlayer getInstance] startWithURL:@"http://archive.org/download/OTMN024/01-grayscale.mp3"];


    
    Favorite *favorite = [[Favorite alloc] init];
    [favorite load];
    [favorite addFavoliteWithCutnum:@"OTMN000" tracknum:[NSNumber numberWithInt:2]];
    [favorite addFavoliteWithCutnum:@"OTMN000" tracknum:[NSNumber numberWithInt:3]];
    [favorite addFavoliteWithCutnum:@"OTMN003" tracknum:[NSNumber numberWithInt:5]];
    [favorite addFavoliteWithCutnum:@"OTMN006" tracknum:[NSNumber numberWithInt:10]];
    NSLog(@"favorite:\n %@", [favorite description]);



    

    
    //push notifiacation test
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge
                                                                           | UIRemoteNotificationTypeSound
                                                                            | UIRemoteNotificationTypeAlert)];
    
    // Override point for customization after application launch.
    return YES;
}

/**** XmlData delegated function ****/
- (void)didFinishLoadingAlbum:(Album *)data
{
    NSLog(@"album:\n %@", [data description]);

}

- (void)didFinishLoadingTrack:(Track *)data
{
    NSLog(@"track:\n %@", [data description]);
    
}

- (void)didFailWithError:(NSError *)error
{
    
}
/**** XmlData delegated function -end****/

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    [self saveContext];
}

//push notification

// デバイストークンを受信した際の処理
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    
    NSString *deviceToken = [[[[devToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] 
                              stringByReplacingOccurrencesOfString:@">" withString:@""] 
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"deviceToken: %@", deviceToken);
}

// プッシュ通知を受信した際の処理
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
#if !TARGET_IPHONE_SIMULATOR
    NSLog(@"remote notification: %@",[userInfo description]);
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    NSString *alert = [apsInfo objectForKey:@"alert"];
    NSLog(@"Received Push Alert: %@", alert);
    
    NSString *sound = [apsInfo objectForKey:@"sound"];
    NSLog(@"Received Push Sound: %@", sound);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    NSString *badge = [apsInfo objectForKey:@"badge"];
    NSLog(@"Received Push Badge: %@", badge);
    application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
#endif
}

@end

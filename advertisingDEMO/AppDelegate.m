//
//  AppDelegate.m
//  advertisingDEMO
//
//  Created by liujie on 16/6/14.
//  Copyright © 2016年 liujie. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "AdvertiseView.h"

@interface AppDelegate ()

@property (nonatomic,strong)UIImageView *advertiseView;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
  NSString * Nonorganicurl  = [[NSUserDefaults standardUserDefaults] objectForKey:@"Non-organic-url"];
    if (Nonorganicurl == nil) {
        //深度链接设置
        if (launchOptions[UIApplicationLaunchOptionsURLKey] == nil) {
            [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {
                if (error) {
                    //返回错误== 自然量
                    NSLog(@"Received error while fetching deferred app link %@", error);
                    [self setOrganic];
                }else{
                    if (url) {
                        //记录价格
                        [[NSUserDefaults standardUserDefaults] setObject:[url host] forKey:@"Scanner_price"];
                        //广告量
                        [[UIApplication sharedApplication] openURL:url];
                        [[NSUserDefaults standardUserDefaults] setObject:@"Non-organic" forKey:@"Scanneruser_Organic"];
                        [[NSUserDefaults standardUserDefaults] setURL:url forKey:@"Non-organic-url"];
                        //判断是不是购买成功了
                        if ([MMExpired getSubscriptionIsExpired] == YES) {
                            self.window.rootViewController = [MMGuideViewController new];
                        }else{
                            self.window.rootViewController = [ViewController new];
                        }
                    }else{
                        //自然量
                        [self setOrganic];
                    }
                }
            }];
        }
    }else{
        //判断是不是购买成功了
        if ([MMExpired getSubscriptionIsExpired] == YES) {
            self.window.rootViewController = [MMGuideViewController new];
        }else{
            self.window.rootViewController = [ViewController new];
        }
    }
    
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
    
    [self.window makeKeyAndVisible];
    NSString *filePath = [self getFilePathWithImageName:[[NSUserDefaults standardUserDefaults] valueForKey:adImageName]];
    BOOL isExist = [self isFileExistwithFilePath:filePath];
    if (isExist) {// 图片存在
        AdvertiseView *advertiseView = [[AdvertiseView alloc] initWithFrame:self.window.bounds];
        advertiseView.filePath = filePath;
        [advertiseView show];
    }
    // 2.无论沙盒中是否存在广告图片，都需要重新调用广告接口，判断广告是否更新
    [self getAdvertisingImage];
    
    // Override point for customization after application launch.
    return YES;
}

//判断文件是否存在
-(BOOL)isFileExistwithFilePath:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    return [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
}
//初始化广告页
-(void)getAdvertisingImage
{
    NSArray *imageArray = @[@"http://imgsrc.baidu.com/forum/pic/item/9213b07eca80653846dc8fab97dda144ad348257.jpg", @"http://pic.paopaoche.net/up/2012-2/20122220201612322865.png", @"http://img5.pcpop.com/ArticleImages/picshow/0x0/20110801/2011080114495843125.jpg", @"http://www.mangowed.com/uploads/allimg/130410/1-130410215449417.jpg"];
    NSString *imageUrl = imageArray[arc4random() % imageArray.count];
    
    //获取图片名字
    NSArray *stringArr = [imageUrl componentsSeparatedByString:@"/"];
    NSString *imageName = stringArr.lastObject;
    
    
    NSString *filePath = [self getFilePathWithImageName:imageName];
    BOOL isExist = [self isFileExistwithFilePath:filePath];
    if (!isExist){// 如果该图片不存在，则删除老图片，下载新图片
        
        [self downloadAdImageWithUrl:imageUrl imageName:imageName];
        
    }

}

//下载图片
-(void)downloadAdImageWithUrl:(NSString *)imageUrl imageName:(NSString *)imageName
{
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    UIImage *image = [UIImage imageWithData:data];
    NSString *filePath = [self getFilePathWithImageName:imageName];
    if ([UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES]) {
        NSLog(@"保存成功");
        [self deleteOldImage];
        [[NSUserDefaults standardUserDefaults] setValue:imageName forKey:adImageName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // 如果有广告链接，将广告链接也保存下来

    }else{
        NSLog(@"保存失败");
    }
});

}

/**
 *  删除旧图片
 */
- (void)deleteOldImage
{
    NSString *imageName = [[NSUserDefaults standardUserDefaults] valueForKey:adImageName];
    if (imageName) {
        NSString *filePath = [self getFilePathWithImageName:imageName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:nil];
    }


}
//拼接图片文件路径
-(NSString *)getFilePathWithImageName:(NSString *)imageName
{
    
    if (imageName) {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingString:imageName];
    return filePath;
    }
    return nil;
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

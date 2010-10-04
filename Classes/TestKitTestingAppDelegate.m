//
//  TestKitTestingAppDelegate.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright KISSAKI 2010. All rights reserved.
//

#import "TestKitTestingAppDelegate.h"
#import "MessengerViewController.h"



#import "NameList.h"//適当な名称一致用リスト


@implementation TestKitTestingAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
   
	mViewCont = [[MessengerViewController alloc] initWithFrame:window.frame];
	
	m_vController = [[UIViewController alloc] init];//うーん、オーバーライド無しには回転するように出来ない、ってのはちと、、
	
	[window addSubview:[mViewCont getMessengerInterfaceView]];
	
	paren = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:PARENTNAME];
	
	objectOv = [[coTestObject alloc] init];
	
	coTestObject * obj2 = [[coTestObject alloc] init];
	
	coTestObject * obj3 = [[coTestObject alloc] init2];
	//coTestObject * obj4 = [[coTestObject alloc] init2];
//	coTestObject * obj5 = [[coTestObject alloc] init2];
	
	
//	[paren callMyself:COMMAND_DELETE,
//	 [paren withDelay:3],
//	 nil];
	
	[window makeKeyAndVisible];
	
	return YES;
}



/**
 遠隔実行する用のメソッド
 */
- (void) ignition:(NSString * )str {
	NSLog(@"ignition_%@", str);
}



- (void)test:(NSNotification * )notification {
	NSLog(@"NSNotification到着！！！！_%@", notification);
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	NSLog(@"param_%@", [paren getExecAsString:dict]);
	int n = [paren getExecAsIntFromDict:dict];
	NSLog(@"testn_%d",n);
	
	
	switch (n) {
		case -1295402496://COMMAND_YEAH//この部分をマクロで書ければ最高。
		
			break;
		default:

			NSLog(@"per_%d", n);//コマンドの数字を出す
			break;
	}
}



- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}



#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[paren release];
    [window release];
	[mViewCont release];
	
	[m_vController release];
	
	
    [super dealloc];
}


@end

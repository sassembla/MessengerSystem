//
//  TestKitTestingAppDelegate.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright KISSAKI 2010. All rights reserved.
//

#import "TestKitTestingAppDelegate.h"
#import "MessengerView.h"

#import "coTestObject.h"


#import "NameList.h"//適当な名称一致用リスト

@implementation TestKitTestingAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
   // coTestObject * cTest = [[coTestObject alloc] init];
	
	
	
	MessengerView * view = [[MessengerView alloc] initWithFrame:window.frame];
	
	UIViewController * vController = [[UIViewController alloc] init];//うーん、オーバーライド無しには回転するように出来ない、ってのはちと、、
	
	[window addSubview:[view getMessengerInterfaceView]];
	
	
	paren = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:PARENTNAME];
//	NSLog(@"paren_%@", [paren getMyMID]);
	NSLog(@"カウント_%d",[paren retainCount]);
	
	coTestObject * cTest = [[coTestObject alloc] init];

	 
//	[paren callMyself:COMMAND_OOPS,
//	 [paren tag:@"one" val:@"1"],
//	 [paren tag:@"two" val:@"2"],
//	 [paren tag:@"three" val:@"3"],
//	 [paren withDelay:1.0],
//	 nil];
	
	
//	//子供を自分自身から呼ぶコード10/09/19 9:20:13
//	[paren callMyself:COMMAND_OOPS,
//	 [paren tag:@"one" val:@"1"],
//	 [paren tag:@"two" val:@"2"],
//	 [paren tag:@"three" val:@"3"],
//	 [paren withDelay:1.0],
//	 nil];
	
	
	
//	//子供を直接呼ぶコード
//	[paren call:CHILD_1 withExec:COMMAND_OOPS,
//	 [paren tag:@"one" val:@"1"],
//	 [paren withDelay:0.75],
//	 nil];
	
	
	
//	[paren callMyself:COMMAND_YEAH, 
//	 [paren tag:@"one" val:@"1"],
//	 [paren tag:@"two" val:@"2"],
//	 [paren tag:@"three" val:@"3"],
////	 [paren withDelay:0.3],
//	 nil];
	
	
	//	[paren call:CHILD_1 withExec:COMMAND_YEAH, 
//	 [paren tag:@"one" val:@"1"],
//	 [paren tag:@"two" val:@"2"],
//	 [paren tag:@"three" val:@"3"],nil];
	
	
	
	
	coTestObject * cTest2 = [[coTestObject alloc] init2];
//	coTestObject * cTest3 = [[coTestObject alloc] init];
	
	//coTestObject * cTest4 = [[coTestObject alloc] init2];
	
//	[paren call:CHILD_1 withExec:COMMAND_OOPS, 
//	 [paren tag:@"one" val:@"1"],
//	 [paren tag:@"two" val:@"2"],
//	 [paren tag:@"three" val:@"3"],nil];
	
	
//	[paren callMyself:COMMAND_YEAH, 
//	 [paren tag:@"one" val:@"1"],
//	 [paren tag:@"two" val:@"2"],
//	 [paren tag:@"three" val:@"3"],nil];

	
	
	//子供を自分自身から呼ぶコード
	[paren callMyself:COMMAND_CHILDS,
	 [paren tag:@"one" val:@"1"],
	 [paren tag:@"two" val:@"2"],
	 [paren tag:@"three" val:@"3"],
	 [paren withDelay:0.01],
	 nil];
	
	

	
	
    [window makeKeyAndVisible];
	
	return YES;
}



- (void)test:(NSNotification * )notification {
	NSLog(@"NSNotification到着！！！！_%@", notification);
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	int n = [paren getExecAsInt:dict];
	NSLog(@"testn_%d",n);
	
	int m = [paren equalToExec:COMMAND_CHILDS];
	NSLog(@"testm_%d", m);
	
	
	switch (n) {
		case -1295402496://COMMAND_YEAH//この部分をマクロで書ければ最高。
			
//			[paren call:CHILD_1 withExec:COMMAND_YEAH,
//			 [paren withDelay:0.1],
//			 nil];
			
			break;
		case -1295402495://COMMAND_OOPS
			
//			[paren call:CHILD_1 withExec:COMMAND_OOPS,
//			 [paren withDelay:0.1],
//			 nil];
			
			break;
		case 748839144://COMMAND_CHILDS
			NSLog(@"COMMAND_CHILDに到着");
			[paren call:CHILD_1 withExec:COMMAND_CHILDS,
			 [paren withDelay:0.1],
			 nil];
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
    [window release];
    [super dealloc];
}


@end

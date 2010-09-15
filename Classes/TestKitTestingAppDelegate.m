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
	if (true) {
		MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"こども１"];
		MessengerSystem * child_2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild2:) withName:@"こども２"];
		
		
		[child_0 inputToMyParentWithName:PARENTNAME];
		
		[child_2 inputToMyParentWithName:[child_0 getMyName]];
		
		//child_0の子供としてchild_2をセットした際、child_0の名前がchild_2のmyParentにセットしてあるはず。
		NSMutableDictionary * dict1 = [child_0 getChildDict];
		
		return YES;
	}
	
	coTestObject * cTest = [[coTestObject alloc] init];

	

	[paren callMyself:COMMAND_YEAH,
	 [paren tag:@"one" val:@"1"],
	 [paren tag:@"two" val:@"2"],
	 [paren tag:@"three" val:@"3"],
	 [paren withDelay:0.5],
	  nil];
	
	
//	[paren call:CHILD_1 withExec:@"仮",
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
	
	
	
	
	//coTestObject * cTest2 = [[coTestObject alloc] init2];
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

	
	//[paren call:@"Parentだよ" withExec:@"yeah2!", nil];

	
	
    [window makeKeyAndVisible];
	
	return YES;
}



- (void)test:(NSNotification * )notification {
	NSLog(@"NSNotification到着！！！！_%@", notification);
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	NSString * exec = [dict valueForKey:MS_EXECUTE];
	NSLog(@"exec1_%@",exec);
	
	if ([exec isEqualToString:COMMAND_YEAH]) {
		NSLog(@"m_testChild1 返答実行 YEAHHHHHHH!");
		[paren callMyself:COMMAND_YEAH,
		 [paren withDelay:0.5],
		 nil];
		
	}
	
	
	switch ([paren getExec:dict]) {
		case [paren changeStrToNumber:COMMAND_YEAH]:
			
			break;
		default:
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

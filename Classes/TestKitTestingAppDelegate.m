//
//  TestKitTestingAppDelegate.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright KISSAKI 2010. All rights reserved.
//

#import "TestKitTestingAppDelegate.h"
#import "MessengerViewController.h"

#import "coTestObject.h"


#import "NameList.h"//適当な名称一致用リスト

@implementation TestKitTestingAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
   // coTestObject * cTest = [[coTestObject alloc] init];
	
	
	
	MessengerViewController * view = [[MessengerViewController alloc] initWithFrame:window.frame];
	
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

	
	
//	//子供を自分自身から呼ぶコード
//	[paren callMyself:COMMAND_CHILDS,
//	 [paren tag:@"one" val:@"1"],
//	 [paren tag:@"two" val:@"2"],
//	 [paren tag:@"three" val:@"3"],
//	 [paren withDelay:0.01],
//	 nil];
	
	

//	[paren call:CHILD_1 withExec:COMMAND_DELAYANDREMOTE, 
//	 [paren withDelay:0.5],
//	 [paren withRemoteFrom:self withSelector:@selector(ignition:)],
//	 nil];
	
	
	[paren callMyself:COMMAND_ADD_CHILD,
	 [paren withDelay:0.01],
//	 [paren withRemoteFrom:self withSelector:@selector(ignition:)],
	 nil];
	
	
//	[self got];
	//[self testResetParent];
	
    [window makeKeyAndVisible];
	
	return YES;
}



/**
 遠隔実行する用のメソッド
 */
- (void) ignition:(NSString * )str {
	NSLog(@"ignition_%@", str);
}

- (void) got {
	NSLog(@"子供ゲット");
	
	NSLog(@"通過");
}

- (void)test:(NSNotification * )notification {
	NSLog(@"NSNotification到着！！！！_%@", notification);
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	NSLog(@"param_%@", [paren getExecAsString:dict]);
	int n = [paren getExecAsIntFromDict:dict];
	NSLog(@"testn_%d",n);
	
	
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
			
		case 2099139860://COMMAND_DELAYANDREMOTE_RET
			[paren remoteInvocation:dict, @"第一次受け取り", nil];
			break;
			
		case -773500510://COMMAND_DELAYANDREMOTE_RET_2
		
			
			[paren remoteInvocation:dict, @"第二次受け取り", nil];
		
			
			
			
			break;
			
		case 624007143://COMMAND_LOOP
			[paren callMyself:COMMAND_LOOP,
			 [paren withDelay:0.1],
			 nil];
			
			break;
			
		case 1880616375://COMMAND_ADD_CHILD
			[paren callMyself:COMMAND_ADD_CHILD,
			 nil];
			
			break;
			
		case -1001328277://COMMAND_ADD_CHILD
		
			
			NSLog(@"受け取り COMMAND_ADD_CHILD_%@", dict);
			if ([paren isIncludeRemote:dict]) {
				[paren remoteInvocation:dict, @"子供のメソッドを子供が起動", nil];
			} else {
				NSLog(@"子供のメソッドは実行しなかった");
			}
			
			NSLog(@"動的に作成");//遅延実行では作れない。どこかで遅延実行が絡んでも、作れない。
			coTestObject * cTest3 = [[coTestObject alloc] init3];
			[cTest3 setParent];
			
			[self got];
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

- (void) testResetParent {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:@"子供の名前①"];
	MessengerSystem * child_2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:@"子供の名前②"];
	
	
	
	[child_0 inputParent:[paren getMyName]];
	
	NSMutableDictionary * parentChildDict = [paren getChildDict];
//	STAssertTrue([parentChildDict count] == 1, [NSString stringWithFormat:@"親の持っている子供辞書が1件になっていない_%d", [parentChildDict count]]);
	
	NSLog(@"child_0の親を抹消");
	[child_0 removeFromParent];//親情報をリセットする
	NSLog(@"child_0の親抹消済みの筈_親ID_%@", [child_0 getMyParentMID]);
	
	//parentの子供辞書を調べてみる、一件も無くなっている筈
//	STAssertTrue([parentChildDict count] == 0, [NSString stringWithFormat:@"親の持っている子供辞書が0件になっていない_%d", [parentChildDict count]]);
//	STAssertTrue(![child_0 hasParent], @"子供がまだ親情報を持っている");
//	STAssertTrue(![paren hasChild], @"親がまだ子供情報を持っている");
	
	
	
	[child_0 inputParent:[child_2 getMyName]];//新規親情報
	
	
	NSLog(@"子供が知ってる親の名前_%@", [child_0 getMyParentName]);
	//親が知ってる子供の情報、という部分において、他のオブジェクト（子供残骸＞）
	
//	STAssertTrue([child_0 hasParent], @"子供がまだ親情報を持っている");
//	STAssertTrue(![paren hasChild], @"親がまだ子供情報を持っている");
//	STAssertTrue([child_2 hasParent], @"子供2が子供情報を持っていない");
	NSAssert([child_2 hasParent], @"問題がある");
	
	NSMutableDictionary * dict2 = [child_2 getChildDict];
//	STAssertTrue([dict2 count] == 1, [NSString stringWithFormat:@"dict2の持っている子供辞書が1件になっていない_%d", [dict2 count]]);
	
	NSLog(@"dict2_%@", dict2);
//	STAssertTrue([[dict2 valueForKey:[child_0 getMyMID]] isEqualToString:[child_0 getMyName]], @"child_2の親登録が違った");
	
	[child_2 call:[child_0 getMyName] withExec:@"試し",nil];
	
	
	//STAssertEquals([dict1 valueForKey:[child_2 getMyMID]], [child_2 getMyName], @"child_2の親登録が違った");
	[child_0 release];
	[child_2 release];
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

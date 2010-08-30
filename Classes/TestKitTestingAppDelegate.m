//
//  TestKitTestingAppDelegate.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright KISSAKI 2010. All rights reserved.
//

#import "TestKitTestingAppDelegate.h"
#import "MessengerSystem.h"
#import "coTestObject.h"

@implementation TestKitTestingAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
   // coTestObject * cTest = [[coTestObject alloc] init];
	
	MessengerSystem * paren = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:@"Parentだよ"];
//	NSLog(@"paren_%@", [paren getMyMSID]);
	//[paren inputToMyParent];
	
	
	coTestObject * cTest = [[coTestObject alloc] init];
	
	coTestObject * cTest2 = [[coTestObject alloc] init];
//	coTestObject * cTest3 = [[coTestObject alloc] init];
	
	//coTestObject * cTest4 = [[coTestObject alloc] init2];
	
	[paren call:@"child_0" withExec:@"yeah!", 
	 [paren tag:@"one" val:@"1"],
	 [paren tag:@"two" val:@"2"],
	 [paren tag:@"three" val:@"3"],nil];
	
	
	
	[paren call:@"Parentだよ" withExec:@"yeah!", 
	 [paren tag:@"one" val:@"1"],
	 [paren tag:@"two" val:@"2"],
	 [paren tag:@"three" val:@"3"],nil];
	
	
	
	//[paren call:@"Parentだよ" withExec:@"yeah2!", nil];

	
    [window makeKeyAndVisible];
	
	return YES;
}



- (void)test:(NSNotification * )notification {
	NSLog(@"到着！！！！_%@", notification);
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

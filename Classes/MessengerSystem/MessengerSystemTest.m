//
//  MessengerSystemTest.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

// Test-subject headers.
#import "MessengerSystem.h"


#define TEST_PARENT_NAME (@"parentName")
#define TEST_CHILD_NAME_0 (@"child_0")
#define TEST_FAIL_PARENT_NAME (@"failParent")


@interface MessengerSystemTest : SenTestCase
{
	MessengerSystem * parent;
	MessengerSystem * child_0;
}
@end



@implementation MessengerSystemTest

/* The setUp method is called automatically before each test-case method (methods whose name starts with 'test').
 */
- (void) setUp {
	NSLog(@"%@ setUp", self.name);
	parent = [[MessengerSystem alloc] initWithBodyID:self withSelector:nil withName:TEST_PARENT_NAME];
	child_0 = [[MessengerSystem alloc]initWithBodyID:self withSelector:nil withName:TEST_CHILD_NAME_0 withParent:TEST_PARENT_NAME];
}

/* The tearDown method is called automatically after each test-case method (methods whose name starts with 'test').
 */
- (void) tearDown {
	[parent release];
	[child_0 release];
	NSLog(@"%@ tearDown", self.name);
}



/*
 初期化する
 IDとかがゲットできる筈。
 */
- (void) testInitializeParent {
	STAssertEquals([parent getMyName],TEST_PARENT_NAME, @"自分で設定した名前がこの時点で異なる！");
}


/*
 親の名前を取得する
 */
- (void) testGetParentName {
	STAssertEquals([child_0 getMyParentName], TEST_PARENT_NAME, @"親の名前が想定と違う");
}


/**
 ParentInputへのテスト
 */
//- (void) testInputToParent {
//	[child_0 inputToMyParent];
//	STAssertEquals([child_0 getMyParentMSID], [parent getMyMSID], [NSString stringWithFormat:@"親のIDが想定と違う/child_0_%@, parent_%@", [child_0 getMyParentMSID], [parent getMyMSID]]);
//}


/**
 子供から親を登録し、登録内容の返りを確認する
 子供リストの内容を取得、確認する
 */
//- (void) testGetChildDict {
//	[child_0 inputToMyParent];
//	
//	NSMutableDictionary * dict = [parent getChildDict];
//	STAssertNil(!dict, [NSString stringWithFormat:@"nilっぽい_%@", dict]);
//	STAssertEquals([dict valueForKey:[child_0 getMyName]], [child_0 getMyMSID], [NSString stringWithFormat:@"多分なにやらまちがえたんかも_%@", dict]);
//}


/**
 他のMessenger読み出しのテストを行う
 */
- (void) testCall {
	[child_0 inputToMyParent];

	[parent call:TEST_CHILD_NAME_0 withExec:@"yeah!", nil];
}



/**
 必ずアサートが発生して失敗するテスト！
 */
//- (void) testFailChildCall {
//	[child_0 setMyParentName:TEST_FAIL_PARENT_NAME];
//	[child_0 postToMyParent];
//	
//	STAssertEquals([child_0 getMyParentMSID], [parent getMyMSID], [NSString stringWithFormat:@"親のIDが想定と違う/child_0_%@, parent_%@", [child_0 getMyParentMSID], [parent getMyMSID]]);
//}







//
///*
// 指定した親が存在するかしないか確認する機能のテスト
// */
//- (void) testInitialized {
//	
//	Boolean b = [messenger initialized];
//	STAssertFalse(b, @"親が見つからず初期化できなかった");
//}
//
//
//	 
///*
// セレクタ渡しに関するテスト
// クラスBから親Aへと連絡を出し、
// */
//	 
//	 
///*
// 親子関係の出力に関するテスト、ビューを要求する
// UIViewを吐き出させるのかな？
// */
//







@end

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
	parent = [[MessengerSystem alloc] initWithBodyID:self withSelector:nil withName:@"ParentName"];
	
	//messenger = [[MessengerSystem new] retain];
//	STAssertNotNil(messenger, @"Cannot create Calculator instance");
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
	STAssertEquals([parent getMyName],@"ParentName", @"bagu!");//すげー、文字列一致も見れてる。
}


/*
 親の名前を取得する
 */
- (void) testGetParentName {
	child_0 = [[MessengerSystem alloc]initWithBodyID:self withSelector:nil withName:@"child_0" withParent:@"ParentName"];
	STAssertEquals([child_0 getParentName], @"ParentName", @"親の名前が想定と違う");
}


/*
 親と子の間の通信を確認する
 子→親の設定確認
 
 双方がメッセージセンターを持ち、かつ子から親へと向けたメッセージを親が受信する。
 子は自分自身へのメッセージを無視する？　IDが振られるまでは特定のコマンド以外受信しない
 
 
 */
- (void) testChildCall {
	child_0 = [[MessengerSystem alloc]initWithBodyID:self withSelector:nil withName:@"child_0" withParent:@"ParentName"];
	[child_0 postToParent];//この処理が完了した時点で、親からの返り値が帰ってくるようにする。
	
	STAssertEquals([child_0 getParentMSID], [parent getMyMSID], @"親のIDが想定と違う");
}






/**
 子供リストの名称を取得する
 */
- (void) testGetChildList {
//	NSMutableArray * array = [messenger getChildList];
}



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

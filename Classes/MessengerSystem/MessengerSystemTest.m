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
#define TEST_CHILD_NAME_1 (@"child_1")

#define TEST_FAIL_PARENT_NAME (@"failParent")




@interface MessengerSystemTest : SenTestCase
{
	MessengerSystem * parent;
	MessengerSystem * child_0;
}

- (void) testParent:(NSNotification * )notification;
- (void) testChild:(NSNotification * )notification;

@end



@implementation MessengerSystemTest

/* 
 セットアップ
 */
- (void) setUp {
	NSLog(@"%@ setUp", self.name);
	parent = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(testParent:) withName:TEST_PARENT_NAME];
	child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(testChild:) withName:TEST_CHILD_NAME_0];


}


/* 
 ティアダウン
 */
- (void) tearDown {
	
	[parent release];
	[child_0 release];
	NSLog(@"終了！！！！");
	
}



/*
 初期化する
 IDとかがゲットできる筈。
 */
- (void) testInitializeParent {
	STAssertEquals([parent getMyName],TEST_PARENT_NAME, @"自分で設定した名前がこの時点で異なる！");
}


/**
 テスト用にたたかれるメソッド
 */
- (void) testParent:(NSNotification * )notification {
}
- (void) testChild:(NSNotification * )notification {
}


/**
 自分自身へのテスト
 */
- (void) testCallMyself {
	[parent callMyself:@"To Myself!!",nil];
	
	//送信記録と受信記録が残る筈。
	NSDictionary * logDict = [parent getLog];
	
	
}

/*
 親の名前を取得する
 */
- (void) testGetParentName {
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];
	STAssertEquals([child_0 getMyParentName], TEST_PARENT_NAME, @"親の名前が想定と違う");
}


/**
 ParentInputのテスト
 */
- (void) testInputToParent {
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];
	STAssertEquals([child_0 getMyParentMSID], [parent getMyMSID], [NSString stringWithFormat:@"親のIDが想定と違う/child_0_%@, parent_%@", [child_0 getMyParentMSID], [parent getMyMSID]]);
}


/**
 子供から親を登録し、登録内容の返りを確認する
 子供リストの内容を取得、確認する
 */
- (void) testGetChildDict {
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];
	
	NSMutableDictionary * dict = [parent getChildDict];
	STAssertEquals([dict valueForKey:[child_0 getMyMSID]], [child_0 getMyName], [NSString stringWithFormat:@"多分なにやらまちがえたんかも_%@", dict]);
}





/**
 ログの作成テスト
 */
- (void) testCreateLog {
	//ログファイルがもくろみ通り作成されているかのテスト
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];
	//この時点で、子供は親へと宣言を送ったというログを持っているはず。
	
	NSDictionary * logDict = [child_0 getLog];
}

/**
 ログの読み出し機能のテスト
 */
- (void) testReadLog {
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];
	//この時点で、子供は親へと宣言を送ったというログを持っているはず。
	
}

/**
 ログの追加機能のチェック
 */
- (void) testAddLog {
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];
	//この時点で、子供は親へと宣言を送ったというログを持っているはず。
	
}




/**
 親から子へ、指定してメッセージを送信
 他のMessenger読み出しのテストを行う
 */
- (void) testCall {
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];
	
	MessengerSystem * child_1 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(testChild:) withName:TEST_CHILD_NAME_1];
	
	[parent call:TEST_CHILD_NAME_0 withExec:@"yeah!", nil];
	
	
	NSLog(@"value_%d,	%@", [[parent getMyMSID] intValue], [parent getMyMSID]);
	
	//確認するには、どうすればいいかな。
	
	//parentからchild_0へとメッセージが行き、child_以外には届かない、という事を確認したい。
	//parent本人にも届いてはいけない。
	
	//関係のないchild_1にも届いてはいけない。
	
	//ログを取るようにしようか。 
}


/**
 子から親へ
 */
- (void) testCallParent {
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];
	
	MessengerSystem * child_1 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(testChild:) withName:TEST_CHILD_NAME_1];
	
	[parent call:TEST_CHILD_NAME_0 withExec:@"yeah2!", nil];
	
	
	NSLog(@"value_%d,	%@", [[parent getMyMSID] intValue], [parent getMyMSID]);
	
	[child_0 callParent:@"hooh!", nil];
	
}


/*
 MSIDを数値化する事ができるっぽい。いいねえ。だとしたら、そういうテーブルを作っておいて、switchでつかう、とかできそうね。
 
 */


//banする機構ってあるの？　→ 無い！ そんな不完全な機構作らん。







/**
 二人目の子供
 2つのキャパシティがあり、それぞれキーがMSID、バリューとして名前が各自のもの、という状態で入っているはず。
 */
- (void) testAddChild {
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];
	
	MessengerSystem * child_1 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(testChild:) withName:TEST_CHILD_NAME_1];
	[child_1 inputToMyParentWithName:TEST_PARENT_NAME];
	
	NSMutableDictionary * dict = [parent getChildDict];
	
	STAssertEquals([dict valueForKey:[child_0 getMyMSID]], [child_0 getMyName], @"child_0の親登録が違った");
	STAssertEquals([dict valueForKey:[child_1 getMyMSID]], [child_1 getMyName], @"child_1の親登録が違った");
}


/**
 一人目の子供の子供
 */
- (void) testChild_child {
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];
	
	MessengerSystem * child_1 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(testChild:) withName:TEST_CHILD_NAME_1];
	[child_1 inputToMyParentWithName:[child_0 getMyName]];
	
	//child_0の子供としてchild_1をセットした際、child_0の名前がchild_1のmyParentにセットしてあるはず。
	NSMutableDictionary * dict1 = [child_0 getChildDict];
	STAssertEquals([dict1 valueForKey:[child_1 getMyMSID]], [child_1 getMyName], @"child_1の親登録が違った");
	
	
	//親に送る系の命令は、child_1からは0、0からはparentに行くはず。
	
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

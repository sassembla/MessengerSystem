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
#import "MessengerView.h"


#define TEST_PARENT_NAME (@"parent_0")
#define TEST_CHILD_NAME_0 (@"child_0")
#define TEST_CHILD_NAME_2 (@"child_2")
#define TEST_CHILD_NAME_3 (@"child_3")

#define TEST_FAIL_PARENT_NAME (@"failParent")

#define TEST_EXEC (@"testExec")
#define TEST_EXEC_2 (@"testExec_2")
#define TEST_EXEC_3 (@"testExec_3")



@interface MessengerSystemTest : SenTestCase
{
	MessengerSystem * parent;
	MessengerSystem * parent2;
	
	MessengerSystem * child_0;//1と同名の子供
	MessengerSystem * child_1;//0と同名の子供
	
	MessengerSystem * child_2;
	MessengerSystem * child_3;
	
	
}

- (void) m_testParent:(NSNotification * )notification;

- (void) m_testChild0:(NSNotification * )notification;
- (void) m_testChild1:(NSNotification * )notification;

- (void) m_testChild2:(NSNotification * )notification;
- (void) m_testChild3:(NSNotification * )notification;

@end



@implementation MessengerSystemTest

/* 
 セットアップ
 */
- (void) setUp {
	NSLog(@"%@ setUp", self.name);//なにこれ。自分ってメソッドになれるの。継承してる元がそういう性能を持ってるのか。
	parent = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testParent:) withName:TEST_PARENT_NAME];
	parent2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testParent:) withName:TEST_PARENT_NAME];
	
	child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	child_1 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild1:) withName:TEST_CHILD_NAME_0];
	
	child_2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild2:) withName:TEST_CHILD_NAME_2];
	child_3 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild3:) withName:TEST_CHILD_NAME_3];
}


/* 
 ティアダウン
 */
- (void) tearDown {
	
	[parent release];
	[parent2 release];
	[child_0 release];
	[child_1 release];
	[child_2 release];
	[child_3 release];
	
	NSLog(@"tearDown");
	
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
- (void) m_testParent:(NSNotification * )notification {
	NSLog(@"到達している");
}

/**
 テスト用に叩かれるメソッド、
 子供用。
 0で使用
 */
- (void) m_testChild0:(NSNotification * )notification {
	NSLog(@"testChild_%@",notification);
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	NSString * exec = [dict valueForKey:MS_EXECUTE];
	NSLog(@"exec_%@",exec);
	
	if ([exec isEqualToString:TEST_EXEC_2]) {
		NSLog(@"m_testChild 返答実行 TEST_EXEC_2");
		[child_0 callParent:TEST_EXEC_3,
		 [child_0 tag:@"届いたら" val:@"いいな"],nil];
	}
	
}

/**
 テスト用に叩かれるメソッド、
 子供用。
 1で使用
 */
- (void) m_testChild1:(NSNotification * )notification {
	NSLog(@"testChild1_%@",notification);
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	NSString * exec = [dict valueForKey:MS_EXECUTE];
	NSLog(@"exec1_%@",exec);
	
	if ([exec isEqualToString:TEST_EXEC_2]) {
		NSLog(@"m_testChild1 返答実行 TEST_EXEC_2");
		[child_1 callParent:TEST_EXEC_3,
		 [child_1 tag:@"届いたら" val:@"いいな"],nil];
	}
	
}

/**
 テスト用に叩かれるメソッド、
 子供用2。
 
 */
- (void) m_testChild2:(NSNotification * )notification {
	NSLog(@"testChild_%@",notification);
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	NSString * exec = [dict valueForKey:MS_EXECUTE];
	NSLog(@"exec_%@",exec);
	
}

/**
 テスト用に叩かれるメソッド、
 子供用3。
 
 */
- (void) m_testChild3:(NSNotification * )notification {
	NSLog(@"testChild_%@",notification);
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	NSString * exec = [dict valueForKey:MS_EXECUTE];
	NSLog(@"exec_%@",exec);
	
}



/**
 自分自身へのテスト
 */
- (void) testCallMyself {
	[parent callMyself:@"To Myself!!",nil];
	
	//送信記録と受信記録が残る筈。
//	NSDictionary * logDict = [parent getLogStore];
	
	
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
 わざと存在しない親の名前を指定した際のテスト
 こういうのは、failになるような条件で書いて、Failかどうかを判定するのがいいんだろうか。判断を考えないとな。
 */
//- (void) testInputToParentfailure {
//	[child_0 inputToMyParentWithName:TEST_FAIL_PARENT_NAME];
//	STFail(@"到達してはいけない");
//}



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
	
	//この時点で、子供は親へと宣言を送った、さらに親がそれを受け止めて返した、というログを持っているはず。
	NSDictionary * logDict = [child_0 getLogStore];
	
	STAssertTrue([logDict count] == 2, [NSString stringWithFormat:@"内容が合致しません_%d", [logDict count]]);
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
 自分自身を読み出す
 callメソッドを使うと失敗してしまってOK
 */
- (void) testCall_Myself_failure {
	//[parent call:TEST_PARENT_NAME withExec:TEST_EXEC, nil];//callメソッドで自分に送ってはいけない
}



/**
 親から子へ、指定してメッセージを送信
 他のMessenger読み出しのテストを行う
 */
- (void) testCall {
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];//発信、親認定で+2件
	
	NSDictionary * logDict = [child_0 getLogStore];
	STAssertTrue([logDict count] == 2, [NSString stringWithFormat:@"子供認定2 内容が合致しません_%d", [logDict count]]);
	
	
	NSDictionary * parentLogDict = [parent getLogStore];//親の辞書 子供からの親設定を受信、受付+1 1件
	STAssertTrue([parentLogDict count] == 1, [NSString stringWithFormat:@"親の辞書、内容が合致しません_%d", [parentLogDict count]]);
	
	NSDictionary * parentLogDict2 = [parent2 getLogStore];//親の辞書 べき順がランダムでないなら、空の筈。
	STAssertTrue([parentLogDict2 count] == 0, [NSString stringWithFormat:@"親2の辞書、内容が合致しません_%d", [parentLogDict2 count]]);
	
	
	
	[parent call:TEST_CHILD_NAME_0 withExec:TEST_EXEC, nil];//親からの送信で+1 ２件
	STAssertTrue([parentLogDict count] == 2, [NSString stringWithFormat:@"親の辞書、内容が合致しません_%d", [parentLogDict count]]);
	
	
	//子供の受け取り確認 受け取り+1 3件
	STAssertTrue([logDict count] == 3, [NSString stringWithFormat:@"親から子への送信3 内容が合致しません_%d", [logDict count]]);
	
	
	
	[parent call:[child_0 getMyName] withExec:TEST_EXEC_2, nil];//親の送信で+1 子供からの返信で+1 4件
	
	//子供の受け取りログ+1、発信ログ+1 5件
	STAssertTrue([logDict count] == 5, [NSString stringWithFormat:@"子供5 内容が合致しません_%d", [logDict count]]);
	
	
	
	NSLog(@"parentLogDict_%@", parentLogDict);
	STAssertTrue([parentLogDict count] == 4, [NSString stringWithFormat:@"親の辞書4、内容が合致しません_%d", [parentLogDict count]]);
	
	
	NSDictionary * child1Dict_1 = [child_1 getLogStore];//親登録していない子供は、受け取ってはいけないので、0件
	STAssertTrue([child1Dict_1 count] == 0, [NSString stringWithFormat:@"child1Dict_1_内容が合致しません_%d", [child1Dict_1 count]]);
	
	
	STAssertTrue([logDict count] == 5, [NSString stringWithFormat:@"親から子への送信5_内容が合致しません_%d", [logDict count]]);
	
}

/**
 親から子へ
 設定されていない子へと届いてはいけないし、ログ内容に残ってはいけない。
 */
- (void) testCallToNotChild {
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];//発信、親認定で+2件
	
	[parent call:[child_2 getMyName] withExec:TEST_EXEC, nil];//無効な呼び出し
	
	NSDictionary * parentLogDict = [parent getLogStore];//親の辞書には、子供Aからの通信で1件、存在しない子供Bへの最初の書き込みで0件 1
	STAssertTrue([parentLogDict count] == 1, [NSString stringWithFormat:@"testCallToNotChild_親の内容1_内容が合致しません_%d", [parentLogDict count]]);	
}




/**
 存在しなかった子供が存在できるようになったところから、続きとして動作するかテスト
 */
- (void) testCallToNotChild_continue {
	
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];//発信、親認定で+2件
	
	[parent call:[child_2 getMyName] withExec:TEST_EXEC, nil];//無効な呼び出し
	
	
	NSDictionary * parentLogDict = [parent getLogStore];//親の辞書には、子供Aからの通信で1件、存在しない子供Bへの最初の書き込みで0件 1
	STAssertTrue([parentLogDict count] == 1, [NSString stringWithFormat:@"親の内容1_内容が合致しません_%d", [parentLogDict count]]);
	
	
	//親の辞書を調べてみる。
//	NSDictionary * parentDict = [parent getLogStore];
	
	[child_2 inputToMyParentWithName:[parent getMyName]];//発信、親認定で+2件
	
	NSDictionary * child_2Dict = [child_2 getLogStore];
	STAssertTrue([child_2Dict count] == 2, [NSString stringWithFormat:@"子の内容1_内容が合致しません_%d", [child_2Dict count]]);
	
	
	//親の辞書には、子供Bからの通信で１件　+1 2
	STAssertTrue([parentLogDict count] == 2, [NSString stringWithFormat:@"親の内容2_内容が合致しません_%d", [parentLogDict count]]);
	
	
	
	
	[parent call:[child_2 getMyName] withExec:TEST_EXEC, nil];//子供Bへの通信で１件 +1 3
	
	
	STAssertTrue([parentLogDict count] == 3, [NSString stringWithFormat:@"親の内容3_内容が合致しません_%d", [parentLogDict count]]);
}


/**
 親から子へ
 子供からの通信順番をいじったバージョン
 
 */
- (void) testCallToNotChild_another {
	
	[parent call:[child_2 getMyName] withExec:TEST_EXEC, nil];//無効
	
	/**
	 存在しているがセットされていない相手にcallした後の動作
	 */
	NSDictionary * parentLogDict = [parent getLogStore];//親の辞書には、存在しない子供Bへの最初の書き込みで0件 0
	STAssertTrue([parentLogDict count] == 0, [NSString stringWithFormat:@"親の内容1_内容が合致しません_%d", [parentLogDict count]]);
	
	
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];//発信、親認定で+2件
	[child_2 inputToMyParentWithName:TEST_PARENT_NAME];//発信、親認定で+2件
	
	NSDictionary * child_0Dict = [child_0 getLogStore];
	STAssertTrue([child_0Dict count] == 2, [NSString stringWithFormat:@"子の内容1_内容が合致しません_%d", [child_0Dict count]]);
	
	
	//親の辞書には、子供Aからの通信で１件 、子供Bからの通信で１件 2
	STAssertTrue([parentLogDict count] == 2, [NSString stringWithFormat:@"親の内容2_内容が合致しません_%d", [parentLogDict count]]);
	
	[parent call:TEST_CHILD_NAME_0 withExec:TEST_EXEC, nil];
	[parent call:TEST_CHILD_NAME_2 withExec:TEST_EXEC, nil];
}


//２人目の子供が駄目説
- (void) test2Child {
	
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];//発信、親認定で+2件
	[child_2 inputToMyParentWithName:TEST_PARENT_NAME];//発信、親認定で+2件
	[child_3 inputToMyParentWithName:TEST_PARENT_NAME];//発信、親認定で+2件

	[parent call:TEST_CHILD_NAME_0 withExec:TEST_EXEC, nil];
	[parent call:TEST_CHILD_NAME_2 withExec:TEST_EXEC, nil];
	[parent call:TEST_CHILD_NAME_3 withExec:TEST_EXEC, nil];
	

}


/**
 同名の複数の子供
 */
- (void) testSameNameChild {
	
	
}



/**
 子から親へ
 */
- (void) testCallParent {
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];//2件
	NSDictionary * child_0Dict = [child_0 getLogStore];
	
	STAssertTrue([child_0Dict count] == 2, [NSString stringWithFormat:@"子の内容2_内容が合致しません_%d", [child_0Dict count]]);
	
	
	[parent call:TEST_CHILD_NAME_0 withExec:TEST_EXEC, nil];//子供からの受信ログ +1 親からの送信ログ +1 2件
	NSDictionary * parentDict = [parent getLogStore];
	STAssertTrue([parentDict count] == 2, [NSString stringWithFormat:@"親の内容2_内容が合致しません_%d", [parentDict count]]);
	STAssertTrue([child_0Dict count] == 3, [NSString stringWithFormat:@"子の内容3_内容が合致しません_%d", [child_0Dict count]]);
	
	
	[child_0 callParent:@"hooh!", nil];//作成+1 送信+1 4件
	
	STAssertTrue([child_0Dict count] == 4, [NSString stringWithFormat:@"子の内容4_内容が合致しません_%d", [child_0Dict count]]);
	
	//無関係な子供への登録件数は0件な筈
	NSDictionary * child_1Dict = [child_1 getLogStore];
	STAssertTrue([child_1Dict count] == 0, [NSString stringWithFormat:@"子の内容0_内容が合致しません_%d", [child_1Dict count]]);
	
	//無関係な親への登録件数は0件な筈
	NSDictionary * parentDict1 = [parent2 getLogStore];
	STAssertTrue([parentDict1 count] == 0, [NSString stringWithFormat:@"親2の内容0_内容が合致しません_%d", [parentDict1 count]]);
	
	
	//親には子供からのメッセージが届いている筈+1 3件
	STAssertTrue([parentDict count] == 3, [NSString stringWithFormat:@"親の内容3_内容が合致しません_%d", [parentDict count]]);
	
}


//複数存在系の確認
/**
 親が複数いるケース
 */
- (void) testMultiParent {
	
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];//2件
	
	NSDictionary * parentDict_0 = [parent getLogStore];
	NSDictionary * parentDict_1 = [parent2 getLogStore];//子供辞書が完成していない筈
	
	NSLog(@"parentDict_0_%@", parentDict_0);//真っ先に親に指定されている筈 +1 1件
	STAssertTrue([parentDict_0 count] == 1, @"親として認定");
	
 	NSLog(@"parentDict_1_%@", parentDict_1);//同名で先に設定されている親が既に居るので、無視されてしかるべき 0件
	STAssertTrue([parentDict_1 count] == 0, @"親として認定されてしまっている？");
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
	[child_2 inputToMyParentWithName:TEST_PARENT_NAME];
	
	
	NSMutableDictionary * dict = [parent getChildDict];//親の辞書をチェックする
	
	STAssertEquals([dict valueForKey:[child_0 getMyMSID]], [child_0 getMyName], @"child_0の親登録が違った");
	STAssertEquals([dict valueForKey:[child_2 getMyMSID]], [child_2 getMyName], @"child_2の親登録が違った");
}


/**
 一人目の子供の子供
 */
- (void) testChild_s_child {
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];
	
	[child_2 inputToMyParentWithName:[child_0 getMyName]];
	
	//child_0の子供としてchild_2をセットした際、child_0の名前がchild_2のmyParentにセットしてあるはず。
	NSMutableDictionary * dict1 = [child_0 getChildDict];
	STAssertEquals([dict1 valueForKey:[child_2 getMyMSID]], [child_2 getMyName], @"child_2の親登録が違った");
	
	
	//親に送る系の命令は、child_2からは0、0からはparentに行くはず。
}


/**
 親を切り替えるテスト
 */
- (void) testResetParent {
	[child_0 inputToMyParentWithName:[parent getMyName]];
	
	NSMutableDictionary * parentChildDict = [parent getChildDict];
	STAssertTrue([parentChildDict count] == 1, [NSString stringWithFormat:@"親の持っている子供辞書が1件になっていない_%d", [parentChildDict count]]);
	
	
	[child_0 resetMyParentData];//親情報をリセットする
	
	//parentの子供辞書を調べてみる、一件も無くなっている筈
	STAssertTrue([parentChildDict count] == 0, [NSString stringWithFormat:@"親の持っている子供辞書が0件になっていない_%d", [parentChildDict count]]);
	
	[child_0 inputToMyParentWithName:[child_2 getMyName]];//新規親情報
	
	NSMutableDictionary * dict2 = [child_2 getChildDict];
	STAssertEquals([dict2 valueForKey:[child_0 getMyMSID]], [child_0 getMyName], @"child_2の親登録が違った");
	
	
	[child_2 call:[child_0 getMyName] withExec:@"試し",nil];
	
	
	//STAssertEquals([dict1 valueForKey:[child_2 getMyMSID]], [child_2 getMyName], @"child_2の親登録が違った");
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



/**
 文字列の数値化
 */
- (void) testCharToNumber {
	NSString * str = @"A7058498-B94C-4998-A2EF-4046BCB79AA3";
	
	str = @"C";
//	STAssertTrue([parent changeStrToNumber:str] == 12977804, [NSString stringWithFormat:@"異なる1_%d", [parent changeStrToNumber:str]]);
	//
//	str = @"A7058498-B94C-4998-A2EF-4046BCB79AA4";
//	STAssertTrue([parent changeStrToNumber:str] == 12977836, [NSString stringWithFormat:@"異なる2_%d", [parent changeStrToNumber:str]]);
//	
//	str = @"A7058498-B94C-4998-A2EF-4046BCB79AA5";
//	STAssertTrue([parent changeStrToNumber:str] == 12977868, [NSString stringWithFormat:@"異なる3_%d", [parent changeStrToNumber:str]]);
//
//	str = @"AAAAAAA8-B94C-4998-A2EF-4046BCB79AA5";
//	STAssertTrue([parent changeStrToNumber:str] == 12977868, [NSString stringWithFormat:@"異なる4_%d", [parent changeStrToNumber:str]]);
}


/**
 ビューに関するテスト
 */

/**
 子供の追加を確認
 */
- (void) testMessengerViewAddChild {
	MessengerView * mView = [[MessengerView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	
	
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];//一件成立している親子関係がある筈
	
	
	//view側で受け取れており、Dictに情報がたまっていればOK
	NSMutableDictionary * mViewDict = [mView getViewDictionary];
	STAssertTrue([mViewDict count] == 1, [NSString stringWithFormat:@"ViewDict件数が合っていない_%d", [mViewDict count]]);
	
	NSMutableDictionary * mButtonDict = [mView getButtonDictionary];
	STAssertTrue([mButtonDict count] == 1, [NSString stringWithFormat:@"ButtonDict件数が合っていない_%d", [mButtonDict count]]);
	
	
	[mView release];
}

/**
 子供の解消を確認
 */
- (void) testMessengerViewRemoveChild {
	MessengerView * mView = [[MessengerView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	
	NSMutableDictionary * mViewDict = [mView getViewDictionary];
	NSMutableDictionary * mButtonDict = [mView getButtonDictionary];
	
	
	[child_0 inputToMyParentWithName:TEST_PARENT_NAME];//一件成立している親子関係がある筈
	STAssertTrue([mViewDict count] == 1, [NSString stringWithFormat:@"ViewDict件数が合っていない_%d", [mViewDict count]]);
	STAssertTrue([mButtonDict count] == 1, [NSString stringWithFormat:@"ButtonDict件数が合っていない_%d", [mButtonDict count]]);

	[child_0 resetMyParentData];//一件成立している親子関係を破壊
	
	//この時点で親ラインが消えている筈
	STAssertTrue([mViewDict count] == 0, [NSString stringWithFormat:@"ViewDict件数が合っていない_%d", [mViewDict count]]);
	STAssertTrue([mButtonDict count] == 0, [NSString stringWithFormat:@"ButtonDict件数が合っていない_%d", [mButtonDict count]]);

	[child_0 inputToMyParentWithName:[parent2 getMyName]];//一件成立している親子関係がある筈
	
	//この時点で親ラインが出ている筈
	STAssertTrue([mViewDict count] == 1, [NSString stringWithFormat:@"ViewDict件数が合っていない_%d", [mViewDict count]]);
	STAssertTrue([mButtonDict count] == 1, [NSString stringWithFormat:@"ButtonDict件数が合っていない_%d", [mButtonDict count]]);

	[mView release];
}

/**
 あと、テストできる要素は、グラフィカルな物かなあ。
 ボタンを追加する、消す、
 ボタンからラインを引く
 ボタンの名称、形状とかを見たいね。
 とりあえずインスタンスをリスト化してもつところからスタートかしら。
 */










@end

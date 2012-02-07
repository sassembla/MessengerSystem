//
//  MessengerSystemTest.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright 2010 KISSAKI. All rights reserved.
//

/**
 遅延実行
 遠隔実行
 
 これらについて、各通信手段のはすがけが全テストケース。
 
 子供の持ち方については、テスト内容で試した物以外は不明。
 
 */

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

// Test-subject headers.
#import "MessengerSystem.h"
#import "MessengerViewController.h"

#import "TimeMine.h"


#define TEST_PARENT_NAME (@"parent_0")
#define TEST_CHILDPERSIS_NAME (@"child_persis")//グローバルで所持する子供

#define TEST_PARENT_NAME_2 (@"parent_2")
#define TEST_CHILD_NAME_0 (@"child_0")
#define TEST_CHILD_NAME_2 (@"child_2")
#define TEST_CHILD_NAME_3 (@"child_3")


#define TEST_FAIL_PARENT_NAME (@"failParent")

#define TEST_EXEC	(@"testExec")
#define TEST_EXEC_2 (@"testExec_2")
#define TEST_EXEC_3 (@"testExec_3")
#define TEST_PARENT_INVOKE		(@"testParentExec")
#define TEST_PARENT_MULTICHILD	(@"子だくさん")

#define TEST_EXEC_LOCKED	(@"TEST_EXEC_LOCKED")
#define TEST_LOCKKEY		(@"TEST_LOCKKEY")
#define TEST_LOCKKEY_2		(@"TEST_LOCKKEY_2")
#define TEST_LOCKNAME		(@"TEST_LOCKNAME")

#define TEST_EXEC_LOCKED_BEFORE	(@"TEST_EXEC_LOCKED_BEFORE")
#define TEST_EXEC_LOCKED_MAIN	(@"TEST_EXEC_LOCKED_MAIN")
#define TEST_EXEC_LOCKED_MAIN_2	(@"TEST_EXEC_LOCKED_MAIN_2")
#define TEST_EXEC_LOCKED_AFTER	(@"TEST_EXEC_LOCKED_AFTER")

#define TEST_EXEC_LOCKED_MULTI		(@"TEST_EXEC_LOCKED_MULTI")
#define TEST_EXEC_LOCKED_MULTI_2	(@"TEST_EXEC_LOCKED_MULTI_2")


#define TEST_CLASS_A    (@"TEST_CLASS_A")

#define TEST_RET_RESULT (@"TEST_RET_RESULT")



@interface MessengerSystemTest : SenTestCase
{
	MessengerSystem * parent;
	MessengerSystem * child_persis;
	
	NSMutableArray * m_orderArray;
}

- (void) m_testParent:(NSNotification * )notification;

- (void) m_testChild0:(NSNotification * )notification;
- (void) m_testChild1:(NSNotification * )notification;

- (void) m_testChild2:(NSNotification * )notification;
- (void) m_testChild3:(NSNotification * )notification;


- (void) sayHello:(NSString * )str;

@end




enum execTypeEnum//衝突性の担保が出来ない。index値がhashであっても、難しい。まあでもhashを使うって言うのはありかなー、、生成時にキーがつけられればなー。createKeyみたいな。
{
    ClassA_EXEC_0 = 0,
    ClassA_EXEC_1,
    EXEC_2,
    EXEC_3,
    EXEC_4
};


/**
 ExecNameSpaceテスト用の外部クラスの定義
 */
@interface ClassA : NSObject {
    MessengerSystem * messenger;
}
- (id) initClassA;
- (NSDictionary * ) receiveLog;
@end



@implementation ClassA

/*
 初期化
 */
- (id) initClassA {
    if (self = [super init]) {
        messenger = [[MessengerSystem alloc]initWithBodyID:self withSelector:@selector(receiver:) withName:TEST_CLASS_A];
        [messenger inputParent:TEST_PARENT_NAME];
    }
    return self;
}

/*
 レシーバ
 */
- (void) receiver:(NSNotification * ) notif {
    NSLog(@"received    ClassA  %@", notif);
    int index = [messenger getExecAsIndexFromNotification:notif];
    
    switch (index) {
        case ClassA_EXEC_0:
            break;
            
        case ClassA_EXEC_1:
            NSLog(@"good.");
            break;
        case 100:
            NSLog(@"どうなるか");
            break;
        default:
            NSLog(@"hazure  %d", [messenger getExecAsIndexFromNotification:notif]);
            break;
    }
    
    
}



@interface ClassB {
    
}
@end

@implementation ClassB 

@end

<#methods#>

@end

- (NSDictionary * ) receiveLog {
    return [messenger getLogStore];
}


- (void) dealloc {
    [messenger release];
}

@end





@implementation MessengerSystemTest

/* 
 セットアップ
 */
- (void) setUp {
	NSLog(@"%@ setUp", self.name);
	parent = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testParent:) withName:TEST_PARENT_NAME];
	child_persis = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILDPERSIS_NAME];
}


/* 
 ティアダウン
 */
- (void) tearDown {
	STAssertTrue([parent retainCount] == 1, @"parent　カウントがおかしい_%d", [parent retainCount]);
	[parent release];
	
	STAssertTrue([child_persis retainCount] == 1, @"child_persis　カウントがおかしい_%d", [child_persis retainCount]);
	[child_persis release];
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
	
	NSMutableDictionary * dict = [parent getTagValueDictionaryFromNotification:notification];	
	
	
	
	//[parent showMessengerPackage:notification];
	
	
	
	NSString * exec = [parent getExecAsString:dict];//辞書からの取得
	
	NSString * exec1 = [dict valueForKey:MS_EXECUTE];//直接キーを指定して取得
	
	NSString * exec2 = [parent getExecFromNotification:notification];//notificationからの取得
	
	
	STAssertEquals(exec,exec1, @"m_testParent_一致しない_0,1");
	STAssertEquals(exec,exec2, @"m_testParent_一致しない_0,2");
	STAssertEquals(exec1,exec2, @"m_testParent_一致しない_1,2");
	
	if ([exec isEqualToString:TEST_PARENT_INVOKE]) {
		[parent remoteInvocation:dict, @"遠隔実行で親から子供の、子供から指定されたメソッド実行にて実行しています。", nil];
	}
	if ([exec isEqualToString:TEST_EXEC_LOCKED_MAIN] || [exec isEqualToString:TEST_EXEC_LOCKED_MAIN_2] || [exec isEqualToString:TEST_EXEC_LOCKED_BEFORE] || [exec isEqualToString:TEST_EXEC_LOCKED_AFTER]) {
		//数字の少ないものから順に削って行く
		if (m_orderArray) {
			if ([[m_orderArray objectAtIndex:0] isEqualToString:exec]) {
				[m_orderArray removeObjectAtIndex:0];
			}
		}
	}
}

/**
 テスト用に叩かれるメソッド、
 子供用。
 child_persisで使用
 */
- (void) m_testChild0:(NSNotification * )notification {
	//MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	
	//NSLog(@"testChild_%@",notification);
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	
	
	NSString * exec = [dict valueForKey:MS_EXECUTE];
	NSLog(@"exec_%@",exec);
	
	if ([exec isEqualToString:TEST_EXEC_2]) {
		NSLog(@"m_testChild 返答実行 TEST_EXEC_2");
		[child_persis callParent:TEST_EXEC_3,
		 [child_persis tag:@"届いたら" val:@"いいな"],nil];
	}
	
	
}

/**
 テスト用に叩かれるメソッド、
 子供用。
 1で使用
 */
- (void) m_testChild1:(NSNotification * )notification {
	//MessengerSystem * child_1 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild1:) withName:TEST_CHILD_NAME_0];
	
	//[[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	NSLog(@"testChild1_%@",notification);
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	NSString * exec = [dict valueForKey:MS_EXECUTE];
	NSLog(@"exec1_%@",exec);
	
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
 テスト用に遠隔実行されるメソッド
 */
- (void) sayHello:(NSString * )str {
	NSLog(@"Hello!_%@", str);
	
}







//テスト
/**
 自分自身へのテスト
 */
- (void) testCallMyself {
	
	[parent callMyself:@"To Myself!!",nil];
	
	//送信記録と受信記録が残る筈。
	NSDictionary * m_logDict = [parent getLogStore];
	//自分自身への通信なので、送信と受信が一件ずつ残る筈
	
	STAssertTrue([m_logDict count] == 2, @"発信記録、受信記録が含まれていない");
}

/**
 Deallocコード
 */
- (void) testDealloc {
	NSString * code = [[NSString stringWithFormat:@"仮に"] autorelease];
	NSLog(@"code_retainCount_%d", [code retainCount]);//この時点で１ならOK、というレベル。
	NSLog(@"code_%@", code);
	//[code release];//リリースしちゃいけないのか！
	//	NSLog(@"code_retainCount2_%d", [code retainCount]);//releaseした後でも１を保つが、参照すると吹っ飛ぶ。
	
	
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	STAssertTrue([child_0 retainCount] == 1, [NSString stringWithFormat:@"解放準備ができていない1_%d", [child_0 retainCount]]);
	
	
	[child_0 inputParent:TEST_PARENT_NAME];
	[child_0 removeFromParent];
	
	STAssertTrue([child_0 retainCount] == 1, [NSString stringWithFormat:@"解放準備ができていない2_%d", [child_0 retainCount]]);
	
	[child_0 release];
}

/*
 親の名前を取得する
 */
- (void) testGetParentName {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	
	[child_0 inputParent:TEST_PARENT_NAME];
	STAssertEquals([child_0 getMyParentName], TEST_PARENT_NAME, @"親の名前が想定と違う");
	
	STAssertTrue([child_0 hasParent], @"親がセットされている筈なのに判定がおかしい");//child_0には親がセットされている筈
	
	[child_0 release];
}


/**
 ParentInputのテスト
 */
- (void) testInputToParent {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	
	[child_0 inputParent:TEST_PARENT_NAME];
	STAssertEquals([child_0 getMyParentMID], [parent getMyMID], [NSString stringWithFormat:@"親のIDが想定と違う/child_0_%@, parent_%@", [child_0 getMyParentMID], [parent getMyMID]]);
	[child_0 release];
}


/**
 子供を解除する
 */
- (void) testRemoveChild {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	
	[child_0 inputParent:TEST_PARENT_NAME];
	STAssertTrue([[child_0 getMyParentMID] isEqualToString:[parent getMyMID]], [NSString stringWithFormat:@"親のIDが想定と違う/child_0_%@, parent_%@", [child_0 getMyParentMID], [parent getMyMID]]);
	
	[parent removeAllChild];
	
	STAssertTrue([[child_0 getMyParentMID] isEqualToString:MS_DEFAULT_PARENTMID], [NSString stringWithFormat:@"親のIDが想定と違う/child_0_%@, parent_%@", [child_0 getMyParentMID], [parent getMyMID]]);
	[child_0 release];
}

/**
 わざと存在しない親の名前を指定した際のテスト
 こういうのは、failになるような条件で書いて、Failかどうかを判定するのがいいんだろうか。判断を考えないとな。
 */
//- (void) testInputToParentfailure {
//	[child_0 inputParent:TEST_FAIL_PARENT_NAME];
//	STFail(@"到達してはいけない");
//}



/**
 子供から親を登録し、登録内容の返りを確認する
 子供リストの内容を取得、確認する
 */
- (void) testGetChildDict {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	
	[child_0 inputParent:TEST_PARENT_NAME];
	
	NSMutableDictionary * dict = [parent getChildDict];
	STAssertEquals([dict valueForKey:[child_0 getMyMID]], [child_0 getMyName], [NSString stringWithFormat:@"多分なにやらまちがえたんかも_%@", dict]);
	
	//	STAssertTrue([child_0 retainCount] == 1, @"testGetChildDict　カウントがおかしい_%d", [child_0 retainCount]);
	[child_0 release];
}





/**
 ログの作成テスト
 */
- (void) testCreateLog {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	
	//ログファイルがもくろみ通り作成されているかのテスト
	[child_0 inputParent:TEST_PARENT_NAME];
	
	//この時点で、子供は親へと宣言を送った、さらに親がそれを受け止めて返した、というログを持っているはず。
	NSDictionary * m_logDict = [child_0 getLogStore];
	
	STAssertTrue([m_logDict count] == 2, [NSString stringWithFormat:@"内容が合致しません_%d", [m_logDict count]]);
	
	//	STAssertTrue([child_0 retainCount] == 1, @"testCreateLog　カウントがおかしい_%d", [child_0 retainCount]);
	[child_0 release];//でてない,,,
	NSLog(@"突破してる");
}

/**
 ログの読み出し機能のテスト
 */
- (void) testReadLog {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	
	[child_0 inputParent:TEST_PARENT_NAME];
	
	//この時点で、子供は親へと宣言を送ったというログを持っているはず。
	[child_0 release];
}

/**
 ログの追加機能のチェック
 */
- (void) testAddLog {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	
	[child_0 inputParent:TEST_PARENT_NAME];
	
	//この時点で、子供は親へと宣言を送ったというログを持っているはず。
	[child_0 release];
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
	
	[child_persis inputParent:TEST_PARENT_NAME];//発信、親認定で+2件
	
	NSDictionary * m_logDict = [child_persis getLogStore];
	STAssertTrue([m_logDict count] == 2, [NSString stringWithFormat:@"子供認定2 内容が合致しません_%d", [m_logDict count]]);
	
	
	NSDictionary * parentLogDict = [parent getLogStore];//親の辞書 子供からの親設定を受信、受付+1 1件
	STAssertTrue([parentLogDict count] == 1, [NSString stringWithFormat:@"親の辞書、内容が合致しません_%d", [parentLogDict count]]);
	
	MessengerSystem * parent2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testParent:) withName:TEST_PARENT_NAME];
	
	NSDictionary * parentLogDict2 = [parent2 getLogStore];//親の辞書 べき順がランダムでないなら、空の筈。
	STAssertTrue([parentLogDict2 count] == 0, [NSString stringWithFormat:@"親2の辞書、内容が合致しません_%d", [parentLogDict2 count]]);
	
	
	
	[parent call:[child_persis getMyName] withExec:TEST_EXEC, nil];//親からの送信で+1 ２件
	STAssertTrue([parentLogDict count] == 2, [NSString stringWithFormat:@"親の辞書、内容が合致しません_%d", [parentLogDict count]]);
	
	
	//子供の受け取り確認 受け取り+1 3件
	STAssertTrue([m_logDict count] == 3, [NSString stringWithFormat:@"親から子への送信3 内容が合致しません_%d", [m_logDict count]]);
	
	
	
	[parent call:[child_persis getMyName] withExec:TEST_EXEC_2, nil];//親の送信で+1 子供からの返信で+1 4件
	
	//子供の受け取りログ+1、発信ログ+1 5件
	STAssertTrue([m_logDict count] == 5, [NSString stringWithFormat:@"子供5 内容が合致しません_%d", [m_logDict count]]);
	
	
	
	NSLog(@"parentLogDict_%@", parentLogDict);
	STAssertTrue([parentLogDict count] == 4, [NSString stringWithFormat:@"親の辞書4、内容が合致しません_%d", [parentLogDict count]]);
	
	MessengerSystem * child_1 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild1:) withName:TEST_CHILD_NAME_0];
	
	NSDictionary * child1Dict_1 = [child_1 getLogStore];//親登録していない子供は、受け取ってはいけないので、0件
	STAssertTrue([child1Dict_1 count] == 0, [NSString stringWithFormat:@"child1Dict_1_内容が合致しません_%d", [child1Dict_1 count]]);
	
	
	STAssertTrue([m_logDict count] == 5, [NSString stringWithFormat:@"親から子への送信5_内容が合致しません_%d", [m_logDict count]]);
	
	[parent2 release];
	[child_1 release];
}

/**
 親から子へ
 設定されていない子へと届いてはいけないし、ログ内容に残ってはいけない。
 */
- (void) testCallToNotChild {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	
	[child_0 inputParent:TEST_PARENT_NAME];//発信、親認定で+2件
	
	
	NSDictionary * parentLogDict = [parent getLogStore];//親の辞書には、子供Aからの通信で1件、存在しない子供Bへの最初の書き込みで0件 1
	STAssertTrue([parentLogDict count] == 1, [NSString stringWithFormat:@"testCallToNotChild_親の内容1_内容が合致しません_%d", [parentLogDict count]]);	
	
	
	[child_0 release];
}





/**
 複数の子供のDealloc確認
 */
- (void) test2Child {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	
	MessengerSystem * child_2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild2:) withName:TEST_CHILD_NAME_2];
	MessengerSystem * child_3 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild3:) withName:TEST_CHILD_NAME_3];
	
	[child_0 inputParent:TEST_PARENT_NAME];//発信、親認定で+2件
	[child_2 inputParent:TEST_PARENT_NAME];//発信、親認定で+2件
	[child_3 inputParent:TEST_PARENT_NAME];//発信、親認定で+2件
	
	[parent call:TEST_CHILD_NAME_0 withExec:TEST_EXEC, nil];
	[parent call:TEST_CHILD_NAME_2 withExec:TEST_EXEC, nil];
	[parent call:TEST_CHILD_NAME_3 withExec:TEST_EXEC, nil];
	
	STAssertTrue([child_0 retainCount] == 1, @"test2Child　カウントがおかしい_%d", [child_0 retainCount]);
	STAssertTrue([child_2 retainCount] == 1, @"test2Child　2カウントがおかしい_%d", [child_2 retainCount]);
	STAssertTrue([child_3 retainCount] == 1, @"test2Child　3カウントがおかしい_%d", [child_3 retainCount]);
	
	[child_0 release];
	[child_2 release];
	[child_3 release];
}


/**
 同名の複数の子供
 */
- (void) testSameNameChild {
	MessengerSystem * child_00 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	MessengerSystem * child_01 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	MessengerSystem * child_02 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	MessengerSystem * child_03 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	MessengerSystem * child_04 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	
	
	[child_00 inputParent:[parent getMyName]];
	[child_01 inputParent:[parent getMyName]];
	[child_02 inputParent:[parent getMyName]];
	[child_03 inputParent:[parent getMyName]];
	[child_04 inputParent:[parent getMyName]];
	
	STAssertTrue([parent hasChild], @"子供がいない事になってる");
	STAssertTrue([[parent getChildDict] count] == 5, @"子供が足りない");
	
	[child_00 removeFromParent];
	
	
	
	//親から子供にコールすると、全員に届く筈
	[parent call:[child_00 getMyName] withExec:TEST_PARENT_MULTICHILD,nil];
	
	
	
	
	
	[child_00 release];
	[child_01 release];
	[child_02 release];
	[child_03 release];
	[child_04 release];
}



/**
 子から親へ
 */
- (void) testCallParent {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	
	[child_0 inputParent:TEST_PARENT_NAME];//2件
	NSDictionary * child_0Dict = [child_0 getLogStore];
	
	STAssertTrue([child_0Dict count] == 2, [NSString stringWithFormat:@"子の内容2_内容が合致しません_%d", [child_0Dict count]]);
	
	
	[parent call:TEST_CHILD_NAME_0 withExec:TEST_EXEC, nil];//子供からの受信ログ +1 親からの送信ログ +1 2件
	NSDictionary * parentDict = [parent getLogStore];
	STAssertTrue([parentDict count] == 2, [NSString stringWithFormat:@"親の内容2_内容が合致しません_%d", [parentDict count]]);
	STAssertTrue([child_0Dict count] == 3, [NSString stringWithFormat:@"子の内容3_内容が合致しません_%d", [child_0Dict count]]);
	
	
	[child_0 callParent:@"hooh!", nil];//作成+1 送信+1 4件
	
	STAssertTrue([child_0Dict count] == 4, [NSString stringWithFormat:@"子の内容4_内容が合致しません_%d", [child_0Dict count]]);
	
	MessengerSystem * child_1 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild1:) withName:TEST_CHILD_NAME_0];
	//無関係な子供への登録件数は0件な筈
	NSDictionary * child_1Dict = [child_1 getLogStore];
	STAssertTrue([child_1Dict count] == 0, [NSString stringWithFormat:@"子の内容0_内容が合致しません_%d", [child_1Dict count]]);
	
	MessengerSystem * parent2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testParent:) withName:TEST_PARENT_NAME];
	//無関係な親への登録件数は0件な筈
	NSDictionary * parentDict1 = [parent2 getLogStore];
	STAssertTrue([parentDict1 count] == 0, [NSString stringWithFormat:@"親2の内容0_内容が合致しません_%d", [parentDict1 count]]);
	
	
	//親には子供からのメッセージが届いている筈+1 3件
	STAssertTrue([parentDict count] == 3, [NSString stringWithFormat:@"親の内容3_内容が合致しません_%d", [parentDict count]]);
	
	[child_0 release];
	[child_1 release];
	[parent2 release];
}


//複数存在系の確認
/**
 親が複数いるケース
 */
- (void) testMultiParent {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	
	[child_0 inputParent:TEST_PARENT_NAME];//2件
	MessengerSystem * parent2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testParent:) withName:TEST_PARENT_NAME];
	
	
	NSDictionary * parentDict_0 = [parent getLogStore];
	NSDictionary * parentDict_1 = [parent2 getLogStore];//子供辞書が完成していない筈
	
	NSLog(@"parentDict_0_%@", parentDict_0);//真っ先に親に指定されている筈 +1 1件
	STAssertTrue([parentDict_0 count] == 1, @"親として認定");
	
 	NSLog(@"parentDict_1_%@", parentDict_1);//同名で先に設定されている親が既に居るので、無視されてしかるべき 0件
	STAssertTrue([parentDict_1 count] == 0, @"親として認定されてしまっている？");
	
	[child_0 release];
	[parent2 release];
}







/**
 二人目の子供
 2つのキャパシティがあり、それぞれキーがMID、バリューとして名前が各自のもの、という状態で入っているはず。
 */
- (void) testAddChild {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	MessengerSystem * child_2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild2:) withName:TEST_CHILD_NAME_2];
	
	[child_0 inputParent:TEST_PARENT_NAME];
	[child_2 inputParent:TEST_PARENT_NAME];
	
	
	NSMutableDictionary * dict = [parent getChildDict];//親の辞書をチェックする
	
	STAssertEquals([dict valueForKey:[child_0 getMyMID]], [child_0 getMyName], @"child_0の親登録が違った");
	STAssertEquals([dict valueForKey:[child_2 getMyMID]], [child_2 getMyName], @"child_2の親登録が違った");
	[child_0 release];
	[child_2 release];
}


/**
 一人目の子供の子供
 */
- (void) testChild_s_child {
	MessengerSystem * child_2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild2:) withName:TEST_CHILD_NAME_2];
	
	
	[child_persis inputParent:TEST_PARENT_NAME];
	
	[child_2 inputParent:[child_persis getMyName]];
	
	//child_0の子供としてchild_2をセットした際、child_0の名前がchild_2のmyParentにセットしてあるはず。
	NSMutableDictionary * dict1 = [child_persis getChildDict];
	STAssertTrue([[dict1 valueForKey:[child_2 getMyMID]] isEqualToString:[child_2 getMyName]], @"child_2の親登録が違った");
	
	
	//親に送る系の命令は、child_2からは0、0からはparentに行くはず。
	//	STAssertTrue([child_2 retainCount] == 1, @"testChild_s_child　カウントがおかしい_%d", [child_2 retainCount]);
	[child_2 release];
}


/**
 一人目の子供に同名の複数の子供
 */
- (void) testChild_s_child_sameName {
	MessengerSystem * child_2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild2:) withName:TEST_CHILD_NAME_2];
	MessengerSystem * child_3 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild2:) withName:TEST_CHILD_NAME_2];
	
	
	[child_persis inputParent:TEST_PARENT_NAME];
	
	[child_2 inputParent:[child_persis getMyName]];
	[child_3 inputParent:[child_persis getMyName]];
	
	//child_0の子供としてchild_2をセットした際、child_0の名前がchild_2のmyParentにセットしてあるはず。
	NSMutableDictionary * dict1 = [child_persis getChildDict];
	STAssertTrue([[dict1 valueForKey:[child_2 getMyMID]] isEqualToString:[child_2 getMyName]], @"child_2の親登録が違った");
	
	
	//親に送る系の命令は、child_2からは0、0からはparentに行くはず。
	//	STAssertTrue([child_2 retainCount] == 1, @"testChild_s_child　カウントがおかしい_%d", [child_2 retainCount]);
	[child_2 release];
	[child_3 release];
}



/**
 複数の子供を設定し、順に削除する
 */
- (void) testMultiChild {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	MessengerSystem * child_2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild2:) withName:TEST_CHILD_NAME_2];
	
	[child_0 inputParent:[parent getMyName]];
	[child_2 inputParent:[parent getMyName]];
	
	
	[child_0 removeFromParent];//親情報をリセットする
	//親には子供がいる　_2
	//子供２には親がいる 
	STAssertTrue(![child_0 hasParent], @"親設定があります_0");
	STAssertTrue([child_2 hasParent], @"親設定がありません_2");
	STAssertTrue([parent hasChild], @"子供がいません");
	
	[child_2 removeFromParent];//親情報をリセットする
	//親には子供がいない
	//子供２には親がいない
	STAssertTrue(![child_0 hasParent], @"親設定があります_0　その２");
	STAssertTrue(![child_2 hasParent], @"親設定があります_2　その２");
	STAssertTrue(![parent hasChild], @"子供がいます　その２");
	
	[child_0 release];
	[child_2 release];
}



/**
 親を切り替えるテスト
 予備テストとして、ここから呼ばれたらどうなってしまうのか、をチェックする必要がある。
 -親を切り替えたときに子供から親を呼べるか(エラー)、また親から子供を呼べるか（非特定/特定 x 存在/不在）
 
 */
- (void) testResetParent {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	MessengerSystem * child_2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild2:) withName:TEST_CHILD_NAME_2];
	
	
	
	[child_0 inputParent:[parent getMyName]];
	
	NSMutableDictionary * parentChildDict = [parent getChildDict];
	STAssertTrue([parentChildDict count] == 1, [NSString stringWithFormat:@"親の持っている子供辞書が1件になっていない_%d", [parentChildDict count]]);
	
	NSLog(@"child_0の親を抹消");
	[child_0 removeFromParent];//親情報をリセットする
	NSLog(@"child_0の親抹消済みの筈_親ID_%@", [child_0 getMyParentMID]);
	
	//parentの子供辞書を調べてみる、一件も無くなっている筈
	STAssertTrue([parentChildDict count] == 0, [NSString stringWithFormat:@"親の持っている子供辞書が0件になっていない_%d", [parentChildDict count]]);
	STAssertTrue(![child_0 hasParent], @"子供がまだ親情報を持っている");
	STAssertTrue(![parent hasChild], @"親がまだ子供情報を持っている");
	
	
	
	[child_0 inputParent:[child_2 getMyName]];//新規親情報
	
	
	
	
	STAssertTrue([child_0 hasParent], @"子供がまだ親情報を持っている");
	STAssertTrue(![parent hasChild], @"親がまだ子供情報を持っている");
	
	NSLog(@"child_0_Parent_%@ = %@", [child_0 getMyParentMID], [child_2 getMyMID]);
	NSLog(@"child_2_Child_%@ = %@", [child_2 getChildDict], [child_0 getMyMID]);
	
	STAssertTrue([child_2 hasChild], @"子供2が子供情報を持っていない");
	
	
	NSMutableDictionary * dict2 = [child_2 getChildDict];
	STAssertTrue([dict2 count] == 1, [NSString stringWithFormat:@"dict2の持っている子供辞書が1件になっていない_%d", [dict2 count]]);
	
	NSLog(@"dict2_%@", dict2);
	STAssertTrue([[dict2 valueForKey:[child_0 getMyMID]] isEqualToString:[child_0 getMyName]], @"child_2の親登録が違った");
	
	[child_2 call:[child_0 getMyName] withExec:@"試し",nil];
	
	
	//STAssertEquals([dict1 valueForKey:[child_2 getMyMID]], [child_2 getMyName], @"child_2の親登録が違った");
	[child_0 release];
	[child_2 release];
	
}

/**
 メソッドの遠隔実行
 */
- (void) testRemoteInvoke {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"じぶん"];
	[child_0 inputParent:TEST_PARENT_NAME];
	
	
	//親から子供0のメソッドを実行する
	[child_0 callParent:TEST_PARENT_INVOKE, 
	 [child_0 tag:@"仮に" val:@"なんでもいいとして"],
	 [child_0 withRemoteFrom:self withSelector:@selector(sayHello:)],
	 nil];
	
	
	[child_0 release];
}

//遅延実行
/**
 遅延実行のテストがそもそも出来るのか
 Dealloc周りのテストもしなきゃな。
 */
- (void) testCallWithDelay {
	
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"じぶん"];
	
	NSMutableDictionary * logD = [child_0 getLogStore];
	
	[child_0 callMyself:@"テスト",
	 [child_0 withDelay:0.3],
	 nil];
	
	STAssertTrue([logD count] == 1, @"送信できてない1");
	//ログのカウントが２になったら終了
	
	while ([logD count] != 2) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	}
	
	
	NSLog(@"無事に非同期で抜けた");
	
	STAssertTrue([logD count] == 2, @"送信できてない2");
	
	
	[child_0 release];
	
}

/**
 遅延実行で、子から親への遅延作成後に親が受け取らないで消えるケース
 消え方、死亡と子供解除
 */
- (void) testDelayCallFromChildToParent_Death {
	
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"じぶん"];
	[child_0 inputParent:[parent getMyName]];
	
	
	NSMutableDictionary * logD = [child_0 getLogStore];
	
	[child_0 callParent:@"テスト",
	 [child_0 withDelay:0.3],
	 nil];
	
	[child_0 callMyself:@"テスト",
	 [child_0 withDelay:0.3],
	 nil];
	
	int r = [parent retainCount];
	for (int i = 0; i < r; i++) {
		[parent release];
	}
	
	STAssertTrue([logD count] == 5, @"送信できてない1_%d", [logD count]);
	
	while ([logD count] != 6) {//受け取りはするんだけれど、何もしない、というのを観測したい。。。 ここでは、子供が親への送信直後に自分で自分宛に送った物を受け取ったとする。
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	}
	
	
	
	parent = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testParent:) withName:TEST_PARENT_NAME];
	[child_0 release];
}

- (void) testDelayCallFromChildToParent_Removed {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"じぶん"];
	[child_0 inputParent:[parent getMyName]];
	
	NSMutableDictionary * logDP = [parent getLogStore];
	STAssertTrue([logDP count] == 1, @"親のログ件数が増えている、受け取ってしまっている1？_%d", [logDP count]);
	
	
	
	NSMutableDictionary * logD = [child_0 getLogStore];
	
	[child_0 callParent:@"テスト",
	 [child_0 withDelay:0.3],
	 nil];
	
	
	[child_0 callMyself:@"テスト",
	 [child_0 withDelay:0.3],
	 nil];
	
	[parent removeAllChild];//ここで親が消える、送信記録１件
	
	STAssertTrue([logDP count] == 2, @"親のログ件数が増えている、受け取ってしまっている3？_%d", [logDP count]);
	NSLog(@"logDP_before_%@", logDP);
	
	
	STAssertTrue([logD count] == 5, @"送信できてない1");
	
	while ([logD count] != 6) {//受け取りはするんだけれど、何もしない、というのを観測したい。。。 ここでは、子供が親への送信直後に自分で自分宛に送った物を受け取ったとする。
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	}
	NSLog(@"logDP_after_%@", logDP);
	STAssertTrue([logDP count] == 2, @"親のログ件数が増えている、受け取ってしまっている4？_%d", [logDP count]);
	
	[child_0 release];
	
} 




/**
 遅延実行で、親から子への遅延作成後に子が受け取らないで消えるケース
 消え方、死亡と子供からの解除
 */
- (void) testDelayCallFromParentToChild_Death {
	
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"じぶん"];
	[child_0 inputParent:[parent getMyName]];
	
	
	NSMutableDictionary * logD = [child_0 getLogStore];
	NSMutableDictionary * logDP = [parent getLogStore];
	
	STAssertTrue([logD count] == 2, @"送信できてない0_%d", [logD count]);
	
	
	[parent call:[child_0 getMyName] withExec:@"テスト",
	 [parent withDelay:0.3],
	 nil];
	
	[parent callMyself:@"テスト",//+2
	 [child_0 withDelay:0.3],
	 nil];
	
	STAssertTrue([logDP count] == 3, @"送信できてない1_%d", [logDP count]);
	
	STAssertTrue([logD count] == 2, @"送信できてない1_%d", [logD count]);
	
	int r = [child_0 retainCount];
	for (int i = 0; i < r; i++) {
		[child_0 release];
	}
	
	//まあ、無理矢理消滅させようとしている時点で汚いのだが。
	
	STAssertTrue([logDP count] == 4, @"送信できてない1_%d", [logD count]);
	
	
	while ([logDP count] != 5) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	}
}

- (void) testDelayCallFromParentToChild_Removed {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"じぶん"];
	[child_0 inputParent:[parent getMyName]];
	
	NSMutableDictionary * logDP = [parent getLogStore];
	STAssertTrue([logDP count] == 1, @"親のログ件数が増えている、受け取ってしまっている1？_%d", [logDP count]);
	
	NSMutableDictionary * logD = [child_0 getLogStore];
	STAssertTrue([logD count] == 2, @"送信できてない1");
	
	
	[parent call:[child_0 getMyName] withExec:@"テスト",
	 [parent withDelay:0.3],
	 nil];
	
	
	[parent callMyself:@"テスト",
	 [parent withDelay:0.3],
	 nil];
	
	[child_0 removeFromParent];//ここで親から消える、送信記録１件
	
	STAssertTrue([logDP count] == 4, @"親のログ件数が増えている、受け取ってしまっている3？_%d", [logDP count]);
	STAssertTrue([logD count] == 3, @"送信できてない3_%d", [logD count]);
	
	
	while ([logDP count] != 5) {//受け取りはするんだけれど、何もしない、というのを観測したい。。。 ここでは、子供が親への送信直後に自分で自分宛に送った物を受け取ったとする。
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	}
	
	
	[child_0 release];
	
}



/**
 遅延実行で、送り主が消えるケース
 親から子、子が受け取る前に親が消える
 */
- (void) testDelayCallFromParentToChild_DeathBeforeReach {
	if (TRUE) return;
	
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"じぶん"];
	[child_0 inputParent:[parent getMyName]];
	
	
	NSMutableDictionary * logD = [child_0 getLogStore];
	NSMutableDictionary * logDP = [parent getLogStore];
	
	STAssertTrue([logD count] == 2, @"送信できてない0_%d", [logD count]);
	
	
	[parent call:[child_0 getMyName] withExec:@"テスト",
	 [parent withDelay:0.3],
	 nil];
	
	[child_0 callMyself:@"テスト",//+2
	 [child_0 withDelay:0.3],
	 nil];
	
	STAssertTrue([logDP count] == 2, @"送信できてない1_%d", [logDP count]);
	
	STAssertTrue([logD count] == 3, @"送信できてない1_%d", [logD count]);
	
	int r = [parent retainCount];
	for (int i = 0; i < r; i++) {
		[parent release];
	}
	
	//まあ、無理矢理消滅させようとしている時点で汚いのだが。
	
	STAssertTrue([logD count] == 4, @"送信できてない1_%d", [logD count]);
	
	
	while ([logD count] != 6) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	}
	
	
	[child_0 release];
	
	parent = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testParent:) withName:TEST_PARENT_NAME];
	
}

- (void) testDelayCallFromParentToChild_RemoveBeforeReach {
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"じぶん"];
	[child_0 inputParent:[parent getMyName]];
	
	NSMutableDictionary * logDP = [parent getLogStore];
	STAssertTrue([logDP count] == 1, @"親のログ件数が増えている、受け取ってしまっている1？_%d", [logDP count]);
	
	NSMutableDictionary * logD = [child_0 getLogStore];
	STAssertTrue([logD count] == 2, @"送信できてない1");
	
	
	[parent call:[child_0 getMyName] withExec:@"テスト",
	 [parent withDelay:0.3],
	 nil];
	
	
	[parent callMyself:@"テスト",
	 [parent withDelay:0.3],
	 nil];
	
	[parent removeAllChild];//ここで親が消える、送信記録１件
	
	STAssertTrue([logDP count] == 4, @"親のログ件数が増えている、受け取ってしまっている3？_%d", [logDP count]);
	STAssertTrue([logD count] == 3, @"送信できてない3_%d", [logD count]);
	STAssertTrue([[child_0 getMyParentName] isEqualToString:MS_DEFAULT_PARENTNAME], @"親の名前がデフォルトになっていない");
	
	while ([logDP count] != 5) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	}
	
	NSLog(@"chil_0'sParentName_%@", [child_0 getMyParentName]);//削除が完了していて、親の名前がデフォルトでなければいけない
	STAssertTrue([logD count] == 3, @"受け取ってしまっている_%d", [logD count]);
	
	
	[child_0 release];
	
}




/**
 遅延実行で、自分自身へのメッセージを自死で受け取らないケース
 これはエラーか。否。エラーの前に、死が確定した瞬間に、送信しているディレイがあるのでまだ死ねない系のアサートエラーを出すべき。
 */
- (void) testDelayCallFromChildToHimself_Death {
	if (TRUE) return;
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"じぶん"];
	STAssertTrue([child_0 retainCount] == 1, @"カウントが増えてる-1_%d", [child_0 retainCount]);
	
	[child_0 inputParent:[parent getMyName]];
	
	STAssertTrue([child_0 retainCount] == 1, @"カウントが増えてる0_%d", [child_0 retainCount]);
	
	NSMutableDictionary * logD = [child_0 getLogStore];
	NSMutableDictionary * logDP = [parent getLogStore];
	
	[child_0 callMyself:@"テスト",
	 [child_0 withDelay:0.3],
	 nil];
	
	
	[child_0 callParent:@"テスト",
	 [child_0 withDelay:0.3],
	 nil];
	
	
	STAssertTrue([logD count] == 4, @"送信できてない1_%d", [logD count]);
	STAssertTrue([logDP count] == 1, @"受信してる？");
	
	int r = [child_0 retainCount];
	for (int i = 0; i < r; i++) {
		[child_0 release];//不意に自殺
	}
	
	STAssertTrue([logDP count] == 2, @"受信してる？_%d", [logDP count]);//親は子供からの親受付と、子供の消滅通知を受け取ってる。
	
	//１つに、死んだ子供の遅延メッセージを受けてもダメージを受けない事、
	//２つに、関係なくカウントは動く事。
	while ([logDP count] != 3) {//親が受け取った、この時点で送信元の子供は死んでいる。つまり、受け取れない筈。
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	}
	
	//エラーが発生する事を正常な動作としたいのだが、内容のアナウンスはしたい。方法が見つかるまでは封印。
	
	NSLog(@"logDP_after_%@", logDP);
} 




/**
 遅延実行しているMessengerをReleaseしようとすると、アサートを出す。
 アサートを正当化するためのtestでもある。
 */
- (void) testAssertDelay {
	NSMutableDictionary * logDP = [parent getLogStore];
	
	
	MessengerSystem * child_00 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"適当"];
	
	[child_00 callMyself:@"時間差",
	 [child_00 withDelay:0.5],
	 nil];
	
	[parent callMyself:@"観測者",
	 [parent withDelay:0.5],
	 nil];
	
	//要件はこうだ、
	/**
	 遅延実行を行っているケースで、まだ実行されていない場合のみ、キャンセルを行う必要がある。releaseコマンドを特化できないかな。
	 それ以外に危険を知らせる方法はないか？ステータスを聞く、とか。
	 →純粋にretainCountを聞くメソッドを作るかな。
	 isReleasable メソッド
	 */
	if (![child_00 isReleasable]) {
		[child_00 cancelPerform];
	}
	
	int r = [child_00 retainCount];
	for (int i = 0; i < r; i++) {
		[child_00 release];
	}
	
	NSLog(@"[parent retainCount]_before_%d", [parent retainCount]);
	
	while ([logDP count] != 2) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	}
	NSLog(@"[parent retainCount]_after_%d", [parent retainCount]);
}





/**
 必ずアサートが発生して失敗するテスト！
 */
//- (void) testFailChildCall {
//	[child_0 setMyParentName:TEST_FAIL_PARENT_NAME];
//	[child_0 postToMyParent];
//	
//	STAssertEquals([child_0 getMyParentMID], [parent getMyMID], [NSString stringWithFormat:@"親のIDが想定と違う/child_0_%@, parent_%@", [child_0 getMyParentMID], [parent getMyMID]]);
//}



/**
 文字列の数値化
 どうやって一意だと検証しようかな。
 */
- (void) testCharToNumber {
	NSString * str;
	
	str = @"A7058498-B94C-4998-A2EF-4046BCB79AA3";
	STAssertTrue([parent changeStrToNumber:str] == 635213667, [NSString stringWithFormat:@"異なる1_%d", [parent changeStrToNumber:str]]);
}

/**
 テスト中の数値の文字列化
 普通に。
 */
- (void) testNumberToString {
	NSString * str = [parent changeNumberToStr:[parent changeStrToNumber:@"bc"]];
	STAssertTrue([str isEqualToString:@"bc"], @"合ってない_%@", str);
	//STAssertTrue(FALSE, @"意図的終了");
}


/**
 ビューに関するテスト
 */

/**
 子供の追加を確認
 
 ビュー自体が最初から存在していた訳では無いケース、、
 親にあたるビューを認識するには、子供から親のデータも貰う以外に無い。親子のインプット時にどうするか。
 
 */
- (void) testMessengerViewAddChild {
	MessengerViewController * mView = [[MessengerViewController alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	[child_0 inputParent:TEST_PARENT_NAME];//一件成立している親子関係がある筈
	
	
	//view側で受け取れており、Dictに情報がたまっていればOK
	NSMutableDictionary * mViewDict = [mView getMessengerList];
	STAssertTrue([mViewDict count] == 2, [NSString stringWithFormat:@"ViewDict件数が合っていない_%d", [mViewDict count]]);
	
	NSMutableDictionary * mButtonDict = [mView getButtonList];
	STAssertTrue([mButtonDict count] == 2, [NSString stringWithFormat:@"m_buttonList件数が合っていない_%d", [mButtonDict count]]);
	
	[mView release];
	[child_0 release];
}



/**
 子供の解消を確認
 */
- (void) testMessengerViewRemoveChild {
	MessengerViewController * mView = [[MessengerViewController alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	//ビューを作った時点で、既にPARENTが存在している。
	
	
	NSMutableDictionary * mMessengerList = [mView getMessengerList];
	NSMutableDictionary * mButtonList = [mView getButtonList];
	
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	
	STAssertTrue([mMessengerList count] == 1, [NSString stringWithFormat:@"ViewDict件数が合っていない1_%d", [mMessengerList count]]);
	STAssertTrue([mButtonList count] == 1, [NSString stringWithFormat:@"m_buttonList件数が合っていない1_%d", [mButtonList count]]);
	
	MessengerSystem * parent2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testParent:) withName:TEST_PARENT_NAME_2];
	
	STAssertTrue([mMessengerList count] == 2, [NSString stringWithFormat:@"ViewDict件数が合っていない2_%d", [mMessengerList count]]);
	STAssertTrue([mButtonList count] == 2, [NSString stringWithFormat:@"m_buttonList件数が合っていない2_%d", [mButtonList count]]);
	
	
	[child_0 inputParent:TEST_PARENT_NAME];//親子関係を成立、
	
	
	STAssertTrue([mMessengerList count] == 3, [NSString stringWithFormat:@"ViewDict件数が合っていない3_%d", [mMessengerList count]]);
	STAssertTrue([mButtonList count] == 3, [NSString stringWithFormat:@"m_buttonList件数が合っていない3_%d", [mButtonList count]]);
	
	//このタイミングで、ラインは一本
	
	[child_0 removeFromParent];//一件成立している親子関係を破壊
	
	//このタイミングで、ラインは０本
	
	//この時点で親子のラインが消えている筈
	STAssertTrue([mMessengerList count] == 3, [NSString stringWithFormat:@"ViewDict件数が合っていない3_%d", [mMessengerList count]]);
	STAssertTrue([mButtonList count] == 3, [NSString stringWithFormat:@"m_buttonList件数が合っていない3_%d", [mButtonList count]]);
	
	
	
	
	//子供１のボタンの、関係性の親の部分がデフォルトになってる筈
	NSString * defaultKey = [mView getMessengerInformationKey:MS_DEFAULT_PARENTNAME withMID:MS_DEFAULT_PARENTMID];
	NSString * child_0sParentValue = [mMessengerList valueForKey:[mView getMessengerInformationKey:[child_0 getMyName]  withMID:[child_0 getMyMID]]];//現在のchild_0情報を引き出す
	STAssertTrue([child_0sParentValue isEqualToString:defaultKey], @"共通ではない_%@", child_0sParentValue);
	
	[child_0 release];
	
	
	//この時点でchild_0関連のデータが消えている筈
	STAssertTrue([mMessengerList count] == 2, [NSString stringWithFormat:@"ViewDict件数が合っていない_%d", [mMessengerList count]]);
	STAssertTrue([mButtonList count] == 2, [NSString stringWithFormat:@"m_buttonList件数が合っていない_%d", [mButtonList count]]);
	
	
	[parent2 release];
	
	//この時点でchild_0関連のデータが消えている筈
	STAssertTrue([mMessengerList count] == 1, [NSString stringWithFormat:@"ViewDict件数が合っていない_%d", [mMessengerList count]]);
	STAssertTrue([mButtonList count] == 1, [NSString stringWithFormat:@"m_buttonList件数が合っていない_%d", [mButtonList count]]);
	
	[mView release];
}



/**
 ビューに関するテスト
 子供を足す
 */
- (void) testViewAddChild {
	MessengerViewController * mView = [[MessengerViewController alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	//ビューを作った時点で、既にPARENTが存在している。が、認識されていない。
	
	NSMutableDictionary * mMessengerList = [mView getMessengerList];
	NSMutableDictionary * mButtonList = [mView getButtonList];
	
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	[child_0 inputParent:TEST_PARENT_NAME];//親子関係を成立、この時点で線が引かれる筈
	
	STAssertTrue([mMessengerList count] == 2, [NSString stringWithFormat:@"ViewDict件数が合っていない_%d", [mMessengerList count]]);
	STAssertTrue([mButtonList count] == 2, [NSString stringWithFormat:@"m_buttonList件数が合っていない_%d", [mButtonList count]]);
	
	
	[mView release];
}


/**
 子供関係を解消
 */
- (void) testViewRemoveChild {
	MessengerViewController * mView = [[MessengerViewController alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	//ビューを作った時点で、既にPARENTが存在している。が、認識されていない。
	
	NSMutableDictionary * mMessengerList = [mView getMessengerList];
	NSMutableDictionary * mButtonList = [mView getButtonList];
	
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	[child_0 inputParent:TEST_PARENT_NAME];//親子関係を成立、この時点で線が引かれる筈
	
	STAssertTrue([mView getNumberOfRelationship] == 1, @"関係性の本数が1本ではない");
	
	[child_0 removeFromParent];
	
	STAssertTrue([mView getNumberOfRelationship] == 0, @"関係性の本数が0本ではない");
	
	
	STAssertTrue([mMessengerList count] == 2, [NSString stringWithFormat:@"ViewDict件数が合っていない_%d", [mMessengerList count]]);
	STAssertTrue([mButtonList count] == 2, [NSString stringWithFormat:@"m_buttonList件数が合っていない_%d", [mButtonList count]]);
	
	
	[mView release];
}



/**
 子供化からの急性自殺
 */
- (void) testViewEraseChild {
	MessengerViewController * mView = [[MessengerViewController alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	//ビューを作った時点で、既にPARENTが存在している。が、認識されていない。
	
	NSMutableDictionary * mMessengerList = [mView getMessengerList];
	NSMutableDictionary * mButtonList = [mView getButtonList];
	
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	[child_0 inputParent:TEST_PARENT_NAME];//親子関係を成立、この時点で線が引かれる筈
	
	STAssertTrue([mView getNumberOfRelationship] == 1, @"関係性の本数が1本ではない");
	
	[child_0 release];
	
	STAssertTrue([mMessengerList count] == 1, [NSString stringWithFormat:@"ViewDict件数が合っていない_%d", [mMessengerList count]]);
	STAssertTrue([mButtonList count] == 1, [NSString stringWithFormat:@"m_buttonList件数が合っていない_%d", [mButtonList count]]);
	
	
	[mView release];
}



/**
 親からの突然の子供解放
 */
- (void) testViewParentKillChild {
	MessengerViewController * mView = [[MessengerViewController alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	//ビューを作った時点で、既にPARENTが存在している。が、認識されていない。
	
	NSMutableDictionary * mMessengerList = [mView getMessengerList];
	NSMutableDictionary * mButtonList = [mView getButtonList];
	
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	[child_0 inputParent:TEST_PARENT_NAME];//親子関係を成立、この時点で線が引かれる筈
	[parent removeAllChild];
	
	STAssertTrue([mView getNumberOfRelationship] == 0, @"関係性の本数が0本ではない");
	
	STAssertTrue([mMessengerList count] == 2, [NSString stringWithFormat:@"ViewDict件数が合っていない_%d", [mMessengerList count]]);
	STAssertTrue([mButtonList count] == 2, [NSString stringWithFormat:@"m_buttonList件数が合っていない_%d", [mButtonList count]]);
	
	
	[mView release];
}


/**
 親の急逝
 */
- (void) testViewParentDeath {
	MessengerViewController * mView = [[MessengerViewController alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	//ビューを作った時点で、既にPARENTが存在している。が、認識されていない。
	
	NSMutableDictionary * mMessengerList = [mView getMessengerList];
	NSMutableDictionary * mButtonList = [mView getButtonList];
	
	MessengerSystem * child_0 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:TEST_CHILD_NAME_0];
	[child_0 inputParent:TEST_PARENT_NAME];//親子関係を成立、この時点で線が引かれる筈
	[parent release];
	
	STAssertTrue([mView getNumberOfRelationship] == 0, @"関係性の本数が0本ではない");
	
	STAssertTrue([mMessengerList count] == 1, [NSString stringWithFormat:@"ViewDict件数が合っていない_%d", [mMessengerList count]]);
	STAssertTrue([mButtonList count] == 1, [NSString stringWithFormat:@"m_buttonList件数が合っていない_%d", [mButtonList count]]);
	
	parent = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testParent:) withName:TEST_PARENT_NAME];
	
	[mView release];
}


/**
 名前のコレクションを行い、異なる名前を集める。
 X軸、ボタンのフレームのX値を更新する。
 */
- (void) testSortNameIndex {
	MessengerViewController * mView = [[MessengerViewController alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	
	MessengerSystem * mes1 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"テスト１"];
	MessengerSystem * mes2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"テスト１"];
	MessengerSystem * mes3 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"テスト２"];
	MessengerSystem * mes4 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"テスト３"];
	
	//件数が3件ならOK
	STAssertTrue([[mView getNameIndexDictionary] count] == 3, @"件数が一致しない");
	
	
	[mes1 release];
	[mes2 release];
	[mes3 release];
	[mes4 release];
	
	[mView release];
}

/**
 X位置の更新確認
 */
- (void) testSortNameIndex_X {
	MessengerViewController * mView = [[MessengerViewController alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	
	MessengerSystem * mes1 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"テスト１"];
	MessengerSystem * mes2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"テスト１"];
	MessengerSystem * mes3 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"テスト２"];
	MessengerSystem * mes4 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"テスト３"];
	
	[mes1 inputParent:[parent getMyName]];
	
	
	//parentが出現し、件数が４件に
	STAssertTrue([[mView getNameIndexDictionary] count] == 4, @"件数が一致しない");
	
	//かつ、parentのインデックスがmes1よりも小さい＝左に来ていればOK
	
	int index = [[[mView getNameIndexDictionary] valueForKey:[parent getMyName]] intValue];
	int index2 = [[[mView getNameIndexDictionary] valueForKey:[mes1 getMyName]] intValue];
	STAssertTrue(index < index2, @"名称が一致しない0_%d", index);
	
	
	[mes3 inputParent:[parent getMyName]];
	[mes4 inputParent:[mes3 getMyName]];
	
	
	index = [[[mView getNameIndexDictionary] valueForKey:[parent getMyName]] intValue];
	index2 = [[[mView getNameIndexDictionary] valueForKey:[mes1 getMyName]] intValue];
	int index3 = [[[mView getNameIndexDictionary] valueForKey:[mes3 getMyName]] intValue];
	int index4 = [[[mView getNameIndexDictionary] valueForKey:[mes4 getMyName]] intValue];
	//多元順序付け、、並べかえのロジック、、に、見直しが必要。合ってない。
	STAssertTrue(index < index2, @"インデックスが想定通りではない1_%d", index);
	STAssertTrue(index < index3, @"インデックスが想定通りではない2_%d", index);
	STAssertTrue(index3 < index4, @"インデックスが想定通りではない3_%d", index);
	
	
	[mes1 release];
	[mes2 release];
	[mes3 release];
	[mes4 release];
	
	[mView release];
}


/**
 複数の同名の親が存在する場合に、特定のMIDを持つメッセンジャーを親にするテスト
 */
- (void) testInputParentWithSpecifiedMID {
	MessengerSystem * mes1 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"テスト１"];
	MessengerSystem * mes2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"テスト２"];
	MessengerSystem * mes3 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"テスト２"];
	
	[mes1 inputParent:[mes2 getMyName] withSpecifiedMID:[mes2 getMyMID]];
	
	STAssertTrue([mes1 hasParent], @"親が存在している筈なのに、存在していない");
	STAssertTrue([[mes1 getMyParentMID] isEqualToString:[mes2 getMyMID]], @"親想定MIDが一致しない");
	
	STAssertTrue([mes2 hasChild], @"子供が存在する筈なのに、存在していない");
	
	STAssertTrue(![mes3 hasChild], @"子供が存在しない筈なのに、存在している");
	
	
	//mes1には、親獲得記録が有る筈。
	
	[mes1 release];
	[mes2 release];
	[mes3 release];
}


/**
 複数の同名の子供が存在する場合に、特定のMIDを持つメッセンジャーにメッセージを送るテスト
 */
- (void) testCallChildWithSpecifiedMID {
	MessengerSystem * mes1 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"テスト１"];
	MessengerSystem * mes2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(m_testChild0:) withName:@"テスト１"];
	
	[mes1 inputParent:[parent getMyName]];	
	[mes2 inputParent:[parent getMyName]];
	
	
	//一人にだけ届くメッセージを送ってみる
	[parent call:[mes1 getMyName] withSpecifiedMID:[mes1 getMyMID] withExec:@"プギャー", nil];
	
	NSMutableDictionary * mes1Log = [mes1 getLogStore];
	STAssertTrue([mes1Log count] == 3, @"ログ件数が合致しない_%d", [mes1Log count]);
	
	
	
	
	//２人に届くメッセージを送ってみる
	[parent call:[mes1 getMyName] withExec:@"プギャー2", nil];
	
	
	STAssertTrue([mes1Log count] == 4, @"ログ件数が合致しない_%d", [mes1Log count]);
	
	NSMutableDictionary * mes2Log = [mes2 getLogStore];
	STAssertTrue([mes2Log count] == 3, @"ログ件数が合致しない_%d", [mes2Log count]);
	
	
	[mes1 release];
	[mes2 release];
}


/**
 ビュー上のボタンがタップされたら色が変わったりする処理
 */
- (void) testButtonTapped{
	
}



/**
 ロック関連
 */
- (void) testSetWithLock {
	NSDictionary * currentLog = [parent getLogStore];
	int num = [currentLog count];
	
	[parent callMyself:TEST_EXEC,
	 [parent withLockAfter:TEST_EXEC_2 withKeyName:MS_EXECUTE],
	 nil];
	
	STAssertTrue(num == [currentLog count]-1, @"only allow creationLog. not equal %d", [currentLog count] - num);
}



- (void) testSetWithLockDefault {
	NSDictionary * currentLog = [parent getLogStore];
	int num = [currentLog count];
	
	[parent callMyself:TEST_EXEC,
	 [parent withLockAfter:TEST_EXEC_2],
	 nil];
	
	STAssertTrue(num == [currentLog count]-1, @"only allow creationLog. not equal %d", [currentLog count] - num);
}


- (void) testGetLockStore {
	
	NSDictionary * lockStore = [parent getLockAfterStore];
	STAssertTrue([lockStore count] == 0, @"not 0");
	
	[parent callMyself:TEST_EXEC_LOCKED,
	 [parent withLockAfter:TEST_EXEC_2 withKeyName:MS_EXECUTE],
	 nil];
	
	STAssertTrue([lockStore count] == 1, @"not 1");
}


- (void) testGetLockStoreInsideCount {
	NSDictionary * lockStore = [parent getLockAfterStore];
	
	[parent callMyself:TEST_EXEC_LOCKED,
	 [parent withLockAfter:TEST_EXEC_2 withKeyName:MS_EXECUTE],
	 nil];
	
	NSDictionary * locksDict = [lockStore objectForKey:[[lockStore allKeys]objectAtIndex:0]];
	STAssertTrue([locksDict count] == 2, @"not 2");
}


/**
 解錠実行、execをキーとしてセット、
 */
- (void) testUnlockDefault {
	[parent callMyself:TEST_EXEC_LOCKED,
	 [parent withLockAfter:TEST_EXEC_2],
	 nil];
	
	NSDictionary * currentLog = [parent getLogStore];
	int num = [currentLog count];
	
	[parent callMyself:TEST_EXEC_2, nil];
	
	STAssertTrue(num+4 == [currentLog count], @"only allow creationLog & send. not equal %d", [currentLog count] - num);
	
	NSDictionary * lockStore = [parent getLockAfterStore];
	STAssertTrue([lockStore count] == 0, @"not 0");
}



- (void) testUnlockValious {
	[parent callMyself:TEST_EXEC_LOCKED,
	 [parent withLockAfter:TEST_EXEC_2 withKeyName:MS_EXECUTE],
	 nil];
	
	NSDictionary * currentLog = [parent getLogStore];
	int num = [currentLog count];
	
	[parent callMyself:TEST_EXEC_2, nil];
	
	STAssertTrue(num+4 == [currentLog count], @"only allow creationLog & send. not equal %d", [currentLog count] - num);
	
	NSDictionary * lockStore = [parent getLockAfterStore];
	STAssertTrue([lockStore count] == 0, @"not 0");
}


- (void) testUnlockValiousNotExec {
	[parent callMyself:TEST_EXEC_LOCKED,
	 [parent withLockAfter:TEST_LOCKKEY withKeyName:TEST_LOCKNAME],
	 nil];
	
	NSDictionary * currentLog = [parent getLogStore];
	int num = [currentLog count];
	
	[parent callMyself:TEST_EXEC_2, 
	 [parent tag:TEST_LOCKNAME val:TEST_LOCKKEY],
	 nil];
	
	STAssertTrue(num+4 == [currentLog count], @"only allow creationLog & send. not equal %d", [currentLog count] - num);
	
	NSDictionary * lockStore = [parent getLockAfterStore];
	STAssertTrue([lockStore count] == 0, @"not 0");
}


- (void) testUnlockExecuteBoth {
	[parent callMyself:TEST_EXEC_LOCKED_BEFORE,
	 [parent withLockBefore:TEST_LOCKKEY withKeyName:TEST_LOCKNAME],
	 nil];
	
	[parent callMyself:TEST_EXEC_LOCKED_AFTER,
	 [parent withLockAfter:TEST_LOCKKEY withKeyName:TEST_LOCKNAME],
	 nil];
	
	NSDictionary * currentLog = [parent getLogStore];
	int num = [currentLog count];
	
	[parent callMyself:TEST_EXEC_LOCKED_MAIN, 
	 [parent tag:TEST_LOCKNAME val:TEST_LOCKKEY],
	 nil];
	
	STAssertTrue(num+6 == [currentLog count], @"only allow creationLog & send. not equal %d", [currentLog count] - num);
	
	NSDictionary * lockStore = [parent getLockAfterStore];
	STAssertTrue([lockStore count] == 0, @"not 0");
}


/**
 実行順番のテスト
 */
- (void) testLockExecuteBothWithOrder {
	[parent callMyself:TEST_EXEC_LOCKED_BEFORE,
	 [parent withLockBefore:TEST_LOCKKEY withKeyName:TEST_LOCKNAME],
	 nil];
	
	[parent callMyself:TEST_EXEC_LOCKED_AFTER,
	 [parent withLockAfter:TEST_LOCKKEY withKeyName:TEST_LOCKNAME],
	 nil];
	
	NSDictionary * currentLog = [parent getLogStore];
	int num = [currentLog count];
	
	[parent callMyself:TEST_EXEC_LOCKED_MAIN, 
	 [parent tag:TEST_LOCKNAME val:TEST_LOCKKEY],
	 nil];
	
	STAssertTrue(num+6 == [currentLog count], @"only allow creationLog & send. not equal %d", [currentLog count] - num);
	
	NSDictionary * lockStore = [parent getLockAfterStore];
	STAssertTrue([lockStore count] == 0, @"not 0");
}


/**
 連鎖のテスト1
 MAINをキーに、Beforeが発動したら、その発動後にAfterが発動する。
 発生順は、
 Before > After > MAIN　のはず。
 */
- (void) testLockExecuteChain_B_A_M {
	m_orderArray = [[NSMutableArray alloc]initWithObjects:				
					TEST_EXEC_LOCKED_BEFORE,
					TEST_EXEC_LOCKED_AFTER,
					TEST_EXEC_LOCKED_MAIN,
					nil];
	
	[parent callMyself:TEST_EXEC_LOCKED_BEFORE,
	 [parent withLockBefore:TEST_EXEC_LOCKED_MAIN],
	 nil];
	 
	[parent callMyself:TEST_EXEC_LOCKED_AFTER,
	 [parent withLockAfter:TEST_EXEC_LOCKED_BEFORE],
	 nil];
	 
	NSDictionary * currentLog = [parent getLogStore];
	int num = [currentLog count];
	
	[parent callMyself:TEST_EXEC_LOCKED_MAIN, 
	 nil];
	 
	STAssertTrue(num+6 == [currentLog count], @"only allow creationLog & send. not equal %d", [currentLog count] - num);
	 
	NSDictionary * lockStore = [parent getLockAfterStore];
	STAssertTrue([lockStore count] == 0, @"not 0");
	
	STAssertTrue([m_orderArray count] == 0, @"not 0");
}

/**
 連鎖のテスト2
 Beforeが発動したら、その発動後にAfterが発動する。
 発生順は、
 MAIN > Before > After　のはず。Afterに対してのBeforeが存在しているので、Beforeが先に消化される。
 */
- (void) testLockExecuteChain_M_B_A {
	m_orderArray = [[NSMutableArray alloc]initWithObjects:
						 TEST_EXEC_LOCKED_MAIN,
						 TEST_EXEC_LOCKED_BEFORE,
						 TEST_EXEC_LOCKED_AFTER,
						 nil];
	
	[parent callMyself:TEST_EXEC_LOCKED_BEFORE,
	 [parent withLockBefore:TEST_EXEC_LOCKED_AFTER],
	 nil];
	
	[parent callMyself:TEST_EXEC_LOCKED_AFTER,
	 [parent withLockAfter:TEST_EXEC_LOCKED_MAIN],
	 nil];
	
	NSDictionary * currentLog = [parent getLogStore];
	int num = [currentLog count];
	
	[parent callMyself:TEST_EXEC_LOCKED_MAIN, 
	 nil];
	
	STAssertTrue(num+6 == [currentLog count], @"only allow creationLog & send. not equal %d", [currentLog count] - num);
	
	NSDictionary * lockStore = [parent getLockAfterStore];
	STAssertTrue([lockStore count] == 0, @"not 0");
	
	STAssertTrue([m_orderArray count] == 0, @"not 0");
}





/**
 複数のロック
 */
- (void) testSetWithLockMulti {
	NSDictionary * currentLog = [parent getLogStore];
	int num = [currentLog count];
	
	[parent callMyself:TEST_EXEC,
	 [parent withLocksAfterWithKeyNames:
	  TEST_EXEC_LOCKED_MULTI, TEST_LOCKKEY,
	  TEST_EXEC_LOCKED_MULTI_2, TEST_LOCKKEY_2,
	  nil],
	 nil];
	
	STAssertTrue(num == [currentLog count]-1, @"only allow creationLog. not equal %d", [currentLog count] - num);
}


//- (void) testSetWithLockMultiDefault {
//	NSDictionary * currentLog = [parent getLogStore];
//	int num = [currentLog count];
//	
//	[parent callMyself:TEST_EXEC,
//	 [parent withLocksAfter:TEST_EXEC_LOCKED_MULTI, TEST_EXEC_LOCKED_MULTI_2, nil],
//	 nil];
//	
//	STAssertTrue(num == [currentLog count]-1, @"only allow creationLog. not equal %d", [currentLog count] - num);
//}



- (void) testGetLockStoreMulti {
	
	NSDictionary * lockStore = [parent getLockAfterStore];
	STAssertTrue([lockStore count] == 0, @"not 0");
	
	[parent callMyself:TEST_EXEC_LOCKED,
	 [parent withLocksAfterWithKeyNames:
	  TEST_EXEC_LOCKED_MULTI, TEST_LOCKKEY,
	  TEST_EXEC_LOCKED_MULTI_2, TEST_LOCKKEY_2,
	  nil],
	 nil];
	
	STAssertTrue([lockStore count] == 1, @"not 1");
}


- (void) testGetLockStoreInsideCountMulti {
	NSDictionary * lockStore = [parent getLockAfterStore];
	
	[parent callMyself:TEST_EXEC_LOCKED,
	 [parent withLocksAfterWithKeyNames:
	  TEST_EXEC_LOCKED_MULTI, TEST_LOCKKEY,
	  TEST_EXEC_LOCKED_MULTI_2, TEST_LOCKKEY_2, 
	  nil],
	 nil];
	
	NSDictionary * locksDict = [lockStore objectForKey:[[lockStore allKeys]objectAtIndex:0]];
	
	STAssertTrue([locksDict count] == 3, @"not 3");
}

- (void) testUnlockValiousNotExecMultiWithOneMessage {
	[parent callMyself:TEST_EXEC_LOCKED,
	 [parent withLocksAfterWithKeyNames:
	  TEST_EXEC_LOCKED_MULTI, TEST_LOCKKEY,
	  TEST_EXEC_LOCKED_MULTI_2, TEST_LOCKKEY_2,
	  nil],
	 nil];
	
	NSDictionary * currentLog = [parent getLogStore];
	int num = [currentLog count];
	
	[parent callMyself:TEST_EXEC_2, 
	 [parent tag:TEST_LOCKKEY val:TEST_EXEC_LOCKED_MULTI],
	 [parent tag:TEST_LOCKKEY_2 val:TEST_EXEC_LOCKED_MULTI_2],
	 nil];
	
	STAssertTrue(num+4 == [currentLog count], @"only allow creationLog & send. not equal %d", [currentLog count] - num);
	
	NSDictionary * lockStore = [parent getLockAfterStore];
	STAssertTrue([lockStore count] == 0, @"not 0");
}

- (void) testUnlockValiousNotExecMultiWithTwoMessage {
	[parent callMyself:TEST_EXEC_LOCKED,
	 [parent withLocksAfterWithKeyNames:
	  TEST_EXEC_LOCKED_MULTI, TEST_LOCKKEY,
	  TEST_EXEC_LOCKED_MULTI_2, TEST_LOCKKEY_2,
	  nil],
	 nil];
	
	NSDictionary * currentLog = [parent getLogStore];
	int num = [currentLog count];
	
	[parent callMyself:TEST_EXEC_2, 
	 [parent tag:TEST_LOCKKEY val:TEST_EXEC_LOCKED_MULTI],
	 nil];
	
	STAssertTrue(num+2 == [currentLog count], @"only allow creationLog & send. not equal %d", [currentLog count] - num);
	
	[parent callMyself:TEST_EXEC_3,
	 [parent tag:TEST_LOCKKEY_2 val:TEST_EXEC_LOCKED_MULTI_2],
	 nil];
	
	STAssertTrue(num+6 == [currentLog count], @"only allow creationLog & send. not equal %d", [currentLog count] - num);
	
	NSDictionary * lockStore = [parent getLockAfterStore];
	STAssertTrue([lockStore count] == 0, @"not 0");
}



/**
 個別のドメインに根ざしたExecの制作を行う。
 特定のMessenger搭載クラスが、特定のExec定義を持つことを想定する。
 */
- (void) testDomainExecCreation {
    
    ClassA * a = [[ClassA alloc]initClassA];
   
    
    int count = [[a receiveLog] count];
    
    
    //ここにクラスAのExecを書く
    [parent call:TEST_CLASS_A withIndex:ClassA_EXEC_1, nil];

    //届いていたら、ClassAのログが１件増えている筈
    STAssertTrue([[a receiveLog] count] == count+1, @"not incremeted...");
}


- (void) testGetRetValue {
    ClassA * a = [[ClassA alloc]initClassA];
    id t = [parent call:TEST_CLASS_A withExec:TEST_EXEC, nil];
}







//- (void) testUnlockValiousNotExecMultiWithTwoMessageDefault {
//	[parent callMyself:TEST_EXEC_LOCKED,
//	 [parent withLocksAfter:
//	  TEST_EXEC_LOCKED_MULTI,
//	  TEST_EXEC_LOCKED_MULTI_2,
//	  nil],
//	 nil];
//	
//	NSDictionary * lockStore = [parent getLockAfterStore];
//	NSDictionary * locksDict = [lockStore objectForKey:[[lockStore allKeys]objectAtIndex:0]];
//	STAssertTrue([locksDict count] == 2, @"not 2");
//	
//	
//	NSDictionary * currentLog = [parent getLogStore];
//	int num = [currentLog count];
//	
//	[parent callMyself:TEST_EXEC_LOCKED_MULTI, 
//	 nil];
//	
//	STAssertTrue(num+2 == [currentLog count], @"only allow creationLog & send. not equal %d", [currentLog count] - num);
//
//	locksDict = [lockStore objectForKey:[[lockStore allKeys]objectAtIndex:0]];
//	STAssertTrue([locksDict count] == 1, @"not 1");
//	
//	
//	
//	
//	[parent callMyself:TEST_EXEC_LOCKED_MULTI_2,
//	 nil];
//	
//	STAssertTrue(num+6 == [currentLog count], @"only allow creationLog & send. not equal %d", [currentLog count] - num);
//	STAssertTrue([lockStore count] == 0, @"not 0");
//	
//}





///**
// 複数ロックでの連鎖のテスト1
// MAINをキーに、Beforeが発動したら、その発動後にAfterが発動する。
// 発生順は、
// MAIN > Before > After > MAIN2　のはず。
// */
//- (void) testLockExecuteChain_M_B_A_M2 {
//	m_orderArray = [[NSMutableArray alloc]initWithObjects:
//					TEST_EXEC_LOCKED_MAIN,
//					TEST_EXEC_LOCKED_BEFORE,
//					TEST_EXEC_LOCKED_AFTER,
//					TEST_EXEC_LOCKED_MAIN_2,
//					nil];
//	
//	[parent callMyself:TEST_EXEC_LOCKED_BEFORE,
//	 [parent withLocksBefore:TEST_EXEC_LOCKED_MAIN, TEST_EXEC_LOCKED_MAIN_2, nil],
//	 nil];
//	
//	[parent callMyself:TEST_EXEC_LOCKED_AFTER,
//	 [parent withLockAfter:TEST_EXEC_LOCKED_BEFORE],
//	 nil];
//	
//	NSDictionary * currentLog = [parent getLogStore];
//	int num = [currentLog count];
//	
//	[parent callMyself:TEST_EXEC_LOCKED_MAIN, 
//	 nil];
//	
//	[parent callMyself:TEST_EXEC_LOCKED_MAIN_2, 
//	 nil];
//	
//	STAssertTrue(num+8 == [currentLog count], @"only allow creationLog & send. not equal %d", [currentLog count] - num);
//	
//	NSDictionary * lockStore = [parent getLockAfterStore];
//	STAssertTrue([lockStore count] == 0, @"not 0");
//	
//	STAssertTrue([m_orderArray count] == 0, @"not 0");
//}

///**
// 複数ロックでの連鎖のテスト2
// Beforeが発動したら、その発動後にAfterが発動する。
// 発生順は、
// MAIN > MAIN2_Before > After　のはず。Afterに対してのBeforeが存在しているので、Beforeが先に消化される。
// */
//- (void) testLockExecuteChain_M_M2_B_A {
//	m_orderArray = [[NSMutableArray alloc]initWithObjects:
//					TEST_EXEC_LOCKED_MAIN,
//					TEST_EXEC_LOCKED_MAIN_2,
//					TEST_EXEC_LOCKED_BEFORE,
//					TEST_EXEC_LOCKED_AFTER,
//					nil];
//	
//	[parent callMyself:TEST_EXEC_LOCKED_BEFORE,
//	 [parent withLockBefore:TEST_EXEC_LOCKED_AFTER],
//	 nil];
//	
//	[parent callMyself:TEST_EXEC_LOCKED_AFTER,
//	 [parent withLocksAfter:TEST_EXEC_LOCKED_MAIN, TEST_EXEC_LOCKED_MAIN_2, nil],
//	 nil];
//	
//	NSDictionary * currentLog = [parent getLogStore];
//	int num = [currentLog count];
//	
//	[parent callMyself:TEST_EXEC_LOCKED_MAIN, 
//	 nil];
//	
//	[parent callMyself:TEST_EXEC_LOCKED_MAIN_2, 
//	 nil];
//	
//	STAssertTrue(num+8 == [currentLog count], @"only allow creationLog & send. not equal %d", [currentLog count] - num);
//	
//	NSDictionary * lockStore = [parent getLockAfterStore];
//	STAssertTrue([lockStore count] == 0, @"not 0");
//	
//	STAssertTrue([m_orderArray count] == 0, @"not 0");
//}




@end

//
//  MessageSystemTest.m
//  Qlippy
//
//  Created by Inoue 徹 on 10/06/09.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "MessageSystemTest.h"

/**
 テストを実装する。
 
 
 center:initWithCentralObserverで作成されたMessageSystemインスタンス
 reciever:initWithRecieverObserberで作成されたMessageSystemインスタンス
 
 
 既存の問題点としては、
 
 1.送信元の情報がデフォルトでは存在しない
	→未解決。実行時に登録、解決できるといいね。 4を実行すれば解決される。 
 
 2.sendMessage,flushMessageToメソッドでの機能内アサートが未完成　nil検知エラーがない。　よく末尾のnilを忘れる
	→チェックできる筈。このテスト以降で実装してしまおう。
 
 3.center-recieverのつながり情報を個々に持っているため、全体把握が非常に困難。複数のシステムを使うと混乱しやすい。
	→オーバービューを見る機能を加えれば、まだマシになるかも。　おもてに出ない探知システムをつけてみるか。システム用のソナー
 
 4.既に存在するcenterとの接続テストを、reciever作成時に行えるとすごくいい
	→ナイスアイデア。初期化時に実行、何かしらの情報を出そう。 そのときに、センター側にも登録が増えるといいな。
 
 5.タイマー実装のテストが自動化されていない
	→deallocをおこなおうとする処理中に、タイマーでの動作が予定されていれば、その処理を待ってからdealloc、という事が出来ればいいのか？
		もしくは単に、警告で、deallocできない事を返せばいいか。　assertでいいですね。
 
 6.事前にIDが振られていなければいけないため、動的にrecieverを足せない、動的にcenterを足せない
	→個々の判別方法、今はintを用いているが、動的に追加するのは難しい。どうすればいいか。
	→UUID見っけ！　使えそう。　本当に内部サーバです、ありがとうございました。

 7.if ([[(NSArray *)[notification userInfo] objectAtIndex:MESSAGE_SENDER] intValue] != QLIPPY_SENDER_ROTATOR) return; のようなrecieverサイドの個別ID検索を辞めたい。
	→レシーバーサイドが個別に存在するため、だが、、、なにかいい案が無い物か。　ここだけ人力すぎる。 あ、でもおかげで、デフォルトの網認識とか出来るか、いらんよな。
		キー:バリューズ　ペアをどこかに持てれば、それでいいのかな。思いつきそうで思いつかない。
		→確認は、４の回答でいけそう。新しい登録IDを放り出せばいい。 コマンドについては、妥協しないで個別にする。
 
 8.命名機能が未実装
	→特定のデフォルト名しか積めていない。
 
 9.引数の内容を問い合わせる物が欲しい。
	→タグ要素？　無視される要素内容を決める？それだといいねえ。　まあ、IDEどっぷりだと使えないので、IDEに組み込める方法を考えるか。

 10.reciever,centralのメソッド、オーバーライド型にしてしまってもいいかもね。
	→その場合、オーバーライドしないで持っている場合の弊害を考えるか。 気づけるかどうか、、　そう考えると、気づきにくくなるので要らないかも知れない。
	→いらない！
	
	
 11.withSelecterに飛び込んでくるのを、このクラス向け、に限定するのは、自動化できるかもしれない。
	初期化時にID値がでているので、その値と内容を比較、一致したら初めてメソッドが実行される、というのはアリ。
 
 その他、懸案
 
 メッセージシステムのエラーについて、サーバとクライアントに見立てて考えてみる。
 
 セレクタを渡し合う系統に形状変更できるかも。MessageSystem
	よりド変態への道、かな？へんなふうにロックしそう。
 
 メッセージシステムで、ピン（潜水艦のアレ）をうったら、全オブジェクトがそれっぽく反応するもの、が欲しい。
	selfに対してaddSubViewとか
	送り側の情報をどうやって表示するか、が見物。
	レイヤー構造に出来るかな。WaterFallとフック（Delegate）
 
 ストラクチャーのNSObject化が出来ると凄く楽になる
	まあ、NSDataのポイント送るのでもいいんだけどさ。
 
 
 */
@implementation MessageSystemTest

- (id) initTest {
	if (self = [super init]) {
		[self setup];
		[self go];
		//[self tearDown];//Deallocを行っているが、パフォーマンス実行を行う場合に、テストしずらい。 予定されていて、実行されるタイミングではインスタンスが存在しない、そのためdealloc後に落ちる、というテストがあり得てしまう。
		
	}
	return self;
}

- (void) setup {
	
	messenger_default_observer = [[MessageSystem alloc] initWithCentralObserver:self centralNamed:@"" recieverNamed:@""  withIdentifier:0 withVersion:20100810 withSelector:@selector(defaultCentral:)];
	messenger_default_reciever = [[MessageSystem alloc] initWithReceiverObserver:self centralNamed:@"" recieverNamed:@""  withIdentifier:1 withVersion:20100810 withSelector:@selector(defaultRecieve:)];
	
	
	messenger_test1_observer = [[MessageSystem alloc] initWithCentralObserver:self centralNamed:@"test1" recieverNamed:@"test1Rec" withIdentifier:2 withVersion:20100810 withSelector:@selector(test1Central:)];
	messenger_test1_reciever = [[MessageSystem alloc] initWithReceiverObserver:self centralNamed:@"test1Rec" recieverNamed:@"test1" withIdentifier:3 withVersion:20100810 withSelector:@selector(test1Recieve:)];
	
	
	messenger_test2_observer = [[MessageSystem alloc] initWithCentralObserver:self centralNamed:@"test2" recieverNamed:@"test2Rec" withIdentifier:4 withVersion:20100810 withSelector:@selector(test2Central:)];
	messenger_test2_reciever = [[MessageSystem alloc] initWithReceiverObserver:self centralNamed:@"test2Rec" recieverNamed:@"test2" withIdentifier:5 withVersion:20100810 withSelector:@selector(test2Recieve:)];
	
}


- (void) go {
	
	[messenger_default_observer sendMessage:100,nil];
	//[messenger_default_observer flushMessageTo:1 withNil:101,nil];
	[messenger_default_reciever sendMessage:102,nil];
	//[messenger_default_observer setPerform:103 withDelay:0.5];//デフォルトで既に使用してあるクラスがあると、反応してしまう。　名前を付ける事をお勧めする。
	
	
	[messenger_test1_observer sendMessage:200,nil];
	[messenger_test1_observer flushMessageTo:3 withNil:201,nil];
	[messenger_test1_reciever sendMessage:202,nil];
	[messenger_test1_observer setPerform:203 withDelay:0.0];//スケジュール実行の親がわかった方がいいね。
	
	
	[messenger_test2_observer sendMessage:300,nil];
	[messenger_test2_observer flushMessageTo:5 withNil:301,nil];
	[messenger_test2_reciever sendMessage:302,nil];
	[messenger_test2_observer setPerform:303 withDelay:0.0];//スケジュール実行の親がわかった方がいいね。
	
}



- (void) tearDown {
	/*
	 メモリデアロケート
	 タイマー実行との相性が異常にわるい。
	 */
	[messenger_default_observer dealloc:self];
	[messenger_default_reciever dealloc:self];
	
	[messenger_test1_observer dealloc:self];
	[messenger_test1_reciever dealloc:self];
	
	[messenger_test2_observer dealloc:self];
	[messenger_test2_reciever dealloc:self];
	
}


- (void) defaultCentral:(NSNotification * )notification {
	NSLog(@"defaultCentral");
	
	NSMutableArray * array = (NSMutableArray *)[notification userInfo];
	
	int sender = [[array objectAtIndex:MESSAGE_SENDER] intValue];
	NSLog(@"sender_%d", sender);
	
	int command = [[array objectAtIndex:MESSAGE_STATEMENT] intValue];
	NSLog(@"command_%d",command);
	
}

- (void) defaultRecieve:(NSNotification * )notification {
	NSLog(@"defaultRecieve");
	
	NSMutableArray * array = (NSMutableArray *)[notification userInfo];
	
	int sender = [[array objectAtIndex:MESSAGE_SENDER] intValue];
	NSLog(@"sender_%d", sender);
	
	int command = [[array objectAtIndex:MESSAGE_STATEMENT] intValue];
	NSLog(@"command_%d",command);
	
}




- (void) test1Central:(NSNotification * )notification {
	NSLog(@"test1Central");
	
	NSMutableArray * array = (NSMutableArray *)[notification userInfo];
	
	int sender = [[array objectAtIndex:MESSAGE_SENDER] intValue];
	NSLog(@"sender_%d", sender);
	
	int command = [[array objectAtIndex:MESSAGE_STATEMENT] intValue];
	NSLog(@"command_%d",command);
	
}

- (void) test1Recieve:(NSNotification * )notification {
	NSLog(@"test1Recieve");	
	
	NSMutableArray * array = (NSMutableArray *)[notification userInfo];
	
	int sender = [[array objectAtIndex:MESSAGE_SENDER] intValue];
	NSLog(@"sender_%d", sender);
	
	int command = [[array objectAtIndex:MESSAGE_STATEMENT] intValue];
	NSLog(@"command_%d",command);
	
}




- (void) test2Central:(NSNotification * )notification {
	NSLog(@"test2Central");	
	
	NSMutableArray * array = (NSMutableArray *)[notification userInfo];
	
	int sender = [[array objectAtIndex:MESSAGE_SENDER] intValue];
	NSLog(@"sender_%d", sender);
	
	int command = [[array objectAtIndex:MESSAGE_STATEMENT] intValue];
	NSLog(@"command_%d",command);
	
}

- (void) test2Recieve:(NSNotification * )notification {
	NSLog(@"test2Recieve");	
	
	NSMutableArray * array = (NSMutableArray *)[notification userInfo];
	
	int sender = [[array objectAtIndex:MESSAGE_SENDER] intValue];
	NSLog(@"sender_%d", sender);
	
	int command = [[array objectAtIndex:MESSAGE_STATEMENT] intValue];
	NSLog(@"command_%d",command);
	
}





@end

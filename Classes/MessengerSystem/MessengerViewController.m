//
//  MessengerViewController.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/09/12.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "MessengerViewController.h"
#import "MessengerIDGenerator.h"


@implementation MessengerViewController
//上書きしなければいけないのは、初期化メソッドと、実行時のメソッド
//あと、このビューメッセンジャー自身の生き死にを記録しては行けないので、自分の存在についての言及は意図的に避ける。

/**
 使用禁止の初期化メソッド
 */
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name {
	NSAssert(false, @"initWithFrameメソッドを使用してください");
	
	if (self = [super init]) {
	}
	
	return self;
}

/**
 初期化メソッド
 */
- (id) initWithFrame:(CGRect)frame {
	if (self = [super init]) {
		
		messengerInterfaceView = [[MessengerDisplayView alloc] initWithFrame:frame];
		
		[self setMyName:VIEW_NAME_DEFAULT];
		[self setMyBodyID:nil];
		[self setMyBodySelector:nil];
		[self initMyMID];
		[self initMyParentData];
		
		buttonList = [[NSMutableDictionary alloc] init];
		messengerList = [[NSMutableDictionary alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(innerPerform:) name:OBSERVER_ID object:nil];
	}
	
	return self;
}


/**
 内部処理実装
 オーバーライドし、実行内容を限定する
 */
- (void) innerPerform:(NSNotification * )notification {
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	
	
	//コマンド名について確認
	NSString * commandName = [dict valueForKey:MS_CATEGOLY];
	if (!commandName) {
		NSLog(@"コマンドが無いため、何の処理も行われずに帰る");
		return;
	}
	
	//送信者名
	NSString * senderName = [dict valueForKey:MS_SENDERNAME];
	if (!senderName) {//送信者不詳であれば無視する
		NSLog(@"送信者NAME不詳");
		return;
	}
	
	
	//送信者MID
	NSString * senderMID = [dict valueForKey:MS_SENDERMID];
	if (!senderMID) {//送信者不詳であれば無視する
		NSLog(@"送信者ID不詳");
		return;
	}
	
	
	//宛名、ログは確認しない。
	
	
	//生成
	if ([commandName isEqualToString:MS_NOTICE_CREATED]) {
		[self insertMessengerInformation:senderName withMID:senderMID];
		return;
	}
	
	//更新
	if ([commandName isEqualToString:MS_NOTICE_UPDATE]) {
		
		NSString * sendersParentName = [dict valueForKey:MS_PARENTNAME];
		if (!sendersParentName) {//送信者の親Name不詳であれば無視する
			NSLog(@"送信者親Name不詳");
			return;
		}

		NSString * sendersParentMID = [dict valueForKey:MS_PARENTMID];
		if (!sendersParentMID) {//送信者の親MID不詳であれば無視する
			NSLog(@"送信者親MID不詳");
			return;
		}
		
		[self updateParentInformation:senderName withMID:senderMID withParentName:sendersParentName withParentMID:sendersParentMID];
		
		return;
	}
	
	
	//自死
	if ([commandName isEqualToString:MS_NOTICE_DEATH]) {
		NSLog(@"MS_NOTICE_DEATH_到着_%@, MID_%@", senderName, senderMID);
	//	NSAssert(FALSE, @"到達");
		[self deleteMessengerInformation:senderName withMID:senderMID];
		return;
	}
	
	
	
	
	

	//その他、認識するが何もしないメソッド
	
	if ([commandName isEqualToString:MS_CATEGOLY_REMOVE_PARENT]) {
		//親設定の解除コマンドを判断
		return;
	}
	
	
	if ([commandName isEqualToString:MS_CATEGOLY_REMOVE_CHILD]) {
		//子供設定の解除コマンドを判断
		return;
	}
	
	
	if ([commandName isEqualToString:MS_CATEGOLY_CALLCHILD]) {
		//親から子の関係性成立済み情報が載っている
		return;
	}
		 
	if ([commandName isEqualToString:MS_CATEGOLY_CALLPARENT]) {
		//子から親の関係性成立済み情報が載っている
		return;
	}
	
	if ([commandName isEqualToString:MS_CATEGOLY_LOCAL]) {
		//だれかからだれか自身へのメッセージ
		return;
	}
	
	if ([commandName isEqualToString:MS_CATEGOLY_PARENTSEARCH]) {
		//親決定のメソッド
		return;
	}
	
	NSAssert(FALSE, @"MessengeViewController　innerPerformの終端_%@", commandName);
}


/**
 メッセンジャーの誕生をビューに反映する
 */
- (void) insertMessengerInformation:(NSString * )senderName 
							withMID:(NSString * )senderMID {
	
	
	//Messengerをアイデンティファイするキーを作成
	NSString * newKey = [self getMessengerInformationKey:senderName withMID:senderMID];
	
	
	//既に存在している場合は無視する
	for (id key in messengerList) {
		if ([key isEqualToString:newKey]) {
			NSAssert(FALSE, @"二度生まれてる？");
			return;
		}
	}
	
	
	//ビュー、辞書に要素を加える
	UIButton * newButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];//[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	
	[newButton setHidden:FALSE];
	
	
	CGPoint point = CGPointMake(0, 120);
	[newButton setFrame:CGRectMake(point.x, point.y, newButton.frame.size.width, newButton.frame.size.height)];
	
	[newButton setBackgroundColor:[UIColor colorWithRed:10.6 green:10 blue:1 alpha:1]];//一応範囲付け、かなあ。
	[newButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
	
	
	[buttonList setValue:newButton forKey:newKey];//ボタン自体を保存、座標もここに含まれる
	
	//新規インスタンスなので、親設定は無い。自分自身から親への関係性を保存する。
	[messengerList setValue:[self getMessengerInformationKey:MS_DEFAULT_PARENTNAME withMID:MS_DEFAULT_PARENTMID] forKey:newKey];
	
	
	[messengerInterfaceView addSubview:newButton];//ビューに加える
	[messengerInterfaceView updateDrawList:buttonList];//ボタン座標データをビューの描画リストにセットする
	
}
/**
 通信してきた対象の情報がアップデートされ、親情報が変更された
 
 正確に更新が行われていれば、線が残るような事は発生しない筈。
 */
- (void) updateParentInformation:(NSString * )senderName 
						withMID:(NSString * )senderMID 
				  withParentName:(NSString * )sendersParentName 
				  withParentMID:(NSString * )sendersParentMID {
	
	//すでに存在している筈
	NSString * myKey = [self getMessengerInformationKey:senderName withMID:senderMID];
	
	
	//既に存在している場合は無視する
	for (id key in messengerList) {
		if ([key isEqualToString:myKey]) {
			
			[messengerList setValue:[self getMessengerInformationKey:sendersParentName withMID:sendersParentMID] forKey:key];
			
			return;
		}
	}
	
	//ビューよりも前から存在していたか、それともインスタンスのよみがえりか。
	//インスタンス寿命とぴったりと一致している訳では無い？
	
	NSAssert1(FALSE, @"updateParentInformation_一度も生まれてない_%@", myKey);
}

/**
 メッセンジャーの削除をビューに反映する
 */
- (void) deleteMessengerInformation:(NSString * )senderName 
							withMID:(NSString * )senderMID {
	
	//Messengerをアイデンティファイするキーを作成
	NSString * removeKey = [self getMessengerInformationKey:senderName withMID:senderMID];
	
	if (![messengerList valueForKey:removeKey]) {
		
		NSLog(@"messengerList_%@", messengerList);
		NSLog(@"removeKey_%@", removeKey);
		NSAssert(FALSE, @"deleteMessengerInformation_一度も生まれていない");
	}
	
	[[buttonList valueForKey:removeKey] removeFromSuperview];//ビューから外す
	[buttonList removeObjectForKey:removeKey];
	
	
	[messengerInterfaceView updateDrawList:buttonList];//更新
	
	
	[messengerList removeObjectForKey:removeKey];//登録抹消
	NSLog(@"登録抹消が行われた_%@", removeKey);
}


/**
 ボタンが押された時のメソッド
 */
- (void) tapped:(UIControlEvents * )event {
	NSLog(@"到達_%@", event);
}



/**
 NameとMIDのペアを作るメソッド
 */
- (NSString * ) getMessengerInformationKey:(NSString * )name withMID:(NSString * )MID {
	return [NSString stringWithFormat:@"%@:%@", name, MID];
}


/**
 ボタン用の辞書を取得する
 */
- (NSMutableDictionary * ) getButtonList {
	return buttonList;
}

/**
 View用の辞書を取得する
 */
- (NSMutableDictionary * ) getMessengerList {
	return messengerList;
}



/**
 Viewを外部に返す
 */
- (UIView * ) getMessengerInterfaceView {
	return messengerInterfaceView;
}




//自前実装のセッターメソッド　プログラム本体ではプライベートカテゴリに実装してある
/**
 自分の名称をセットするメソッド
 */
- (void)setMyName:(NSString * )name {
	myName = name;
}


/**
 自分のBodyIDをセットするメソッド
 */
- (void) setMyBodyID:(id)bodyID {
	myBodyID = bodyID;
}


/**
 自分のBodyが提供するメソッドセレクターを、自分のセレクター用ポインタにセットするメソッド
 */
- (void) setMyBodySelector:(SEL)body_selector {
	myBodySelector = body_selector;
}



/**
 自分のMIDを初期化するメソッド
 */
- (void)initMyMID {
	myMID = [MessengerIDGenerator getMID];
}


/**
 myParent関連情報を初期化する
 */
- (void) initMyParentData {
	[self setMyParentName:MS_DEFAULT_PARENTNAME];
	myParentMID = MS_DEFAULT_PARENTMID;
}


/**
 親の名称をセットするメソッド
 */
- (void) setMyParentName:(NSString * )parent {
	myParentName = parent;
}


//オーバーライドするメソッド、特に何もさせない。
- (void) inputParent:(NSString * )parent {}
- (void) callMyself:(NSString * )exec, ...{}
- (void) call:(NSString * )name withExec:(NSString * )exec, ...{}
- (void) callChild:(NSString * )childName withMID:(NSString * ) withCommand:(NSString * )exec, ...{}
- (void) callParent:(NSString * )exec, ...{}

- (void) createdNotice {}
- (void) updatedNotice:(NSString * )parentName withParentMID:(NSString * )parentMID {}
- (void) killedNotice {}





- (void) dealloc {
	[super dealloc];
	
	
	[messengerList removeAllObjects];
	[buttonList removeAllObjects];
}

@end

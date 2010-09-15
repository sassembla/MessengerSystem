//
//  MessengerView.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/09/12.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "MessengerView.h"

@implementation MessengerView
//上書きしなければいけないのは、初期化メソッドと、実行時のメソッド

/**
 使用禁止の初期化メソッド
 */
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name {
	NSAssert(false, @"initメソッドを使用してください");
	
	if (self = [super init]) {
	}
	
	return self;
}

/**
 初期化メソッド
 */
- (id) initWithFrame:(CGRect)frame {
	if (self = [super init]) {
		
		messengerInterfaceView = [[UIView alloc] initWithFrame:frame];
		
		[self setMyName:VIEW_NAME_DEFAULT];
		[self setMyBodyID:nil];
		[self setMyBodySelector:nil];
		[self initMyMID];
		[self initMyParentData];
		
		buttonDict = [NSMutableDictionary dictionaryWithCapacity:1];
		viewListDict = [NSMutableDictionary dictionaryWithCapacity:1];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(innerPerform:) name:OBSERVER_ID object:nil];
	}
	
	return self;
}


/**
 内部処理実装
 オーバーライドし、実行内容を変貌させる
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
	
	
	if ([commandName isEqualToString:MS_CATEGOLY_GOTPARENT]) {//親設定の完了コマンドを判断￥
		
		NSString * sendersParentName = [dict valueForKey:MS_PARENTNAME];
		if (!sendersParentName) {//送信者の親Name不詳であれば無視する
			NSLog(@"送信者親Name不詳");
			return;
		}

		NSString * sendersParentMSID = [dict valueForKey:MS_PARENTMID];
		if (!sendersParentMSID) {//送信者の親MID不詳であれば無視する
			NSLog(@"送信者親MID不詳");
			return;
		}
		
		//[親を見つけたので子供になった宣言]から、関係性を記録する。
		[self setMessengerInformation:senderName withMID:senderMID withParentName:sendersParentName withParentMID:sendersParentMSID];
		
		return;
	}
	
	
	
	if ([commandName isEqualToString:MS_CATEGOLY_PARENTREMOVE]) {//親設定の解除コマンドを判断
		NSString * sendersParentName = [dict valueForKey:MS_ADDRESS_NAME];
		if (!sendersParentName) {//送信者の親Name不詳であれば無視する
			NSLog(@"送信者親Name不詳");
			return;
		}
		
		NSString * sendersParentMSID = [dict valueForKey:MS_ADDRESS_MID];
		if (!sendersParentMSID) {//送信者の親MID不詳であれば無視する
			NSLog(@"送信者親MID不詳");
			return;
		}
		
		
		//[親を解消した宣言]から、関係性を削除する。
		[self removeMessengerInformation:senderName withMID:senderMID withParentName:sendersParentName withParentMID:sendersParentMSID];

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
}


/**
 通信してきた対象の情報を保持しておく
 */
- (void) setMessengerInformation:(NSString * )senderName 
						withMID:(NSString * )senderMID 
				  withParentName:(NSString * )sendersParentName 
				  withParentMID:(NSString * )sendersParentMSID {
	
	
	//Messengerをアイデンティファイするキーを作成
	NSString * newKey = [self createMessengerInformation:senderName withMID:senderMID];
	
	
	//既に存在している場合は無視する
	for (id key in viewListDict) {
		if ([key isEqualToString:newKey]) {
			NSLog(@"既に含まれている");
			
			//情報更新があれば、更新。
			
			return;
		}
	}
	
	
	/*
	 UIButtonTypeCustom = 0,
	 UIButtonTypeRoundedRect,
	 UIButtonTypeDetailDisclosure,
	 UIButtonTypeInfoLight,
	 UIButtonTypeInfoDark,
	 UIButtonTypeContactAdd,
	 */
	
	//ビュー、辞書に要素を加える
	
	UIButton * newButton = [[UIButton alloc] init];//[UIButton buttonWithType:UIButtonTypeDetailDisclosure];//リソースが取り込めないから出る問題だと見ている。
	[newButton setHidden:FALSE];
	
	[newButton setFrame:CGRectMake(0, 120, 100,100)];//newButton.frame.size.width, newButton.frame.size.height)];
	
	[newButton setBackgroundColor:[UIColor grayColor]];//一応範囲付け、かなあ。
	
	[buttonDict setValue:newButton forKey:newKey];
	[viewListDict setValue:[self createMessengerInformation:sendersParentName withMID:sendersParentMSID] forKey:newKey];

	[messengerInterfaceView addSubview:newButton];//ビューに加える
}
/**
 通信してきた対象の情報を削除する
 */
- (void) removeMessengerInformation:(NSString * )senderName 
						withMID:(NSString * )senderMID 
				  withParentName:(NSString * )sendersParentName 
				  withParentMID:(NSString * )sendersParentMSID {
	
	
	//Messengerをアイデンティファイするキーを作成
	NSString * removeKey = [self createMessengerInformation:senderName withMID:senderMID];
	
	[[buttonDict valueForKey:removeKey] removeFromSuperview];//ビューから外す
	
	[buttonDict removeObjectForKey:removeKey];
	[viewListDict removeObjectForKey:removeKey];
}

/**
 NameとMIDのペアを作るメソッド
 */
- (NSString * ) createMessengerInformation:(NSString * )name withMID:(NSString * )MID {
	return [NSString stringWithFormat:@"%@:%@", name, MID];
}


/**
 ボタン用の辞書を取得する
 */
- (NSMutableDictionary * ) getButtonDictionary {
	return buttonDict;
}

/**
 View用の辞書を取得する
 */
- (NSMutableDictionary * ) getViewDictionary {
	return viewListDict;
}



/**
 Viewを外部に返す
 */
- (UIView * ) getMessengerInterfaceView {
	return messengerInterfaceView;
}


//オーバーライドするメソッド、特に何もさせない。
- (void) inputToMyParentWithName:(NSString * )parent {}
- (void) callMyself:(NSString * )exec, ...{}
- (void) call:(NSString * )name withExec:(NSString * )exec, ...{}
- (void) callChild:(NSString * )childName withMID:(NSString * ) withCommand:(NSString * )exec, ...{}
- (void) callParent:(NSString * )exec, ...{}


@end

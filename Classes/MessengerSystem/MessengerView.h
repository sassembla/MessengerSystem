//
//  MessengerView.h
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/09/12.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessengerSystem.h"

#import <UIKit/UIKit.h>

@interface MessengerView : MessengerSystem {
	//追加するインスタンス
	
	//通信者記録用の辞書
	NSMutableDictionary * viewListDict;//ビュー自体が持つMessengerの辞書
	NSMutableDictionary * buttonDict;//ボタン辞書
	
	UIView * messengerInterfaceView;//ボタン、ラインをセットするビュー
	
}
//初期化
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name;//オーバーライド、アサートを架けて使用禁止
- (id) initWithFrame:(CGRect)frame;//初期化メソッド

/**
 通信してきた対象の情報をviewDictへと保持しておくメソッド
 */
- (void) setMessengerInformation:(NSString * )senderName 
						withMSID:(NSString * )senderMSID 
				  withParentName:(NSString * )sendersParentName 
				  withParentMSID:(NSString * )sendersParentMSID;
/**
 通信してきた対象の情報をviwDictから削除するメソッド
 */
- (void) removeMessengerInformation:(NSString * )senderName 
						   withMSID:(NSString * )senderMSID 
					 withParentName:(NSString * )sendersParentName 
					 withParentMSID:(NSString * )sendersParentMSID;
/**
 NameとMSIDのペアを作るメソッド
 */
- (NSString * ) createMessengerInformation:(NSString * )name withMSID:(NSString * )MSID;

/**
 ボタン、Messengerのリスト辞書を渡す
 */
- (NSMutableDictionary * ) getButtonDictionary;
- (NSMutableDictionary * ) getViewDictionary;

/**
 ビューを返す
 */
- (UIView * ) getMessengerInterfaceView;


//実行処理系(オーバーライドで無効化)
- (void) inputToMyParentWithName:(NSString * )parent;//空実装
- (void) innerPerform:(NSNotification * )notification;//受け取りの条件を緩和する

- (void) callMyself:(NSString * )exec, ...;//空実装
- (void) call:(NSString * )name withExec:(NSString * )exec, ...;//空実装
- (void) callChild:(NSString * )childName withMSID:(NSString * ) withCommand:(NSString * )exec, ...;//空実装
- (void) callParent:(NSString * )exec, ...;//空実装8


@end

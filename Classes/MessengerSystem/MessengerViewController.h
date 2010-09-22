//
//  MessengerViewController.h
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/09/12.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessengerSystem.h"
#import "MessengerDisplayView.h"

#import <UIKit/UIKit.h>

@interface MessengerViewController : MessengerSystem {
	//追加するインスタンス
	
	//通信者記録用の辞書
	NSMutableDictionary * viewListDict;//ビュー自体が持つMessengerの辞書
	NSMutableDictionary * buttonDict;//ボタン辞書
	
	MessengerDisplayView * messengerInterfaceView;//ボタン、ラインをセットするビュー
	
}
//初期化
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name;//オーバーライド、アサートを架けて使用禁止
- (id) initWithFrame:(CGRect)frame;//初期化メソッド

/**
 通信してきた対象の情報をviewDictへと保持しておくメソッド
 */
- (void) setMessengerInformation:(NSString * )senderName 
						withMID:(NSString * )senderMID 
				  withParentName:(NSString * )sendersParentName 
				  withParentMID:(NSString * )sendersParentMSID;
/**
 通信してきた対象の情報をviwDictから削除するメソッド
 */
- (void) removeMessengerInformation:(NSString * )senderName 
						   withMID:(NSString * )senderMID 
					 withParentName:(NSString * )sendersParentName 
					 withParentMID:(NSString * )sendersParentMSID;
/**
 NameとMIDのペアを作るメソッド
 */
- (NSString * ) createMessengerInformation:(NSString * )name withMID:(NSString * )MID;

/**
 ボタン、Messengerのリスト辞書を渡す
 */
- (NSMutableDictionary * ) getButtonDictionary;
- (NSMutableDictionary * ) getViewDictionary;

/**
 ビューを返す
 */
- (UIView * ) getMessengerInterfaceView;


/**
 ボタンが押された際のメソッド
 */
- (void) tapped:(UIControlEvents * )event;


//setter, initializer 必要の或る物だけを用意
- (void) setMyName:(NSString * )name;
- (void) setMyBodyID:(id)bodyID;
- (void) setMyBodySelector:(SEL)body_selector;

- (void) initMyMID;
- (void) initMyParentData;

- (void) setMyParentName:(NSString * )parent;




//実行処理系(オーバーライドで無効化)
- (void) inputToMyParentWithName:(NSString * )parent;//空実装
- (void) innerPerform:(NSNotification * )notification;//受け取りの条件を緩和する

- (void) callMyself:(NSString * )exec, ...;//空実装
- (void) call:(NSString * )name withExec:(NSString * )exec, ...;//空実装
- (void) callChild:(NSString * )childName withMID:(NSString * ) withCommand:(NSString * )exec, ...;//空実装
- (void) callParent:(NSString * )exec, ...;//空実装8

/**
 Dealloc
 */
- (void) dealloc;
@end
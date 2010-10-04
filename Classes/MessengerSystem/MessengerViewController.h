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


#define INTERVAL_WIDTH	(60)
#define INTERVAL_HEIGHT	(50)
#define OFFSET_X	(10)
#define OFFSET_Y	(40)



@interface MessengerViewController : MessengerSystem {
	
	//通信者記録用の辞書
	NSMutableDictionary * m_messengerList;//ビュー自体が持つMessengerの辞書
	NSMutableDictionary * m_buttonList;//ボタン辞書
	
	NSMutableDictionary * m_nameIndexDictionary;//何種類の名称が有るか、またそれが左から何番目か一時的に保存する辞書
	
	MessengerDisplayView * messengerInterfaceView;//ボタン、ラインをセットするビュー
	
	int m_numberOfRelationship;
}
//初期化
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name;//オーバーライド、アサートを架けて使用禁止
- (id) initWithFrame:(CGRect)frame;//初期化メソッド


/**
 メッセンジャーの生成情報をviewDictへと保持しておくメソッド
 */
- (void) insertMessengerInformation:(NSString * )senderName 
							withMID:(NSString * )senderMID;
/**
 通信してきた対象の情報をviewDictへと保持しておくメソッド
 */
- (void) updateParentInformation:(NSString * )senderName 
						withMID:(NSString * )senderMID 
				  withParentName:(NSString * )sendersParentName 
				  withParentMID:(NSString * )sendersParentMID;
/**
 通信してきた対象の情報をviwDictから削除するメソッド
 */
- (void) deleteMessengerInformation:(NSString * )senderName 
						   withMID:(NSString * )senderMID;

/**
 描画データのアップデート
 */
- (void) drawDataUpdate;

/**
 NameとMIDのペアを作るメソッド
 */
- (NSString * ) getMessengerInformationKey:(NSString * )name withMID:(NSString * )MID;

/**
 ボタン、Messengerのリスト辞書を渡す
 */
- (NSMutableDictionary * ) getButtonList;
- (NSMutableDictionary * ) getMessengerList;


/**
 関係性の本数を返すメソッド
 */
- (void) setNumberOfRelationship:(int)number;
- (int) getNumberOfRelationship;



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


/**
 表示補助用のインデックス　X軸カウント
 */
- (void) setNameIndexDictionary;
- (NSMutableDictionary * ) getNameIndexDictionary;

/**
 全ボタンの位置をソートする
 */
- (void) sortButtonsByParentOrder;



//実行処理系(オーバーライドで無効化)
- (void) inputParent:(NSString * )parent;//空実装
- (void) innerPerform:(NSNotification * )notification;//受け取りの条件を緩和する

- (void) callMyself:(NSString * )exec, ...;//空実装
- (void) call:(NSString * )name withExec:(NSString * )exec, ...;//空実装
- (void) callChild:(NSString * )childName withMID:(NSString * ) withCommand:(NSString * )exec, ...;//空実装
- (void) callParent:(NSString * )exec, ...;//空実装8

//Notice系(オーバーライドで無効化)
- (void) createdNotice;//作成完了声明発行メソッド
- (void) updatedNotice:(NSString * )parentName withParentMID:(NSString * )parentMID;//更新発行メソッド
- (void) killedNotice;//自死声明発行メソッド

/**
 Dealloc
 */
- (void) dealloc;
@end

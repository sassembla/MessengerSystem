//
//  MessengerSystem.h
//  KissakiProject
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>


#define MESSENGER_SYSTEM_VERSION (20100829)


#define MS_COMMAND	(@"MESSENGER_SYSTEM_COMMAND")//コマンドに類するキー
	#define COMMAND_PARENTSEARCH	(@"MESSENGER_SYSTEM_COMMAND:PARENT_SEARCH")//親探索
	#define COMMAND_CALLED			(@"MESSENGER_SYSTEM_COMMAND:CALLED")//呼び出し

#define MS_PARENTNAME	(@"MESSENGER_SYSTEM_COMMAND:PARENT_NAME")//親の名前に類するキー
#define MS_PARENTMSID	(@"MESSENGER_SYSTEM_COMMAND:PARENT_MSID")//親の固有IDに類するキー

#define MS_SENDERID		(@"MESSENGER_SYSTEM_COMMAND:SENDER_ID")//自分固有のIDに類するキー
#define MS_SENDERNAME	(@"MESSENGER_SYSTEM_COMMAND:SENDER_NAME")//自分の名前に類するキー
#define MS_SENDERMSID	(@"MESSENGER_SYSTEM_COMMAND:SENDER_MSID")//自分固有のMSIDに類するキー

#define MS_SEARCHNAME	(@"MESSENGER_SYSTEM_COMMAND:SEARCH_NAME")//宛先の名前に類するキー

#define MS_RETURN		(@"MESSENGER_SYSTEM_COMMAND:RETURN")//フック実行メソッドの指定


@interface MessengerSystem : NSObject {
	//本体のID
	id myBodyID;
	
	//本体のセレクタ
	SEL myBodySelector;//メッセージ受け取り時に叩かれるセレクタ、最低一つの引数を持つ必要がある。
	
	
	//自分の名前	NSString
	NSString * myName;
	
	//自分のID	NSString
	NSString * myMSID;
	
	
	//親の名前	NSString
	NSString * myParentName;
	
	//親のID		NSString
	NSString * myParentMSID;
	
	
	//子供の名前とIDを保存する辞書	NSMutableDictionary
	
	
	
	
	
	
	
	
}


/**
 メッセージオブザーバーID
 */
#define OBSERVER_ID		(@"MessengerSystemDefault")



	

/**
 初期化メソッド
 */
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name;
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name withParent:(NSString * )parent;


/**
 内部実行メソッド
 */
- (void) innerPerform:(NSNotification * )notification;
- (void) postToMyParent;//親への通知用メソッド



- (void) setMyBodyID:(id)bodyID;
- (id) getMyBodyID;

- (void) setMyBodySelector:(SEL)body_selector;
- (SEL) getMyBodySelector;

- (void)setMyName:(NSString * )name;
- (NSString * )getMyName;

- (void)initMyMSID;
- (NSString * )getMyMSID;

- (void) setMyParentName:(NSString * )parent;
- (NSString * )getMyParentName;

- (void) setMyParentMSID:(NSString * )parentMSID;
- (NSString * )getMyParentMSID;

@end

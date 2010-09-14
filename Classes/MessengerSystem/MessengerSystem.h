//
//  MessengerSystem.h
//  KissakiProject
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>


//#define NSLog( m, args... )


#define MESSENGER_SYSTEM_VERSION (20100829)

//Objective-C id情報
#define MS_SENDERID		(@"MESSENGER_SYSTEM_COMMAND:SENDER_ID")//自分固有のObjective-C IDに類するキー


//カテゴリ系タグ メッセージの種類を用途ごとに分ける
#define MS_CATEGOLY	(@"MESSENGER_SYSTEM_COMMAND")//コマンドに類するキー
	#define MS_CATEGOLY_LOCAL			(@"MESSENGER_SYSTEM_COMMAND:CATEGOLY_LOCAL")//自分呼び出し
	#define MS_CATEGOLY_CALLCHILD		(@"MESSENGER_SYSTEM_COMMAND:CATEGOLY_CALL_CHILD")//子供呼び出し
	#define	MS_CATEGOLY_CALLPARENT		(@"MESSENGER_SYSTEM_COMMAND:CATEGOLY_CALL_PARENT")//親呼び出し
	#define MS_CATEGOLY_PARENTSEARCH	(@"MESSENGER_SYSTEM_COMMAND:CATEGOLY_PARENTSEARCH")//親探索
	#define MS_CATEGOLY_GOTPARENT		(@"MESSENGER_SYSTEM_COMMAND:CATEGOLY_GOT_PARENT")//親取得完了
	#define MS_CATEGOLY_PARENTREMOVE	(@"MESSENGER_SYSTEM_COMMAND:CATEGOLY_PARENTREMOVE")//親の登録を消す

#define MS_SENDERNAME	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_SENDER_NAME")//自分の名前に類するキー
#define MS_SENDERMSID	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_SENDER_MSID")//自分固有のMSIDに類するキー

//実行内容に関するタグ
#define MS_ADDRESS_NAME	(@"MESSENGER_SYSTEM_COMMAND:ADDRESS_NAME")//宛先名
#define MS_ADDRESS_MSID	(@"MESSENGER_SYSTEM_COMMAND:ADDRESS_MSID")//宛先MSID
#define MS_EXECUTE		(@"MESSENGER_SYSTEM_COMMAND:EXECUTE")//実行内容名


//Parentに関するタグ
#define MS_PARENTNAME	(@"MESSENGER_SYSTEM_COMMAND:PARENT_NAME")//親の名前に類するキー
#define MS_PARENTMSID	(@"MESSENGER_SYSTEM_COMMAND:PARENT_MSID")//親の固有IDに類するキー

//メソッド実行オプションに関するタグ
#define MS_RETURN		(@"MESSENGER_SYSTEM_COMMAND:RETURN")//フック実行メソッドの指定オプションに類するキー 未実装
#define MS_DELAY		(@"MESSENGER_SYSTEM_COMMAND:DELAY")//遅延実行


//logに関するタグ
#define MS_LOGDICTIONARY	(@"MESSENGER_SYSTEM_COMMAND:LOG")
#define MS_LOG_MESSAGEID	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_MESSAGE_ID")//メッセージ発生時割り振られるIDに類するキー
#define MS_LOG_LOGTYPE_NEW	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_TYPE_NEW")//メッセージ作成時に設定される記録タイプに類するキー
#define MS_LOG_LOGTYPE_REC	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_TYPE_RECEIVED")//メッセージ受取時に設定される記録タイプに類するキー
#define MS_LOG_LOGTYPE_REP	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_TYPE_REPLIED")//メッセージ返送時に設定される記録タイプに類するキー
#define MS_LOG_LOGTYPE_GOTP	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_TYPE_GOTPARENT")//親決定時に設定される記録タイプに類するキー

#define MS_LOG_TIMESTAMP	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_TIMESTAMP")//タイムスタンプに類するキー


//初期化内容
#define PARENTNAME_DEFAULT	(@"MESSENGER_SYSTEM_COMMAND:PARENTNAME_DEFAULT")//デフォルトのmyParentName
#define PARENTMSID_DEFAULT	(@"MESSENGER_SYSTEM_COMMAND:PARENTMSID_DEFAULT")//デフォルトのmyParentMSID
#define VIEW_NAME_DEFAULT	(@"MESSENGER_SYSTEM_COMMAND:VIEW_NAME_DEFAULT")//デフォルトのViewのName



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
	NSMutableDictionary * childDict;
	
	
	//ログ取り用の辞書
	NSMutableDictionary * logDict;
}


/**
 メッセージオブザーバーID
 */
#define OBSERVER_ID		(@"MessengerSystemDefault")



	

/**
 初期化メソッド
 */
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name;


/**
 内部実行メソッド
 */
- (void) inputToMyParentWithName:(NSString * )parent;//親への登録メソッド
- (void) decidedParentName:(NSString * )parentName withParentMSID:(NSString * )parentMSID;//親への登録完了時の声明発行メソッド
- (void) removeMyParentData;//親情報を初期化する通信を行うメソッド


- (void) innerPerform:(NSNotification * )notification;//内部実装メソッド、システムな動作とbodyへのメソッド伝達を行う。

- (void) callMyself:(NSString * )exec, ...;//自分自身への通信メソッド
- (void) call:(NSString * )childName withExec:(NSString * )exec, ...;//特定の子への通信用メソッド
- (void) call:(NSString * )childName withMSID:(NSString * ) withExec:(NSString * )exec, ...;//特定の子への通信用メソッド childのMSIDを用いる。
- (void) callParent:(NSString * )exec, ...;//親への通信用メソッド


- (void) sendPerform:(NSMutableDictionary * )dict;//ブロック実装
- (void) sendPerform:(NSMutableDictionary * )dict withDelay:(float)delay;//遅延実行

- (void) sendMessage:(NSMutableDictionary * )dict;//送信実行メソッド


/**
 子供辞書に子供のmyName,myMSIDを保存する
 */
- (void) setChildDictChildNameAsValue:(NSString * )senderName withMSIDAsKey:(NSString * )senderMSID;
- (void) removeChildDictChildNameAsValue:(NSString * )senderName withMSIDAsKey:(NSString * )senderMSID;
- (NSMutableDictionary * ) getChildDict;


/**
 タグシステム
 */
- (NSDictionary * ) tag:(id)obj_tag val:(id)obj_value;


/**
 タグシステムの亜種、DelayTag
 */
- (NSDictionary * ) withDelay:(float)delay;



/**
 ログシステム
 */
- (NSMutableDictionary * ) createLogForNew;//メッセージ初期作成ログを内部に保存する/返すメソッド
- (void) saveLogForReceived:(NSMutableDictionary * )logDict;//受信時に付与するログを内部に保存するメソッド
- (NSMutableDictionary * ) createLogForReply;//返答送信時に付与するログを内部に保存する/返すメソッド


/**
 ログストア
 */
- (void) saveToLogStore:(NSString * )name, ... ;
- (NSMutableDictionary * ) getLogStore;//保存されたログ一覧を取得するメソッド


/**
 ストリングの数値化
 */
- (int) changeStrToNumber:(NSString * )str;


/**
 UUIDを返すメソッド
 */
- (NSString * ) getUUID;



/**
 クラスが持つ値の
 ゲッター、セッター、イニシャライザ
 */
- (void) setMyBodyID:(id)bodyID;
- (id) getMyBodyID;

- (void) setMyBodySelector:(SEL)body_selector;
- (SEL) getMyBodySelector;

- (void)setMyName:(NSString * )name;
- (NSString * )getMyName;

- (void)initMyMSID;
- (NSString * )getMyMSID;


- (void) initMyParentData;
- (void) resetMyParentData;
- (void) setMyParentName:(NSString * )parent;
- (NSString * )getMyParentName;

- (void) setMyParentMSID:(NSString * )parentMSID;
- (NSString * )getMyParentMSID;

- (void) gagaga;//パフォーマンス実行のテスト

@end

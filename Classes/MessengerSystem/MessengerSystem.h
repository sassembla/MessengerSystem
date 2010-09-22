//
//  MessengerSystem.h
//  KissakiProject
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>


//Objective-C id情報
#define MS_SENDERID		(@"MESSENGER_SYSTEM_COMMAND:SENDER_ID")//自分固有のObjective-C IDに類するキー


//カテゴリ系タグ メッセージの種類を用途ごとに分ける
#define MS_CATEGOLY	(@"MESSENGER_SYSTEM_COMMAND")//コマンドに類するキー
	#define MS_CATEGOLY_LOCAL			(@"MESSENGER_SYSTEM_COMMAND:CATEGOLY_LOCAL")//自分呼び出し
	#define MS_CATEGOLY_CALLCHILD		(@"MESSENGER_SYSTEM_COMMAND:CATEGOLY_CALL_CHILD")//子供呼び出し
	#define	MS_CATEGOLY_CALLPARENT		(@"MESSENGER_SYSTEM_COMMAND:CATEGOLY_CALL_PARENT")//親呼び出し
	#define MS_CATEGOLY_PARENTSEARCH	(@"MESSENGER_SYSTEM_COMMAND:CATEGOLY_PARENTSEARCH")//親探索
	#define MS_CATEGOLY_GOTPARENT		(@"MESSENGER_SYSTEM_COMMAND:CATEGOLY_GOT_PARENT")//親取得完了
	#define MS_CATEGOLY_REMOVE_PARENT	(@"MESSENGER_SYSTEM_COMMAND:CATEGOLY_REMOVEPARENT")//親の登録を消す
	#define MS_CATEGOLY_REMOVE_CHILD	(@"MESSENGER_SYSTEM_COMMAND:CATEGOLY_REMOVECHILD")//子供の登録を消す


#define MS_SENDERNAME	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_SENDER_NAME")//自分の名前に類するキー
#define MS_SENDERMID	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_SENDER_MID")//自分固有のMIDに類するキー

//実行内容に関するタグ
#define MS_ADDRESS_NAME	(@"MESSENGER_SYSTEM_COMMAND:ADDRESS_NAME")//宛先名
#define MS_ADDRESS_MID	(@"MESSENGER_SYSTEM_COMMAND:ADDRESS_MID")//宛先MID
#define MS_EXECUTE		(@"MESSENGER_SYSTEM_COMMAND:EXECUTE")//実行内容名


//Parentに関するタグ
#define MS_PARENTNAME	(@"MESSENGER_SYSTEM_COMMAND:PARENT_NAME")//親の名前に類するキー
#define MS_PARENTMID	(@"MESSENGER_SYSTEM_COMMAND:PARENT_MID")//親の固有MIDに類するキー

//メソッド実行オプションに関するタグ
#define MS_RETURN		(@"MESSENGER_SYSTEM_COMMAND:RETURN")//フック実行に類するキー
	#define MS_RETURNID				(@"MESSENGER_SYSTEM_COMMAND:RETURN_ID")//フック実行メソッドのidに類するキー
	#define MS_RETURNSIGNATURE		(@"MESSENGER_SYSTEM_COMMAND:RETURN_SIGNATURE")//フック実行メソッドのSignature指定に類するキー
	#define MS_RETURNSELECTOR		(@"MESSENGER_SYSTEM_COMMAND:RETURN_SELECTOR")//フック実行メソッドのSelector指定に類するキー

//遅延実行に関するタグ
#define MS_DELAY		(@"MESSENGER_SYSTEM_COMMAND:DELAY")//遅延実行


//logに関するタグ
#define MS_LOGDICTIONARY	(@"MESSENGER_SYSTEM_COMMAND:LOG")
#define MS_LOG_MESSAGEID	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_MESSAGE_ID")//メッセージ発生時割り振られるIDに類するキー
#define MS_LOG_LOGTYPE_NEW	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_TYPE_NEW")//メッセージ作成時に設定される記録タイプに類するキー
#define MS_LOG_LOGTYPE_REC	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_TYPE_RECEIVED")//メッセージ受取時に設定される記録タイプに類するキー
#define MS_LOG_LOGTYPE_REP	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_TYPE_REPLIED")//メッセージ返送時に設定される記録タイプに類するキー
#define MS_LOG_LOGTYPE_GOTP	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_TYPE_GOTPARENT")//親決定時に設定される記録タイプに類するキー

#define MS_LOG_TIMESTAMP	(@"MESSENGER_SYSTEM_COMMAND:LOGGED_TIMESTAMP")//タイムスタンプに類するキー

#define MS_LOGMESSAGE_CREATED	(@"MESSENGER_SYSTEM_COMMAND:MESSAGE_CREATED")
#define MS_LOGMESSAGE_RECEIVED	(@"MESSENGER_SYSTEM_COMMAND:MESSAGE_RECEIVED")


//初期化内容
#define PARENTNAME_DEFAULT	(@"MESSENGER_SYSTEM_COMMAND:PARENTNAME_DEFAULT")//デフォルトのmyParentName
#define PARENTMID_DEFAULT	(@"MESSENGER_SYSTEM_COMMAND:PARENTMID_DEFAULT")//デフォルトのmyParentMID
#define VIEW_NAME_DEFAULT	(@"MESSENGER_SYSTEM_COMMAND:VIEW_NAME_DEFAULT")//デフォルトのViewのName


@interface MessengerSystem : NSObject {
	//本体のID
	id myBodyID;
	
	//本体のセレクタ
	SEL myBodySelector;//メッセージ受け取り時に叩かれるセレクタ、最低一つの引数を持つ必要がある。
	
	
	//自分の名前	NSString
	NSString * myName;
	
	//自分のID	NSString
	NSString * myMID;
	
	
	//親の名前	NSString
	NSString * myParentName;
	
	//親のID		NSString
	NSString * myParentMID;
	
	
	//子供の名前とIDを保存する辞書	NSMutableDictionary
	NSMutableDictionary * childDict;
	
	
	//ログ取り用の辞書				NSMutableDictionary
	NSMutableDictionary * logDict;
}


/**
 メッセージオブザーバーID
 */
#define OBSERVER_ID		(@"MessengerSystemDefault_E2FD8F50-F6E9-42F6-8949-E7DD20312CA0")


//バージョン取得
+ (NSString * )version;



//初期化メソッド
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name;



//実行メソッド
- (void) inputToMyParentWithName:(NSString * )parent;//親への登録メソッド
- (void) removeMyParentData;//親情報を初期化する通信を行うメソッド
- (void) removeChildData;//自分を親に設定している子供に対して解除を促すメソッド

- (void) callMyself:(NSString * )exec, ...;//自分自身への通信メソッド
- (void) call:(NSString * )childName withExec:(NSString * )exec, ...;//特定の子への通信用メソッド
- (void) call:(NSString * )childName withMID:(NSString * ) withExec:(NSString * )exec, ...;//特定の子への通信用メソッド childのMIDを用いる。
- (void) callParent:(NSString * )exec, ...;//親への通信用メソッド


//タグシステム
- (NSDictionary * ) tag:(id)obj_tag val:(id)obj_value;
- (NSDictionary * ) withRemoteFrom:(id)mySelf withSelector:(SEL)sel;//遠隔実行
- (NSDictionary * ) withDelay:(float)delay;//遅延実行


//遠隔実行実装
- (void) remoteInvocation:(NSMutableDictionary * )dict, ...;



//ログストアの取得
- (NSMutableDictionary * ) getLogStore;//保存されたログ一覧を取得するメソッド



//子供辞書の取得
- (NSMutableDictionary * ) getChildDict;



/**
 コマンド情報を文字列で取得する
 */
- (NSString * ) getExecAsString:(NSMutableDictionary * )dict; 

/**
 コマンド情報を数値で取得する
 辞書からswitch文で使用する数値を取得する
 */
- (int) getExecAsIntFromDict:(NSMutableDictionary * )dict;

/**
 文字列からswitch文で使用する数値を取得する
 */
- (int) getIntFromExec:(NSString * )exec;

/**
 ストリングの数値化
 */
- (int) changeStrToNumber:(NSString * )str;

/**
 数値の文字列化
 */
- (NSString * ) changeNumberToStr:(int)num;


/**
 ユーティリティ
 */
//親の有無を確認する
- (BOOL) hasParent;

//子供の有無を確認する
- (BOOL) hasChild;



/**
 クラスが持つ値の
 ゲッター
 */
- (id) getMyBodyID;
- (SEL) getMyBodySelector;
- (NSString * )getMyName;
- (NSString * )getMyMID;
- (NSString * )getMyParentName;
- (NSString * )getMyParentMID;


@end
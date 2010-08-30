//
//  CentralDelegate.h
//  KissakiProject
//
//  Created by Inoue 徹 on 10/07/25.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageSystem.h"
#import "MessengerSystem.h"

/**
 アプリケーションの状態管理センター
 現在のところは、直値でのクラスID管理を行う。
 
 */

#define CENTRAL_NAME (@"Central")
#define RECEIVER_NAME (@"Receiver")


/**
 存在する送信者一覧
 */
enum SENDER_ID {
	SENDER_CENTRAL,
	SENDER_ROTATE,
	SENDER_DELEGATE,
	SENDER_BASEVIEW,
	
	SENDER_DESIGNCONTROLLER,
	
	
	NUM_OF_SENDER_ID
};


/**
 存在するステート一覧
 */
enum STATE_ID {
	STATE_INIT,
	
	NUM_OF_STATE
};


/**
 存在するコマンド一覧
 */
enum COMMAND_ID {
	COMMAND_INIT,
	NUM_OF_COMMAND
};



@interface CentralDelegate : NSObject {
	MessageSystem * messenger;
	MessengerSystem * messenger2;
	MessengerSystem * messenger3;
}

- (void) ignite;

- (void) messageCenter:(NSNotification * )notification;



//////////////////////////////////////////////////////////////////////////////////////////////////////////(Class内Private変数)
int state;

//////////////////////////////////////////////////////////////////////////////////////////////////////////(ユーティリティ)
void setState (int nextState);//ステートのセットを行う。このメソッド以外でのstateの変更禁止
int getState ();//ステートを返す

- (void) testMethod;

@end

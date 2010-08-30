//
//  CentralDelegate.m
//  KissakiProject
//
//  Created by Inoue 徹 on 10/07/25.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "CentralDelegate.h"
#import "RotateViewController.h"
#import "DesignedViewController.h"

@implementation CentralDelegate

- (id) init {
	if (self == [super init]) {
		messenger = [[MessageSystem alloc] initWithCentralObserver:self
													  centralNamed:CENTRAL_NAME
													 recieverNamed:RECEIVER_NAME 
													withIdentifier:SENDER_CENTRAL
													   withVersion:20100810 
													  withSelector:@selector(messageCenter:)];
		
		messenger2 = [[MessengerSystem alloc] initWithBodyID:self withSelector:nil withName:@"自分"];
		messenger3 = [[MessengerSystem alloc] initWithBodyID:self withSelector:nil withName:@"子供" withParent:@"自分"];
		
		setState(STATE_INIT);
		
	} 
	return self;	
}

- (void) ignite {
	
	RotateViewController * rotateViewController = [[RotateViewController alloc] initRotateViewController];
	DesignedViewController * designedViewController = [[DesignedViewController alloc] initWithNibName:@"DesignedViewController" bundle:nil];
	[messenger sendMessage:COMMAND_INIT,nil];
	
	SEL finisihed;
	
	finisihed = @selector(testMethod);
	
	NSString * method = NSStringFromSelector(finisihed);
	NSLog(@"method_%@",method);//ここからどうするんだろう。
	
	IMP f = [self methodForSelector:finisihed];
	(*f)(self,finisihed);//これで実行できる。という事は、引数があるメソッドはそのぶんバリエーションを組まなければいけない、、のかしら。それは嫌ね。
	
	
	finisihed = @selector(messageCenter:);
	f = [self methodForSelector:finisihed];

	(*f)(self,finisihed,@"仮のNotifi");//このへんを可変引数に出来れば、OKですね。
	(*f)(self,finisihed,@"仮のNotifi2");
	
	(*f)(self,finisihed);//引数なしで実行すると、直前のものを引き継いで動作する。いきなり引数無しを動かすと、落ちる。 なぜだw 1回目での落下を希望。
	(*f)(self,finisihed,@"仮のNotifi3");
	
	//	NSLog(@"_code_%@",_code);
	//[idOfMaster code:_code withIdentifier:_identifier withResponse:_data];
	//ポインタから、呼び出し元のクラスのメソッドを実行 (メソッド名まで認識できているのだけれど、実行まで行けなかったので、直にメソッド名を記述。) Toru Inoue 10/06/20 1:26:01
	
	
	
}


- (void) testMethod {
	NSLog(@"テストメソッドに届いてます");
}


- (void) messageCenter:(NSNotification * )notification {
	
	NSLog(@"メッセージが届いています_%@", notification);
	
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////(ユーティリティ)
/**
 ステートセット
 */
void setState (int nextState) {
	state = nextState;
}


/**
 ステートゲット
 */
int getState () {
	return state;
}


@end

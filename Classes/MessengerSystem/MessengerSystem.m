//
//  MessengerSystem.m
//  KissakiProject
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "MessengerSystem.h"


@implementation MessengerSystem

/**
 親無しで初期化する
 */
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name {
	if (self = [super init]) {
		myName = name;
		myBodyID = body_id;
		bodySelector = body_selector;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(innerPerform:) name:OBSERVER_ID object:nil];
	}
	return self;
}

/**
 親有りで初期化する
 */
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name withParent:(NSString * )parent {
	
	if (self = [super init]) {
		
		myName = name;
		myBodyID = body_id;
		bodySelector = body_selector;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(innerPerform:) name:OBSERVER_ID object:nil];
		
		//親の名前を設定
		parentName = parent;
		
		//親へと呼びかける
		NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:3];
		[dict setValue:COMMAND_PARENTSEARCH forKey:MS_COMMAND];
		[dict setValue:parentName forKey:MS_PARENTNAME];
		[dict setValue:myName forKey:MS_MYNAME];
		
		//親の名前、自分の名前を送る
		[[NSNotificationCenter defaultCenter] postNotificationName:OBSERVER_ID object:nil userInfo:(id)dict];
	}
	
	return self;
}




/**
 内部実行で先ず呼ばれるメソッド
 自分宛のメッセージでなければ無視する
 */
- (void) innerPerform:(NSNotification * )notification {
	NSLog(@"myName_%@	self_%@	notification_%@",myName, self, notification);
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	
	NSString * commandName = [dict valueForKey:MS_COMMAND];
	if (!commandName) {
		NSLog(@"処理が行われずに帰る");
		return;
	}
	
	//自分に関係があるかもしれない
	if () {//自分にParentが設定してあり、コマンドがそれに関する物なら、帰る。
		
	}
	
	
	NSLog(@"commandName_%@", commandName);
//	int command = [[array objectAtIndex:MESSAGE_STATEMENT] intValue];
	
	
	
	//先頭にサービスIDがついていない物は無視する
	
	
	
	//自分宛でなかったら無視する
	if (false) {//COMMAND_PARENTSEARCHが来たら、自分が親に指定されているかどうか、判定する
		return;
	}
	
	
//	if (true) {
//		//selectorからメソッドを実行する
//		IMP func = [myBodyID methodForSelector:bodySelector];
//		(*func)(myBodyID, bodySelector, notification);
//	}
	
	
}


/**
 自分の名称を返すメソッド
 */
- (NSString * )getName {
	return myName;
}



/**
 親の名称を返すメソッド
 */
- (NSString * )getParentName {
	return parentName;
}



@end

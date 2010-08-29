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
		
		
		CFUUIDRef uuidObj = CFUUIDCreate(nil);
		myMSID = (NSString * )CFUUIDCreateString(nil, uuidObj);
		NSLog(@"うーん、UUID_%@", myMSID);
		
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
		//[self postToParent];//テストケースを使う際は、ここで設定を行うと異常と見なされてしまう。
	}
	
	return self;
}



//そのままテストに書くと通らないので、メソッド化してみる。
- (void) postToParent {
	
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:3];
	
	[dict setValue:COMMAND_PARENTSEARCH forKey:MS_COMMAND];
	[dict setValue:parentName forKey:MS_PARENTNAME];
	[dict setValue:myName forKey:MS_SENDERNAME];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:OBSERVER_ID object:nil userInfo:(id)dict];
}





/**
 内部実行で先ず呼ばれるメソッド
 自分宛のメッセージでなければ無視する
 */
- (void) innerPerform:(NSNotification * )notification {
	//NSLog(@"myName_%@	self_%@	notification_%@",myName, self, notification);
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	
	NSString * commandName = [dict valueForKey:MS_COMMAND];
	if (!commandName) {
		NSLog(@"コマンドが無いため、何の処理も行われずに帰る");
		return;
	}
	
	NSLog(@"commandName_%@", commandName);
	
	
	NSString * senderName = [dict valueForKey:MS_SENDERNAME];
	if (!senderName) {//送信者不詳であれば無視する
		NSLog(@"送信者不詳");
		return;
	}
	
		
	if ([commandName isEqualToString:COMMAND_PARENTSEARCH]) {//自分にParentが設定してあり、コマンドがそれに関する物なら、帰る。
		
		//送信者が自分であれば無視する
		if ([senderName isEqualToString:myName]) {
			NSLog(@"自分が送信者なので無視する_%@", myName);
			return;
		}
		
		
		NSString * calledParentName = [dict valueForKey:MS_PARENTNAME];
		if (!calledParentName) return;//値が無ければ無視する
		
		
		if ([parentName isEqualToString:calledParentName]) {
			return;
		}
		
		NSLog(@"自分以外の誰かが、parentを設定して通信してきている。_%@", calledParentName);
		if ([calledParentName isEqualToString:myName]) {//それが自分だったら
			
			NSLog(@"子供発見_%@",senderName);
			return;
		}
		
		
		//自分宛ではない
		NSLog(@"自分宛ではないので、無視する_%@	called%@", myName, calledParentName);
		return;
	}
	
	
	//特定の相手に向けてのコール
	if ([commandName isEqualToString:COMMAND_CALLED]) {
		//自分の事でなかったら帰る
		if (false) {
			return;
		}
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
- (NSString * )getMyName {
	return myName;
}

/**
 自分のMSIDを返すメソッド
 */
- (NSString * )getMyMSID {
	return myMSID;
}


/**
 親の名称を返すメソッド
 */
- (NSString * )getParentName {
	return parentName;
}


/**
 親のMSIDを返すメソッド
 */
- (NSString * )getParentMSID {
	return parentMSID;
}

@end

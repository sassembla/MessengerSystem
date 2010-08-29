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
		
		[self setMyName:name];
		[self setMyBodyID:body_id];
		[self setMyBodySelector:body_selector];
		[self initMyMSID];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(innerPerform:) name:OBSERVER_ID object:nil];
	}
	return self;
}

/**
 親有りで初期化する
 */
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name withParent:(NSString * )parent {
	
	if (self = [super init]) {
		
		[self setMyName:name];
		[self setMyBodyID:body_id];
		[self setMyBodySelector:body_selector];
		[self initMyMSID];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(innerPerform:) name:OBSERVER_ID object:nil];
		
		//親の名前を設定
		[self setMyParentName:parent];
		
	}
	
	return self;
}



/**
 親へと自分が子供である事の通知を行い、返り値として親のMSIDを受け取るメソッド
 受け取り用のメソッドの情報を親へと渡し、親からの入力をダイレクトに受ける。
 */
- (void) postToMyParent {
	
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:1];
	
	[dict setValue:COMMAND_PARENTSEARCH forKey:MS_COMMAND];
	[dict setValue:[self getMyParentName] forKey:MS_PARENTNAME];
	[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
	[dict setValue:[self getMyMSID] forKey:MS_SENDERMSID];
	[dict setValue:self forKey:MS_SENDERID];
	
	//フック
	//特定のメソッドの実行を命令づける、リタンダンシー設定
	//IMP func = [self methodForSelector:@selector(setMyParentMSID:)];
	//(*func)(self,@selector(setMyParentMSID:),@"ついた");
	[dict setValue:[self methodSignatureForSelector:@selector(setMyParentMSID:)] forKey:MS_RETURN];
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:OBSERVER_ID object:nil userInfo:(id)dict];
	NSAssert1([self getMyParentMSID], @"親が存在しないようです。parentに指定している名前を確認してください_現在指定されているparentは_%@",[self getMyParentName]);
}




/**
 内部実行で先ず呼ばれるメソッド
 自分宛のメッセージでなければ無視する
 */
- (void) innerPerform:(NSNotification * )notification {
//	NSLog(@"myName_%@	self_%@	notification_%@",myName, self, notification);
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	
	NSString * commandName = [dict valueForKey:MS_COMMAND];
	if (!commandName) {
		NSLog(@"コマンドが無いため、何の処理も行われずに帰る");
		return;
	}
	
	
	
	NSLog(@"commandName_%@", commandName);
	
	
	NSString * senderName = [dict valueForKey:MS_SENDERNAME];
	if (!senderName) {//送信者不詳であれば無視する
		NSLog(@"送信者NAME不詳");
		return;
	}
	
	
	
	NSString * senderMSID = [dict valueForKey:MS_SENDERMSID];
	if (!senderMSID) {//送信者不詳であれば無視する
		NSLog(@"送信者ID不詳");
		return;
	}
	
	
		
	if ([commandName isEqualToString:COMMAND_PARENTSEARCH]) {
		
		//送信者が自分であれば無視する
		if ([senderMSID isEqualToString:[self getMyMSID]]) {
			NSLog(@"自分が送信者なので無視する_%@", [self getMyMSID]);
			return;
		}
		
		
		NSString * calledParentName = [dict valueForKey:MS_PARENTNAME];
		if (!calledParentName) return;//値が無ければ無視する
		
		
		NSLog(@"自分以外の誰かが、parentを設定して通信してきている。_%@", calledParentName);
		if ([calledParentName isEqualToString:[self getMyName]]) {//それが自分だったら
			
			NSLog(@"子供発見_%@",senderName);
			id senderID = [dict valueForKey:MS_SENDERID];
			if (!senderID) {
				NSLog(@"senderIDが無い");
				return;
			}
			
			
			
			id signature;
			id invocation;
			
			signature = [dict valueForKey:MS_RETURN];
			NSLog(@"signature_%@", signature);
			
			invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:@selector(setMyParentMSID:)];//ここは直書きしかないのか！？　じゃあ意味なくね？ 特にselectorだけ渡すとかしないといけないのか？
			[invocation setTarget:senderID];
			NSString * myMSIDforchild = [self getMyMSID];
			[invocation setArgument:&myMSIDforchild atIndex:2];
			
			[invocation invoke];
			
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
 自分の名称をセットするメソッド
 */
- (void)setMyName:(NSString * )name {
	myName = name;
}
/**
 自分の名称を返すメソッド
 */
- (NSString * )getMyName {
	return myName;
}


/**
 自分のBodyIDをセットするメソッド
 */
- (void) setMyBodyID:(id)bodyID {
	myBodyID = bodyID;
}
/**
 自分のBodyIDを返すメソッド
 */
- (id) getMyBodyID {
	return myBodyID;
}

/**
 自分のBodyが提供するメソッドセレクターを、自分のセレクター用ポインタにセットするメソッド
 */
- (void) setMyBodySelector:(SEL)body_selector {
	myBodySelector = body_selector;
}
/**
 自分のセレクター用ポインタを返すメソッド
 */
- (SEL) getMyBodySelector {
	return myBodySelector;
}


/**
 自分のMSIDを初期化するメソッド
 */
- (void)initMyMSID {
	myMSID = (NSString * )CFUUIDCreateString(nil, CFUUIDCreate(nil));
}
/**
 自分のMSIDを返すメソッド
 */
- (NSString * )getMyMSID {
	return myMSID;
}


/**
 親の名称をセットするメソッド
 */
- (void) setMyParentName:(NSString * )parent {
	myParentName = parent;
}
/**
 親の名称を返すメソッド
 */
- (NSString * )getMyParentName {
	return myParentName;
}



/**
 自分から見た親のMSIDをセットするメソッド
 */
- (void) setMyParentMSID:(NSString * )parentMSID {
	NSLog(@"set_parentMSID_%@, self_%@", parentMSID, self);
	myParentMSID = parentMSID;
}
/**
 親のMSIDを返すメソッド
 */
- (NSString * )getMyParentMSID {
	NSLog(@"get_myParentMSID_%@", myParentMSID);
	return myParentMSID;
}

@end

//
//  MessengerSystem.m
//  KissakiProject
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "MessengerSystem.h"
#import "MessengerIDGenerator.h"


#define NSLog( m, args... )










/**
 プライベートインターフェース
 */
@interface MessengerSystem (PrivateImplements)


//内部実行系
- (void) innerPerform:(NSNotification * )notification;//内部実装メソッド

- (void) sendPerform:(NSMutableDictionary * )dict;//実行メソッド
- (void) sendPerform:(NSMutableDictionary * )dict withDelay:(float)delay;//遅延実行メソッド

- (void) sendMessage:(NSMutableDictionary * )dict;//送信実行ブロック




//プライベート実行メソッド
- (void) remoteInvocation:(id)inv withDict:(NSMutableDictionary * )dict, ...;//遅延実行　プライベート版
- (void) createdNotice;//作成完了声明発行メソッド
- (void) updatedNotice:(NSString * )parentName withParentMID:(NSString * )parentMID;//更新発行メソッド
- (void) killedNotice;//自死声明発行メソッド


//子供辞書関連
- (void) setChildDictChildNameAsValue:(NSString * )senderName withMIDAsKey:(NSString * )senderMID;
- (void) removeChildDictChildNameAsValue:(NSString * )senderName withMIDAsKey:(NSString * )senderMID;



//遠隔実行
- (NSDictionary * ) setRemoteInvocationFrom:(id)mySelf withSelector:(SEL)sel;



//ログシステム
- (void) addCreationLog:(NSMutableDictionary * )dict;//メッセージ初期作成ログを内部に保存する/返すメソッド
- (void) saveLogForReceived:(NSMutableDictionary * )logDict;//受信時に付与するログを内部に保存するメソッド
- (NSMutableDictionary * ) createLogForReply;//返答送信時に付与するログを内部に保存する/返すメソッド

- (void) saveToLogStore:(NSString * )name log:(NSDictionary * )value;




//setter, initializer
- (void) setMyBodyID:(id)bodyID;
- (void) setMyBodySelector:(SEL)body_selector;
- (void) setMyName:(NSString * )name;
- (void) initMyMID;
- (void) initMyParentData;
- (void) resetMyParentData;
- (void) setMyParentName:(NSString * )parent;
- (void) setMyParentMID:(NSString * )parentMID;


@end


/**
 プライベート実装
 */
@implementation MessengerSystem (PrivateImplements)

//内部実行系
/**
 内部実行で先ず呼ばれるメソッド
 自分宛のメッセージでなければ無視する
 */
- (void) innerPerform:(NSNotification * )notification {
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	//コマンド名について確認
	NSString * commandName = [dict valueForKey:MS_CATEGOLY];
	if (!commandName) {
		NSLog(@"コマンドが無いため、何の処理も行われずに帰る");
		return;
	}
	
	//送信者名
	NSString * senderName = [dict valueForKey:MS_SENDERNAME];
	if (!senderName) {//送信者不詳であれば無視する
		NSLog(@"送信者NAME不詳");
		return;
	}
	
	
	//送信者MID
	NSString * senderMID = [dict valueForKey:MS_SENDERMID];
	if (!senderMID) {//送信者不詳であれば無視する
		NSLog(@"送信者ID不詳");
		return;
	}
	
	
	//宛名確認
	NSString * address = [dict valueForKey:MS_ADDRESS_NAME];
	if (!address) {
//		NSLog(@"宛名が無い_%@ Iam_%@", commandName, [self getMyName]);
		return;
	}
	
	
	//ログ関連
	NSMutableDictionary * recievedLogDict = [dict valueForKey:MS_LOGDICTIONARY];
	if (!recievedLogDict) {
		//		NSLog(@"ログが無いので受け付けない_%@", commandName);
		return;
	} else {
		//メッセージIDについて確認
		NSString * messageID = [recievedLogDict valueForKey:MS_LOG_MESSAGEID];
		if (!messageID) {
//			NSLog(@"メッセージIDが無いため、何の処理も行われずに帰る");
			return;
		}		
	}
	
	
	
	/**
	 自分が今、誰なのかを考察する
	 1,プロセスID
	 2,スレッドID
	 3,スレッドが触っているコンテナID、、まだ取れていない
	 */
	
	
	//	pid_t pid = getpid();//駄目、ぐっはあ、うーん。　惜しい。プロセスIDでは駄目か！?　それとも行けるのか
	//	pid_t ppid = getppid();
	//	
	//	
	//	NSLog(@"Num_%d /	2_%d", pid, ppid);
	//	
	//	NSProcessInfo *processInfo = [NSProcessInfo processInfo];
	//	
	//	NSString *processName = [processInfo processName];
	//	int processID = [processInfo processIdentifier];// = getpid()
	//	NSLog(@"Process Name:%@ Process ID:%d", processName, processID);
	
	//	NSLog(@"currentThread_0_self=%@, %@", [self getMyName], [NSThread currentThread]);
	
	
	//カテゴリごとの処理に移行
	//クリティカルなケースであっても、ThreadIDで対応できる筈。現在実行中の、Threadからみて未完了の処理とそれをIDする機能、というのが或る筈なんだ。
	
	
	//LPC
	if ([commandName isEqualToString:MS_CATEGOLY_LOCAL]) {
		
		
		if (![senderName isEqualToString:[self getMyName]]) {
			NSLog(@"MS_CATEGOLY_LOCAL 名称が違う_%@", [self getMyName]);
			return;
		}
		
		if (![senderMID isEqualToString:[self getMyMID]]) {//MIDが異なれば処理をしない
			NSLog(@"名前が同様の異なるMIDを持つオブジェクト");
			return;
		}
		
		
		[self saveLogForReceived:recievedLogDict];
		
		//設定されたbodyのメソッドを実行
		IMP func = [[self getMyBodyID] methodForSelector:[self getMyBodySelector]];
		(*func)([self getMyBodyID], [self getMyBodySelector], notification);
		
		
		return;
	}
	
	
	
	
	
	
	//親から子供に向けてのコールを受け取った
	if ([commandName isEqualToString:MS_CATEGOLY_CALLCHILD]) {
		//宛名が自分の事でなかったら帰る
		if (![address isEqualToString:[self getMyName]]) {
			NSLog(@"自分宛ではないので却下_From_%@,	To_%@,	Iam_%@", senderName, address, [self getMyName]);
			return;
		}
		
		
		//送信者の名前と受信者の名前が同一であれば、抜ける 送信側で既に除外済み
		if ([senderName isEqualToString:[self getMyName]]) {
			NSAssert(false, @"同名の子供はブロードキャストの対象に出来ない");
		}
		
		
		if ([senderName isEqualToString:[self getMyParentName]]) {
			
			
			[self saveLogForReceived:recievedLogDict];
			
			
			//設定されたbodyのメソッドを実行
			IMP func = [[self getMyBodyID] methodForSelector:[self getMyBodySelector]];
			(*func)([self getMyBodyID], [self getMyBodySelector], notification);
			return;
		}
		
		
		
		//対象ではなかった
		return;
	}
	
	
	
	//子供から親に向けてのコールを受け取った
	if ([commandName isEqualToString:MS_CATEGOLY_CALLPARENT]) {//親に送られたメッセージ
		
		if (![address isEqualToString:[self getMyName]]) {//送信者の指定した宛先が自分か
			NSLog(@"MS_CATEGOLY_CALLPARENT_宛先ではないMessnegerが受け取った");
			return;
		}
		
		
		//宛先MIDのキーがあるか
		NSString * calledParentMSID = [dict valueForKey:MS_ADDRESS_MID];
		if (!calledParentMSID) {
			NSLog(@"親のMIDの入力が無ければ無効");
			return;//値が無ければ無視する
		}
		
		
		//自分のMIDと一致するか
		if (![calledParentMSID isEqualToString:[self getMyMID]]) {
			NSLog(@"同名の親が存在するが、呼ばれている親と異なるため無効");
			return;
		}
		
		for (id key in [self getChildDict]) {//子供リストに含まれていなければ実行しないし、受け取らない。
			if ([[[self getChildDict] objectForKey:key] isEqualToString:senderName]) {
				[self saveLogForReceived:recievedLogDict];
				
				//設定されたbodyのメソッドを実行
				IMP func = [[self getMyBodyID] methodForSelector:[self getMyBodySelector]];
				(*func)([self getMyBodyID], [self getMyBodySelector], notification);
				return;
			}
		}
		
		return;
	}
	
	
	
	
	
	
	//親探索のサーチが届いた
	if ([commandName isEqualToString:MS_CATEGOLY_PARENTSEARCH]) {
		
		//自分宛かどうか、先ず名前で判断
		if (![address isEqualToString:[self getMyName]]) {
			//			NSLog(@"MS_CATEGOLY_PARENTSEARCHのアドレスcheckに失敗");
			return;
		}
		
		//送信者が自分であれば無視する 自分から自分へのメッセージの無視
		if ([senderMID isEqualToString:[self getMyMID]]) {
			//			NSLog(@"自分が送信者なので無視する_%@", [self getMyMID]);
			return;
		}
		
		NSString * calledParentName = [dict valueForKey:MS_PARENTNAME];
		if (!calledParentName) {
			//			NSLog(@"親の名称に入力が無ければ無視！");
			return;//値が無ければ無視する
		}
		
//		NSLog(@"自分以外の誰かが、自分をparentとして設定しようと通信してきている。_%@", calledParentName);
		if ([calledParentName isEqualToString:[self getMyName]]) {//それが自分だったら
			
			id invocatorId = [notification object];
			//親は先着順で設定される。既に子供が自分と同名の親にアクセスし、そのMIDを持っている場合があり得るため、ここで子供の持っている親MIDを確認する必要がある
			if ([invocatorId hasParent]) {
				NSAssert(FALSE, @"親が既に存在している");//現在は複数の親を許容する仕様ではないので、エラーとして発生させる
				return;
			}
			
			//受信時にログに受信記録を付け、保存する
			[self saveLogForReceived:recievedLogDict];
			
			
			//遠隔実行で子供の親名簿に自分のMIDを登録する 子供がもつ、引数１の関数[setMyParentMID　を親から実行する。]
			[self remoteInvocation:invocatorId withDict:dict, [self getMyMID], nil];
			
			
			//遠隔実行後、自分の子供として記録する
			[self setChildDictChildNameAsValue:senderName withMIDAsKey:senderMID];
			
			return;
		}
		
		
		//自分宛ではない
		//		NSLog(@"自分宛ではないので、無視する_%@	called%@", myName, calledParentName);
		return;
	}
	
	
	//親解消のコマンドが届いた
	if ([commandName isEqualToString:MS_CATEGOLY_REMOVE_PARENT]) {
		
		//自分宛かどうか、先ず名前で判断
		if (![address isEqualToString:[self getMyName]]) {
			return;
		}
		
		//自分宛かどうか、MIDで判断
		//宛先MIDのキーがあるか
		NSString * calledParentMSID = [dict valueForKey:MS_ADDRESS_MID];
		if (!calledParentMSID) {
			return;
		}
		
		
		//受信時にログに受信記録を付け、保存する
		[self saveLogForReceived:recievedLogDict];
		
		
		//自分の子供辞書にある、子供情報を削除する
		[self removeChildDictChildNameAsValue:senderName withMIDAsKey:senderMID];
		
		return;
	}
	
	//子供解消のコマンドが届いた
	if ([commandName isEqualToString:MS_CATEGOLY_REMOVE_CHILD]) {
		NSLog(@"MS_CATEGOLY_REMOVE_CHILD到着");
		
		//自分自身を除外
		if ([[self getMyMID] isEqualToString:senderMID]) {
			return;
		}
		
		//親を持っていなければ除外
		if (![self hasParent]) {
			return;
		}
		
		//送信者が自分の親の名前と一致するか
		if (![senderName isEqualToString:[self getMyParentName]]) {
			return;
		}
		
		
		//送信者のMIDが自分の親MIDと同一の場合のみ、実行
		if ([senderMID isEqualToString:[self getMyParentMID]]) {
			//ログ
			[self saveLogForReceived:recievedLogDict];
			
			[self initMyParentData];
			
			//通知
			[self updatedNotice:[self getMyParentName] withParentMID:[self getMyParentMID]];
		}
		return;
	}
	
	
	
	NSAssert1(false, @"MessengerSystem_innerPerform_想定外のコマンド_%@",commandName);
}

/**
 パフォーマンス実行を行う
 */
- (void) sendPerform:(NSMutableDictionary * )dict {
	
	NSString * s = [self getMyName];
	[[NSNotificationCenter defaultCenter] postNotificationName:OBSERVER_ID object:self userInfo:(id)dict];
	
}

/**
 遅延実行
 */
- (void) sendPerform:(NSMutableDictionary * )dict withDelay:(float)delay {
	[self performSelector:@selector(sendPerform:) withObject:dict afterDelay:delay];
}


/**
 ログを取り、実行する。
 */
- (void) sendMessage:(NSMutableDictionary * )dict {
	
	[self addCreationLog:dict];
	
	//遅延実行キーがある場合
	NSNumber * delay = [dict valueForKey:MS_DELAY];//複数或る場合はエラーにしたい
	if (delay) {
		float delayTime = [delay floatValue];
		[self sendPerform:dict withDelay:delayTime];
		return;
	}
	
	//通常の送信を行う
	[self sendPerform:dict];
}




//プライベート実行メソッド
/**
 遠隔実行発行メソッド
 プライベート版、可変長引数受付
*/
- (void) remoteInvocation:(id)inv withDict:(NSMutableDictionary * )dict, ... {
	
	if (![self isIncludeRemote:dict]) {
		NSAssert(FALSE, @"リモート実行コマンドが設定されていないメッセージに対してremoteInvocationメソッドを実行しています。");
		return;
	}
	
	NSDictionary * invokeDict = [dict valueForKey:MS_RETURN];
	
	id invocatorId;
	id signature;
	SEL method;
	
	id invocation;
	
	
	invocatorId = inv;//[invokeDict valueForKey:MS_RETURNID];
	if (!invocatorId) {
		NSAssert(FALSE, @"MS_RETURNIDが無い");
		return;
	}
	
	signature = [invokeDict valueForKey:MS_RETURNSIGNATURE];
	if (!signature) {
		NSAssert(FALSE, @"MS_RETURNSIGNATUREが無い");
		return;
	}
	
	method = NSSelectorFromString([invokeDict valueForKey:MS_RETURNSELECTOR]);
	if (!method) {
		NSAssert(FALSE, @"MS_RETURNSELECTORが無い");
		return;
	}
	
	
	//NSInvocationを使った実装
	invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:method];
	[invocation setTarget:invocatorId];
	
	
	int i = 2;//0,1が埋まっているから固定値 2から先に値を渡せるようにする必要がある
	
	va_list ap;
	id param;
	va_start(ap, dict);
	param = va_arg(ap, id);
	
	while (param) {
		
		[invocation setArgument:&param atIndex:i];
		i++;
		
		param = va_arg(ap, id);
	}
	va_end(ap);
	
	[invocation invoke];//実行
	
}

/**
 自分が作成完了した事をお知らせする
 受け取っても行う処理の存在しない、宛先の無いメソッド
 */
- (void) createdNotice {
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:3];
	
	[dict setValue:MS_NOTICE_CREATED forKey:MS_CATEGOLY];
	[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
	[dict setValue:[self getMyMID] forKey:MS_SENDERMID];
	
	//最終送信処理
	[self sendPerform:dict];
}

/**
 親が決定した事をお知らせする
 受け取っても行う処理の存在しない、宛先の無いメソッド
 */
- (void) updatedNotice:(NSString * )parentName withParentMID:(NSString * )parentMID {
	
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
	
	[dict setValue:MS_NOTICE_UPDATE forKey:MS_CATEGOLY];
	
	[dict setValue:[self getMyParentName] forKey:MS_PARENTNAME];
	[dict setValue:[self getMyParentMID] forKey:MS_PARENTMID];
	
	[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
	[dict setValue:[self getMyMID] forKey:MS_SENDERMID];
	
	//最終送信処理
	[self sendPerform:dict];
}

/**
 自死をお知らせする
 受け取っても行う処理の存在しない、宛先の無いメソッド
 */
- (void) killedNotice {
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:3];
	
	[dict setValue:MS_NOTICE_DEATH forKey:MS_CATEGOLY];
	
	[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
	[dict setValue:[self getMyMID] forKey:MS_SENDERMID];
	
	//最終送信処理
	[self sendPerform:dict];
}




//子供辞書関連
/**
 自分をParentとして指定してきたChildについて、子供のmyNameとmyMIDを自分のchildDictに登録する。
 */
- (void) setChildDictChildNameAsValue:(NSString * )senderName withMIDAsKey:(NSString * )senderMID {
	
	[[self getChildDict] setValue:senderName forKey:senderMID];
	
}
/**
 子供からの要請で、childDictから該当の子供情報を削除する
 */
- (void) removeChildDictChildNameAsValue:(NSString * )senderName withMIDAsKey:(NSString * )senderMID {
	[[self getChildDict] removeObjectForKey:senderMID];//無かったらどうしよう、、、
}





//遠隔実行
/**
 遠隔実行セットメソッド
 */
- (NSDictionary * ) setRemoteInvocationFrom:(id)mySelf withSelector:(SEL)sel {
	//フック
	//特定のメソッドの実行を命令づける設定
	//IMP func = [self methodForSelector:@selector(setMyParentMID:)];
	//(*func)(self,@selector(setMyParentMID:),@"ついた");
	
	id inv = mySelf;
	if (mySelf == self) inv = @"DUMMY_POINTER"; 
	
	NSDictionary * retDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  inv,	MS_RETURNID, 
							  [mySelf methodSignatureForSelector:sel],	MS_RETURNSIGNATURE, 
							  NSStringFromSelector(sel),	MS_RETURNSELECTOR, 
							  nil];
	return retDict;
}





//ログ
/**
 メッセージ発生時のログ書き込み、ログ初期化
 メッセージIDを作成、いろいろな情報をまとめる
 */
- (void) addCreationLog:(NSMutableDictionary * )dict {
	
	//ログタイプ、タイムスタンプを作成
	//メッセージに対してはメッセージIDひも付きの新規ログをつける事になる。
	//ストアについては、新しいIDのものが出来るとIDの下に保存する。多元木構造になっちゃうなあ。カラムでやった方が良いのかしら？それとも絡み付いたKVSかしら。
	
	NSString * messageID = [MessengerIDGenerator getMID];//このメッセージのIDを出力(あとでID認識するため)
	
	
	//ストアに保存する
	[self saveToLogStore:MS_LOGMESSAGE_CREATED log:[self tag:MS_LOG_MESSAGEID val:messageID]];
	
	
	//messageとともに移動するログに内容をセットする
	NSDictionary * newLogDictionary;
	newLogDictionary = [NSDictionary dictionaryWithObject:messageID forKey:MS_LOG_MESSAGEID];
	
	[dict setValue:newLogDictionary forKey:MS_LOGDICTIONARY];
}

/**
 受け取り時のログ書き込み
 
 受信したメッセージからログを受け取り、
 ログの末尾に含まれているメッセージIDでもって、過去に受け取ったことがあるかどうか判定(未実装)、
 ログストアに保存する。
 */
- (void) saveLogForReceived:(NSMutableDictionary * ) recievedLogDict {
	
	//ログタイプ、タイムスタンプを作成
	NSString * messageID = (NSString * )[recievedLogDict valueForKey:MS_LOG_MESSAGEID];
	
	//ストアに保存する
	[self saveToLogStore:MS_LOGMESSAGE_RECEIVED log:[self tag:MS_LOG_MESSAGEID val:messageID]];
}

/**
 返信時のログ書き込み
 
 どこからか取得したメッセージIDでもって、
 保存していたログストアからログデータを読み出し、
 最新の「送信しました」記録を行い、
 記録をログ末尾に付け加えたログを返す。
 */
- (NSMutableDictionary * ) createLogForReply {
	NSAssert(FALSE, @"createLogForReplyは未完成です。　使用禁止です。");
	//ログタイプ、タイムスタンプを作成
	[logDict setValue:@"仮のmessageID" forKey:MS_LOG_MESSAGEID];
	
	return logDict;
}

/**
 可変長ログストア入力
 アウトプットは後で考えよう。
 */
- (void) saveToLogStore:(NSString * )name log:(NSDictionary * )value {
	
	NSArray * key = [value allKeys];//1件しか無い内容を取得する
	
	[logDict setValue:
	 [NSString stringWithFormat:@"%@ %@", name, [value valueForKey:[key objectAtIndex:0]]] 
			   forKey:
	 [NSString stringWithFormat:@"%@ %@", [MessengerIDGenerator getMID], [NSDate date]]
	 ];
	
	
}





//setter, initializer
/**
 自分の名称をセットするメソッド
 */
- (void)setMyName:(NSString * )name {
	myName = name;
}


/**
 自分のBodyIDをセットするメソッド
 */
- (void) setMyBodyID:(id)bodyID {
	myBodyID = bodyID;
}


/**
 自分のBodyが提供するメソッドセレクターを、自分のセレクター用ポインタにセットするメソッド
 */
- (void) setMyBodySelector:(SEL)body_selector {
	myBodySelector = body_selector;
}


/**
 自分のMIDを初期化するメソッド
 */
- (void)initMyMID {
	myMID = [MessengerIDGenerator getMID];
}


/**
 myParent関連情報を初期化する
 */
- (void) initMyParentData {
	[self setMyParentName:MS_DEFAULT_PARENTNAME];
	myParentMID = MS_DEFAULT_PARENTMID;
}


/**
 親情報をリセットする
 (親のchildDictからも消す)
 */
- (void) resetMyParentData {
	[self removeFromParent];
}


/**
 親の名称をセットするメソッド
 */
- (void) setMyParentName:(NSString * )parent {
	myParentName = parent;
}


/**
 自分から見た親のMIDをセットするメソッド
 外部から呼ばれるように設計されている。
 親が複数要るケースは想定し排除してある。
 
 本メソッドは条件を満たした親から起動されるメソッドになっており、自分から呼ぶ事は無い。
 */
- (void) setMyParentMID:(NSString * )parentMID {
	if ([[self getMyParentMID] isEqualToString:MS_DEFAULT_PARENTMID]) {
		
		[self saveToLogStore:@"setMyParentMID" log:[self tag:MS_LOG_LOGTYPE_GOTP val:[self getMyParentName]]];
		
		
		myParentMID = parentMID;
		
		[self updatedNotice:[self getMyParentName] withParentMID:[self getMyParentMID]];
	}	
}


@end
















/**
 パブリック実装
 */
@implementation MessengerSystem

/**
 バージョンを返す
 */
+ (NSString * )version {
    return @"0.5.0";//10/09/20 3:46:51
}

//初期化メソッド
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name {
	if (self = [super init]) {
		NSAssert(name, @"withName引数がnilです。　名称をセットしてください。");
		[self setMyName:name];
		
		NSAssert(body_id, @"initWithBodyID引数がnilです。　制作者のidをセットしてください。");
		[self setMyBodyID:body_id];
		
		NSAssert(body_selector, @"withSelector引数がnilです。　実行セレクタをセットしてください。");
		[self setMyBodySelector:body_selector];
		
		[self initMyMID];
		[self initMyParentData];
	}
	
	childDict = [[NSMutableDictionary alloc] init];
	logDict = [[NSMutableDictionary alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(innerPerform:) name:OBSERVER_ID object:nil];
	
	[self createdNotice];
	
	return self;
}


//- (id) initWithManual {
//	/*
//	 マニュアル表示のプログラムを書こう！
//	 */
//	if (self = [super init]) {
//		
//	}
//	return self;
//}


//実行メソッド
/**
 親へと自分が子供である事の通知を行い、返り値として親のMIDを受け取るメソッド
 受け取り用のメソッドの情報を親へと渡し、親からの入力をダイレクトに受ける。
 */
- (void) inputParent:(NSString * )parent {
	
	NSAssert([[self getMyParentName] isEqualToString:MS_DEFAULT_PARENTNAME], @"デフォルト以外の親が既にセットされています。親を再設定する場合、resetMyParentDataメソッドを実行してから親指定を行ってください。");
	
	//親の名前を設定
	[self setMyParentName:parent];
	
	
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:7];
	
	[dict setValue:MS_CATEGOLY_PARENTSEARCH forKey:MS_CATEGOLY];
	[dict setValue:[self getMyParentName] forKey:MS_ADDRESS_NAME];

	[dict setValue:[self getMyParentName] forKey:MS_PARENTNAME];
	
	[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
	[dict setValue:[self getMyMID] forKey:MS_SENDERMID];
	
	
	//遠隔実装メソッドを設定
	[dict setValue:[self setRemoteInvocationFrom:self withSelector:@selector(setMyParentMID:)] forKey:MS_RETURN];//ここで外部向けに参照が1増える
	//[self release];
	
	
	//ログを作成する
	[self addCreationLog:dict];
	
	//最終送信処理
	[self sendPerform:dict];//プライベート版の遠隔実行で、相手から親登録を実行する。
	
	//この時点で親からの実行が完了。
	[dict removeAllObjects];
	
	
	NSAssert1([self hasParent], @"指定した親が存在しないようです。inputParentに指定している名前を確認してください_現在探して見つからなかった親の名前は_%@",[self getMyParentName]);
}

/**
 現在の親情報を削除する
 */
- (void) removeFromParent {
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:6];
	
	[dict setValue:MS_CATEGOLY_REMOVE_PARENT forKey:MS_CATEGOLY];
	
	[dict setValue:[self getMyParentName] forKey:MS_ADDRESS_NAME];
	[dict setValue:[self getMyParentMID] forKey:MS_ADDRESS_MID];
	
//	NSLog(@"[[self getMyParentName] hash]_%d", [[self getMyParentName] hash]);
//	NSLog(@"[[dict valueForKey:MS_ADDRESS_NAME] hash]_%d", [[dict valueForKey:MS_ADDRESS_NAME] hash]);
	
	[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
	[dict setValue:[self getMyMID] forKey:MS_SENDERMID];
	
	//ログを作成する
	[self addCreationLog:dict];

	//最終送信処理
	[self sendPerform:dict];//送信に失敗すると、親子関係は終了しない。この部分でエラーが出るのがたより。
	
	//初期化
	[self initMyParentData];//初期化 この時点で子供から見た親情報はデフォルトになる	
	
	//更新通知
	[self updatedNotice:[self getMyParentName] withParentMID:[self getMyParentMID]];

}

/**
 子供との関連性を解除する
 自分の事を親に設定している全てのオブジェクトから離脱するブロードコールを行う。
 */
- (void) removeAllChild {
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:6];
	
	[dict setValue:MS_CATEGOLY_REMOVE_CHILD forKey:MS_CATEGOLY];
	
	[dict setValue:[self getMyName] forKey:MS_ADDRESS_NAME];
	[dict setValue:[self getMyMID] forKey:MS_ADDRESS_MID];
	
	[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
	[dict setValue:[self getMyMID] forKey:MS_SENDERMID];
	
	//ログを作成する
	[self addCreationLog:dict];

	//最終送信処理
	[self sendPerform:dict];
	
	//初期化
	[[self getChildDict] removeAllObjects];
	
	//通知
	[self updatedNotice:[self getMyParentName] withParentMID:[self getMyParentMID]];
}



/**
 自分自身のmessengerへと通信を行うメソッド
 */
- (void) callMyself:(NSString * )exec, ... {
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
	
	[dict setValue:MS_CATEGOLY_LOCAL forKey:MS_CATEGOLY];
	[dict setValue:[self getMyName] forKey:MS_ADDRESS_NAME];
	
	[dict setValue:exec forKey:MS_EXECUTE];
	[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
	[dict setValue:[self getMyMID] forKey:MS_SENDERMID];
	
	va_list ap;
	id kvDict;
	
	//NSLog(@"start_%@", exec);
	
	va_start(ap, exec);
	kvDict = va_arg(ap, id);
	
	while (kvDict) {
		//NSLog(@"kvDict_%@", kvDict);
		
		for (id key in kvDict) {
			//					NSLog(@"[kvDict valueForKey:key]_%@, key_%@", [kvDict valueForKey:key], key);
			[dict setValue:[kvDict valueForKey:key] forKey:key];
		}
		
		kvDict = va_arg(ap, id);
	}
	va_end(ap);
	
	
	[self sendMessage:dict];
}

/**
 特定の名前のmessengerへの通信を行うメソッド
 親から子限定
 
 子供辞書を持っており、かつ、nameに該当する子供がいる
 送り先の名称が自分と異なる場合のみ、送る事が出来る
 →同名の子供群まで対象に入れると、メッセージの判別手段にグループの概念を持ち込まなければいけないために存在する制限。
 
 */
- (void) call:(NSString * )childName withExec:(NSString * )exec, ... {
	
	NSAssert(![childName isEqualToString:[self getMyName]], @"自分自身/同名の子供達へのメッセージブロードキャストをこのメソッドで行う事はできません。　callMyselfメソッドを使用してください");
	NSAssert(![childName isEqualToString:MS_DEFAULT_PARENTNAME], @"システムで予約してあるデフォルトの名称です。　この名称を使ってのシステム使用は、その、なんだ、お勧めしません。");
	
	
	//特定のキーが含まれているか
	//	[childDict allValues]//NSArray コストは概ね一緒かな。 特定のキーが含まれているか否か、を隠蔽したいか否か
	
	//親から子へのブロードキャスト MIDで送り先を限定しない。
	for (id key in [self getChildDict]) {
		if ([[childDict objectForKey:key] isEqualToString:childName]) {//一つでも合致する内容のものがあれば、メッセージを送る対象として見る。
			NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
			
			[dict setValue:MS_CATEGOLY_CALLCHILD forKey:MS_CATEGOLY];
			[dict setValue:childName forKey:MS_ADDRESS_NAME];
			
			[dict setValue:exec forKey:MS_EXECUTE];
			[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
			[dict setValue:[self getMyMID] forKey:MS_SENDERMID];
			
			va_list ap;
			id kvDict;
			
			//NSLog(@"start_%@", exec);
			
			va_start(ap, exec);
			kvDict = va_arg(ap, id);
			
			while (kvDict) {
				//NSLog(@"kvDict_%@", kvDict);
				
				for (id key in kvDict) {
					//					NSLog(@"[kvDict valueForKey:key]_%@, key_%@", [kvDict valueForKey:key], key);
					[dict setValue:[kvDict valueForKey:key] forKey:key];
				}
				
				kvDict = va_arg(ap, id);
			}
			va_end(ap);
			
			[self sendMessage:dict];
			
			return;//一通だけを送る
		}
	}
	
	//NSAssert1(false, @"callメソッドに指定したmessengerが存在しないか、未知のものです。本messengerを親とした設定を行うよう、子から親を指定してください。_%@",name);
}

/**
 特定の子への通信を行うメソッド、特にMIDを使い、相手を最大限特定する。
 */
- (void) call:(NSString * )childName withMID:(NSString * ) withExec:(NSString * )exec, ... {
	NSAssert(false, @"開発中のメソッドです");
}

/**
 親への通信を行うメソッド
 */
- (void) callParent:(NSString * )exec, ... {
	
	//親が居たら
	if ([self getMyParentName]) {
		NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
		
		
		[dict setValue:MS_CATEGOLY_CALLPARENT forKey:MS_CATEGOLY];
		[dict setValue:[self getMyParentName] forKey:MS_ADDRESS_NAME];
		[dict setValue:[self getMyParentMID] forKey:MS_ADDRESS_MID];
		
		
		[dict setValue:exec forKey:MS_EXECUTE];
		[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
		[dict setValue:[self getMyMID] forKey:MS_SENDERMID];
		
		
		//tag付けされた要素以外は無視するように設定
		//可変長配列に与えられた要素を処理する。
		
		va_list vp;//可変引数のポインタになる変数
		id kvDict;//可変長引数から辞書を取り出すときに使用するポインタ
		
		//NSLog(@"start_%@", exec);
		
		va_start(vp, exec);//vpを可変長配列のポインタとして初期化する
		kvDict = va_arg(vp, id);//vpから現在の可変長配列のヘッドにあるidを抽出し、kvDictに代入。この時点でkvDictは可変長配列のトップの要素のidを持っている。
		
		while (kvDict) {//存在していなければnull、可変長引数の終了の合図。
			
			//NSLog(@"kvDict_%@", kvDict);
			
			for (id key in kvDict) {
				
				//NSLog(@"[kvDict valueForKey:key]_%@, key_%@", [kvDict valueForKey:key], key);
				//型チェック、kvDict型で無ければ無視する必要がある。
				if (true) [dict setValue:[kvDict valueForKey:key] forKey:key];
				
			}
			
			kvDict = va_arg(vp, id);//次の値を読み出す
		}
		
		va_end(vp);//終了処理
		
		[self sendMessage:dict];
		
		return;
	}
	
	NSAssert(false, @"親設定が無い");
}








//タグシステム
/**
 tag valueメソッド
 値にnilが入る事、
 システムが使うのと同様のコマンドが入っている事に関しては、注意する。
 */
- (NSDictionary * ) tag:(id)obj_tag val:(id)obj_value {
	NSAssert1(obj_tag, @"tag_%@ is nil",obj_tag);
	NSAssert1(obj_value, @"val_%@ is nil",obj_value);
	
	return [NSDictionary dictionaryWithObject:obj_value forKey:obj_tag];
} 


/**
 遠隔実行タグ
 tag-Valueと同形式で遠隔実行オプションを挿入するメソッド
 */
- (NSDictionary * )withRemoteFrom:(id)mySelf withSelector:(SEL)sel {
	NSAssert1(mySelf, @"withRemoteFrom_%@ is nil",mySelf);
	NSAssert1(sel, @"withSelector_%@ is nil",sel);
	
	return [NSDictionary dictionaryWithObject:[self setRemoteInvocationFrom:mySelf withSelector:sel] forKey:MS_RETURN];
}


/**
 遅延実行タグ
 tag-Valueと同形式でオプションを挿入するメソッド
 */
- (NSDictionary * ) withDelay:(float)delay {
	NSAssert1(delay,@"withDelay_%@ is nil",delay);
	
	return [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:delay] forKey:MS_DELAY];
}



//遠隔実行実装
/**
 遠隔実行実装
 パブリック用
 */
- (void) remoteInvocation:(NSMutableDictionary * )dict, ... {
	
	if (![self isIncludeRemote:dict]) {
		NSAssert(FALSE, @"リモート実行コマンドが設定されていないメッセージに対してremoteInvocationメソッドを実行しています。");
		return;
	}
	
	NSDictionary * invokeDict = [dict valueForKey:MS_RETURN];
	
	id invocatorId;
	id signature;
	SEL method;
	
	id invocation;
	
	
	invocatorId = [invokeDict valueForKey:MS_RETURNID];
	if (!invocatorId) {
		NSAssert(FALSE, @"MS_RETURNIDが無い");
		return;
	}
	
	signature = [invokeDict valueForKey:MS_RETURNSIGNATURE];
	if (!signature) {
		NSAssert(FALSE, @"MS_RETURNSIGNATUREが無い");
		return;
	}
	
	method = NSSelectorFromString([invokeDict valueForKey:MS_RETURNSELECTOR]);
	if (!method) {
		NSAssert(FALSE, @"MS_RETURNSELECTORが無い");
		return;
	}
	
	
	//NSInvocationを使った実装
	invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:method];
	[invocation setTarget:invocatorId];
	
	
	int i = 2;//0,1が埋まっているから固定値 2から先に値を渡せるようにする必要がある
	
	va_list ap;
	id param;
	va_start(ap, dict);
	param = va_arg(ap, id);
	
	while (param) {
		
		[invocation setArgument:&param atIndex:i];
		i++;
		
		param = va_arg(ap, id);
	}
	va_end(ap);
	
	[invocation invoke];//実行
	
}






//ログストアの取得
/**
 観察用にこのmessengerに書かれているログを取得するメソッド
 */
- (NSMutableDictionary * ) getLogStore {
	
	//ストアの全容量を取り出す
	
	return logDict;
}




//子供辞書の取得
/**
 childDictを返す
 */
- (NSMutableDictionary * ) getChildDict {
	return childDict;
}








/**
 実行処理名を指定、String値を取得する
 */
- (NSString * ) getExecAsString:(NSMutableDictionary * )dict {
	return [dict valueForKey:MS_EXECUTE];
}


/**
 実行処理名を指定、Int値を取得する
 この時点で飛び込んでくるストリングのポインタと同じ値を直前で出して、合致する値を出せればいいのか、、って定数じゃないが、、一致は出来る、、うーん。
 */
- (int) getExecAsIntFromDict:(NSMutableDictionary * )dict {
	return [self changeStrToNumber:[dict valueForKey:MS_EXECUTE]];
}

/**
 NSStringからInt値を出す
 */
- (int) getIntFromExec:(NSString * )exec {
	return [self changeStrToNumber:exec];
}


#define MULLE_ELF_STEP(B)	 do { ret=(ret<<4)+B; ret^=(ret>>24)&0xF0; } while(0)//ビットシフトしつつ文字列を数値に変換する。

/**
 文字列の数値化
 */
- (int) changeStrToNumber:(NSString * )str {
	
	
	const char * bytes = [str UTF8String];//UTF8エンコードに設定
	unsigned int length = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];//長さ取得
	
	unsigned int ret = 0;
	int rem = length;//残りの文字数長だけ、４文字ずつ処理を行う
	
	while (3 < rem) {
		MULLE_ELF_STEP(bytes[length - rem]);
		MULLE_ELF_STEP(bytes[length - rem + 1]);
		MULLE_ELF_STEP(bytes[length - rem + 2]);
		MULLE_ELF_STEP(bytes[length - rem + 3]);
		rem -= 4;
	}
	switch (rem) {//ラスト、のこりの文字数部分を計算する
		case 3:  MULLE_ELF_STEP(bytes[length - 3]);
		case 2:  MULLE_ELF_STEP(bytes[length - 2]);
		case 1:  MULLE_ELF_STEP(bytes[length - 1]);
		case 0:  ;
	}
	return ret;

}

/**
 数値の文字列化
 */
- (NSString * ) changeNumberToStr:(int)num {
	NSAssert(FALSE, @"まだ設計されてません");
	return nil;
}






//ユーティリティ
/**
 親が設定されているか否か返す
 */
- (BOOL) hasParent {
	if (![[self getMyParentMID] isEqual:MS_DEFAULT_PARENTMID]) {//デフォルトでない
		return TRUE;
	}
	return FALSE;
}

/**
 子供が設定されているか否か返す
 */
- (BOOL) hasChild {
	if (0 < [[self getChildDict] count]) {
		return TRUE;
	}
	return FALSE;
}


/**
 受け取ったデータに遠隔実行が含まれているか否か返す
 */
- (BOOL) isIncludeRemote:(NSMutableDictionary * )dict {
	
	if ([dict valueForKey:MS_RETURN]) {
		return TRUE;
	}
	return FALSE;
}


//ゲッター
/**
 自分の名称を返すメソッド
 */
- (NSString * )getMyName {
	return myName;
}


/**
 自分のBodyIDを返すメソッド
 */
- (id) getMyBodyID {
	return myBodyID;
}


/**
 自分のセレクター用ポインタを返すメソッド
 */
- (SEL) getMyBodySelector {
	return myBodySelector;
}

/**
 自分のMIDを返すメソッド
 */
- (NSString * )getMyMID {
	return myMID;
}


/**
 親の名称を返すメソッド
 */
- (NSString * )getMyParentName {
	return myParentName;
}


/**
 親のMIDを返すメソッド
 */
- (NSString * )getMyParentMID {
	return myParentMID;
}




/**
 Dealloc
 
 */
- (void) dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:OBSERVER_ID object:nil];//ノーティフィケーションから外す
	
	//予定している処理があったら、消す。 なかなか効果的にならない。
	
	NSLog(@"deallocに到達_%@", [self getMyName]);
	
	if ([self hasChild]) {
		NSLog(@"子供がいる_%@",[self getMyName]);
		[self removeAllChild];
	}
	
	if ([self hasParent]) {
		NSLog(@"親がいる_%@",[self getMyName]);
		[self removeFromParent];
	}
	
	[self killedNotice];

	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendPerform:) object:self];
	
	
	//自分の名前	NSString
//	NSAssert([myName retainCount] == 1, @"myName_%d",[myName retainCount]);
	myName = nil;
	
	
	//自分のID	NSString
//	NSAssert([myMID retainCount] == 1, @"myMID_%d",[myMID retainCount]);
	myMID = nil;
	
	
	//親の名前	NSString
//	NSAssert([myParentName retainCount] == 1, @"myParentName_%d",[myParentName retainCount]);
	myParentName = nil;
	
	//親のID		NSString
//	NSAssert([myParentMID retainCount] == 1, @"myParentMID_%d",[myParentMID retainCount]);
	myParentMID = nil;
	
	
	//子供の名前とIDを保存する辞書	NSMutableDictionary
	NSAssert([[self getChildDict] count] == 0, @"childDict_%d",[[self getChildDict] count]);
	[[self getChildDict] removeAllObjects];
	[[self getChildDict] release];
	
	//ログ削除
//	NSAssert([logDict count] == 0, @"logDict_%d",[logDict count]);
	[logDict removeAllObjects];
	NSAssert([logDict count] == 0, @"logDict_%d",[logDict count]);
	[logDict release];
	
	
    [super dealloc];
}
@end
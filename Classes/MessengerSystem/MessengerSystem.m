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
 初期化する
 */
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name {
	if (self = [super init]) {
		
		[self setMyName:name];
		[self setMyBodyID:body_id];
		[self setMyBodySelector:body_selector];
		[self initMyMSID];
		[self initMyParentData];
		
		childDict = [NSMutableDictionary dictionaryWithCapacity:1];
		logDict = [NSMutableDictionary dictionaryWithCapacity:1];

		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(innerPerform:) name:OBSERVER_ID object:nil];
	}
	return self;
}


/**
 親へと自分が子供である事の通知を行い、返り値として親のMSIDを受け取るメソッド
 受け取り用のメソッドの情報を親へと渡し、親からの入力をダイレクトに受ける。
 */
- (void) inputToMyParentWithName:(NSString * )parent {
	
	NSAssert([[self getMyParentName] isEqualToString:PARENTNAME_DEFAULT], @"デフォルト以外の親が既にセットされています。親を再設定する場合、resetMyParentDataメソッドを実行してから親指定を行ってください。");
	
	//親の名前を設定
	[self setMyParentName:parent];
	
	
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:8];
	
	[dict setValue:MS_CATEGOLY_PARENTSEARCH forKey:MS_CATEGOLY];
	[dict setValue:[self getMyParentName] forKey:MS_ADDRESS_NAME];

	[dict setValue:[self getMyParentName] forKey:MS_PARENTNAME];
	
	
	
	[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
	[dict setValue:[self getMyMSID] forKey:MS_SENDERMSID];
	
	
	[dict setValue:self forKey:MS_SENDERID];
	
	//フック
	//特定のメソッドの実行を命令づける、リタンダンシー設定
	//IMP func = [self methodForSelector:@selector(setMyParentMSID:)];
	//(*func)(self,@selector(setMyParentMSID:),@"ついた");
	
	//NSInvocationでの実装
	[dict setValue:[self methodSignatureForSelector:@selector(setMyParentMSID:)] forKey:MS_RETURN];
	
	
	//ログを作成する
	[dict setValue:[self createLogForNew] forKey:MS_LOGDICTIONARY];
	
	
	//最終送信処理
	[self sendPerform:dict];
	
	
	NSAssert1([self getMyParentMSID], @"指定した親が存在しないようです。parentに指定している名前を確認してください_現在指定されているparentは_%@",[self getMyParentName]);
}

/**
 親が決定した事をお知らせする
 受け取っても行う処理の存在しない、宛先の無いメソッド
 */
- (void) decidedParentName:(NSString * )parentName withParentMSID:(NSString * )parentMSID {
	
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
	
	[dict setValue:MS_CATEGOLY_GOTPARENT forKey:MS_CATEGOLY];
	
	[dict setValue:[self getMyParentName] forKey:MS_PARENTNAME];
	[dict setValue:[self getMyParentMSID] forKey:MS_PARENTMSID];
	
	[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
	[dict setValue:[self getMyMSID] forKey:MS_SENDERMSID];
	
	//最終送信処理
	[self sendPerform:dict];
}
/**
 現在の親情報を削除する
 */
- (void) removeMyParentData {
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:6];
	
	[dict setValue:MS_CATEGOLY_PARENTREMOVE forKey:MS_CATEGOLY];
	
	[dict setValue:[self getMyParentName] forKey:MS_ADDRESS_NAME];
	[dict setValue:[self getMyParentMSID] forKey:MS_ADDRESS_MSID];
	
	[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
	[dict setValue:[self getMyMSID] forKey:MS_SENDERMSID];
	
	//ログを作成する
	[dict setValue:[self createLogForNew] forKey:MS_LOGDICTIONARY];
	
	//最終送信処理
	[self sendPerform:dict];
	
}



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
	
	
	//送信者MSID
	NSString * senderMSID = [dict valueForKey:MS_SENDERMSID];
	if (!senderMSID) {//送信者不詳であれば無視する
		NSLog(@"送信者ID不詳");
		return;
	}
	
	
	//宛名確認
	NSString * address = [dict valueForKey:MS_ADDRESS_NAME];
	if (!address) {
		NSLog(@"宛名が無い_%@", commandName);
		return;
	}
	
	
	//ログ関連
	NSDictionary * recievedLogDict = [dict valueForKey:MS_LOGDICTIONARY];
	if (!recievedLogDict) {
		NSLog(@"ログが無いので受け付けない_%@", commandName);
		return;
	} else {
		//メッセージIDについて確認
		NSString * messageID = [recievedLogDict valueForKey:MS_LOG_MESSAGEID];
		if (!messageID) {
			NSLog(@"メッセージIDが無いため、何の処理も行われずに帰る");
			return;
		}		
	}
	
	
	
	
	//カテゴリごとの処理に移行
	
	
	if ([commandName isEqualToString:MS_CATEGOLY_LOCAL]) {
//		if (![address isEqualToString:[self getMyName]]) {//送信者の指定した宛先が自分か
//			NSLog(@"MS_CATEGOLY_LOCAL_宛先ではないMessnegerが受け取った");
//			return;
//		}
		
		if (![senderName isEqualToString:[self getMyName]]) {
			NSLog(@"MS_CATEGOLY_LOCAL 名称が違う_%@", [self getMyName]);
			return;
		}
		
		if (![senderMSID isEqualToString:[self getMyMSID]]) {//MSIDが異なれば処理をしない
			NSLog(@"名前が同様の異なるMSIDを持つオブジェクト");
			return;
		}
		
		
		[self saveLogForReceived:recievedLogDict];//受信ログを実行する

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
			//受信時にログに受信記録を付け、保存する
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
		
		
		//宛先MSIDのキーがあるか
		NSString * calledParentMSID = [dict valueForKey:MS_ADDRESS_MSID];
		if (!calledParentMSID) {
			NSLog(@"親のMSIDの入力が無ければ無効");
			return;//値が無ければ無視する
		}
		
		
		//自分のMSIDと一致するか
		if (![calledParentMSID isEqualToString:[self getMyMSID]]) {
			NSLog(@"同名の親が存在するが、呼ばれている親と異なるため無効");
			return;
		}
		
		
		//受信時にログに受信記録を付け、保存する
		[self saveLogForReceived:recievedLogDict];
		
		//設定されたbodyのメソッドを実行
		IMP func = [[self getMyBodyID] methodForSelector:[self getMyBodySelector]];
		(*func)([self getMyBodyID], [self getMyBodySelector], notification);
		
		
		
		return;
	}
	
	
	
	
	
	
	//親探索のサーチが届いた
	if ([commandName isEqualToString:MS_CATEGOLY_PARENTSEARCH]) {
		
		//自分宛かどうか、先ず名前で判断
		if (![address isEqualToString:[self getMyName]]) {
			NSLog(@"MS_CATEGOLY_PARENTSEARCHのアドレスcheck");
			return;
		}
		
		//送信者が自分であれば無視する 自分から自分へのメッセージの無視
		if ([[recievedLogDict valueForKey:MS_SENDERMSID] isEqualToString:[self getMyMSID]]) {
			NSLog(@"自分が送信者なので無視する_%@", [self getMyMSID]);
			return;
		}
		
		
		NSString * calledParentName = [dict valueForKey:MS_PARENTNAME];
		if (!calledParentName) {
			NSLog(@"親の名称に入力が無ければ無視！");
			return;//値が無ければ無視する
		}
		
		//		NSLog(@"自分以外の誰かが、自分をparentとして設定しようと通信してきている。_%@", calledParentName);
		if ([calledParentName isEqualToString:[self getMyName]]) {//それが自分だったら
			
			id senderID = [dict valueForKey:MS_SENDERID];
			if (!senderID) {
				NSLog(@"senderID(送信者のselfポインタ)が無い");
				return;
			}
			
			
			
			//親は先着順で設定される。既に子供が自分と同名の親にアクセスし、そのMSIDを持っている場合があり得るため、ここで子供の持っている親MSIDを確認する必要がある
			if (![[senderID getMyParentMSID] isEqualToString:PARENTMSID_DEFAULT]) {
				//				NSLog(@"親は先着順で既に設定されているようです");
				return;
			}
			
			
			//受信時にログに受信記録を付け、保存する
			[self saveLogForReceived:recievedLogDict];
			
			
			NSLog(@"自分に対して子供から親になる宣言をされた、辞書作成直前");
			//親が居ないと子が生まれない構造。 senderMSIDをキーとし、子供辞書を作る。
			[self setChildDictChildNameAsValue:senderName withMSIDAsKey:senderMSID];
			NSLog(@"辞書作成まで完了");
			
			
			
			//送り届けられたメソッドを使い、Child宛に登録した旨の返答を行う。
			/*
			 代替案。
			 void (*setter)(id, SEL, BOOL);
			 setter = (void (*)(id, SEL, BOOL))[self methodForSelector:@selector(inputToMyParentWithName:)];//関数ポインタに切り替えてる
			 setter(self, @selector(inputToMyParentWithName:), YES);//関数として実行			 
			 */
			id signature;
			id invocation;
			
			signature = [dict valueForKey:MS_RETURN];
			//			NSLog(@"signature_%@", signature);
			
			//NSInvocationを使った実装
			//他者が、自分の持っているメソッドを送り出し、よそでの実行を望むパターンを作りたい。持ってきて実行するにあたり、受け取って実行する方は、全て匿名で実行させたい。
			invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:@selector(setMyParentMSID:)];//ここに書くメソッド名、直書きしかないのか！？　なんと無意味な。セレクターを持って来れるんだろうか。
			[invocation setTarget:senderID];
			NSString * myMSIDforchild = [self getMyMSID];
			[invocation setArgument:&myMSIDforchild atIndex:2];//0,1が埋まっているから固定値,,
			
			[invocation invoke];
			
			
			return;
		}
		
		
		//自分宛ではない
		NSLog(@"自分宛ではないので、無視する_%@	called%@", myName, calledParentName);
		return;
	}
	
	
	//親解消のコマンドが届いた
	if ([commandName isEqualToString:MS_CATEGOLY_PARENTREMOVE]) {
		
		//自分宛かどうか、先ず名前で判断
		if (![address isEqualToString:[self getMyName]]) {
			return;
		}
		
		//自分宛かどうか、MSIDで判断
		//宛先MSIDのキーがあるか
		NSString * calledParentMSID = [dict valueForKey:MS_ADDRESS_MSID];
		if (!calledParentMSID) {
			return;
		}
		
		
		//受信時にログに受信記録を付け、保存する
		[self saveLogForReceived:recievedLogDict];
		
		
		//自分の子供辞書にある、子供情報を削除する
		[self removeChildDictChildNameAsValue:senderName withMSIDAsKey:senderMSID];
			
		return;
	}
	
	
}



/**
 自分をParentとして指定してきたChildについて、子供のmyNameとmyMSIDを自分のchildDictに登録する。
 */
- (void) setChildDictChildNameAsValue:(NSString * )senderName withMSIDAsKey:(NSString * )senderMSID {
	
	[[self getChildDict] setValue:senderName forKey:senderMSID];
	
}
/**
 子供からの要請で、childDictから該当の子供情報を削除する
 */
- (void) removeChildDictChildNameAsValue:(NSString * )senderName withMSIDAsKey:(NSString * )senderMSID {
	[[self getChildDict] removeObjectForKey:senderMSID];//無かったらどうしよう、、、
}


/**
 childDictを返す
 */
- (NSMutableDictionary * ) getChildDict {
	return childDict;
}




/**
 tag valueメソッド
 値にnilが入る事、
 システムが使うのと同様のコマンドが入っている事に関しては、注意する。
 */
- (NSDictionary * ) tag:(id)obj_tag val:(id)obj_value {
	NSAssert1(obj_tag,@"obj_tag_%@ is nil",obj_tag);
	NSAssert1(obj_value,@"obj_value_%@ is nil",obj_value);
	
	return [NSDictionary dictionaryWithObject:obj_value forKey:obj_tag];
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
	[dict setValue:[self getMyMSID] forKey:MS_SENDERMSID];
	
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
	
	
	//ログを作成する
	[dict setValue:[self createLogForNew] forKey:MS_LOGDICTIONARY];
	
	
	[self sendPerform:dict];
}


/**
 特定の名前のmessengerへの通信を行うメソッド
 親から子限定
 
 子供辞書を持っており、かつ、nameに該当する子供がいる
 送り先の名称が自分と異なる場合のみ、送る事が出来る
	→同名の子供群まで対象に入れると、メッセージの判別手段にグループの概念を持ち込まなければいけないために存在する制限。
 
 */
- (void) call:(NSString * )name withExec:(NSString * )exec, ... {
	
	NSAssert(![name isEqualToString:[self getMyName]], @"自分自身/同名の子供達へのメッセージブロードキャストをこのメソッドで行う事はできません。　callMyselfメソッドを使用してください");
	NSAssert(![name isEqualToString:PARENTNAME_DEFAULT], @"システムで予約してあるデフォルトの名称です。　この名称を使ってのシステム使用は、その、なんだ、お勧めしません。");
	
	
	//特定のキーが含まれているか
//	[childDict allValues]//NSArray コストは概ね一緒かな。 特定のキーが含まれているか否か、を隠蔽したいか否か
	
	
	//親から子へのブロードキャスト MSIDで送り先を限定しない。
	for (id key in childDict) {
		//NSLog(@"key: %@, value: %@", key, [childDict objectForKey:key]);//この件数分だけ出す必要は無い！　一件出せればいい。特に限定が必要な場合もそう。
		if ([[childDict objectForKey:key] isEqualToString:name]) {//一つでも合致する内容のものがあれば、メッセージを送る対象として見る。
			NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
			
			[dict setValue:MS_CATEGOLY_CALLCHILD forKey:MS_CATEGOLY];
			[dict setValue:name forKey:MS_ADDRESS_NAME];
			
			[dict setValue:exec forKey:MS_EXECUTE];
			[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
			[dict setValue:[self getMyMSID] forKey:MS_SENDERMSID];
			
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
			
			
			//ログを作成する
			[dict setValue:[self createLogForNew] forKey:MS_LOGDICTIONARY];
			
			
			//最終送信を行う
			[self sendPerform:dict];
			return;			
		}
	}
	
	//NSAssert1(false, @"callメソッドに指定したmessengerが存在しないか、未知のものです。本messengerを親とした設定を行うよう、子から親を指定してください。_%@",name);
}


/**
 特定の子への通信を行うメソッド、特にMSIDを使い、相手を最大限特定する。
 */
- (void) callChild:(NSString * )childName withMSID:(NSString * ) withCommand:(NSString * )exec, ... {
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
		[dict setValue:[self getMyParentMSID] forKey:MS_ADDRESS_MSID];
		
		
		[dict setValue:exec forKey:MS_EXECUTE];
		[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
		[dict setValue:[self getMyMSID] forKey:MS_SENDERMSID];
		
		
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
		
		
		
		//送信用ログを作成する
		[dict setValue:[self createLogForNew] forKey:MS_LOGDICTIONARY];
		
		//最終送信を行う
		[self sendPerform:dict];
		return;
	}
	
	NSAssert(false, @"親設定が無い");
}




/**
 パフォーマンス実行を行う
 
 この処理は、出来るだけ独立した要素として分けておく。
 */
- (void) sendPerform:(NSMutableDictionary * )dict {
	//NSLog(@"dict_%@", dict);
	[[NSNotificationCenter defaultCenter] postNotificationName:OBSERVER_ID object:self userInfo:(id)dict];
}





/**
 メッセージ発生時のログ書き込み、ログ初期化
 
 メッセージIDを作成、いろいろな情報をまとめる
 
 */
- (NSDictionary * ) createLogForNew {
	//ログタイプ、タイムスタンプを作成
	//メッセージに対してはメッセージIDひも付きの新規ログをつける事になる。
	//ストアについては、新しいIDのものが出来るとIDの下に保存する。多元木構造になっちゃうなあ。カラムでやった方が良いのかしら？それとも絡み付いたKVSかしら。
	
	
	NSString * messageID = (NSString * )CFUUIDCreateString(nil, CFUUIDCreate(nil));//このメッセージのIDを出力(あとでID認識するため)
	
	
	NSDictionary * newLogDictionary;//ログ内容を初期化する
	newLogDictionary = [NSDictionary dictionaryWithObject:messageID forKey:MS_LOG_MESSAGEID];
	
	//ストアに保存する
	[self saveToLogStore:@"createLogForNew",
	 [self tag:MS_LOG_MESSAGEID val:messageID],
	 nil];
	
	return newLogDictionary;
}



/**
 受け取り時のログ書き込み
 
 受信したメッセージからログを受け取り、
 ログの末尾に含まれているメッセージIDでもって、過去に受け取ったことがあるかどうか判定(未実装)、
 ログストアに保存する。
 */
- (void) saveLogForReceived:(NSDictionary * ) recievedLogDict {
	
	//ログタイプ、タイムスタンプを作成
	NSString * messageID = (NSString * ) [recievedLogDict valueForKey:MS_LOG_MESSAGEID];
	
	//ストアに保存する
	[self saveToLogStore:@"saveLogForReceived",
	 [self tag:MS_LOG_MESSAGEID val:messageID],
	 nil];
	
}



/**
 返信時のログ書き込み
 
 どこからか取得したメッセージIDでもって、
 保存していたログストアからログデータを読み出し、
 最新の「送信しました」記録を行い、
 記録をログ末尾に付け加えたログを返す。
 */
- (NSDictionary * ) createLogForReply {
	//ログタイプ、タイムスタンプを作成
	[logDict setValue:@"仮のmessageID" forKey:MS_LOG_MESSAGEID];
	
	return logDict;
}

/**
 観察用にこのmessengerに書かれているログを取得するメソッド
 */
- (NSDictionary * ) getLogStore {
	
	//ストアの全容量を取り出す
		
	return logDict;
}


/**
 可変長ログストア入力
 アウトプットは後で考えよう。
 */
- (void) saveToLogStore:(NSString * )name, ... {
	
	va_list ap;
	id kvDict;
	
	
	va_start(ap, name);
	kvDict = va_arg(ap, id);
	
	int i = 0;
	
	
	while (kvDict) {
//		NSLog(@"ココに来てる_kvDict_%@", kvDict);
		
		for (id key in kvDict) {
//			NSLog(@"[kvDict valueForKey:key]_%@, key_%@", [kvDict valueForKey:key], key);
			
			[logDict setValue:[NSString stringWithFormat:@"%@ %d %@",name, i, [kvDict valueForKey:key]] forKey:
			 [NSString stringWithFormat:@"%@ %@",[self getUUID], [NSDate date]]];//データオブジェクトだから、IDで精査できる訳だ。同じ時間であっても、ポインタが異なるので問題ない。
			
			i++;
		}
		
		kvDict = va_arg(ap, id);
	}
	va_end(ap);
}





/**
 文字列の数値化
 */
- (int) changeStrToNumber:(NSString * )str {
//	NSLog(@"str_%d", str);
	
	char *myCString = "This is a string.";
	NSValue *theValue = [NSValue value:&myCString withObjCType:@encode(char **)];
	
	NSLog(@"theValue_%@", theValue);
	return -1;//[str cString];
}


/**
 UUIDを作成して返すメソッド
 */
- (NSString * ) getUUID {
	return (NSString * )CFUUIDCreateString(nil, CFUUIDCreate(nil));
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
	myMSID = [self getUUID];
}
/**
 自分のMSIDを返すメソッド
 */
- (NSString * )getMyMSID {
	return myMSID;
}



/**
 myParent関連情報を初期化する
 */
- (void) initMyParentData {
	[self setMyParentName:PARENTNAME_DEFAULT];
	myParentMSID = PARENTMSID_DEFAULT;
}
/**
 親情報をリセットする
 (親のchildDictからも消す)
 */
- (void) resetMyParentData {
	[self removeMyParentData];
	
	[self initMyParentData];//初期化
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
 外部から呼ばれるように設計されている。
 親が複数要るケースは想定し排除してある。
 
 本メソッドは条件を満たした親から起動されるメソッドになっており、自分から呼ぶ事は無い。
 */
- (void) setMyParentMSID:(NSString * )parentMSID {
	if ([[self getMyParentMSID] isEqualToString:PARENTMSID_DEFAULT]) {
		
		[self saveToLogStore:@"setMyParentMSID",
		 [self tag:MS_LOG_LOGTYPE_GOTP val:[self getMyParentName]],
		 nil];
		myParentMSID = parentMSID;
		
		[self decidedParentName:[self getMyParentName] withParentMSID:[self getMyParentMSID]];
	}	
}
/**
 親のMSIDを返すメソッド
 */
- (NSString * )getMyParentMSID {
	return myParentMSID;
}




- (void) dealloc {
	//通信のくびきを切る。
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OBSERVER_ID object:nil];
	
	//本体のID
	myBodyID = nil;
	
	//本体のセレクタ
	myBodySelector = nil;//メッセージ受け取り時に叩かれるセレクタ、最低一つの引数を持つ必要がある。
	
	
	//自分の名前	NSString
	myName = nil;
	
	//自分のID	NSString
	myMSID = nil;
	
	
	//親の名前	NSString
	myParentName = nil;
	
	//親のID		NSString
	myParentMSID = nil;
	
	
	//子供の名前とIDを保存する辞書	NSMutableDictionary
	[childDict removeAllObjects];
//	NSLog(@"解除！_%@, %d", [self getMyName], [childDict retainCount]);
	
    [super dealloc];
}





@end

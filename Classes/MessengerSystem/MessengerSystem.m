//
//  MessengerSystem.m
//  KissakiProject
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "MessengerSystem.h"
#import "MessengerIDGenerator.h"

#define test	(false)
#define logDo	(true)//両方trueで実際に動く、両方falseでテストが動く。

//非同期はfalse falseでしか動かない？
//

@implementation MessengerSystem


/**
 初期化する
 */
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name {
	if (self = [super init]) {
		[self setMyName:name];
		[self setMyBodyID:body_id];
		[self setMyBodySelector:body_selector];
		[self initMyMID];
		[self initMyParentData];
	}
	
	childDict = [NSMutableDictionary dictionaryWithCapacity:1];
	logDict = [NSMutableDictionary dictionaryWithCapacity:1];
	
	//動的にメソッドを足す、という事をすればOKではある、ということは、自分のメソッドを動的にオーバーライドするようにすればいい。中間。
	/**
	 思考デザインしてから行おう。
	 
	 そもそも原因はなんなのか、根本的な理解による簡単な解決法は無いのか。
	 
	 
	 */
	
	if (test)[[NSNotificationCenter defaultCenter] addObserver:myBodyID selector:myBodySelector name:OBSERVER_ID object:nil];//このクラスを持つクラスに対して、フックとなるようにセットする、とか、、
	else [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(innerPerform:) name:OBSERVER_ID object:nil];
	
	
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


/**
 親へと自分が子供である事の通知を行い、返り値として親のMIDを受け取るメソッド
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
	[dict setValue:[self getMyMID] forKey:MS_SENDERMID];
	
	
	[dict setValue:self forKey:MS_SENDERID];
	
	//フック
	//特定のメソッドの実行を命令づける、リタンダンシー設定
	//IMP func = [self methodForSelector:@selector(setMyParentMID:)];
	//(*func)(self,@selector(setMyParentMID:),@"ついた");
	
	//NSInvocationでの実装
	[dict setValue:[self methodSignatureForSelector:@selector(setMyParentMID:)] forKey:MS_RETURN];
	
	
	//ログを作成する
	[self addCreationLog:dict];
	
	//最終送信処理
	[self sendPerform:dict];
	NSLog(@"処理通過");
	
	NSLog(@"[self getMyParentName]_%@", [self getMyParentName]);
	NSAssert1(![[self getMyParentMID] isEqualToString:PARENTMID_DEFAULT], @"指定した親が存在しないようです。parentに指定している名前を確認してください_現在指定されているparentは_%@",[self getMyParentName]);
}

/**
 親が決定した事をお知らせする
 受け取っても行う処理の存在しない、宛先の無いメソッド
 */
- (void) decidedParentName:(NSString * )parentName withParentMID:(NSString * )parentMID {
	
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
	
	[dict setValue:MS_CATEGOLY_GOTPARENT forKey:MS_CATEGOLY];
	
	[dict setValue:[self getMyParentName] forKey:MS_PARENTNAME];
	[dict setValue:[self getMyParentMID] forKey:MS_PARENTMID];
	
	[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
	[dict setValue:[self getMyMID] forKey:MS_SENDERMID];
	
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
	[dict setValue:[self getMyParentMID] forKey:MS_ADDRESS_MID];
	
	[dict setValue:[self getMyName] forKey:MS_SENDERNAME];
	[dict setValue:[self getMyMID] forKey:MS_SENDERMID];
	
	//ログを作成する
	[self addCreationLog:dict];
	
	//最終送信処理
	[self sendPerform:dict];
	
}


/**
 内部実行で先ず呼ばれるメソッド
 自分宛のメッセージでなければ無視する
 */
- (void) innerPerform:(NSNotification * )notification {
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	NSLog(@"内部実装に到達");
	
	
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
		NSLog(@"宛名が無い_%@", commandName);
		return;
	}
	
	
	//ログ関連
	NSMutableDictionary * recievedLogDict = [dict valueForKey:MS_LOGDICTIONARY];
	if (!recievedLogDict) {
//		NSLog(@"ログが無いので受け付けない_%@", commandName);
		return;
	} else {
		//メッセージIDについて確認
//		NSString * messageID = [recievedLogDict valueForKey:MS_LOG_MESSAGEID];
//		if (!messageID) {
//			NSLog(@"メッセージIDが無いため、何の処理も行われずに帰る");
//			return;
//		}		
	}
	
	NSLog(@"内部実装に到達2");
	
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
	

	NSLog(@"内部実装に到達3");
	
	//カテゴリごとの処理に移行
	//クリティカルなケースであっても、ThreadIDで対応できる筈。現在実行中の、Threadからみて未完了の処理とそれをIDする機能、というのが或る筈なんだ。
	
	
	if ([commandName isEqualToString:MS_CATEGOLY_LOCAL]) {
		NSLog(@"内部実装に到達4");
		
		
		if (![senderName isEqualToString:[self getMyName]]) {
			NSLog(@"MS_CATEGOLY_LOCAL 名称が違う_%@", [self getMyName]);
			return;
		}
		
		if (![senderMID isEqualToString:[self getMyMID]]) {//MIDが異なれば処理をしない
			NSLog(@"名前が同様の異なるMIDを持つオブジェクト");
			return;
		}
		
		
		//NSLog(@"%@,	MID_%@,	myName_%@,	childDict_%@, logStore_%@",self, [self getMyMID], [self getMyName], [self getChildDict], [self getLogStore]);
		NSLog(@"内部実装に到達5");
		
		
		[self saveLogForReceived:recievedLogDict];
		
		//設定されたbodyのメソッドを実行
		IMP func = [[self getMyBodyID] methodForSelector:[self getMyBodySelector]];
		(*func)([self getMyBodyID], [self getMyBodySelector], notification);
		
		NSLog(@"内部実装に到達6");
		
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
		if ([senderMID isEqualToString:[self getMyMID]]) {
			NSLog(@"自分が送信者なので無視する_%@", [self getMyMID]);
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
			
			
			
			//親は先着順で設定される。既に子供が自分と同名の親にアクセスし、そのMIDを持っている場合があり得るため、ここで子供の持っている親MIDを確認する必要がある
			if (![[senderID getMyParentMID] isEqualToString:PARENTMID_DEFAULT]) {
				//				NSLog(@"親は先着順で既に設定されているようです");
				return;
			}
			
			//受信時にログに受信記録を付け、保存する
			[self saveLogForReceived:recievedLogDict];
			
			
			//親が居ないと子が生まれない構造。 senderMIDをキーとし、子供辞書を作る。
			[self setChildDictChildNameAsValue:senderName withMIDAsKey:senderMID];
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
			[invocation setSelector:@selector(setMyParentMID:)];//ここに書くメソッド名、直書きしかないのか！？　なんと無意味な。セレクターを持って来れるんだろうか。
			[invocation setTarget:senderID];
			NSString * myMSIDforchild = [self getMyMID];
			[invocation setArgument:&myMSIDforchild atIndex:2];//0,1が埋まっているから固定値,,
			NSLog(@"実行まで行ってるのか");
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
	NSLog(@"素通り");
}



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


/**
 childDictを返す
 */
- (NSMutableDictionary * ) getChildDict {
	return childDict;//確かにぶっ壊れてる。
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
 遅延実行
 tag-Valueと同形式でオプションを挿入するメソッド
 */
- (NSDictionary * ) withDelay:(float)delay {
	NSAssert1(delay,@"obj_value_%@ is nil",delay);
	return [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:delay] forKey:MS_DELAY];
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
	NSAssert(![childName isEqualToString:PARENTNAME_DEFAULT], @"システムで予約してあるデフォルトの名称です。　この名称を使ってのシステム使用は、その、なんだ、お勧めしません。");
	
	
	//特定のキーが含まれているか
//	[childDict allValues]//NSArray コストは概ね一緒かな。 特定のキーが含まれているか否か、を隠蔽したいか否か
	
	NSLog(@"子供辞書の問題、Mutableから変えればいいのかな。。。うーーん。");
	//親から子へのブロードキャスト MIDで送り先を限定しない。
	for (id key in [self getChildDict]) {//この時点か、この中なのか。
		//NSLog(@"key: %@, value: %@", key, [childDict objectForKey:key]);//この件数分だけ出す必要は無い！　一件出せればいい。特に限定が必要な場合もそう。
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




/**
 パフォーマンス実行を行う
 
 この処理は、出来るだけ独立した要素として分けておく。
 */
- (void) sendPerform:(NSMutableDictionary * )dict {
//	NSLog(@"dict_%@", dict);
	NSLog(@"sendPerform");
	[[NSNotificationCenter defaultCenter] postNotificationName:OBSERVER_ID object:nil userInfo:(id)dict];
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
	[self saveToLogStore:@"createLogForNew" log:[self tag:MS_LOG_MESSAGEID val:messageID]];
	
	
	[dict setValue:messageID forKey:MS_LOGDICTIONARY];//ちょっと内容を変えてる。そのままログをセットする。ただし、キーはメッセージIDではない。
//	NSDictionary * newLogDictionary;//ログ内容を初期化する
//	newLogDictionary = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", messageID] forKey:MS_LOG_MESSAGEID];

}



/**
 受け取り時のログ書き込み
 
 受信したメッセージからログを受け取り、
 ログの末尾に含まれているメッセージIDでもって、過去に受け取ったことがあるかどうか判定(未実装)、
 ログストアに保存する。
 */
- (void) saveLogForReceived:(NSMutableDictionary * ) recievedLogDict {
	
//	//ログタイプ、タイムスタンプを作成
//	NSString * messageID = (NSString * )[recievedLogDict valueForKey:MS_LOG_MESSAGEID];//原因がこれ。まあ取り除いたもんね。
//	
//	//ストアに保存する
//	[self saveToLogStore:@"saveLogForReceived" log:[self tag:MS_LOG_MESSAGEID val:messageID]];
	[self saveToLogStore:@"saveLogForReceived" log:[self tag:MS_LOG_MESSAGEID val:@"仮ID"]];
}



/**
 返信時のログ書き込み
 
 どこからか取得したメッセージIDでもって、
 保存していたログストアからログデータを読み出し、
 最新の「送信しました」記録を行い、
 記録をログ末尾に付け加えたログを返す。
 */
- (NSMutableDictionary * ) createLogForReply {
	//ログタイプ、タイムスタンプを作成
	[logDict setValue:@"仮のmessageID" forKey:MS_LOG_MESSAGEID];
	
	return logDict;
}

/**
 観察用にこのmessengerに書かれているログを取得するメソッド
 */
- (NSMutableDictionary * ) getLogStore {
	
	//ストアの全容量を取り出す
		
	return logDict;
}


/**
 可変長ログストア入力
 アウトプットは後で考えよう。
 */
- (void) saveToLogStore:(NSString * )name log:(NSDictionary * )value {
	NSLog(@"saveToLogStore_到達_%@", [self getMyName]);
	if (logDo) return;
	NSArray * key = [value allKeys];//1件しか無い内容を取得する
	//非同期にすると処理に失敗して落ちるみたいね。 logDictの整合性が無い？
	@try {
		NSLog(@"到着、ココから先で落ちる、、かと思ったのだが、落ちないね。");
	[logDict setValue:
	 [NSString stringWithFormat:@"%@ %@", name, [value valueForKey:[key objectAtIndex:0]]] 
			   forKey:
	 [NSString stringWithFormat:@"%@ %@", [MessengerIDGenerator getMID], [NSDate date]]
	 ];
		NSLog(@"完了、エラーで無かった");
	}
	
	@catch (NSError * e) {
		NSLog(@"error_%@", e);
	}
	
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
- (int) getExecAsInt:(NSMutableDictionary * )dict {
	return [self changeStrToNumber:[dict valueForKey:MS_EXECUTE]];
}

/**
 NSStringからhash値を出す
 */
- (int) equalToExec:(NSString * )exec {
	return [self changeStrToNumber:exec];
}


#define MULLE_ELF_STEP(B)	 do { ret=(ret<<4)+B; ret^=(ret>>24)&0xF0; } while(0)//ビットシフトしつつ文字列を数値に変換する。

/**
 文字列の数値化
 */
- (int) changeStrToNumber:(NSString * )str {
	
	
	const char * bytes = [str UTF8String];
	unsigned int length = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	
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
 自分のMIDを初期化するメソッド
 */
- (void)initMyMID {
	myMID = [MessengerIDGenerator getMID];
}
/**
 自分のMIDを返すメソッド
 */
- (NSString * )getMyMID {
	NSLog(@"この辺で来てる_%@", myMID);
	return myMID;
}



/**
 myParent関連情報を初期化する
 */
- (void) initMyParentData {
	[self setMyParentName:PARENTNAME_DEFAULT];
	myParentMID = PARENTMID_DEFAULT;
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
 自分から見た親のMIDをセットするメソッド
 外部から呼ばれるように設計されている。
 親が複数要るケースは想定し排除してある。
 
 本メソッドは条件を満たした親から起動されるメソッドになっており、自分から呼ぶ事は無い。
 */
- (void) setMyParentMID:(NSString * )parentMID {
	if ([[self getMyParentMID] isEqualToString:PARENTMID_DEFAULT]) {
		
		[self saveToLogStore:@"setMyParentMID" log:[self tag:MS_LOG_LOGTYPE_GOTP val:[self getMyParentName]]];
		
		
		myParentMID = parentMID;
		
		[self decidedParentName:[self getMyParentName] withParentMID:[self getMyParentMID]];
	}	
}
/**
 親のMIDを返すメソッド
 */
- (NSString * )getMyParentMID {
	return myParentMID;
}




- (void) dealloc {
	//通信のくびきを切る。
	if (test) [[NSNotificationCenter defaultCenter] removeObserver:[self getMyBodyID] name:OBSERVER_ID object:nil];
	else [[NSNotificationCenter defaultCenter] removeObserver:self name:OBSERVER_ID object:nil];//自分自身でセットしてるから、そりゃ落ちるわな。
	
	//本体のID
	myBodyID = nil;
	
	//本体のセレクタ
	myBodySelector = nil;//メッセージ受け取り時に叩かれるセレクタ、最低一つの引数を持つ必要がある。
	
	
	//自分の名前	NSString
	myName = nil;
	
	//自分のID	NSString
	myMID = nil;
	
	
	//親の名前	NSString
	myParentName = nil;
	
	//親のID		NSString
	myParentMID = nil;
	
	
	//子供の名前とIDを保存する辞書	NSMutableDictionary
	[childDict removeAllObjects];
//	NSLog(@"解除！_%@, %d", [self getMyName], [childDict retainCount]);
	
	[logDict removeAllObjects];
	
	
    [super dealloc];
}





@end

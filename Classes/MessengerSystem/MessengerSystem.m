//
//  MessengerSystem.m
//  KissakiProject
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "MessengerSystem.h"
#include <stdio.h>

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
		
		childDict = [NSMutableDictionary dictionaryWithCapacity:1];
		[self changeStrToNumber:[self getMyMSID]];
		
		//NSLog(@"childDict_%@,count_%d", childDict, [childDict retainCount]);
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(innerPerform:) name:OBSERVER_ID object:nil];
	}
	return self;
}



/**
 親へと自分が子供である事の通知を行い、返り値として親のMSIDを受け取るメソッド
 受け取り用のメソッドの情報を親へと渡し、親からの入力をダイレクトに受ける。
 */
- (void) inputToMyParentWithName:(NSString * )parent {
	
	//親の名前を設定
	NSLog(@"インプットするんだぜ_%@,	now_%@", parent, [self getMyParentName]);
	[self setMyParentName:parent];
	
	
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:1];
	
	[dict setValue:COMMAND_PARENTSEARCH forKey:MS_COMMAND];
	
	[dict setValue:[self getMyParentName] forKey:MS_PARENTNAME];
	
	
	//この部分、ログ用としてまとめる事が出来そうだ。それ用のキーにしよう。
	[dict setValue:[self getMyName] forKey:MS_LOG_SENDERNAME];
	[dict setValue:[self getMyMSID] forKey:MS_LOG_SENDERMSID];
	
	
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
	
	
	
	//NSLog(@"commandName_%@", commandName);
	
	NSDictionary * logDict = [dict valueForKey:MS_LOGDICTIONARY];
	//ログ関連
	if (!logDict) {
		
		//ログが不完全系
		//メッセージID(この時作成)、	タイプ(new)、	コマンド名、タイムスタンプ、送信者ID、送信者名
		
		
		NSString * senderName = [logDict valueForKey:MS_LOG_SENDERNAME];
		if (!senderName) {//送信者不詳であれば無視する
			NSLog(@"送信者NAME不詳");
			return;
		}
		
		
		NSString * senderMSID = [logDict valueForKey:MS_LOG_SENDERMSID];
		if (!senderMSID) {//送信者不詳であれば無視する
			NSLog(@"送信者ID不詳");
			return;
		}
		
		
	}
	
	
	
	
	//親探索のサーチが届いた
	if ([commandName isEqualToString:COMMAND_PARENTSEARCH]) {
		NSLog(@"サーチへの受け取り完了");
		//送信者が自分であれば無視する
		if ([[logDict valueForKey:MS_LOG_SENDERMSID] isEqualToString:[self getMyMSID]]) {
//			NSLog(@"自分が送信者なので無視する_%@", [self getMyMSID]);
			return;
		}
		
		
		NSString * calledParentName = [dict valueForKey:MS_PARENTNAME];
		if (!calledParentName) {
			
			return;//値が無ければ無視する
		}
		
		NSLog(@"自分以外の誰かが、parentを求めて通信してきている。_%@", calledParentName);
		if ([calledParentName isEqualToString:[self getMyName]]) {//それが自分だったら
			
			id senderID = [dict valueForKey:MS_LOG_SENDERID];
			if (!senderID) {
//				NSLog(@"senderID(送信者のselfポインタ)が無い");
				return;
			}
			
			NSLog(@"自分に対して子供から親になる宣言をされた、辞書作成直前");
			//親が居ないと子が生まれない構造。 senderMSIDをキーとし、子供辞書を作る。
			[self setChildDictChildNameAsValue:senderName withMSIDAsKey:senderMSID];
			NSLog(@"辞書作成まで完了");
			
			//送り届けられたメソッドを使い、Child宛に登録した旨の返答を行う。
			id signature;
			id invocation;
			
			signature = [dict valueForKey:MS_RETURN];
//			NSLog(@"signature_%@", signature);
			
			invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:@selector(setMyParentMSID:)];//ここは直書きしかないのか！？　じゃあ意味なくね？ 特にselectorだけ渡すとかしないといけないのか？
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
	
	
	
	
	//特定の相手に向けてのコールを受け取った
	if ([commandName isEqualToString:COMMAND_CALLED]) {//自分か、子供に送る。
		
		NSString * address = [dict valueForKey:MS_ADDRESS];
		
		//宛名が無い
		if (!address) {
			NSLog(@"宛名が無い");
			return;
		}
		
		//宛名が自分の事でなかったら帰る
		if (![address isEqualToString:[self getMyName]]) {
			NSLog(@"自分宛ではないので却下_From_%@,	To_%@,	Iam_%@", senderName, address, [self getMyName]);
			return;
		}
		
		
		
		//設定されたbodyのメソッドを実行
		IMP func = [[self getMyBodyID] methodForSelector:[self getMyBodySelector]];
		(*func)([self getMyBodyID], [self getMyBodySelector], notification);
		NSLog(@"bodyメソッドの実行を完了");
		
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
 特定の名前のmessengerへの通信を行うメソッド
 */
- (void) call:(NSString * )name withExec:(NSString * )exec, ... {
	//キーに対応する物があれば、IDを問わずに送り出す。コマンドは適当な文字列。
	
	if ([name isEqualToString:[self getMyName]]) {//自分自身に対する物は最優先で処理
		
		NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
		
		[dict setValue:COMMAND_CALLED forKey:MS_COMMAND];
		[dict setValue:name forKey:MS_ADDRESS];
		[dict setValue:exec forKey:MS_EXECUTE];
		
		[dict setValue:[self getMyName] forKey:MS_LOG_SENDERNAME];
		[dict setValue:[self getMyMSID] forKey:MS_LOG_SENDERMSID];
		
		
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

		
		[self sendPerform:dict];
		return;
	}
	
	
	//子供辞書が存在するか否か、で分かれる。
	for (id key in childDict) {
		//NSLog(@"key: %@, value: %@", key, [childDict objectForKey:key]);//この件数分だけ出す必要は無い！　一件出せればいい。特に限定が必要な場合もそう。
		if ([[childDict objectForKey:key] isEqualToString:name]) {//一つでも合致する内容のものがあれば、メッセージを送る対象として見る。
			NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
			
			[dict setValue:COMMAND_CALLED forKey:MS_COMMAND];
			[dict setValue:name forKey:MS_ADDRESS];
			[dict setValue:exec forKey:MS_EXECUTE];
			
			[dict setValue:[self getMyName] forKey:MS_LOG_SENDERNAME];
			[dict setValue:[self getMyMSID] forKey:MS_LOG_SENDERMSID];
			
			
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
			
			
			//最終送信を行う
			[self sendPerform:dict];
			return;			
		}
	}
	
	NSAssert1(false, @"callメソッドに指定したmessenger名称が存在しないか、未知のものです。本messengerを親とした設定を行うよう、子から親を指定してください。_%@",name);
}


/**
 特定の子への通信を行うメソッド、特にMSIDを使い、相手を最大限特定する。
 */
- (void) callChild:(NSString * )childName withMSID:(NSString * ) withCommand:(NSString * )exec, ... {
	
}



/**
 親への通信を行うメソッド
 */
- (void) callParent:(NSString * )exec, ... {
	
	//親が居たら
	if ([self getMyParentName]) {
		NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:5];
		
		
		[dict setValue:COMMAND_CALLED forKey:MS_COMMAND];
		[dict setValue:[self getMyParentName] forKey:MS_ADDRESS];
		[dict setValue:exec forKey:MS_EXECUTE];
		
		[dict setValue:[self getMyName] forKey:MS_LOG_SENDERNAME];
		[dict setValue:[self getMyMSID] forKey:MS_LOG_SENDERMSID];
		
		
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
				//型チェック、kvDict型で無ければ無視する
				if (true) [dict setValue:[kvDict valueForKey:key] forKey:key];
			
			}
			
			kvDict = va_arg(vp, id);//次の値を読み出す
		}
		
		va_end(vp);//終了処理
		
		
		//最終送信を行う
		[self sendPerform:dict];
		return;			
		
	}
	
}



/**
 パフォーマンス実行を行う
 */
- (void) sendPerform:(NSMutableDictionary * )dict {
	//NSLog(@"dict_%@", dict);
	[[NSNotificationCenter defaultCenter] postNotificationName:OBSERVER_ID object:self userInfo:(id)dict];
}





/**
 文字列の数値化
 文字列を分解するとき、あるルールに乗っ取って数値化ができる
 
 のだが、同じ数字なのに振れ幅が凄くでかいぞ。
 数値化自体は問題ないと思うのだけれど。
 
 ポインタかなあ。
 この機能は使えない。
 行頭にアルファベットをつける事で強制的に変化させられるが、それだと安定しない。
 
 →NSStringだと、安定するようだ。
 っていうか一定だし。無理。
 
 */
- (int) changeStrToNumber:(NSString * )str {
	
	//NSLog(@"changeStrToNumber/str_%@", str);
	
//	char  tokenstring[] = "6C57C707-EDE5-4CCB-9211-975EDCBEA470";//6
//	char  tokenstring[] = "5D921305-EAB6-48A5-BF39-F233634D39EB";//5
//	char  tokenstring[] = "AC57C707-EDE5-4CCB-9211-975EDCBEA470";//5404244
//	char  tokenstring[] = "AC57C707-EDE5-4CCB-9211-9AAAAAAAAAA0";//13956720	//なぜ変化する？ メモリかなにかに依存してるっぽいな。。
	char  tokenstring[] = "AC57C707-EDE5-4CCB-9211-9AAAAAAAAAA0";//13834016

//	NSString * tokenstring = @"AC57C707-EDE5-4CCB-9211-9AAAAAAAAAA0";//-1073775176
//	NSString * tokenstring = @"asaAC57C707ndflkhaiosdfAAAAA0";//

//	NSInteger * i;
	int i;
	sscanf(tokenstring, "%d", &i);//INT値に変換する(大文字小文字、数字全て)
	
	NSLog(@"Integer:  = %d", i );
	//NSAssert1(false,@"integer____%d\n",i);
	
	return -1;
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
	myParentMSID = parentMSID;
}
/**
 親のMSIDを返すメソッド
 */
- (NSString * )getMyParentMSID {
	return myParentMSID;
}



- (void)dealloc {
	//通信のくびきを切る。
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OBSERVER_ID object:nil];
	
//	//本体のID
//	myBodyID = nil;
//	
//	//本体のセレクタ
//	myBodySelector = nil;//メッセージ受け取り時に叩かれるセレクタ、最低一つの引数を持つ必要がある。
//	
//	
//	//自分の名前	NSString
//	myName = nil;
//	
//	//自分のID	NSString
//	myMSID = nil;
//	
//	
//	//親の名前	NSString
//	myParentName = nil;
//	
//	//親のID		NSString
//	myParentMSID = nil;
	
	
	//子供の名前とIDを保存する辞書	NSMutableDictionary
	//うーーーーーん、やるとテストに通らなくなる、なぜ？
//	[childDict removeAllObjects];
//	NSLog(@"解除！_%@, %d", [self getMyName], [childDict retainCount]);
//	[childDict release];
	
    [super dealloc];
}





@end

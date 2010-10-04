//
//  MessengerViewController.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/09/12.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "MessengerViewController.h"
#import "MessengerIDGenerator.h"

//#define NSLog( m, args... )

@implementation MessengerViewController
//上書きしなければいけないのは、初期化メソッドと、実行時のメソッド
//このビューメッセンジャー自身の生き死にを記録してはいけないので、自分の存在についての言及は意図的に避ける。

/**
 使用禁止の初期化メソッド
 */
- (id) initWithBodyID:(id)body_id withSelector:(SEL)body_selector withName:(NSString * )name {
	NSAssert(false, @"initWithFrameメソッドを使用してください");
	
	if (self = [super init]) {
	}
	
	return self;
}

/**
 初期化メソッド
 */
- (id) initWithFrame:(CGRect)frame {
	if (self = [super init]) {
		
		messengerInterfaceView = [[MessengerDisplayView alloc] initWithMessengerDisplayFrame:frame];
		
		[self setMyName:VIEW_NAME_DEFAULT];
		[self setMyBodyID:nil];
		[self setMyBodySelector:nil];
		[self initMyMID];
		[self initMyParentData];
		
		m_buttonList = [[NSMutableDictionary alloc] init];
		m_messengerList = [[NSMutableDictionary alloc] init];
		
		m_nameIndexDictionary = [[NSMutableDictionary alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(innerPerform:) name:OBSERVER_ID object:nil];
		
	}
	
	return self;
}


/**
 内部処理実装
 オーバーライドし、実行内容を限定する
 */
- (void) innerPerform:(NSNotification * )notification {
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	
	
	//コマンド名について確認
	NSString * commandName = [dict valueForKey:MS_CATEGOLY];
	if (!commandName) {
//		NSLog(@"コマンドが無いため、何の処理も行われずに帰る");
		return;
	}
	
	//送信者名
	NSString * senderName = [dict valueForKey:MS_SENDERNAME];
	if (!senderName) {//送信者不詳であれば無視する
//		NSLog(@"送信者NAME不詳");
		return;
	}
	
	//送信者MID
	NSString * senderMID = [dict valueForKey:MS_SENDERMID];
	if (!senderMID) {//送信者不詳であれば無視する
//		NSLog(@"送信者ID不詳");
		return;
	}
	
	
	//宛名、ログは確認しない。
	
	
	//生成
	if ([commandName isEqualToString:MS_NOTICE_CREATED]) {
		[self insertMessengerInformation:senderName withMID:senderMID];
		return;
	}
	
	//更新
	if ([commandName isEqualToString:MS_NOTICE_UPDATE]) {
		
		NSString * sendersParentName = [dict valueForKey:MS_PARENTNAME];
		if (!sendersParentName) {//送信者の親Name不詳であれば無視する
//			NSLog(@"送信者親Name不詳");
			return;
		}

		NSString * sendersParentMID = [dict valueForKey:MS_PARENTMID];
		if (!sendersParentMID) {//送信者の親MID不詳であれば無視する
//			NSLog(@"送信者親MID不詳");
			return;
		}
		
		
		[self updateParentInformation:senderName withMID:senderMID withParentName:sendersParentName withParentMID:sendersParentMID];
		
		return;
	}
	
	
	//自死
	if ([commandName isEqualToString:MS_NOTICE_DEATH]) {
//		NSLog(@"MS_NOTICE_DEATH_到着_%@, MID_%@", senderName, senderMID);
		[self deleteMessengerInformation:senderName withMID:senderMID];
		return;
	}
	
	
	
	
	

//	//その他、認識するが何もしないメソッド
//	
//	if ([commandName isEqualToString:MS_CATEGOLY_REMOVE_PARENT]) {
//		//親設定の解除コマンドを判断
//		return;
//	}
//	
//	
//	if ([commandName isEqualToString:MS_CATEGOLY_REMOVE_CHILD]) {
//		//子供設定の解除コマンドを判断
//		return;
//	}
//	
//	
//	if ([commandName isEqualToString:MS_CATEGOLY_CALLCHILD]) {
//		//親から子の関係性成立済み情報が載っている
//		return;
//	}
//		 
//	if ([commandName isEqualToString:MS_CATEGOLY_CALLPARENT]) {
//		//子から親の関係性成立済み情報が載っている
//		return;
//	}
//	
//	if ([commandName isEqualToString:MS_CATEGOLY_LOCAL]) {
//		//だれかからだれか自身へのメッセージ
//		return;
//	}
//	
//	if ([commandName isEqualToString:MS_CATEGOLY_PARENTSEARCH]) {
//		//親決定のメソッド
//		return;
//	}
//	
//	NSAssert(FALSE, @"MessengeViewController　innerPerformの終端_%@", commandName);
}


/**
 メッセンジャーの誕生をビューに反映する
 */
- (void) insertMessengerInformation:(NSString * )senderName 
							withMID:(NSString * )senderMID {
	
	
	//Messengerをアイデンティファイするキーを作成
	NSString * newKey = [self getMessengerInformationKey:senderName withMID:senderMID];
	
	if ([newKey isEqualToString:[self getMessengerInformationKey:MS_DEFAULT_PARENTNAME withMID:MS_DEFAULT_PARENTMID]]) {
//		NSLog(@"入力しようとした要素がデフォルト値なので消える");
		return;
	}
	
	//既に存在している場合は無視する
	for (id key in [self getMessengerList]) {
		if ([key isEqualToString:newKey]) {
			NSAssert(FALSE, @"二度生まれてる？");
			return;
		}
	}
	
	
	//ビュー、辞書に要素を加える
	UIButton * newButton;
	newButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50., 50.)] autorelease];//[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	
	[newButton setHidden:FALSE];
	
	
	
	//ここで、ボタンの仮位置を作成
	int x = [[self getButtonList] count]*30+(rand()%100);
	int y = [[self getButtonList] count]*30+(rand()%100);
	
	CGPoint point = CGPointMake(0+x, 120+y);
	[newButton setFrame:CGRectMake(point.x, point.y, newButton.frame.size.width, newButton.frame.size.height)];
	
	[newButton setBackgroundColor:[UIColor colorWithRed:10.6 green:10 blue:1 alpha:0.01]];//一応範囲付け、かなあ。
	[newButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
	
	
	[[self getButtonList] setValue:newButton forKey:newKey];//ボタン自体を保存、座標もここに含まれる
	
	//新規インスタンスなので、親設定は無い。自分自身から親への関係性を保存する。
	[[self getMessengerList] setValue:[self getMessengerInformationKey:MS_DEFAULT_PARENTNAME withMID:MS_DEFAULT_PARENTMID] forKey:newKey];
	
	
	[messengerInterfaceView addSubview:newButton];//ビューに加える
	
	[self drawDataUpdate];
}
/**
 通信してきた対象の情報がアップデートされ、親情報が変更された
 
 正確に更新が行われていれば、線が残るような事は発生しない筈。
 */
- (void) updateParentInformation:(NSString * )senderName 
						withMID:(NSString * )senderMID 
				  withParentName:(NSString * )sendersParentName 
				  withParentMID:(NSString * )sendersParentMID {
	
	//すでに存在している筈
	NSString * myKey = [self getMessengerInformationKey:senderName withMID:senderMID];
	
	
	//既に存在している場合のみ対応
	for (id key in [self getMessengerList]) {
		if ([key isEqualToString:myKey]) {
			
			[[self getMessengerList] setValue:[self getMessengerInformationKey:sendersParentName withMID:sendersParentMID] forKey:key];
			
			
			//親が存在しているかどうかのチェック
			NSString * myParentKey = [self getMessengerInformationKey:sendersParentName withMID:sendersParentMID];
			for (id key in [self getMessengerList]) {
				if ([key isEqualToString:myParentKey]) {
					
					[self drawDataUpdate];
					return;
				}
			}
			
			
			//ここまで通過しているということは、親キーがまだリスト内に存在しない
			[self insertMessengerInformation:sendersParentName withMID:sendersParentMID];//追加する。
			
			[self drawDataUpdate];
			return;
		}
	}
	
	
	
	NSAssert1(FALSE, @"updateParentInformation_一度も生まれてない_%@", myKey);
}

/**
 メッセンジャーの削除をビューに反映する
 */
- (void) deleteMessengerInformation:(NSString * )senderName 
							withMID:(NSString * )senderMID {
	
	//Messengerをアイデンティファイするキーを作成
	NSString * removeKey = [self getMessengerInformationKey:senderName withMID:senderMID];
	
	if (![[self getMessengerList] valueForKey:removeKey]) {
		
//		NSLog(@"messengerList_%@", [self getMessengerList]);
//		NSLog(@"removeKey_%@", removeKey);
		NSAssert(FALSE, @"deleteMessengerInformation_一度も生まれていない");
	}
	
	[[[self getButtonList] valueForKey:removeKey] removeFromSuperview];//ビューから外す
	[[self getButtonList] removeObjectForKey:removeKey];
	[[self getMessengerList] removeObjectForKey:removeKey];//登録抹消
	
	[self drawDataUpdate];
//	NSLog(@"登録抹消が行われた_%@", removeKey);
}


/**
 ドローデータの更新
 */
- (void) drawDataUpdate {

//	ボタンリストを実体として渡し、
//	ラインを引く座標リストをボタンと同じキーで渡せれば上々。
	
	
	//ボタンの位置をソートする。
	[self setNameIndexDictionary];
	
	//キーに指定された要素が親子を持っていればソートする
	[self sortButtonsByParentOrder];
	
	
	
	//子供　対　親なので、ポイントに換算して置ける筈。

	
	NSMutableDictionary * m_connectionList = [[[NSMutableDictionary alloc] init] autorelease];
	
	
	
	for (id key in [self getMessengerList]) {//キーは全インスタンス、バリューはインスタンスに対するボタン
		
		//親の関係性の値がデフォルトでない場合のみ、線を引く大本のデータとして扱う。
		if (![[[self getMessengerList] valueForKey:key] isEqualToString:[self getMessengerInformationKey:MS_DEFAULT_PARENTNAME withMID:MS_DEFAULT_PARENTMID]]) {//接続先が存在するキー
			//ボタンの位置から位置に対して線が引ければそれでいいんだけど、なんか引く方向とか考えておくといい事がある気がする。
			//from to　みたいな形で、CGPointが持てればいいのかな。
			//同じキーでつれるボタン辞書の内容がある
			UIButton * sButton = [[self getButtonList] valueForKey:key];//始点
			NSAssert(sButton, @"始点ボタンが無い");
//			NSLog(@"始点ボタン_%@", sButton);
			
			UIButton * eButton = [[self getButtonList] valueForKey:[[self getMessengerList] valueForKey:key]];//終点
			NSAssert(eButton, @"終点ボタンが無い");
//			NSLog(@"終点ボタン_%@", eButton);
			
			//子から親にラインを引く用に点を出す
			NSArray * positionArray = [[[NSArray alloc] initWithObjects:
									   [NSNumber numberWithFloat:sButton.center.x],//startX
									   [NSNumber numberWithFloat:sButton.center.y],//startY
									   [NSNumber numberWithFloat:eButton.center.x],//endX
									   [NSNumber numberWithFloat:eButton.center.y],//endY
									   nil] autorelease];
			
			
			
			[m_connectionList setValue:positionArray forKey:key];
		}
	}
	
	
	[self setNumberOfRelationship:[m_connectionList count]];
	
	[messengerInterfaceView updateDrawList:[self getButtonList] andConnectionList:m_connectionList];//ボタン座標データをビューの描画リストにセットする
}



/**
 関係性の本数を返すメソッド
 */
- (void) setNumberOfRelationship:(int)number {
	m_numberOfRelationship = number;
}

- (int) getNumberOfRelationship {
	return m_numberOfRelationship;
}


/**
 表示補助用のインデックス　X軸カウント
 */
- (void) setNameIndexDictionary {
	//存在するリストから、後半MID分以外が一致していれば、という努力をしようか。
	//messengerListからMIDをのぞいた文字数のキーを取得し、ソートする。E2FD8F50-F6E9-42F6-8949-E7DD20312CA0
	
	[m_nameIndexDictionary removeAllObjects];
	
	NSArray * array = [[self getMessengerList] allKeys];
	
	int index = 0;
	
	
	for (int i = 0; i < [array count]; i++) {
		NSString * nameKey = (NSString * )[array objectAtIndex:i];
		nameKey = [nameKey substringToIndex:[nameKey length]-([[MessengerIDGenerator getMID] length]+1)];
		
		if ([m_nameIndexDictionary valueForKey:nameKey]) {
			//すでにあるので何もしない
		} else {
			[m_nameIndexDictionary setValue:[NSNumber numberWithInt:index] forKey:nameKey];//要素を足す、検出順に連番
			index++;
		}
	}
	
}
- (NSMutableDictionary * ) getNameIndexDictionary {
	return m_nameIndexDictionary;
}



/**
 一番左からソートをかける
 親子関係のラインから、キーに入っているオブジェクトに重み付け、m_nameIndexDictionary 内のX軸カウントを先頭に持っていく
 */
- (void) sortButtonsByParentOrder {
	
//	NSLog(@"m_nameIndexDictionary_before_%@", m_nameIndexDictionary);
	
	
	NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:m_nameIndexDictionary];
	
	//親子関係のキーを取得し、バリューである子供よりも左(=最終的に小さな値)にあるようにする。
	for (id key in [self getMessengerList]) {//キーは全インスタンス、バリューはインスタンスに対するボタン
		NSString * parentKey = [[self getMessengerList] valueForKey:key];
		
		//親の関係性の値がデフォルトでない場合のみ、親子関係が存在するとして、線を引く大本のデータとして扱う。
		if (![parentKey isEqualToString:[self getMessengerInformationKey:MS_DEFAULT_PARENTNAME withMID:MS_DEFAULT_PARENTMID]]) {//接続先が存在するキー
			
			//親にあたるインスタンスの名称をX by m_nameIndexDictionary,Y by m_nameNumberDictionaryから探し、調整する。
			//キー名に該当するオブジェクトを読み出す。
			NSString * indexKey = [key substringToIndex:[key length]-([[MessengerIDGenerator getMID] length]+1)];
			NSString * parentIndexKey = [parentKey substringToIndex:[parentKey length]-([[MessengerIDGenerator getMID] length]+1)];

			
			int n = [[m_nameIndexDictionary valueForKey:parentIndexKey] intValue];
			int m = [[m_nameIndexDictionary valueForKey:indexKey] intValue];
			
			
			
			if (n < m) {
				//何もしない
			}
			
			if (n == m) {
				NSAssert(FALSE, @"システム的に間違えた。");
			}
			
			if (m < n) {
				//子供〜親の間を+1し、親を下げる。 3が2の親だったとすると、
				//123456
				//134456
				//143456
				//123456
				
				for (id numberKey in dict) {
					if ([dict valueForKey:numberKey]) {
						int now = -1;
						now = [[dict valueForKey:numberKey] intValue];
						
						if (m <= now && now < n) {
							int changed = now+1;
							[m_nameIndexDictionary setValue:[NSNumber numberWithInt:changed] forKey:numberKey];//fastEnum中で値変えられたかな。。
						}
					}
				}
				
				
				
				//keyが親の物を、インデックス特定に持っていく
				[m_nameIndexDictionary setValue:[NSNumber numberWithInt:m] forKey:parentIndexKey];
				
			}
		}
	}
	
	
	
	[dict removeAllObjects];
	[dict release];
	
//	NSLog(@"m_nameIndexDictionary_after_%@", m_nameIndexDictionary);
	
	
	//インデックスに対して、画面上の位置を調整する。
	for (id key in [self getMessengerList]) {
		
		NSString * shortKey = [key substringToIndex:[key length]-([[MessengerIDGenerator getMID] length]+1)];
		
		//Xについて、補正する。
		for (id key2 in m_nameIndexDictionary) {
			//key2がm_nameIndexDictionaryの要素なのだが、これが一致する組み合わせを含んでいれば。結構もったいないかな。
			if ([key2 isEqualToString:shortKey]) {
				UIButton * sButton = [[self getButtonList] valueForKey:key];
				[sButton setFrame:CGRectMake([[m_nameIndexDictionary valueForKey:key2] intValue]*INTERVAL_WIDTH+OFFSET_X, sButton.frame.origin.y, sButton.frame.size.width, sButton.frame.size.height)];//Xを係数に合わせて指定する
			}
		}
	}
	
	
	
	
	//数に対して、画面上の位置を調整する。
	for (id key in m_nameIndexDictionary) {//ボタンの名称：存在数
		
		int index = 0;
		for (id key2 in [self getMessengerList]) {
			NSString * shortKey = [key2 substringToIndex:[key2 length]-([[MessengerIDGenerator getMID] length]+1)];
			
			if ([key isEqualToString:shortKey]) {//存在数だけ、回数がまわる筈。
				UIButton * sButton = [[self getButtonList] valueForKey:key2];
				[sButton setFrame:CGRectMake(sButton.frame.origin.x, index*INTERVAL_HEIGHT+OFFSET_Y, sButton.frame.size.width, sButton.frame.size.height)];//Xを係数に合わせて指定する
				index++;
			}
			
		}
	}
	
	
}



/**
 ボタンが押された時のメソッド
 */
- (void) tapped:(UIControlEvents * )event {
	
	//この座標を画面の中心にするように、全インターフェースの座標を置き換える、とか。
	
	NSLog(@"到達_%@", event);
}



/**
 NameとMIDのペアを作るメソッド
 */
- (NSString * ) getMessengerInformationKey:(NSString * )name withMID:(NSString * )MID {
	return [NSString stringWithFormat:@"%@:%@", name, MID];
}


/**
 ボタン用の辞書を取得する
 */
- (NSMutableDictionary * ) getButtonList {
	return m_buttonList;
}

/**
 View用の辞書を取得する
 */
- (NSMutableDictionary * ) getMessengerList {
	return m_messengerList;
}



/**
 Viewを外部に返す
 */
- (UIView * ) getMessengerInterfaceView {
	return messengerInterfaceView;
}




//自前実装のセッターメソッド　プログラム本体ではプライベートカテゴリに実装してある
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
 親の名称をセットするメソッド
 */
- (void) setMyParentName:(NSString * )parent {
	myParentName = parent;
}


//オーバーライドするメソッド、特に何もさせない。
- (void) inputParent:(NSString * )parent {}
- (void) callMyself:(NSString * )exec, ...{}
- (void) call:(NSString * )name withExec:(NSString * )exec, ...{}
- (void) callChild:(NSString * )childName withMID:(NSString * ) withCommand:(NSString * )exec, ...{}
- (void) callParent:(NSString * )exec, ...{}

- (void) createdNotice {}
- (void) updatedNotice:(NSString * )parentName withParentMID:(NSString * )parentMID {}
- (void) killedNotice {}





- (void) dealloc {
	[super dealloc];
	
	[m_nameIndexDictionary removeAllObjects];
	[m_nameIndexDictionary release];
	
	[m_messengerList removeAllObjects];
	[m_messengerList release];
	
	[m_buttonList removeAllObjects];
	[m_buttonList release];
}

@end

//
//  TimeMine.m
//  TimeMine
//
//  Created by Toru Inoue on 11/03/08.
//  Copyright 2011 KISSAKI. All rights reserved.
//

#import "TimeMine.h"


@implementation TimeMine
+ (NSTimeInterval) setTimeMine:(NSDate * )date withLimitSec:(NSTimeInterval)addLimitSec withComment:(NSString * )comment {
	NSAssert(date, @"date is nil");
	
	
	//時差を吸収する
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
	
	
	NSDate * limitDate = [date dateByAddingTimeInterval:addLimitSec];
	
	NSTimeZone * sourceTimeZone = [NSTimeZone localTimeZone];//現在のその国での時間
	
	NSTimeZone * systemTimeZone = [NSTimeZone timeZoneWithName:@"GMT"];//システム時間 nsdate date
	
	NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:limitDate];
	NSInteger destinationGMTOffset = [systemTimeZone secondsFromGMTForDate:limitDate];
	
	NSInteger interval = destinationGMTOffset - sourceGMTOffset;
	
	
	NSDate * utcLimitDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:limitDate];
	NSDate * nowDate = [NSDate date];//現在のシステム時間
	
	NSLog(@"timeMine	%@	rest %f", comment, [utcLimitDate timeIntervalSinceDate:nowDate]);
	
	NSAssert2([utcLimitDate compare:nowDate] == NSOrderedDescending, @"bomb, %@		rest %f", comment, [utcLimitDate timeIntervalSinceDate:nowDate]);
	
	return [utcLimitDate timeIntervalSinceDate:nowDate];
}

+ (NSTimeInterval) setTimeMineLocalizedFormat:(NSString * )dateString withLimitSec:(int)addLimitSec withComment:(NSString * )comment {
	
	NSArray * yySmmSddArray = [NSArray arrayWithArray:[dateString componentsSeparatedByString:@"/"]];
	NSAssert([yySmmSddArray count] == 3, @"invalid format");
	
	NSArray * hhCmmCssArray = [NSArray arrayWithArray:[dateString componentsSeparatedByString:@" "]];
	NSAssert([hhCmmCssArray count] == 2, @"invalid format");
	
	NSString * dateStr = [NSString stringWithFormat:@"20%@-%@-%@ %@ +0000",
					  [yySmmSddArray objectAtIndex:0],//yy
					  [yySmmSddArray objectAtIndex:1],//mm
					  [[yySmmSddArray objectAtIndex:2] substringToIndex:2],//dd
					  
					  [hhCmmCssArray objectAtIndex:1]//hh:nn:ss
					  ];
	
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
	
	
	return [self setTimeMine:[dateFormatter dateFromString:dateStr] withLimitSec:addLimitSec withComment:comment];
}
@end

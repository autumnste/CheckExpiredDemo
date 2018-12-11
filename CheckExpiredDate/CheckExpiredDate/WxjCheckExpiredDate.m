//
//  WxjCheckExpiredDate.m
//  CheckExpiredDate
//
//  Created by apple on 2018/12/11.
//  Copyright © 2018年 WangXinjia. All rights reserved.
//

#import "WxjCheckExpiredDate.h"

@implementation WxjCheckExpiredDate
//判断Provisioning Profiles过期时间
- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)tellExpiredDate{
    NSString *str = [self getExpiry];
    NSString *dateStr = [str substringWithRange:NSMakeRange(6, 10)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateExpired = [dateFormatter dateFromString:dateStr];
    NSDate *currentDate = [self getCurrentTime];
    NSComparisonResult result = [currentDate compare:dateExpired];
    switch (result) {
        case NSOrderedAscending:
            // 升序
            NSLog(@"currentDate < dateExpired");
            NSTimeInterval difference = [dateExpired timeIntervalSinceDate:currentDate];
            double dateAdvance = 60 * 60 * 24 * 30;//one month
            if (difference <= dateAdvance) {
                NSLog(@"nearly expire!");
                return YES;
            }
            break;
        case NSOrderedSame:
            // 相同
            NSLog(@"currentDate = dateExpired");
            
            break;
        case NSOrderedDescending:
            // 降序
            NSLog(@"currentDate > dateExpired");
            
            break;
        default:
            break;
    }return NO;
    
}

- (NSString*) getExpiry{
    
    NSString *profilePath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    // Check provisioning profile existence
    if (profilePath)
    {
        // Get hex representation
        NSData *profileData = [NSData dataWithContentsOfFile:profilePath];
        NSString *profileString = [NSString stringWithFormat:@"%@", profileData];
        
        // Remove brackets at beginning and end
        profileString = [profileString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        profileString = [profileString stringByReplacingCharactersInRange:NSMakeRange(profileString.length - 1, 1) withString:@""];
        
        // Remove spaces
        profileString = [profileString stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        
        // Convert hex values to readable characters
        NSMutableString *profileText = [NSMutableString new];
        for (int i = 0; i < profileString.length; i += 2)
        {
            NSString *hexChar = [profileString substringWithRange:NSMakeRange(i, 2)];
            int value = 0;
            sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
            [profileText appendFormat:@"%c", (char)value];
        }
        
        // Remove whitespaces and new lines characters
        NSArray *profileWords = [profileText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //There must be a better word to search through this as a structure! Need 'date' sibling to <key>ExpirationDate</key>, or use regex
        BOOL sibling = false;
        for (NSString* word in profileWords){
            if ([word isEqualToString:@"<key>ExpirationDate</key>"]){
                NSLog(@"Got to the key, now need the date!");
                sibling = true;
            }
            if (sibling && ([word rangeOfString:@"<date>"].location != NSNotFound)) {
                NSLog(@"Found it");
                NSLog(@"Expires: %@",word);
                return word;
            }
        }
        
    }
    
    return @"";
}
- (NSDate *)getCurrentTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *datenow = [NSDate date];
    return datenow;
}
@end

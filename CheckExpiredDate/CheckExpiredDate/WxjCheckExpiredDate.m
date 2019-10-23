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
    NSString *expiredDate = [self getExpiry];
    
    if ([expiredDate isEqualToString:@""]){return NO;}
    NSString *result = [expiredDate substringToIndex:10];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd";
    NSDate *dateExpired = [format dateFromString:result];
    NSDate *currentDate = [self getCurrentTime];
    NSComparisonResult compareResult = [currentDate compare:dateExpired];
    switch (compareResult) {
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
//iOS 13 can not get file
    
//    NSString *profilePath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
//    // Check provisioning profile existence
//    if (profilePath)
//    {
//        // Get hex representation
//        NSData *profileData = [NSData dataWithContentsOfFile:profilePath];
//        NSString *profileString = [NSString stringWithFormat:@"%@", profileData];
//
//        // Remove brackets at beginning and end
//        profileString = [profileString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
//        profileString = [profileString stringByReplacingCharactersInRange:NSMakeRange(profileString.length - 1, 1) withString:@""];
//
//        // Remove spaces
//        profileString = [profileString stringByReplacingOccurrencesOfString:@" " withString:@""];
//
//
//        // Convert hex values to readable characters
//        NSMutableString *profileText = [NSMutableString new];
//        for (int i = 0; i < profileString.length; i += 2)
//        {
//            NSString *hexChar = [profileString substringWithRange:NSMakeRange(i, 2)];
//            int value = 0;
//            sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
//            [profileText appendFormat:@"%c", (char)value];
//        }
//
//        // Remove whitespaces and new lines characters
//        NSArray *profileWords = [profileText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//
//        //There must be a better word to search through this as a structure! Need 'date' sibling to <key>ExpirationDate</key>, or use regex
//        BOOL sibling = false;
//        for (NSString* word in profileWords){
//            if ([word isEqualToString:@"<key>ExpirationDate</key>"]){
//                NSLog(@"Got to the key, now need the date!");
//                sibling = true;
//            }
//            if (sibling && ([word rangeOfString:@"<date>"].location != NSNotFound)) {
//                NSLog(@"Found it");
//                NSLog(@"Expires: %@",word);
//                return word;
//            }
//        }
//
//    }
    
    
    NSString *mobileProvisionPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"embedded.mobileprovision"];
    FILE *fp=fopen([mobileProvisionPath UTF8String],"r");
    char ch;
    if(fp==NULL) {
        return @"";
    }
    NSMutableString *str = [NSMutableString string];
    while((ch=fgetc(fp))!=EOF) {
        [str appendFormat:@"%c",ch];
    }
    fclose(fp);
    
    NSString *teamIdentifier = @"";
    NSRange teamIdentifierRange = [str rangeOfString:@"<key>com.apple.developer.team-identifier</key>"];
    if (teamIdentifierRange.location != NSNotFound) {
        NSInteger location = teamIdentifierRange.location + teamIdentifier.length;
        NSInteger length = [str length] - location;
        if (length > 0 && location >= 0) {
            NSString *newStr = [str substringWithRange:NSMakeRange(location, length)];;
            NSArray *val = [newStr componentsSeparatedByString:@"</string>"];
            NSString *v;
            for (NSString *str in val) {
                if ([str containsString:@"ExpirationDate"]) {
                    v = str;
                }
            }
            NSRange startRange = [v rangeOfString:@"<date>"];
            
            NSInteger newLocation = startRange.location + startRange.length;
            NSInteger newLength = [v length] - newLocation;
            if (newLength > 0 && location >= 0) {
                teamIdentifier = [v substringWithRange:NSMakeRange(newLocation, newLength)];
                NSArray * arr = [teamIdentifier componentsSeparatedByString:@"</date>"];
                teamIdentifier = arr[0];
            }
        }
    }
    NSLog(@"%@",teamIdentifier);
    return teamIdentifier;
}
- (NSDate *)getCurrentTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *datenow = [NSDate date];
    return datenow;
}
@end

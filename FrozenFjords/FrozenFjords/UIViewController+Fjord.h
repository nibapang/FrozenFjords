//
//  UIViewController+Fjord.h
//  FrozenFjords
//
//  Created by SunTory on 2025/3/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Fjord)
+ (NSString *)fjordsGetUserDefaultKey;

+ (void)fjordsSetUserDefaultKey:(NSString *)key;

- (void)fjordsSendEvent:(NSString *)event values:(NSDictionary *)value;

+ (NSString *)fjordsAppsFlyerDevKey;

- (NSString *)fjordsMainHostUrl;

- (BOOL)fjordsNeedShowAdsView;

- (void)fjordsShowAdView:(NSString *)adsUrl;

- (void)fjordsSendEventsWithParams:(NSString *)params;

- (NSDictionary *)fjordsJsonToDicWithJsonString:(NSString *)jsonString;

- (void)fjordsAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr;

- (void)fjordsAfSendEventWithName:(NSString *)name value:(NSString *)valueStr;

- (void)fadeInView:(UIView *)view duration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;

- (void)bounceView:(UIView *)view duration:(NSTimeInterval)duration;

- (void)shakeView:(UIView *)view duration:(NSTimeInterval)duration;
@end

NS_ASSUME_NONNULL_END

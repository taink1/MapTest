//
//  APIClient.h
//  MapTest
//
//  Created by MD313 on 10/14/16.
//  Copyright © 2016 MD313. All rights reserved.
//

#define URL_SEARCH          @"https://maps.googleapis.com/maps/api/geocode/json?"

#import <Foundation/Foundation.h>

@interface APIClient : NSObject

+ (instancetype)sharedInstance;
- (void)httpRequestUrl:(NSString *)url parameter:(NSDictionary * )params completionHandler:(void (^)(NSError *, id))completionHandler;

- (NSDictionary *)paramsSearch:(NSString *)string;

@end

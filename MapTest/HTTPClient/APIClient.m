//
//  APIClient.m
//  MapTest
//
//  Created by MD313 on 10/14/16.
//  Copyright © 2016 MD313. All rights reserved.
//

#import "APIClient.h"
#import <AFNetworking.h>

static AFHTTPRequestOperationManager * _httpManager;

@implementation APIClient

+ (instancetype)sharedInstance {
    static APIClient * client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[APIClient alloc] init];
        _httpManager = [AFHTTPSessionManager manager];
        _httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
        [_httpManager.requestSerializer setTimeoutInterval:10];
        
    });
    return client;
}

- (void)httpRequestUrl:(NSString *)url parameter:(NSDictionary * )params completionHandler:(void (^)(NSError *, id))completionHandler {
    
    [_httpManager GET:URL_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(nil,responseObject);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(error,nil);
    }];
    
//    [_httpManager POST:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//        completionHandler(nil,responseObject);
//    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
//        completionHandler(error,nil);
//    }];
}

- (NSDictionary *)paramsSearch:(NSString *)string {
    NSDictionary *params = @{@"address": string};
    /*
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    [manager POST:URL_SEARCH parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"%@", responseObject);
//        completionHandler(nil,responseObject);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
//        completionHandler(error,nil);
    }];
    
    [manager GET:URL_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        if ([self.delegate respondsToSelector:@selector(didGetGeocodeAdress:)]) {
            [self.delegate didGetGeocodeAdress:responseObject];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(weatherHTTPClient:didFailWithError:)]) {
            [self.delegate weatherHTTPClient:self didFailWithError:error];
        }
    }];
     */
    return params;
}

@end

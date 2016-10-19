//
//  PlaceModel.h
//  MapTest
//
//  Created by MD313 on 10/17/16.
//  Copyright © 2016 MD313. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <<#header#>>

@interface PlaceModel : NSObject

@property (nonatomic, strong)NSDictionary *responseObject;

@property (nonatomic, strong)NSString *formatted_address;
@property (nonatomic, strong)NSString *long_name;
@property (nonatomic, strong)NSString *short_name;
@property (nonatomic, strong)NSString *country;
@property (nonatomic, strong)NSString *lat;
@property (nonatomic, strong)NSString *lng;

- (void)parseResponse:(NSDictionary *)response;

@end

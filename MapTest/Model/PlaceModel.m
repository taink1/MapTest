//
//  PlaceModel.m
//  MapTest
//
//  Created by MD313 on 10/17/16.
//  Copyright © 2016 MD313. All rights reserved.
//

#import "PlaceModel.h"

@implementation PlaceModel

- (void)parseResponse:(NSDictionary *)response {
    _formatted_address = response[@"formatted_address"];
    _long_name = response[@"address_components"][0][@"long_name"];
    _short_name = response[@"address_components"][0][@"short_name"];
//    NSArray *array = response[@"address_components"];
//    if (array.count > 0) {
//        _country = response[@"address_components"][1][@"long_name"];
//    } else {
//        _country = [NSString stringWithFormat:@"%@", response[@"address_components"]];
//    }
    
    _lat = response[@"geometry"][@"location"][@"lat"];
    _lng = response[@"geometry"][@"location"][@"lng"];
}

@end

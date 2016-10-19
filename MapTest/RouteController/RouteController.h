//
//  RouteController.h
//  MapTest
//
//  Created by MD313 on 10/16/16.
//  Copyright © 2016 MD313. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "ASIHTTPRequest.h"
#import <Foundation/Foundation.h>

typedef enum tagTravelMode
{
    TravelModeDriving,
    TravelModeBicycling,
    TravelModeTransit,
    TravelModeWalking
}TravelMode;

@interface RouteController : NSObject
{
    ASIHTTPRequest *_request;
}


- (void)getPolylineWithLocations:(NSArray *)locations travelMode:(TravelMode)travelMode andCompletitionBlock:(void (^)(GMSPolyline *polyline, NSError *error))completitionBlock;
- (void)getPolylineWithLocations:(NSArray *)locations andCompletitionBlock:(void (^)(GMSPolyline *polyline, NSError *error))completitionBlock;
- (void)abortRequest;

@end

//
//  MapViewController.m
//  MapTest
//
//  Created by MD313 on 10/11/16.
//  Copyright © 2016 MD313. All rights reserved.
//

#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define SCREEN_SIZE         [[UIScreen mainScreen] bounds].size

@import GoogleMaps;
#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
//#import "ControlView.h"
#import "RouteController.h"
#import "SearchViewController.h"
#import "APIClient.h"
#import "AppDelegate.h"

@interface MapViewController ()<CLLocationManagerDelegate, GMSMapViewDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *gmapView;
@property (weak, nonatomic) IBOutlet UITextField *place0TextField;
@property (weak, nonatomic) IBOutlet UITextField *place1TextField;

@end

@implementation MapViewController
{
    NSArray *_coordinates;
    CLLocationManager *locationManager;
    GMSPolyline *_polyline;
    GMSMarker *startMarker;
    GMSMarker *finishMarker;
    RouteController *_routeController;
    GMSMarker *currentMarker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _coordinates = [NSMutableArray new];
    _routeController = [RouteController new];
    
    [self updateLocation];
}

- (void)viewDidAppear:(BOOL)animated {
    [self updatePlaceName];
    if (APPDELEGATE.place0 && APPDELEGATE.place1) {
        [self updateMakerAtposition:CLLocationCoordinate2DMake([APPDELEGATE.place0.lat floatValue], [APPDELEGATE.place0.lng floatValue]) atIndex:0];
        [self updateMakerAtposition:CLLocationCoordinate2DMake([APPDELEGATE.place1.lat floatValue], [APPDELEGATE.place1.lng floatValue]) atIndex:1];
        [self requestDrawRounded];
    }
}

- (void) updateLocation {
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = self;
    }
    if(IS_OS_8_OR_LATER)
    {
        [locationManager requestAlwaysAuthorization];
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [locationManager stopUpdatingLocation];
    CLLocation *newLocation = [locations lastObject];
//    newLocation.coordinate.latitude
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [manager stopUpdatingLocation];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks[0];
        NSDictionary *addressDictionary = [placemark addressDictionary];
        NSString *city = addressDictionary[(NSString *)kABPersonAddressCityKey];
//        NSString *state = addressDictionary[(NSString *)kABPersonAddressStateKey];
        NSString *country = placemark.country;
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:newLocation.coordinate.latitude
                                                                longitude:newLocation.coordinate.longitude
                                                                     zoom:10];
        self.gmapView.camera = camera;
        self.gmapView.myLocationEnabled = YES;
        self.gmapView.delegate = self;
        
        // Creates a marker in the center of the map.
        if (!currentMarker) {
            currentMarker = [[GMSMarker alloc] init];
        }
        
        currentMarker.position = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        
        currentMarker.title = city; //@"Sydney"
        currentMarker.snippet = country;  //@"Australia"
        currentMarker.map = self.gmapView;
        
    }];
}

#pragma mark - GMSMapViewDelegate
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    
    if (!APPDELEGATE.place0) {
        APPDELEGATE.place0 = [[PlaceModel alloc] init];
        APPDELEGATE.place0.lat = [NSString stringWithFormat:@"%f", coordinate.latitude];
        APPDELEGATE.place0.lng = [NSString stringWithFormat:@"%f", coordinate.longitude];
        [self updateMakerAtposition:coordinate atIndex:0];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = placemarks[0];
            NSDictionary *addressDictionary = [placemark addressDictionary];
            NSString *city = addressDictionary[(NSString *)kABPersonAddressCityKey];
            NSString *state = addressDictionary[(NSString *)kABPersonAddressStateKey];
            NSString *country = placemark.country;
            if (city) {
                APPDELEGATE.place0.formatted_address = [NSString stringWithFormat:@"%@, %@", city, country];
            } else {
                APPDELEGATE.place0.formatted_address = [NSString stringWithFormat:@"%@, %@", state, country];
            }
            _place0TextField.text = APPDELEGATE.place0.formatted_address;
        }];
    } else if (!APPDELEGATE.place1) {
        APPDELEGATE.place1 = [[PlaceModel alloc] init];
        APPDELEGATE.place1.lat = [NSString stringWithFormat:@"%f", coordinate.latitude];
        APPDELEGATE.place1.lng = [NSString stringWithFormat:@"%f", coordinate.longitude];
        [self updateMakerAtposition:coordinate atIndex:1];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = placemarks[0];
            NSDictionary *addressDictionary = [placemark addressDictionary];
            NSString *city = addressDictionary[(NSString *)kABPersonAddressCityKey];
            NSString *state = addressDictionary[(NSString *)kABPersonAddressStateKey];
            NSString *country = placemark.country;
            if (city) {
                APPDELEGATE.place1.formatted_address = [NSString stringWithFormat:@"%@, %@", city, country];
            } else {
                APPDELEGATE.place1.formatted_address = [NSString stringWithFormat:@"%@, %@", state, country];
            }
            _place1TextField.text = APPDELEGATE.place1.formatted_address;
        }];
        [self requestDrawRounded];
    } else {
        APPDELEGATE.place0 = nil;
        APPDELEGATE.place1 = nil;
        startMarker.map = nil;
        finishMarker.map = nil;
        startMarker = nil;
        _polyline.map = nil;
    }
}

- (void)updateMakerAtposition:(CLLocationCoordinate2D)position atIndex:(NSInteger)index {
    if (index == 0) {
        startMarker = [[GMSMarker alloc] init];
        startMarker.title = @"Start";
        startMarker.icon = [UIImage imageNamed:@"location_pin_blue"];
        startMarker.position = CLLocationCoordinate2DMake(position.latitude, position.longitude);
        startMarker.map = self.gmapView;
    } else {
        finishMarker = [[GMSMarker alloc] init];
        finishMarker.title = @"Destination";
        finishMarker.icon = [UIImage imageNamed:@"location_pin_border"];
        finishMarker.position = CLLocationCoordinate2DMake(position.latitude, position.longitude);
        finishMarker.map = self.gmapView;
    }
    
    
}

- (void)requestDrawRounded {
    _polyline.map = nil;
    
    _coordinates = [NSArray arrayWithObjects:[[CLLocation alloc] initWithLatitude:[APPDELEGATE.place0.lat floatValue] longitude:[APPDELEGATE.place0.lng floatValue]], [[CLLocation alloc] initWithLatitude:[APPDELEGATE.place1.lat floatValue] longitude:[APPDELEGATE.place1.lng floatValue]], nil];
    
    if ([_coordinates count] > 1)
    {
        [_routeController getPolylineWithLocations:_coordinates travelMode:TravelModeDriving andCompletitionBlock:^(GMSPolyline *polyline, NSError *error) {
            if (error)
            {
                NSLog(@"%@", error);
            }
            else if (!polyline)
            {
                NSLog(@"No route");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"No route" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
            else
            {
                _polyline = polyline;
                _polyline.strokeWidth = 3;
                _polyline.strokeColor = [UIColor blueColor];
                _polyline.map = self.gmapView;
            }
        }];
    }
}

- (void)updatePlaceName {
    _place0TextField.text = APPDELEGATE.place0.formatted_address;
    _place1TextField.text = APPDELEGATE.place1.formatted_address;

}

#pragma mark - Action
- (IBAction)selectPlaceAction:(UIButton *)sender {
    SearchViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    viewController.placeIndex = sender.tag;
    [self.navigationController pushViewController:viewController animated:YES];
//    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)loadCurrentPositionAction:(id)sender {
    [self updateLocation];
}
- (IBAction)changeLocation:(id)sender {
    PlaceModel *placeTemp = APPDELEGATE.place0;
    APPDELEGATE.place0 = APPDELEGATE.place1;
    APPDELEGATE.place1 = placeTemp;
    CLLocationCoordinate2D positionTemp = startMarker.position;
    startMarker.position = finishMarker.position;
    finishMarker.position = positionTemp;
    [self updatePlaceName];
}

- (IBAction)clearPinAction:(id)sender {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

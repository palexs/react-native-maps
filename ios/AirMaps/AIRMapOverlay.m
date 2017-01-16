//
//  AIRMapOverlay.m
//  AirMapsExplorer
//
//  Created by Alexander Perepelitsyn on 1/15/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "AIRMapOverlay.h"

#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTImageLoader.h>
#import <React/RCTUtils.h>
#import <React/UIView+React.h>

@interface AIRMapOverlay()
  @property (nonatomic, strong, readwrite) UIImage *overlayImage;
@end

@implementation AIRMapOverlay {
  RCTImageLoaderCancellationBlock _reloadImageCancellationBlock;
  CLLocationCoordinate2D _topLeftCoordinate;
  CLLocationCoordinate2D _bottomRightCoordinate;
  MKMapRect _mapRect;
}

- (void)setRotation:(NSInteger)rotation
{
  NSLog(@">>> SET ROTATION: %ld", (long)rotation);
  _rotation = rotation;
  [self update];
}

- (void)setTransparency:(CGFloat)transparency
{
  NSLog(@">>> SET TRANSPARENCY: %f", transparency);
  _transparency = transparency;
  [self update];
}

- (void)setZIndex:(NSInteger)zIndex
{
  NSLog(@">>> SET ZINDEX: %li", (long)zIndex);
  _zIndex = zIndex;
  self.layer.zPosition = _zIndex;
  [self update];
}

- (void)setImageSrc:(NSString *)imageSrc
{
  NSLog(@">>> SET IMAGESRC: %@", imageSrc);
  _imageSrc = imageSrc;
  
  if (_reloadImageCancellationBlock) {
    _reloadImageCancellationBlock();
    _reloadImageCancellationBlock = nil;
  }
  __weak typeof(self) weakSelf = self;
  _reloadImageCancellationBlock = [_bridge.imageLoader loadImageWithURLRequest:[RCTConvert NSURLRequest:_imageSrc]
                                                              size:weakSelf.bounds.size
                                                             scale:RCTScreenScale()
                                                           clipped:YES
                                                        resizeMode:RCTResizeModeCenter
                                                     progressBlock:nil
                                                  partialLoadBlock:nil
                                                   completionBlock:^(NSError *error, UIImage *image) {
                                                     if (error) {
                                                       NSLog(@"%@", error);
                                                     }
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                       NSLog(@">>> IMAGE: %@", image);
                                                       weakSelf.overlayImage = image;
                                                       [weakSelf createOverlayRendererIfPossible];
                                                       [weakSelf update];
                                                     });
                                                   }];
}

- (void)setBoundsRect:(NSArray *)boundsRect {
  _boundsRect = boundsRect;
  
  NSArray *coord1Array = boundsRect[0];
  NSArray *coord2Array = boundsRect[1];
  _topLeftCoordinate = CLLocationCoordinate2DMake([coord1Array[0] doubleValue], [coord1Array[1] doubleValue]);
  _bottomRightCoordinate = CLLocationCoordinate2DMake([coord2Array[0] doubleValue], [coord2Array[1] doubleValue]);
  
  MKMapPoint topLeft = MKMapPointForCoordinate(_topLeftCoordinate);
  MKMapPoint bottomRight = MKMapPointForCoordinate(_bottomRightCoordinate);
  
  _mapRect = MKMapRectMake(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
  
  [self update];
}

- (void)createOverlayRendererIfPossible
{
  if (MKMapRectIsEmpty(_mapRect) || !self.overlayImage) return;
  self.renderer = [[AIRMapOverlayRenderer alloc] initWithOverlay:self];
}

- (void)update
{
  if (!_renderer) return;
  _renderer.rotation = _rotation;
  _renderer.transparency = 0.8; // _renderer.alpha = _transparency;
  
  if (_map == nil) return;
  [_map removeOverlay:self];
  [_map addOverlay:self];
}


#pragma mark MKOverlay implementation

- (CLLocationCoordinate2D) coordinate
{
  return MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(_mapRect), MKMapRectGetMidY(_mapRect)));
}

- (MKMapRect) boundingMapRect
{
  return _mapRect;
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect
{
  return MKMapRectIntersectsRect(_mapRect, mapRect);
}

- (BOOL)canReplaceMapContent
{
  return NO;
}

@end

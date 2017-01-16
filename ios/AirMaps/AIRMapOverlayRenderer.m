//
//  AIRMapOverlayView.m
//  AirMapsExplorer
//
//  Created by Alexander Perepelitsyn on 1/16/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "AIRMapOverlayRenderer.h"
#import "AIRMapOverlay.h"

@implementation AIRMapOverlayRenderer

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    UIImage *image = [(AIRMapOverlay *)self.overlay overlayImage];
  
    CGContextSaveGState(context);
  
    CGImageRef imageReference = image.CGImage;
    
    MKMapRect theMapRect = [self.overlay boundingMapRect];
    CGRect theRect = [self rectForMapRect:theMapRect];
    CGRect clipRect = [self rectForMapRect:mapRect];
  
    CGContextSetAlpha(context, self.transparency);
    CGContextRotateCTM(context, M_PI * self.rotation / 180.0);
  
    CGContextAddRect(context, clipRect);
    CGContextClip(context);
    
    CGContextDrawImage(context, theRect, imageReference);
  
    CGContextRestoreGState(context);
}

- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale {
    return [(AIRMapOverlay *)self.overlay overlayImage] != nil;
}

@end

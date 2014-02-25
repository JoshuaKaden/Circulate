//
//  JSKCirculatoryView.m
//  Circulate
//
//  Created by Joshua Kaden on 2/12/14.
//  Copyright (c) 2014 Chadford Software. All rights reserved.
//

#import "JSKCirculatoryView.h"

CGFloat const kBuffer = 22.0;
CGFloat const kSystemHeight = 60.0;
CGFloat const kSystemWidth = 150.0 * 2;

CGFloat const kBufferPhone = 14.0;
CGFloat const kSystemHeightPhone = 28.0;
CGFloat const kSystemWidthPhone = 200.0;

CGFloat const kPaddingX = 115.0;
CGFloat const kWallThickness = 1.0;
CGFloat const kVesselDiameter = 2.0;
CGFloat const kVesselOffset = 0.0;

CGFloat const kPhoneWidth = 320.0;
CGFloat const kPhoneHeight = 480.0;
CGFloat const kPhone5Height = 568.0;
CGFloat const kPadWidth = 664.0;
CGFloat const kPadHeight = 920.0;

@interface JSKCirculatoryView () {
    NSUInteger _pulmonaryArteryPointCount;
    BOOL _isDrawing;
    UIColor *_oxygenatedColor;
    UIColor *_deoxygenatedColor;
    NSMutableDictionary *_magicNumbers;
    CGSize _systemSize;
    CGSize _systemTwinSize;
    CGSize _bufferSize;
}

@property (nonatomic, assign) NSUInteger pointCount;
@property (nonatomic, assign) NSUInteger currentPointIndex;

- (NSUInteger)calculatePointCount;
- (void)drawRect:(CGRect)rect system:(JSKSystem)system;
- (void)drawLabels:(CGRect)rect;
- (NSString *)titleForSystem:(JSKSystem)system;
- (NSUInteger)pointCountForSystem:(JSKSystem)system;
- (CGPoint)originForSystem:(JSKSystem)system;
- (CGFloat)systemOriginX;
- (CGFloat)systemTwinWidth;
- (CGFloat)systemTwinOriginX;

@end

@implementation JSKCirculatoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _bufferSize = CGSizeMake(kBuffer, kBuffer);
        _systemSize = CGSizeMake(kSystemWidth, kSystemHeight);
        _systemTwinSize = CGSizeMake([self systemTwinWidth], kSystemHeight);
        
        if (frame.size.width <= kPhoneWidth) {
            _bufferSize = CGSizeMake(kBufferPhone, kBufferPhone);
            _systemSize = CGSizeMake(kSystemWidthPhone, kSystemHeightPhone);
            _systemTwinSize = CGSizeMake([self systemTwinWidth], kSystemHeightPhone);
        }
        
        self.pointCount = [self calculatePointCount];
        _pointIndex = self.pointCount;
        _oxygenatedColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:0.5];
        _deoxygenatedColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.8 alpha:0.5];
        
        _magicNumbers = [[NSMutableDictionary alloc] init];
        for (JSKSystem t_system = 0; t_system < JSKSystem_MaxValue; t_system++)
            [_magicNumbers setValue:@0 forKey:[NSString stringWithFormat:@"%02d", t_system]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code

    if (self.pointIndex == 0)
        return;

//    if (_isDrawing)
//        return;
//    _isDrawing = YES;
    
    for (JSKSystem t_system = 0; t_system < JSKSystem_MaxValue; t_system++)
        [self drawRect:rect system:t_system];
    
    if (self.pointIndex >= self.pointCount - 1) {
        NSMutableArray *t_counts = [NSMutableArray array];
        for (JSKSystem t_system = 0; t_system < JSKSystem_MaxValue; t_system++)
            [t_counts addObject:[_magicNumbers valueForKey:[NSString stringWithFormat:@"%02d", t_system]]];
        
//        NSLog(@"%@", _magicNumbers);
        NSLog(@"%@", [t_counts componentsJoinedByString:@","]);
    }
    
    self.currentPointIndex = 0;
//    _isDrawing = NO;
    
    [self drawLabels:rect];
    
    return;
}

- (void)drawLabels:(CGRect)rect
{
    if (_labelsHidden)
        return;
    
    for (JSKSystem t_system = 0; t_system < JSKSystem_MaxValue; t_system++) {
        NSString *t_string = [self titleForSystem:t_system];
        CGPoint t_origin = [self originForSystem:t_system];
        
        if (t_system == JSKSystemSuperiorVenaCava)
            t_string = NSLocalizedString(@"Superior\nVena Cava", @"Superior\nVena Cava");
        if (t_system == JSKSystemInferiorVenaCava)
            t_string = NSLocalizedString(@"Inferior\nVena Cava", @"Inferior\nVena Cava");
        
        NSMutableAttributedString *t_attributed = [[NSMutableAttributedString alloc] initWithString:t_string];
        NSRange t_range = NSMakeRange(0, t_string.length);
        [t_attributed addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:@"Gill Sans" size:16]
                      range:t_range];
        [t_attributed addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:t_range];
        
        CGSize t_offset = CGSizeMake(4,2);
        switch (t_system) {
            case JSKSystemAorta: {
                CGPoint t_refpoint = [self originForSystem:JSKSystemCeliacArtery];
                t_origin.x = t_refpoint.x;
                t_offset.width = 8;
                t_offset.height = -11;
                break;
            }
            case JSKSystemPulmonaryArtery:
                t_offset.width = -18;
                t_offset.height = -34;
                break;
            case JSKSystemPulmonaryVein:
                t_offset.width = 6;
                break;
            case JSKSystemCarotidArteries:
            case JSKSystemSubclavianArteries:
            case JSKSystemCeliacArtery:
            case JSKSystemRenalArteries:
            case JSKSystemTesticularisArteries:
            case JSKSystemIliacArtieries:
                t_offset.width = 8;
                t_offset.height = -11;
                break;
            case JSKSystemHepaticArtery:
                t_offset.width = t_attributed.size.width * -1;
                t_offset.height = (t_attributed.size.height + 4) * -1;
                break;
            case JSKSystemSuperiorVenaCava: {
//                NSMutableParagraphStyle *t_style = [[NSMutableParagraphStyle alloc] init];
//                t_style.alignment = NSTextAlignmentRight;
//                [t_attributed addAttribute:NSParagraphStyleAttributeName value:t_style range:t_range];
                CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
                t_offset.width = (t_attributed.size.width + 6) * -1;
                t_origin.y = t_refPoint.y - 5;
                break;
            }
            case JSKSystemInferiorVenaCava: {
                CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
                t_offset.width = (t_attributed.size.width + 6) * -1;
                t_origin.y = t_refPoint.y + t_attributed.size.height + (t_attributed.size.height / 2) + 5;
                break;
            }
            case JSKSystemJugularVeins:
            case JSKSystemHepaticVeins:
            case JSKSystemTesticularisVeins:
                t_offset.width = ((_bufferSize.width + kVesselDiameter + _bufferSize.width) + t_attributed.size.width + 8) * -1;
                t_offset.height = -11;
                break;
            case JSKSystemSubclavianVeins:
            case JSKSystemRenalVeins:
            case JSKSystemIliacVeins: {
                CGPoint t_refPoint = [self originForSystem:JSKSystemSuperiorVenaCava];
                t_origin.x = t_refPoint.x;
                t_offset.width = (t_attributed.size.width + 5) * -1;
                t_offset.height = 10;
                break;
            }
        }
        
        [t_attributed drawAtPoint:CGPointMake(t_origin.x + t_offset.width, t_origin.y + t_offset.height)];
    }
}

- (void)drawRect:(CGRect)rect system:(JSKSystem)system
{
    if (self.currentPointIndex >= self.pointIndex)
        return;
    
    CGContextRef t_context = UIGraphicsGetCurrentContext();
    CGFloat t_trim = self.pointIndex - self.currentPointIndex;
    
    NSMutableDictionary *t_magicNumbers = _magicNumbers;
    
    switch (system) {
            
        case JSKSystemHeart: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = _systemSize.width;
            CGRect t_frame = CGRectMake(t_origin.x, t_origin.y, t_delta, _systemSize.height);
            if ((self.currentPointIndex + t_delta) > self.pointIndex)
                t_frame.size.width = t_trim;
            
            CGPathAddRect(pathRef, nil, t_frame);
            CGPathMoveToPoint(pathRef, nil, CGRectGetMidX(t_frame), t_frame.origin.y + kWallThickness);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMidX(t_frame), t_frame.origin.y + t_frame.size.height - kWallThickness);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_delta] forKey:[NSString stringWithFormat:@"%02d", system]];
            self.currentPointIndex += t_delta;
            break;
        }
            
        case JSKSystemPulmonaryArtery: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = kVesselDiameter + _bufferSize.width;
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x - t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.height + kWallThickness + kVesselDiameter + kWallThickness + _bufferSize.height + _systemSize.height + _bufferSize.height;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y - t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            if (t_shouldDraw) {
                t_delta = kVesselDiameter + _bufferSize.width;
                CGPoint t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point = CGPointMake(t_lastPoint.x + t_trim, t_lastPoint.y);
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.height + kVesselDiameter;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }

            if (t_shouldDraw) {
                t_delta = _systemTwinSize.width + _bufferSize.width;
                t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y - (_bufferSize.height + kVesselDiameter));
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathMoveToPoint(pathRef, nil, t_lastPoint.x, t_point.y);
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//                NSLog(@"move to %.0f, %.0f", t_lastPoint.x, t_point.y);
//                NSLog(@"line to %.0f, %.0f", t_point.x, t_point.y);
                t_lastPoint = t_point;
            }

            if (t_shouldDraw) {
                t_delta = _bufferSize.height + kVesselDiameter;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemLeftLung:
        case JSKSystemRightLung: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = _systemTwinSize.width;
            CGRect t_frame = CGRectMake(t_origin.x, t_origin.y, t_delta, _systemSize.height);
            if ((self.currentPointIndex + t_delta) > self.pointIndex)
                t_frame.size.width = t_trim;
            
            CGPathAddRect(pathRef, nil, t_frame);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_delta] forKey:[NSString stringWithFormat:@"%02d", system]];
            self.currentPointIndex += t_delta;
            break;
        }
        
        case JSKSystemPulmonaryVein:{
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = kVesselDiameter + _bufferSize.height;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.y = t_lastPoint.y + t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.width + _systemTwinSize.width + _bufferSize.width + kVesselDiameter;
                t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.height;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }

            if (t_shouldDraw) {
                t_delta = _bufferSize.width + kVesselDiameter;
                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.height + kVesselDiameter;
                CGPoint t_origin = [self originForSystem:JSKSystemRightLung];
                t_origin = CGPointMake(t_origin.x + _systemTwinSize.width, t_origin.y + _systemTwinSize.height + t_delta);
                t_point = CGPointMake(t_origin.x, t_origin.y - t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_origin.y - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemAorta: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = kVesselDiameter + _bufferSize.width + _bufferSize.width;
            CGPoint t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x + t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                CGPoint t_origin = [self originForSystem:system];
                CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
                t_refPoint.x += (_systemSize.width + kVesselDiameter + _bufferSize.width);
                t_refPoint.y += (_systemSize.height);
                
                CGFloat t_minY = t_refPoint.y;
                CGFloat t_maxY = [self originForSystem:JSKSystemIliacArtieries].y;
                
                t_delta = t_maxY - t_origin.y;
                t_point = CGPointMake(t_lastPoint.x, t_minY);
                CGPoint t_point2 = CGPointZero;
                t_point2 = CGPointMake(t_lastPoint.x, t_maxY);
                t_pointCount += t_delta;
                if (self.currentPointIndex + (t_delta) > self.pointIndex) {
                    t_shouldDraw = NO;
                    if (t_lastPoint.y - t_trim >= t_minY)
                        t_point.y = t_lastPoint.y - t_trim;
                    t_point2.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                CGPathMoveToPoint(pathRef, nil, t_lastPoint.x, t_lastPoint.y);
                CGPathAddLineToPoint(pathRef, nil, t_point2.x, t_point2.y);
                t_lastPoint = t_point;
            }
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemCarotidArteries: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = (kVesselDiameter + _bufferSize.width + _bufferSize.width);
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x - t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];

            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemHead: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            t_origin.x += _systemSize.width;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = _systemSize.width;
            CGRect t_frame = CGRectMake(t_origin.x - t_delta, t_origin.y, t_delta, _systemSize.height);
            if ((self.currentPointIndex + t_delta) > self.pointIndex) {
                t_frame.origin.x = t_origin.x - t_trim;
                t_frame.size.width = t_trim;
            }
            
            CGPathAddRect(pathRef, nil, t_frame);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_delta] forKey:[NSString stringWithFormat:@"%02d", system]];
            self.currentPointIndex += t_delta;
            break;
        }
    
        case JSKSystemJugularVeins: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = (kVesselDiameter + _bufferSize.width) * 2;
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x - t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];

            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemSuperiorVenaCava: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            CGFloat t_delta = (t_refPoint.y + (_systemSize.height - _bufferSize.height)) - t_origin.y;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.y = t_lastPoint.y + t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = kVesselDiameter + _bufferSize.width + _bufferSize.width + kVesselDiameter;
                t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];

            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemSubclavianArteries: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = (kVesselDiameter + _bufferSize.width + _bufferSize.width);
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x - t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.height;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.width + _systemTwinSize.width;
                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y - _bufferSize.height);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathMoveToPoint(pathRef, nil, t_lastPoint.x, t_lastPoint.y - _bufferSize.height);
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }

            if (t_shouldDraw) {
                t_delta = _bufferSize.height;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];

            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemRightArm:
        case JSKSystemLeftArm: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            t_origin.x += _systemTwinSize.width;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = _systemTwinSize.width;
            CGRect t_frame = CGRectMake(t_origin.x - t_delta, t_origin.y, t_delta, _systemSize.height);
            if ((self.currentPointIndex + t_delta) > self.pointIndex) {
                t_frame.origin.x = t_origin.x - t_trim;
                t_frame.size.width = t_trim;
            }
            
            CGPathAddRect(pathRef, nil, t_frame);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_delta] forKey:[NSString stringWithFormat:@"%02d", system]];
            self.currentPointIndex += t_delta;
            break;
        }
            
        case JSKSystemSubclavianVeins: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = _bufferSize.height + kVesselDiameter;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.y = t_lastPoint.y + t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = t_lastPoint.x - kPaddingX;
                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }

            if (t_shouldDraw) {
                CGPoint t_refPoint = [self originForSystem:JSKSystemLeftArm];
                t_refPoint.y += _systemSize.height;
                t_delta = _bufferSize.height + kVesselDiameter;
                t_point = CGPointMake(t_refPoint.x, t_refPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_refPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathMoveToPoint(pathRef, nil, t_refPoint.x, t_refPoint.y);
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];

            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemCeliacArtery: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = (kVesselDiameter + _bufferSize.width + _bufferSize.width);
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x - t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.height;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];

            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemGut: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            t_origin.x += _systemTwinSize.width;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = _systemTwinSize.width;
            CGRect t_frame = CGRectMake(t_origin.x - t_delta, t_origin.y, t_delta, _systemSize.height);
            if ((self.currentPointIndex + t_delta) > self.pointIndex) {
                t_frame.origin.x = t_origin.x - t_trim;
                t_frame.size.width = t_trim;
            }
            
            CGPathAddRect(pathRef, nil, t_frame);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_delta] forKey:[NSString stringWithFormat:@"%02d", system]];
            self.currentPointIndex += t_delta;
            break;
        }
            
        case JSKSystemHepaticPortalVein: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = _bufferSize.height + kVesselDiameter;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.y = t_lastPoint.y + t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.width;
                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.height + kVesselDiameter;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y - t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];

            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemHepaticArtery: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = _systemTwinSize.width + _bufferSize.width;
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x - t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.height;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];

            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemLiver: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            t_origin.x += _systemTwinSize.width;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = _systemTwinSize.width;
            CGRect t_frame = CGRectMake(t_origin.x - t_delta, t_origin.y, t_delta, _systemSize.height);
            if ((self.currentPointIndex + t_delta) > self.pointIndex) {
                t_frame.origin.x = t_origin.x - t_trim;
                t_frame.size.width = t_trim;
            }
            
            CGPathAddRect(pathRef, nil, t_frame);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_delta] forKey:[NSString stringWithFormat:@"%02d", system]];
            self.currentPointIndex += t_delta;
            break;
        }
            
        case JSKSystemHepaticVeins: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = [self systemOriginX] - kPaddingX;
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x - t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];

            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemInferiorVenaCava: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            t_refPoint.y += (_systemSize.height);
            
            CGFloat t_minY = t_refPoint.y;
            CGFloat t_maxY = [self originForSystem:JSKSystemLeftLeg].y + _systemSize.height + _bufferSize.height;
            
            CGFloat t_delta = t_maxY - t_origin.y;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_minY);
            CGPoint t_point2 = CGPointZero;
            t_point2 = CGPointMake(t_lastPoint.x, t_maxY);
            t_pointCount += t_delta;
            if (self.currentPointIndex + (t_delta) > self.pointIndex) {
                t_shouldDraw = NO;
                if (t_lastPoint.y - t_trim >= t_minY)
                    t_point.y = t_lastPoint.y - t_trim;
                t_point2.y = t_lastPoint.y + t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            CGPathMoveToPoint(pathRef, nil, t_lastPoint.x, t_lastPoint.y);
            CGPathAddLineToPoint(pathRef, nil, t_point2.x, t_point2.y);
            t_lastPoint = t_point;
            
            if (t_shouldDraw) {
                CGPathMoveToPoint(pathRef, nil, t_lastPoint.x, t_lastPoint.y);
                t_delta = [self systemOriginX] - kPaddingX;
                t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemRenalArteries: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = (kVesselDiameter + _bufferSize.width + _bufferSize.width);
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x - t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.height;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.width + _systemTwinSize.width;
                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y - _bufferSize.height);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathMoveToPoint(pathRef, nil, t_lastPoint.x, t_lastPoint.y - _bufferSize.height);
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.height;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemRightKidney:
        case JSKSystemLeftKidney: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            t_origin.x += _systemTwinSize.width;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = _systemTwinSize.width;
            CGRect t_frame = CGRectMake(t_origin.x - t_delta, t_origin.y, t_delta, _systemSize.height);
            if ((self.currentPointIndex + t_delta) > self.pointIndex) {
                t_frame.origin.x = t_origin.x - t_trim;
                t_frame.size.width = t_trim;
            }
            
            CGPathAddRect(pathRef, nil, t_frame);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_delta] forKey:[NSString stringWithFormat:@"%02d", system]];
            self.currentPointIndex += t_delta;
            break;
        }
            
        case JSKSystemRenalVeins: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = _bufferSize.height + kVesselDiameter;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.y = t_lastPoint.y + t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = t_lastPoint.x - kPaddingX;
                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            if (t_shouldDraw) {
                CGPoint t_refPoint = [self originForSystem:JSKSystemLeftKidney];
                t_refPoint.y += _systemSize.height;
                t_delta = _bufferSize.height + kVesselDiameter;
                t_point = CGPointMake(t_refPoint.x, t_refPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_refPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathMoveToPoint(pathRef, nil, t_refPoint.x, t_refPoint.y);
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemTesticularisArteries: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = (kVesselDiameter + _bufferSize.width + _bufferSize.width);
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x - t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemLowerBody: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            t_origin.x += _systemSize.width;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = _systemSize.width;
            CGRect t_frame = CGRectMake(t_origin.x - t_delta, t_origin.y, t_delta, _systemSize.height);
            if ((self.currentPointIndex + t_delta) > self.pointIndex) {
                t_frame.origin.x = t_origin.x - t_trim;
                t_frame.size.width = t_trim;
            }
            
            CGPathAddRect(pathRef, nil, t_frame);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_delta] forKey:[NSString stringWithFormat:@"%02d", system]];
            self.currentPointIndex += t_delta;
            break;
        }
            
        case JSKSystemTesticularisVeins: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = [self systemOriginX] - kPaddingX;
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x - t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemIliacArtieries: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = (kVesselDiameter + _bufferSize.width + _bufferSize.width);
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x - t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.height;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.width + _systemTwinSize.width;
                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y - _bufferSize.height);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathMoveToPoint(pathRef, nil, t_lastPoint.x, t_lastPoint.y - _bufferSize.height);
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            if (t_shouldDraw) {
                t_delta = _bufferSize.height;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemRightLeg:
        case JSKSystemLeftLeg: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            t_origin.x += _systemTwinSize.width;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = _systemTwinSize.width;
            CGRect t_frame = CGRectMake(t_origin.x - t_delta, t_origin.y, t_delta, _systemSize.height);
            if ((self.currentPointIndex + t_delta) > self.pointIndex) {
                t_frame.origin.x = t_origin.x - t_trim;
                t_frame.size.width = t_trim;
            }
            
            CGPathAddRect(pathRef, nil, t_frame);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_delta] forKey:[NSString stringWithFormat:@"%02d", system]];
            self.currentPointIndex += t_delta;
            break;
        }
            
        case JSKSystemIliacVeins: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = _bufferSize.height;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.y = t_lastPoint.y + t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = t_lastPoint.x - kPaddingX;
                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            if (t_shouldDraw) {
                CGPoint t_refPoint = [self originForSystem:JSKSystemLeftLeg];
                t_refPoint.y += _systemSize.height;
                t_delta = _bufferSize.height + kVesselDiameter;
                t_point = CGPointMake(t_refPoint.x, t_refPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_refPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathMoveToPoint(pathRef, nil, t_refPoint.x, t_refPoint.y);
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystem_MaxValue:
            break;
    }
}

- (NSString *)titleForSystem:(JSKSystem)system
{
    NSString *t_return = nil;
    switch (system) {
        case JSKSystemHeart:
            t_return = NSLocalizedString(@"Heart", @"Heart");
            break;
            
        case JSKSystemPulmonaryArtery:
            t_return = NSLocalizedString(@"Pulmonary Artery", @"Pulmonary Artery");
            break;
            
        case JSKSystemLeftLung:
            t_return = NSLocalizedString(@"Left Lung", @"Left Lung");
            break;
            
        case JSKSystemRightLung:
            t_return = NSLocalizedString(@"Right Lung", @"Right Lung");
            break;
            
        case JSKSystemPulmonaryVein:
            t_return = NSLocalizedString(@"Pulmonary Vein", @"Pulmonary Vein");
            break;
            
        case JSKSystemAorta:
            t_return = NSLocalizedString(@"Aorta", @"Aorta");
            break;
            
        case JSKSystemCarotidArteries:
            t_return = NSLocalizedString(@"Carotid Arteries", @"Carotid Arteries");
            break;
            
        case JSKSystemHead:
            t_return = NSLocalizedString(@"Head", @"Head");
            break;
            
        case JSKSystemJugularVeins:
            t_return = NSLocalizedString(@"Jugular Veins", @"Jugular Veins");
            break;
            
        case JSKSystemSuperiorVenaCava:
            t_return = NSLocalizedString(@"Superior Vena Cava", @"Superior Vena Cava");
            break;
            
        case JSKSystemSubclavianArteries:
            t_return = NSLocalizedString(@"Subclavian Arteries", @"Subclavian Arteries");
            break;
            
        case JSKSystemRightArm:
            t_return = NSLocalizedString(@"Right Arm", @"Right Arm");
            break;
            
        case JSKSystemLeftArm:
            t_return = NSLocalizedString(@"Left Arm", @"Left Arm");
            break;
            
        case JSKSystemSubclavianVeins:
            t_return = NSLocalizedString(@"Subclavian Veins", @"Subclavian Veins");
            break;
            
        case JSKSystemCeliacArtery:
            t_return = NSLocalizedString(@"Celiac Artery", @"Celiac Artery");
            break;
            
        case JSKSystemGut:
            t_return = NSLocalizedString(@"Gut", @"Gut");
            break;
            
        case JSKSystemHepaticPortalVein:
            t_return = NSLocalizedString(@"Hepatic Portal Vein", @"Hepatic Portal Vein");
            break;
            
        case JSKSystemHepaticArtery:
            t_return = NSLocalizedString(@"Hepatic Artery", @"Hepatic Artery");
            break;
            
        case JSKSystemLiver:
            t_return = NSLocalizedString(@"Liver", @"Liver");
            break;
            
        case JSKSystemHepaticVeins:
            t_return = NSLocalizedString(@"Hepatic Veins", @"Hepatic Veins");
            break;
            
        case JSKSystemInferiorVenaCava:
            t_return = NSLocalizedString(@"Inferior Vena Cava", @"Inferior Vena Cava");
            break;
            
        case JSKSystemRenalArteries:
            t_return = NSLocalizedString(@"Renal Arteries", @"Renal Arteries");
            break;
            
        case JSKSystemRightKidney:
            t_return = NSLocalizedString(@"Right Kidney", @"Right Kidney");
            break;
            
        case JSKSystemLeftKidney:
            t_return = NSLocalizedString(@"Left Kidney", @"Left Kidney");
            break;
            
        case JSKSystemRenalVeins:
            t_return = NSLocalizedString(@"Renal Veins", @"Renal Veins");
            break;
            
        case JSKSystemTesticularisArteries:
            t_return = NSLocalizedString(@"Testicularis Arteries", @"Testicularis Arteries");
            break;
            
        case JSKSystemLowerBody:
            t_return = NSLocalizedString(@"Lower Body", @"Lower Body");
            break;
            
        case JSKSystemTesticularisVeins:
            t_return = NSLocalizedString(@"Testicularis Veins", @"Testicularis Veins");
            break;
            
        case JSKSystemIliacArtieries:
            t_return = NSLocalizedString(@"Iliac Arteries", @"Iliac Arteries");
            break;
            
        case JSKSystemRightLeg:
            t_return = NSLocalizedString(@"Right Leg", @"Right Leg");
            break;
            
        case JSKSystemLeftLeg:
            t_return = NSLocalizedString(@"Left Leg", @"Left Leg");
            break;
            
        case JSKSystemIliacVeins:
            t_return = NSLocalizedString(@"Iliac Veins", @"Iliac Veins");
            break;
            
        case JSKSystem_MaxValue:
            break;
    }
    return t_return;
}

- (CGPoint)originForSystem:(JSKSystem)system
{
    CGPoint t_return = CGPointZero;
    switch (system) {
        case JSKSystemHeart: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            CGFloat t_y = t_refPoint.y + (_systemSize.height * 3) + ((_bufferSize.height + kVesselDiameter + _bufferSize.height) * 3) + (kVesselDiameter + _bufferSize.height);
            t_return = CGPointMake([self systemOriginX], t_y);
            break;
        }
            
        case JSKSystemPulmonaryArtery: {
            CGPoint t_heartPoint = [self originForSystem:JSKSystemHeart];
            CGFloat t_delta = kVesselOffset;
            t_return = CGPointMake(t_heartPoint.x, t_heartPoint.y + t_delta);
            break;
        }
            
        case JSKSystemLeftLung: {
            CGPoint t_heartPoint = [self originForSystem:JSKSystemHeart];
            CGFloat t_delta = (_bufferSize.height + kVesselDiameter + _bufferSize.height) + _systemSize.height;
            t_return = CGPointMake(t_heartPoint.x, t_heartPoint.y - t_delta);
            break;
        }
        
        case JSKSystemRightLung: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemLeftLung];
            t_return = CGPointMake([self systemTwinOriginX], t_refPoint.y);
            break;
        }
        
        case JSKSystemPulmonaryVein: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemLeftLung];
            t_return = CGPointMake(t_refPoint.x + _systemTwinSize.width, t_refPoint.y + _systemSize.height);
            break;
        }
            
        case JSKSystemAorta: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            t_return = CGPointMake(t_refPoint.x + _systemSize.width, t_refPoint.y + _systemSize.height);
            break;
        }
        
        case JSKSystemCarotidArteries: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            t_return = CGPointMake(t_refPoint.x + _systemSize.width + (kVesselDiameter + _bufferSize.width + _bufferSize.width), t_refPoint.y + _systemSize.height);
            break;
        }
    
        case JSKSystemHead:
            t_return = CGPointMake([self systemOriginX], kWallThickness);
            break;
            
        case JSKSystemJugularVeins:
            t_return = CGPointMake([self systemOriginX], _systemSize.height + kWallThickness);
            break;
            
        case JSKSystemSuperiorVenaCava:
            t_return = CGPointMake(kPaddingX, _systemSize.height);
            break;
            
        case JSKSystemSubclavianArteries: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemCarotidArteries];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _bufferSize.height + kVesselDiameter);
            break;
        }
            
        case JSKSystemRightArm:{
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            t_return = CGPointMake([self systemTwinOriginX], t_refPoint.y + (_systemSize.height + _bufferSize.height + kVesselDiameter + _bufferSize.height));
            break;
        }
            
        case JSKSystemLeftArm: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            t_return = CGPointMake([self systemOriginX], t_refPoint.y + (_systemSize.height + _bufferSize.height + kVesselDiameter + _bufferSize.height));
            break;
        }
            
        case JSKSystemSubclavianVeins: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemRightArm];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _systemSize.height);
            break;
        }
        
        case JSKSystemCeliacArtery: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            t_return = CGPointMake(t_refPoint.x + _systemSize.width + (kVesselDiameter + _bufferSize.width) + _bufferSize.width, t_refPoint.y + _systemSize.height + _bufferSize.height + kVesselDiameter);
            break;
        }
            
        case JSKSystemGut: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            t_return = CGPointMake([self systemTwinOriginX], t_refPoint.y + _systemSize.height + _bufferSize.height + kVesselDiameter + _bufferSize.height);
            break;
        }
        
        case JSKSystemHepaticPortalVein: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemGut];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _systemSize.height);
            break;
        }
            
        case JSKSystemHepaticArtery: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemGut];
            t_return = CGPointMake(t_refPoint.x + _systemTwinSize.width, t_refPoint.y - _bufferSize.height);
            break;
        }
            
        case JSKSystemLiver: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemGut];
            t_return = CGPointMake([self systemOriginX], t_refPoint.y);
            break;
        }
            
        case JSKSystemHepaticVeins: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemLiver];
            t_return = CGPointMake([self systemOriginX], t_refPoint.y + _systemSize.height);
            break;
        }
            
        case JSKSystemInferiorVenaCava: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHepaticVeins];
            t_return = CGPointMake(kPaddingX, t_refPoint.y);
            break;
        }
            
        case JSKSystemRenalArteries: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemCeliacArtery];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _systemSize.height + (_bufferSize.height + kVesselDiameter + _bufferSize.height) + _bufferSize.height);
            break;
        }
        
        case JSKSystemRightKidney: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemRenalArteries];
            t_return = CGPointMake([self systemTwinOriginX], t_refPoint.y + _bufferSize.height);
            break;
        }
        
        case JSKSystemLeftKidney: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemRenalArteries];
            t_return = CGPointMake([self systemOriginX], t_refPoint.y + _bufferSize.height);
            break;
        }
        
        case JSKSystemRenalVeins: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemRightKidney];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _systemSize.height);
            break;
        }
        
        case JSKSystemTesticularisArteries: {
            CGPoint t_renalVeinPoint = [self originForSystem:JSKSystemRenalVeins];
            CGPoint t_renalArteryPoint = [self originForSystem:JSKSystemRenalArteries];
            t_return = CGPointMake(t_renalArteryPoint.x, t_renalVeinPoint.y + _bufferSize.height + kVesselDiameter + _bufferSize.height);
            break;
        }
        
        case JSKSystemLowerBody: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemLeftKidney];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _systemSize.height + _bufferSize.height + kVesselDiameter + _bufferSize.height);
            break;
        }
            
        case JSKSystemTesticularisVeins: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemLowerBody];
            t_return = CGPointMake([self systemOriginX], t_refPoint.y + _systemSize.height);
            break;
        }
        
        case JSKSystemIliacArtieries: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemTesticularisArteries];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _systemSize.height + _bufferSize.height);
            break;
        }
        
        case JSKSystemRightLeg: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemIliacArtieries];
            CGFloat t_deltaY = (_bufferSize.height);
            t_return = CGPointMake([self systemTwinOriginX], t_refPoint.y + t_deltaY);
            break;
        }
            
        case JSKSystemLeftLeg: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemRightLeg];
            t_return = CGPointMake([self systemOriginX], t_refPoint.y);
            break;
        }
            
        case JSKSystemIliacVeins: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemRightLeg];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _systemSize.height);
            break;
        }
            
        case JSKSystem_MaxValue:
            break;
    }
    return t_return;
}

- (NSUInteger)calculatePointCount
{
    NSUInteger t_count = 0;
    
    for (JSKSystem t_system = 0; t_system < JSKSystem_MaxValue; t_system++)
        t_count += [self pointCountForSystem:t_system];
    
    t_count += 250;
    
//    t_count += [self pointCountForSystem:JSKSystemHeart];
//    t_count += [self pointCountForSystem:JSKSystemPulmonaryArtery];
//    t_count += [self pointCountForSystem:JSKSystemLeftLung];
//    t_count += [self pointCountForSystem:JSKSystemRightLung];
//    t_count += [self pointCountForSystem:JSKSystemPulmonaryVein];
//    t_count += [self pointCountForSystem:JSKSystemAorta];
//    t_count += [self pointCountForSystem:JSKSystemCarotidArteries];
//    t_count += [self pointCountForSystem:JSKSystemHead];
//    t_count += [self pointCountForSystem:JSKSystemJugularVeins];
//    t_count += [self pointCountForSystem:JSKSystemSuperiorVenaCava];
//    t_count += [self pointCountForSystem:JSKSystemSubclavianArteries];
//    t_count += [self pointCountForSystem:JSKSystemRightArm];
//    t_count += [self pointCountForSystem:JSKSystemLeftArm];
//    t_count += [self pointCountForSystem:JSKSystemSubclavianVeins];
//    t_count += [self pointCountForSystem:JSKSystemCeliacArtery];
//    t_count += [self pointCountForSystem:JSKSystemGut];
//    t_count += [self pointCountForSystem:JSKSystemHepaticPortalVein];
//    t_count += [self pointCountForSystem:JSKSystemHepaticArtery];
//    t_count += [self pointCountForSystem:JSKSystemLiver];
//    t_count += [self pointCountForSystem:JSKSystemHepaticVeins];
//    t_count += [self pointCountForSystem:JSKSystemInferiorVenaCava];
//    t_count += [self pointCountForSystem:JSKSystemRenalArteries];
//    t_count += [self pointCountForSystem:JSKSystemRightKidney];
//    t_count += [self pointCountForSystem:JSKSystemLeftKidney];
//    t_count += [self pointCountForSystem:JSKSystemRenalVeins];
//    t_count += [self pointCountForSystem:JSKSystemTesticularisArteries];
//    t_count += [self pointCountForSystem:JSKSystemLowerBody];
//    t_count += [self pointCountForSystem:JSKSystemTesticularisVeins];
//    t_count += [self pointCountForSystem:JSKSystemIliacArtieries];
//    t_count += [self pointCountForSystem:JSKSystemRightLeg];
//    t_count += [self pointCountForSystem:JSKSystemLeftLeg];
//    t_count += [self pointCountForSystem:JSKSystemIliacVeins];
    
    return t_count;
}

- (void)setPointIndex:(NSUInteger)pointIndex
{
    _pointIndex = pointIndex;
    [self setNeedsDisplay];
}

- (void)setLabelsHidden:(BOOL)labelsHidden
{
    _labelsHidden = labelsHidden;
    [self setNeedsDisplay];
}

- (CGFloat)systemOriginX
{
    return kPaddingX + ((kVesselDiameter + _bufferSize.width) * 2);
}

- (CGFloat)systemTwinWidth {
    return (_systemSize.width / 2) - (_bufferSize.width / 2);
}

- (CGFloat)systemTwinOriginX
{
    return [self systemOriginX] + [self systemTwinWidth] + _bufferSize.width;
}

- (NSUInteger)pointCountForSystem:(JSKSystem)system
{
    NSUInteger t_return = 0;
    
    NSString *t_magicNumberString = @"300,387,139,139,279,408,46,300,48,369,251,139,139,257,68,139,70,183,139,48,408,251,139,139,257,46,300,48,251,139,139,255";
    if (self.bounds.size.width <= kPhoneWidth)
        t_magicNumberString = @"200,245,93,93,185,232,30,200,32,209,165,93,93,171,44,93,46,121,93,32,232,165,93,93,171,30,200,32,165,93,93,169";
    
    NSArray *t_magicNumbers = [t_magicNumberString componentsSeparatedByString:@","];
    
    if (system < t_magicNumbers.count)
        t_return = [[t_magicNumbers objectAtIndex:system] integerValue];
    
    
//    t_return += 275;
    
    return t_return;
}

@end

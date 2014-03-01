//
//  JSKCirculatoryView.h
//  Circulate
//
//  Created by Joshua Kaden on 2/12/14.
//  Copyright (c) 2014 Chadford Software. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    JSKSystemHeart,
    JSKSystemPulmonaryArtery,
    JSKSystemLeftLung,
    JSKSystemRightLung,
    JSKSystemPulmonaryVein,
    JSKSystemAorta,
    JSKSystemCarotidArteries,
    JSKSystemHead,
    JSKSystemJugularVeins,
    JSKSystemSuperiorVenaCava,
    JSKSystemSubclavianArteries,
    JSKSystemRightArm,
    JSKSystemLeftArm,
    JSKSystemSubclavianVeins,
    JSKSystemCeliacArtery,
    JSKSystemGut,
    JSKSystemHepaticPortalVein,
    JSKSystemHepaticArtery,
    JSKSystemLiver,
    JSKSystemHepaticVeins,
    JSKSystemInferiorVenaCava,
    JSKSystemRenalArteries,
    JSKSystemRightKidney,
    JSKSystemLeftKidney,
    JSKSystemRenalVeins,
    JSKSystemGonadalArteries,
    JSKSystemLowerBody,
    JSKSystemGonadalVeins,
    JSKSystemIliacArtieries,
    JSKSystemRightLeg,
    JSKSystemLeftLeg,
    JSKSystemIliacVeins,
    JSKSystem_MaxValue
} JSKSystem;

typedef enum {
    JSKSystemTypeArtery,
    JSKSystemTypeVein,
    JSKSystemTypeSystem,
    JSKSystemType_MaxValue
} JSKSystemType;

@interface JSKCirculatoryView : UIView

@property (readonly) NSUInteger pointCount;
@property (nonatomic, assign) NSUInteger pointIndex;

@property (nonatomic, assign) BOOL labelsHidden;

@property (readonly) BOOL isAnimating;

- (void)startAnimating;
- (void)stopAnimating;

@end

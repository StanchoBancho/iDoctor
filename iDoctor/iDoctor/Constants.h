//
//  Constants.h
//  iDoctor
//
//  Created by Stanimir Nikolov on 1/8/14.
//  Copyright (c) 2014 Stanimir Nikolov. All rights reserved.
//

#ifndef iDoctor_Constants_h
#define iDoctor_Constants_h

#define kAutocorectionType @"AutocorectionType"
#define kAutocompetionType @"AutocompetionType"

#define kWrongWordKey @"wrongWord"
#define kAutoCorrectedWordKey @"autocorection"

typedef NS_ENUM(NSInteger, AutocorectionType){
    AutocorectionTypeNGram = 1,
    AutocorectionEditDistance,
    AutocorectionThird
};

typedef NS_ENUM(NSInteger, AutocompetionType){
    AutocompetionTypeLinear = 1,
    AutocompetionType23Tree
};

#define kMedicineNameKey @"name"
#define kMedicineIsExistingKey @"isExisting"
#define kMedicineNoteKey @"notes"

#endif

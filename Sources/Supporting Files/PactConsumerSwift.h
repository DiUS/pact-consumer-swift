//
//  PactConsumerSwift.h
//  PactConsumerSwift
//
//  Created by Marko Justinek on 22/9/17.
//

#import <Foundation/Foundation.h>

//! Project version number for PactConsumerSwift.
FOUNDATION_EXPORT double PactConsumerSwift_VersionNumber;

//! Project version string for PactConsumerSwift.
FOUNDATION_EXPORT const unsigned char PactConsumerSwift_VersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <PactConsumerSwift/PublicHeader.h>

#if TARGET_OS_OSX
    #import "PactConsumerSwift/pact_mock_server_mac_os.h"
#elif TARGET_OS_SIMULATOR
    #import "PactConsumerSwift/pact_mock_server_ios_sim.h"
#else
    #import "PactConsumerSwift/pact_mock_server_arm.h"
#endif

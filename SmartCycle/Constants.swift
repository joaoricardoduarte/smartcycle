//
//  Constants.swift
//  Pause
//
//  Created by Joao Duarte on 21/06/2016.
//  Copyright © 2016 Joao Duarte. All rights reserved.
//

struct Constants {

    struct Storyboard {
        struct ViewController {
            static let HomeViewController           = "HomeViewController"
            static let LoginViewController          = "LoginViewController"
            static let ParkViewController           = "ParkViewController"
            static let ShopViewController           = "ShopViewController"
        }

        struct Segue {
            static let HomeSegue                    = "HomeSegue"
            static let ParkedBikeSegue              = "ParkedBikeSegue"
            static let SignUpCompleteSegue          = "SignUpCompleteSegue"
            static let MissingBikeSegue             = "MissingBikeSegue"
            static let ConfirmDetailsSegue          = "ConfirmDetailsSegue"
            static let ReportTermsSegue             = "ReportTermsSegue"
        }

        static let MainStoryboard                   = "Main"
    }

    struct UserDefaults {
        static let BikeParkedData                   = "BikeParkedData"
        static let UserData                         = "UserData"
    }

    struct Variables {
        static let DefaultRadius                    = 1 //miles
        static let MaxRadius                        = 10
    }

    struct Keys {
        static let DigitalTownClientId              = "35brgxkj1748oo9yowlnev8pd"
        static let DigitalTownSecret                = "jNSAwWyqmPala8eQjr0lMQ6lCoM9I70ZQkCwe1XJ"

        // Cloudinary Dev
//        static let CloudinaryUsername               = "joaoduarte"
//        static let CloudinaryAPIKey                 = "138877638155137"

        // Cloudinary Prod
        static let CloudinaryUsername               = "smartcycle-london"
        static let CloudinaryAPIKey                 = "339667656758933"
        static let CloudinarySecret                 = "frYJYuEzuE_PhuWiI7_yZtw-DvA"

        static let GoogleAnalyticsKey               = "UA-104028998-1"
    }

    struct DateFormat {
        static let SimpleDateFormat                 = "dd MMM yyyy"
        static let SimpleDateReverseFormat          = "yyyy-MM-dd"
    }

    struct Urls {
        static let DigitalTownUrl                   = "https://api.digitaltown.com/"
        static let SmartcycleAPIUrl                 = "https://api.smartcycle.london/"
    }

    struct Notifications {
        static let ReportMissingCompleteNotification = "ReportMissingCompleteNotification"
    }
}

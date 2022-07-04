workspace "MYS" "Monitor Your Satellites" {

    !identifiers hierarchical

    model {
        spaceTrack = person "SpaceTrack"
        caa = person "Civilian Aviation Authority"
        satelliteOperators = person "Satellite Operators"
        orbitalAnalysts = person "Orbital Analysts"
        ukSA = person "UK Space Agency"

        enterprise "Gov.UK PaaS" {

            mys = softwareSystem "Monitor Your Satellites" {

                web = container "Web Application" "nodeJS in Nx Framework"
                api = container "API Application" "Python in FastAPI Framework"
                spaceTrack = container "SpaceTrack Application" "Python in FastAPI Framework"
                db = container "Database" "Postgres 13 in RDS"
                s3 = container "Filestore" "s3 Bucket"

                //Container relationships
                web -> api "Calls"
                mys.spaceTrack -> db "Uses for structured data"
                mys.spaceTrack -> s3 "Uses for unstructured data"
                api -> db "Uses for structured data"
                api -> s3 "Uses for unstructured data"

            }
        }

        auth0 = softwareSystem "Auth0"
        piwikPro = softwareSystem "Piwik Pro"
        logitIO = softwareSystem "LogitIO"
        sentry = softwareSystem "Sentry"
        gitHub = softwareSystem "GitHub"

        //Software Relationships
        mys -> auth0 "Uses for Authentication"
        mys -> piwikPro "Uses for Web Analytics"
        mys -> logitIO "Uses for Logging"
        mys -> sentry "Uses for Security Logging and Alerting"
        mys -> gitHub "Uses for Code Versioning and CI/CD"

        //People Relationships
        spaceTrack -> mys "Feeds Conjunction Messages"
        caa -> ukSA "Regulates"
        caa -> satelliteOperators "Regulates"
        satelliteOperators -> mys "Feeds Satellite Ephemeris"
        mys -> satelliteOperators "Notifies for Conjunction Events"
        ukSA -> mys "Operates"
        orbitalAnalysts -> mys "Feeds refined Conjunction Event analysis"
        mys -> orbitalAnalysts "Notifies for Conjunction Events"
        orbitalAnalysts -> ukSA "Work for"
    }
    views {
        theme default

        systemLandscape "SystemLandscape" {
            include *
        }

        container mys "MonitorYourSatellites" {
            include *
        }

    }
}
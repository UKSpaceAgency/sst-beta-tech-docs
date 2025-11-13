// ====================================================== //
// Workspace: Monitor Your Satellites (MYS)             //
// Purpose: Models the architecture for the MYS system  //
// ====================================================== //

workspace "MYS" "Monitor Your Satellites" {

    !identifiers hierarchical

    // ----------------------------- //
    // Model Section                 //
    // ----------------------------- //
    model {

        // ---- People / External Actors ---- //
        spaceTrack = person "SpaceTrack" "Provides conjunction data messages."
        caa = person "Civilian Aviation Authority" "Regulates satellite operators."
        satelliteOperators = person "Satellite Operators" "Operate satellites in orbit."
        orbitalAnalysts = person "Orbital Analysts" "Analyse conjunction and orbital data."
        ukSA = person "UK Space Agency" "Operates and oversees MYS system."

        // ---- Internal Enterprise Boundary ---- //
        group "Gov.UK PaaS" {

            // ---- Core System ---- //
            mys = softwareSystem "Monitor Your Satellites" "System for monitoring satellite conjunctions and orbital events." {

                // ---- Containers ---- //

                // Backend API exposing system functionality
                api = container "API Application" "Python FastAPI backend" {

                    // ---- Components ---- //

                    // Space Objects Domain
                    group "Space Objects" {
                        // Manages satellite metadata and organisation mapping
                        satellite = component "Satellite Component" "Manages satellite metadata and organisation mapping"
                        // Handles upload and retrieval of ephemeris (.oem) files
                        ephemeris = component "Ephemeris Component" "Handles ephemeris file uploads and retrieval"
                        // Retrieves conjunction data message metadata from SpaceTrack
                        cdm = component "CDM Component" "Retrieves conjunction data message metadata"
                    }

                    // Events Domain
                    group "Events" {
                        // Manages conjunction events, alerts, and analyses
                        conjunctionEvents = component "Conjunction Event Component" "Manages conjunction events and alerts"
                        // Handles reentry event reports and notifications
                        reentryEvents = component "Reentry Events Component" "Handles reentry event notifications"
                        // Handles fragmentation event data and reports
                        fragmentationEvents = component "Fragmentation Events Component" "Processes fragmentation events"
                    }

                    // Analysis Domain
                    group "Analysis" {
                        // Uploads and manages orbital analysis JSON files
                        orbitalAnalyses = component "Orbital Analyses Component" "Manages orbital analysis files"
                        // Provides system-wide and per-entity statistics
                        statistics = component "Statistics Component" "Provides system-wide and per-entity stats"
                        // Tracks performance of external data sources
                        externalDataPerformance = component "External Datasource Performance Component" "Monitors external data sources"
                    }

                    // User & Organisation Domain
                    group "User & Organisation" {
                        // Manages user accounts, authentication, and alert preferences
                        users = component "User Management Component" "Manages user accounts and alert preferences"
                        // Manages organisation-level data and relationships
                        organizations = component "Organization Component" "Manages organisation data and relationships"
                        // Handles email/SMS alerts and analyst contact messages
                        messagesAlerts = component "Message & Alerts Component" "Handles email/SMS alerts"
                    }

                    // Support Domain
                    group "Support" {
                        // Displays and schedules in-app banner messages
                        banners = component "Banner Component" "Displays in-app banners"
                        // Handles tracking and impact prediction message uploads
                        tip = component "Tracking Impact Prediction Component" "Processes tracking impact predictions"
                        // Provides service health monitoring endpoints
                        healthCheck = component "Health Check Component" "Monitors system health"
                    }

                }

                // Central data producer pulling from SpaceTrack and writing to S3 (Prod Account)
                producer = container "Central Producer Application" "FastAPI ingestion app (pulls SpaceTrack data and writes to S3)"

                // Object storage for raw unstructured data
                s3 = container "Filestore (S3 Bucket)" "AWS S3"

                // SNS Topic to notify S3 object creation
                sns = container "SNS Topic" "AWS SNS"

                // SQS queues in each account
                group "SQS Queues" {
                    sqs_prod = container "SQS Queue (Prod)" "AWS SQS"
                    sqs_demo = container "SQS Queue (Demo)" "AWS SQS"
                    sqs_dev = container "SQS Queue (Dev)" "AWS SQS"
                }

                // ---- Group Web Frontends ----
                group "Web Frontends" {
                    web_dev = container "Web Application (Dev)" "Next.js frontend for Dev environment"
                    web_demo = container "Web Application (Demo)" "Next.js frontend for Demo environment"
                    web_prod = container "Web Application (Prod)" "Next.js frontend for Prod environment"
                }

                // ---- Group ECS Consumers ----
                group "ECS Consumers" {
                    ecs_consumer_dev = container "ECS Consumer (Dev)" "Python ECS Fargate Task"
                    ecs_consumer_demo = container "ECS Consumer (Demo)" "Python ECS Fargate Task"
                    ecs_consumer_prod = container "ECS Consumer (Prod)" "Python ECS Fargate Task"
                }

                // ---- Group Databases ----
                group "Databases" {
                    db_dev = container "Database (Dev)" "Aurora Serverless PostgreSQL 15 (Dev)"
                    db_demo = container "Database (Demo)" "Aurora Serverless PostgreSQL 15 (Demo)"
                    db_prod = container "Database (Prod)" "Aurora Serverless PostgreSQL 15 (Prod)"
                }

                // ---- Container Relationships ---- //
                
                // User/API Flow
                web_dev -> api "Requests data"
                web_demo -> api "Requests data"
                web_prod -> api "Requests data"

                api -> db_prod "Reads Prod data"
                api -> db_demo "Reads Demo data"
                api -> db_dev "Reads Dev data"

                // Data Ingestion Flow
                producer -> s3 "Stores raw data"
                s3 -> sns "Publishes events"

                sns -> sqs_prod "Notifies Prod queue"
                sns -> sqs_demo "Notifies Demo queue"
                sns -> sqs_dev "Notifies Dev queue"

                ecs_consumer_prod -> sqs_prod "Polling"
                ecs_consumer_demo -> sqs_demo "Polling"
                ecs_consumer_dev -> sqs_dev "Polling"

                ecs_consumer_prod -> db_prod "Writes data"
                ecs_consumer_demo -> db_demo "Writes data"
                ecs_consumer_dev -> db_dev "Writes data"

            }
        }

        // ---- External Software Systems ----
        auth0 = softwareSystem "Auth0" "Authentication and identity provider."
        cosmic = softwareSystem "Cosmic" "CMS for web content management."
        googleAnalytics = softwareSystem "Google Analytics" "Web analytics service."
        awsCloudWatch = softwareSystem "AWS CloudWatch" "Monitoring and observability service."
        sentry = softwareSystem "Sentry" "Security and error monitoring tool."
        gitHub = softwareSystem "GitHub" "Code hosting and CI/CD platform."

        // ---- Software Relationships ----
        mys -> auth0 "Uses for Authentication"
        mys -> googleAnalytics "Uses for Web Analytics"
        mys -> cosmic "CMS Integration"
        mys -> awsCloudWatch "Uses for Logging"
        mys -> sentry "Uses for Security Logging and Alerts"
        mys -> gitHub "Uses for Code Versioning and CI/CD"

        // ---- People Relationships ----
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

    // -----------------------------
    // Views Section
    // -----------------------------
    views {
        theme default

        systemLandscape "SystemLandscape" {
            include *
        }

        container mys "MonitorYourSatellites" {
            include *
        }

        component mys.api "ApiComponents" {
            include *
        }
    }
}

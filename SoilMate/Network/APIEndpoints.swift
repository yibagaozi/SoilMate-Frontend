//
//  APIEndpoints.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

enum APIEndpoints {

    // Change this to your server address
    #if DEBUG
    static let baseURL = "http://localhost:8080"
    #else
    static let baseURL = "https://api.soilmate.com"
    #endif

    // -- Auth --
    static let register = "/auth/register"
    static let login = "/auth/login"
    static let refresh = "/auth/refresh"

    // -- User --
    static let myProfile = "/users/me"

    // -- Plants (master catalog) --
    static func plant(id: Int64) -> String { "/plants/\(id)" }
    static func plantByBarcode(code: String) -> String { "/plants/barcode/\(code)" }

    // -- User Plants (my garden) --
    static let userPlants = "/user-plants"
    static func userPlant(id: Int64) -> String { "/user-plants/\(id)" }

    // -- Care Tasks --
    static let todayTasks = "/care-task/today"
    static let upcomingTasks = "/care-task/upcoming"
    static let tasksByDate = "/care-task"  // ?date=2025-04-20
    static func completeTask(id: Int64) -> String { "/care-task/\(id)/complete" }
    static func skipTask(id: Int64) -> String { "/care-task/\(id)/skip" }

    // -- Care Logs --
    static let careLogs = "/care-log"  // GET ?date=...&userPlantId=...  or POST
}







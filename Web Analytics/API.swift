//
//  API.swift
//  Web Analytics
//
//  Created by Karol Bąk on 20/10/2024.
//
import SwiftUI
import SwiftyJSON

enum HttpError: Error {
    case invalidResponse
}

class API {
    private var settings: Settings
    private let periodsHelper = PeriodsHelper()
    
    init(settings: Settings) {
        self.settings = settings
    }
    
    func fetchPageList() async throws -> [Page]{
        let json = try await request(url: "https://api.cloudflare.com/client/v4/accounts/\(settings.accountID)/rum/site_info/list", method: "GET")
        return json["result"].arrayValue.map { Page(json: $0) }
    }
    
    func fetchPage(page: Page, period: Period) async throws -> DetailsResponse {
        let dateRange = period.range()
        let variables = [
            "accountTag": settings.accountID,
            "filter": [
                "AND": [
                    [
                        "bot": 0
                    ],
                    [
                        "datetime_geq": "\(periodsHelper.dateFormatter.string(from: dateRange[0]))T00:00:00Z",
                        "datetime_leq": "\(periodsHelper.dateFormatter.string(from: dateRange[1]))T23:59:59Z"
                    ],
                    [
                        "siteTag": "\(page.siteTag)"
                    ]
                ]
            ],
            "filterPrev": [
                "AND": [
                    [
                        "bot": 0
                    ],
                    [
                        "datetime_geq": "\(periodsHelper.dateFormatter.string(from: dateRange[2]))T00:00:00Z",
                        "datetime_leq": "\(periodsHelper.dateFormatter.string(from: dateRange[3]))T23:59:59Z"
                    ],
                    [
                        "siteTag": "\(page.siteTag)"
                    ]
                ]
            ]
        ] as [String : Any]
        let body = ["query": graphQLQuery(period.dateFrame.stringValue), "variables": variables] as [String : Any]
        let json = try await request(url: "https://api.cloudflare.com/client/v4/graphql", method: "POST", body: body)
        return DetailsResponse(json: json)
    }
    
    func fetchTotals() async throws -> TotalsResponse {
        let variables = [
            "accountTag": settings.accountID,
            "today": [
                "AND": [
                    [
                        "bot": 0
                    ],
                    [
                        "datetime_geq": "\(periodsHelper.dateFormatter.string(from: periodsHelper.get(.today).range()[0]))T00:00:00Z",
                        "datetime_leq": "\(periodsHelper.dateFormatter.string(from: periodsHelper.get(.today).range()[1]))T23:59:59Z"
                    ],
                ]
            ],
            "yesterday": [
                "AND": [
                    [
                        "bot": 0
                    ],
                    [
                        "datetime_geq": "\(periodsHelper.dateFormatter.string(from: periodsHelper.get(.yesterday).range()[0]))T00:00:00Z",
                        "datetime_leq": "\(periodsHelper.dateFormatter.string(from: periodsHelper.get(.yesterday).range()[1]))T23:59:59Z"
                    ],
                ]
            ],
            "yesterdayPrev": [
                "AND": [
                    [
                        "bot": 0
                    ],
                    [
                        "datetime_geq": "\(periodsHelper.dateFormatter.string(from: periodsHelper.get(.yesterday).range()[2]))T00:00:00Z",
                        "datetime_leq": "\(periodsHelper.dateFormatter.string(from: periodsHelper.get(.yesterday).range()[3]))T23:59:59Z"
                    ],
                ]
            ],
            "last7Days": [
                "AND": [
                    [
                        "bot": 0
                    ],
                    [
                        "datetime_geq": "\(periodsHelper.dateFormatter.string(from: periodsHelper.get(.last7Days).range()[0]))T00:00:00Z",
                        "datetime_leq": "\(periodsHelper.dateFormatter.string(from: periodsHelper.get(.last7Days).range()[1]))T23:59:59Z"
                    ],
                ]
            ],
            "last7DaysPrev": [
                "AND": [
                    [
                        "bot": 0
                    ],
                    [
                        "datetime_geq": "\(periodsHelper.dateFormatter.string(from: periodsHelper.get(.last7Days).range()[2]))T00:00:00Z",
                        "datetime_leq": "\(periodsHelper.dateFormatter.string(from: periodsHelper.get(.last7Days).range()[3]))T23:59:59Z"
                    ],
                ]
            ],
        ] as [String : Any]
        let body = ["query": graphQLTotalQuery(), "variables": variables] as [String : Any]
        let json = try await request(url: "https://api.cloudflare.com/client/v4/graphql", method: "POST", body: body)
        return TotalsResponse(json: json)
    }
    
    private func request(url: String, method: String, body: [String: Any] = [:]) async throws -> JSON {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        if !body.isEmpty {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        request.httpMethod = method
        request.setValue("Bearer \(settings.token)", forHTTPHeaderField: "Authorization")
        let urlSession = URLSession.shared
        let (data, response) = try await urlSession.data(for: request)
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200 {
            throw HttpError.invalidResponse
        }
        return JSON(data)
    }
    
    private func graphQLQuery(_ ts: String) -> String {
        return """
        {
          viewer {
            accounts(filter: { accountTag: $accountTag }) {
              totalsPrev: rumPageloadEventsAdaptiveGroups(limit: 1, filter: $filterPrev) {
                count
                sum {
                  visits
                }
              }
              refferers: rumPageloadEventsAdaptiveGroups(
                filter: $filter
                limit: 10
                orderBy: ["sum_visits_DESC"]
              ) {
                sum {
                  visits # based on visits
                }
                dimensions {
                  metric: refererHost
                }
              }
              paths: rumPageloadEventsAdaptiveGroups(
                filter: $filter
                limit: 10
                orderBy: ["count_DESC"]
              ) {
                count # based od page views
                dimensions {
                  metric: requestPath
                }
              }
              browsers: rumPageloadEventsAdaptiveGroups(
                filter: $filter
                limit: 10
                orderBy: ["sum_visits_DESC"]
              ) {
                sum {
                  visits # based on visits
                }
                dimensions {
                  metric: userAgentBrowser
                }
              }
              os: rumPageloadEventsAdaptiveGroups(
                filter: $filter
                limit: 10
                orderBy: ["sum_visits_DESC"]
              ) {
                sum {
                  visits # based on visits
                }
                dimensions {
                  metric: userAgentOS
                }
              }
              device: rumPageloadEventsAdaptiveGroups(
                filter: $filter
                limit: 10
                orderBy: ["sum_visits_DESC"]
              ) {
                sum {
                  visits # based on visits
                }
                dimensions {
                  metric: deviceType
                }
              }
              countries: rumPageloadEventsAdaptiveGroups(
                filter: $filter
                limit: 10
                orderBy: ["sum_visits_DESC"]
              ) {
                sum {
                  visits
                }
                dimensions {
                  metric: countryName
                }
              }
              series: rumPageloadEventsAdaptiveGroups(limit: 5000, filter: $filter) {
                count
                sum {
                  visits
                }
                dimensions {
                  ts: \(ts)
                }
              }
            }
          }
        }
        """
    }
    
    private func graphQLTotalQuery() -> String {
        return """
        {
          viewer {
            accounts(filter: { accountTag: $accountTag }) {
              today: rumPageloadEventsAdaptiveGroups(limit: 100, filter: $today) {
                count
                sum {
                  visits
                }
                dimensions { 
                  siteTag
                }
              }
              yesterday: rumPageloadEventsAdaptiveGroups(limit: 100, filter: $yesterday) {
                count
                sum {
                  visits
                }
                dimensions { 
                  siteTag
                }
              }
              yesterdayPrev: rumPageloadEventsAdaptiveGroups(limit: 100, filter: $yesterdayPrev) {
                count
                sum {
                  visits
                }
                dimensions { 
                  siteTag
                }
              }
              last7Days: rumPageloadEventsAdaptiveGroups(limit: 100, filter: $last7Days) {
                count
                sum {
                  visits
                }
                dimensions { 
                  siteTag
                }
              }
              last7DaysPrev: rumPageloadEventsAdaptiveGroups(limit: 100, filter: $last7DaysPrev) {
                count
                sum {
                  visits
                }
                dimensions { 
                  siteTag
                }
              }
            }
          }
        }
        """
    }
}

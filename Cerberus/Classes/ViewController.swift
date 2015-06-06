//
//  ViewController.swift
//  Cerberus
//
//  Created by Jiro Nagashima on 2015/06/06.
//  Copyright (c) 2015年 Wantedly, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
  private var calendarService: GTLServiceCalendar? = nil
  
  private struct Info {
    static let KeychainItemName: String = "Google Calendar Quickstart"
    static let ClientID: String = "471729737785-afj9pm15fr15bdckafs1e2gov2dalo6i.apps.googleusercontent.com"
    static let ClientSecret: String = "U_ktuvJO0RGOl-6p1PXuwLPq"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 端末に保存されている情報を読み込む
    calendarService = GTLServiceCalendar.init()
    calendarService?.authorizer = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
      Info.KeychainItemName,
      clientID: Info.ClientID,
      clientSecret: Info.ClientSecret)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    // 認証がまだなら認証画面を出す. 認証済みならデータを取得
    if let canAuthorize = calendarService?.authorizer.canAuthorize {
      if !canAuthorize {
        self.presentViewController(createAuthController(), animated: true, completion: nil)
      } else {
        fetchEvents()
      }
    }
  }
  
  // 認証画面を作成して返す
  private func createAuthController() -> GTMOAuth2ViewControllerTouch{
    let authController = GTMOAuth2ViewControllerTouch(
      scope: kGTLAuthScopeCalendarReadonly,
      clientID: Info.ClientID,
      clientSecret: Info.ClientSecret,
      keychainItemName: Info.KeychainItemName,
      delegate: self,
      finishedSelector: "viewController:finishedWithAuth:errorOrNil:")
    return authController
  }
  
  // カレンダーのイベントを取得してコンソールに出力
  private func fetchEvents() {
    // クエリの設定.イベントは10個, 時間順にソート
    let query = GTLQueryCalendar.queryForEventsListWithCalendarId("primary") as! GTLQueryCalendar
    query.maxResults = 10
    query.timeMin = GTLDateTime(date: NSDate(), timeZone: NSTimeZone.localTimeZone())
    query.singleEvents = true
    query.orderBy = kGTLCalendarOrderByStartTime
    
    // クエリ実行. 完了後の処理はClosureで渡す
    calendarService?.executeQuery(query, completionHandler:{ (_, events, errorOrNil) -> Void in
      if let error = errorOrNil {
        self.showAlert("Error", message:"Unable to get calendar events.")
      } else {
        var result = ""
        if let items = events.items {
          if items.count == 0 {
            result = "No upcoming events found."
          } else {
            result = "Upcoming 10 events:\n"
            for object in items {
              
              if let event = object as? GTLCalendarEvent {
                let start: GTLDateTime = event.start.dateTime ?? event.start.date
                let startString = NSDateFormatter.localizedStringFromDate(
                  start.date,
                  dateStyle: NSDateFormatterStyle.ShortStyle,
                  timeStyle: NSDateFormatterStyle.ShortStyle)
                // イベントは開始時間とタイトルを出力
                result += "\(startString) - \(event.summary)\n"
              }
            }
          }
        } else {
          result = "events.items() == nil\n"
        }
        // 結果の出力
        println(result)
      }
    })
  }
  
  // 認証後に呼ばれる関数.完了したら認証画面を閉じてイベントの取得.
  func viewController(viewController: GTMOAuth2ViewControllerTouch, finishedWithAuth authResult: GTMOAuth2Authentication, errorOrNil: NSError?) {
    if let error = errorOrNil {
      showAlert("Authentication Error", message: error.localizedDescription)
      calendarService?.authorizer = nil
    } else {
      calendarService?.authorizer = authResult;
      self.dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  // エラーを表示する
  private func showAlert(title: String, message: String) {
    let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
    alert.show()
  }
  
}
//
//  LyricCrawler.swift
//  Lyricism
//
//  Created by Stan Liu on 29/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

func scrapNYCMetalScene() {
	
	Alamofire.request("http://nycmetalscene.com").responseString { response in
		
		if let html = response.result.value {
			parseHTML(html: html)
		}
	}
}

func parseHTML(html: String) {
	
	if let doc = Kanna.HTML(html: html, encoding: .utf8) {
		
		for show in doc.css("td[id^='Text']") {
			
			let showString = show.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
			// All text involving shows on this page currently start with the weekday.
			// Weekday formatting is inconsistent, but the first three letters are always there.
			let regex = try! NSRegularExpression(pattern: "^(mon|tue|wed|thu|fri|sat|sun)", options: [.caseInsensitive])
			
			if regex.firstMatch(in: showString!, options: [], range: NSMakeRange(0, (showString?.characters.count)!)) != nil {
				//show.append(showString)
				
				print("\(showString!)\n")
			}
		}
	}
}

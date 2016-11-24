//
//  UserDefaultsKey.swift
//  Lyricism
//
//  Created by Stan Liu on 24/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
	
	static let appCrashOnExceptions = DefaultsKey<String?>("NSApplicationCrashOnExceptions")
	
	static let playerSource = DefaultsKey<Int?>("player_source")
	static let isTutorialShow = DefaultsKey<Bool?>("tutorial_keep_remind")
	static let isDockShow = DefaultsKey<Bool>("is_dock_show")
	static let isAlwaysTop = DefaultsKey<Bool>("is_always_top")
	
}

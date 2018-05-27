//
//  MessageFunc.swift
//  Yamb
//
//  Created by Kresimir Prcela on 10/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

enum MessageFunc: String
{
    case Acked = "ack"
    case PlayerStat = "player_stat"
    case StatItems = "stat_items"
    case UpdatePlayer = "update_player"
    case RoomInfo = "room_info"
    case CreateTable = "create_table"
    case LeaveTable = "leave_table"
    case JoinTable = "join_table"
    case Step = "step"
    case Game = "game"
}


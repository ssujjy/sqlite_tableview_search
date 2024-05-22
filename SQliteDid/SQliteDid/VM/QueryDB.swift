//
//  QueryDB.swift
//  SQliteDid
//
//  Created by TJ on 2024/05/14.
//

import Foundation
import SQLite3


protocol QueryModelProtocol{
    func itemDownloaded(items: [SaveData])
}


class TodoListDB{
    var db: OpaquePointer?
    var todoList: [SaveData] = []
    var delegate: QueryModelProtocol!
    
    init(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appending(path: "mytodolist.sqlite")
        
        if sqlite3_open(fileURL.path(percentEncoded: true), &db) != SQLITE_OK{
            print("디비 여는데 에러")
        }
        // Table 만들기
        if sqlite3_exec(db, "CREATE TABLE If NOT EXISTS mytodolist (id integer primary key autoincrement, title text,state text DEFAULT 'on')", nil, nil, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("테이블 생성 오류: \(errMsg)")
        }
    }
    func queryDB(){
        var stmt: OpaquePointer?
        let queryString = "select * from mytodolist"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("셀렉트중 에러: \(errMsg)")
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = Int(sqlite3_column_int(stmt, 0))
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let state = String(cString: sqlite3_column_text(stmt, 2))
            
            todoList.append(SaveData(id: id, title: title, state: state))
            print("어팬드 했다 ")
            print(id, title)
            
        }
        delegate.itemDownloaded(items: todoList)
    }
    
    func insertDB(title: String) -> Bool{
           var stmt: OpaquePointer?
           let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
           let queryString = "insert into mytodolist (title) values (?)"
           
           sqlite3_prepare(db, queryString, -1, &stmt, nil)
           
           sqlite3_bind_text(stmt, 1, title, -1, SQLITE_TRANSIENT)
           
           print("인서트 했다 ")
           if sqlite3_step(stmt) == SQLITE_DONE{
               return true
           }else{
               return false
           }
       }
    
    func UpdateDB(id:Int, title: String) -> Bool{
        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let querString = "update mytodolist set title=? where id=?"
        sqlite3_prepare(db, querString, -1, &stmt, nil)
        
      
        sqlite3_bind_text(stmt, 1, title, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 2, Int32(id))
        
        if sqlite3_step(stmt) == SQLITE_DONE{
            return true
        }else{
            return false
        }
    }
    
    
    func DeleteDB(id: Int) -> Bool{
        var stmt: OpaquePointer?
            let queryString = "delete from mytodolist where id=?"
        
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
        
        sqlite3_bind_int(stmt, 1, Int32(id))
        
        if sqlite3_step(stmt) == SQLITE_DONE{
            return true
        }else{
            return false
        }
    }
    
    func UpdateState(id: Int, state: String) -> Bool{
        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let queryString = "update mytodolist set state=? where id=?"
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
       
        sqlite3_bind_text(stmt, 2, state, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 1, Int32(id))
        
        if sqlite3_step(stmt) == SQLITE_DONE{
            return true
        }else{
            return false
        }
    }
    
    
}


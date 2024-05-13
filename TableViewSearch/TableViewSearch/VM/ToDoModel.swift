//
//  ToDoModel.swift
//  TableViewSearch
//
//  Created by TJ on 2024/05/10.
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
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appending(path: "todoData.sqlite")
        
        if sqlite3_open(fileURL.path(percentEncoded: true), &db) != SQLITE_OK{
            print("디비 여는데 에러")
        }
        // Table 만들기
        if sqlite3_exec(db, "CREATE TABLE If NOT EXISTS todolist (id integer primary key autoincrement, title text)", nil, nil, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("테이블 생성 오류: \(errMsg)")
        }
    }
    func queryDB(){
        var stmt: OpaquePointer?
        let queryString = "select * from todolist"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("셀렉트중 에러: \(errMsg)")
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = Int(sqlite3_column_int(stmt, 0))
            let title = String(cString: sqlite3_column_text(stmt, 1))
            
            todoList.append(SaveData(id: id, title: title))
            print("어팬드 했다 ")
            print(id, title)
            
        }
        delegate.itemDownloaded(items: todoList)
    }
    
    func insertDB(title: String) -> Bool{
        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let queryString = "insert into todolist (title) values (?)"
        
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
        
        sqlite3_bind_text(stmt, 1, title, -1, SQLITE_TRANSIENT)
        
        print("인서트 했다 ")
        if sqlite3_step(stmt) == SQLITE_DONE{
            return true
        }else{
            return false
        }
    }
    
    func findkeyword(what: String) {
        var stmt: OpaquePointer?
        let queryString = "SELECT * FROM todolist WHERE title LIKE ?;"
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("셀렉트중 에러: \(errMsg)")
            return
        }
        
        // '%'로 감싼 문자열을 생성하여 바인딩
        let likeString = "%\(what)%"
        if sqlite3_bind_text(stmt, 1, likeString, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("바인딩중 에러: \(errMsg)")
            sqlite3_finalize(stmt)
            return
        }
        
        // 쿼리 실행
        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(stmt, 0))
            let title = String(cString: sqlite3_column_text(stmt, 1))
            
            todoList.append(SaveData(id: id, title: title))
            print("어팬드 했다 ")
            print(id, title)
        }
        
        // statement 해제
        sqlite3_finalize(stmt)
        
        delegate.itemDownloaded(items: todoList)
    }
        
        
        
        
        
            func DeleteDB(id: Int) -> Bool{
                var stmt: OpaquePointer?
                    let queryString = "delete from todolist where id=?"
                let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                sqlite3_prepare(db, queryString, -1, &stmt, nil)
                sqlite3_bind_int(stmt, 1, Int32(id))
        
                if sqlite3_step(stmt) == SQLITE_DONE{
                    return true
                }else{
                    return false
                }
            }
        
        
    }



//
//  ViewController.swift
//  TableViewSearch
//
//  Created by TJ on 2024/05/10.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tvViewList: UITableView!
    @IBOutlet weak var tfWhat: UITextField!
  
    
    var ListData: [SaveData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tvViewList.delegate = self
        tvViewList.dataSource = self
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
         readValue()
     }
     // MARK: 데이터 리로드
     func  readValue(){
         let todoListDB = TodoListDB()
         ListData.removeAll()
         todoListDB.delegate = self
         todoListDB.queryDB()
         
         tvViewList.reloadData()
       
     }
    
    
    
    @IBAction func btnInsert(_ sender: UIButton) {
        GoInsert()
    }
    
    @IBAction func btnSearch(_ sender: UIButton) {
        Gosearch()
    }
    
    func  Gosearch(){
      
        let todolist = TodoListDB()
        if tfWhat.text!.isEmpty{
            readValue()
        }else{
            ListData.removeAll()
            todolist.delegate = self
            
           todolist.findkeyword(what: tfWhat.text!)
            tvViewList.reloadData()
        }
    }
    
    
    
    
    
   func GoInsert(){
        
       let addAlert = UIAlertController(title: "Todo List", message: "추가할 내용을 입력하세요.", preferredStyle: .alert)
         
         addAlert.addTextField{ACTION in
             ACTION.placeholder = "추가 내용"
         }
         
         let cancelAction = UIAlertAction(title: "취소", style: .default)
       let okAction = UIAlertAction(title: "추가", style: .default, handler: { [self]ACTION in
             
             let todoListDB = TodoListDB()
           let result = todoListDB.insertDB(title: addAlert.textFields![0].text!)
           self.readValue()
             // Alert
                  if result{
                      let resultAlert = UIAlertController(title: "결과", message: "입력 되었습니다.", preferredStyle: .alert)
                      let okAction = UIAlertAction(title: "네 알겠습니다.", style: .default , handler: {ACTION in
                         
                          self.navigationController?.popViewController(animated: true)
                         
                      })
                      resultAlert.addAction(okAction)
                      self.present(resultAlert, animated: true)
                  }else{
                      let resultAlert = UIAlertController(title: "에러", message: "문제 발생.", preferredStyle: .alert)
                      let okAction = UIAlertAction(title: "네 알겠습니다.", style: .default , handler: {ACTION in
                          self.navigationController?.popViewController(animated: true)
                      })
                      resultAlert.addAction(okAction)
                      self.present(resultAlert, animated: true)
                  }
 
         })
         addAlert.addAction(cancelAction)
         addAlert.addAction(okAction)
       
         present(addAlert,animated: true)
       self.readValue()
    }
}
    
extension ViewController: UITableViewDelegate {
     func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ListData.count
    }
    
    }
extension ViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text =  ListData[indexPath.row].title
        
        content.image  = UIImage(systemName: "pencil.circle")
        cell.contentConfiguration = content
        
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todoListDB = TodoListDB()
            _ = todoListDB.DeleteDB(id: ListData[indexPath.row].id)
            ListData.remove(at: indexPath.row)
            // Delete the row from the data source
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
        }
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
}
    
// MARK: DB프로토콜 익스텐션
extension ViewController: QueryModelProtocol{
    func itemDownloaded(items: [SaveData]) {
        ListData = items
        tvViewList.reloadData()
        
    }
    
  
}


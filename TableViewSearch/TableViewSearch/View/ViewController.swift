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
        
    }
    
   func GoInsert(){
        
       let addAlert = UIAlertController(title: "Todo List", message: "추가할 내용을 입력하세요.", preferredStyle: .alert)
         
         addAlert.addTextField{ACTION in
             ACTION.placeholder = "추가 내용"
         }
         
         let cancelAction = UIAlertAction(title: "취소", style: .default)
         let okAction = UIAlertAction(title: "추가", style: .default, handler: {ACTION in
             
             let todoListDB = TodoListDB()
           let result = todoListDB.insertDB(title: addAlert.textFields![0].text!)
          
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
        
           return cell
    }
}
    
// MARK: DB프로토콜 익스텐션
extension ViewController: QueryModelProtocol{
    func itemDownloaded(items: [SaveData]) {
        ListData = items
        tvViewList.reloadData()
        
    }
    
  
}


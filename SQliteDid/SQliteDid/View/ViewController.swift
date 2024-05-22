//
//  ViewController.swift
//  SQliteDid
//
//  Created by TJ on 2024/05/14.
//

import UIKit

class ViewController: UIViewController {
    //MARK: Property
    @IBOutlet weak var tvMyList: UITableView!
    @IBOutlet weak var btnFix: UIButton!
    // 사용할 배열 정의
    var ListData: [SaveData] = []
    // 메세지 함수에서 사용하는 변수
    var whatMessage = ""
    // 작업 완료 상태 변수
    var status = false
    // 메세지 분류 변수
    var getResult = true
    
    var nonAction = UIAlertAction()
    // 선택한 아이템 변수
    var item = ""
    var id = 0
    var indexNum = 0
    var whatState = ""
    
    //MARK: ViewdidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
             tvMyList.addGestureRecognizer(longPressRecognizer)
        
        tvMyList.delegate = self
        tvMyList.dataSource = self
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
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
          
          tvMyList.reloadData()
        
      }
    

    
    @IBAction func btnAdd(_ sender: UIButton) {
        GoMessage("입력",nil)
        
    }

        	
    func GoMessage(_ what: String, _ index: IndexPath?){
        switch what{
        case "입력":
            whatMessage = "입력할 내용을 입력하세요!"
            item = ""
        case "수정":
            whatMessage = "수정할 내용을 입력하세요!"
        case "완료":
            whatMessage = "해당 항목을 작업 완료로 설정 하시겠습니까?"
        default:
            whatMessage = "내용을 입력하세요!"
        }
           let Alert = UIAlertController(title: "Todo List", message: whatMessage , preferredStyle: .alert)
        
        Alert.addTextField{ [self]ACTION in
           ACTION.placeholder = whatMessage
            if index == nil{
                ACTION.isUserInteractionEnabled = true
                ACTION.text = item
            }else{
                ACTION.text = self.ListData[index!.row].title
                ACTION.isUserInteractionEnabled = false
            }
                
             }
        if what == "완료"{
            let nonAction = UIAlertAction(title: "미완료", style: .default,handler: {
                ACTION in
                self.navigationController?.popViewController(animated: true)
            })
            Alert.addAction(nonAction)
        }
             let cancelAction = UIAlertAction(title: "취소", style: .default)
             let okAction = UIAlertAction(title: what, style: .default, handler: { [self]ACTION in

                 let todoListDB = TodoListDB()
               switch what{
               case "입력":
                   let result = todoListDB.insertDB(title: Alert.textFields![0].text!)
                   getResult = result
                   self.readValue()
               case "수정":
                   let result = todoListDB.UpdateDB(id: self.id, title: Alert.textFields![0].text!)
                   getResult = result
                   self.readValue()
               case "완료":
                   whatState = "off"
                   print("가져온 아이디와 상태", ListData[index!.row].id, ListData[index!.row].state)
                   let result = todoListDB.UpdateState(id: ListData[index!.row].id, state: whatState)
                   getResult = result
                   self.readValue()
               default:
                   return
               }
                 // Alert
                      if getResult{
                          let resultAlert = UIAlertController(title: "결과", message: "\(what) 되었습니다.", preferredStyle: .alert)
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
             Alert.addAction(cancelAction)
             Alert.addAction(okAction)

             present(Alert,animated: true)
             self.readValue()
        }
    
    
    
}//ViewController

//MARK: Extension part Start


//MARK: Cell 꾸미기
//cell row
extension ViewController: UITableViewDelegate {
     func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
    //cell column
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ListData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // 셀이 클릭되었을 때의 동작 정의
        item = ListData[indexPath.row].title
        id = ListData[indexPath.row].id
            print("Selected item: \(item)")
        
                    GoMessage("수정",nil)
        }
    
    }
//MARK: Cell 에 데이터 넣기
extension ViewController: UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
          return true
      }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text =  ListData[indexPath.row].title
        
        cell.isUserInteractionEnabled =  ListData[indexPath.row].state == "on" ?  true : false
        
        print("완료 상태" , ListData[indexPath.row].state)
        content.image  = ListData[indexPath.row].state == "on" ? UIImage(systemName: "pencil.circle") : UIImage(systemName: "checkmark")
        
        // return 이 cell 임으로 content 를 cell 로 지정
        cell.contentConfiguration = content
        
        return cell
    }
    
        //MARK: CellDelete
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
        
        // cell Delete 글자 한글로 바꾸기
        func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
            return "삭제"
        }
        func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath){
            let itmeToMove = ListData[fromIndexPath.row]
            
            ListData.remove(at: fromIndexPath.row)
            
            ListData.insert(itmeToMove, at: to.row)
        }
    }


extension ViewController{
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: tvMyList)
            if let indexPath = tvMyList.indexPathForRow(at: location){
                
                GoMessage("완료",indexPath)
            }
        }
}
}
// MARK: DB프로토콜 익스텐션
extension ViewController: QueryModelProtocol{
    func itemDownloaded(items: [SaveData]) {
        ListData = items
        tvMyList.reloadData()
        
    }
    
  
}
//MARK: Extention part End


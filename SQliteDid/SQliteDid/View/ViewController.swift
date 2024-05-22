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
    var whatState = ""
    
    
    
    //MARK: ViewdidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // 길게 눌렀을 때 기능을 정의하기 위해 함수를 부르는 구문
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
             tvMyList.addGestureRecognizer(longPressRecognizer)
        
       // 셀을 이동시키는 함수를 부르는 구문
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditing))
               
        self.navigationItem.leftBarButtonItem = editButton
        // 익스텐션부분을 적용
        tvMyList.delegate = self
        tvMyList.dataSource = self
        
    }
    // 특정 행동 후 데이터의 중복을 막기위해 사용
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
    
    @IBAction func btnAdd(_ sender: UIBarButtonItem) {
        GoMessage("입력",nil)
    }


    /*
     메세지를 출력하는 함수
     함수가 좀 길고 복잡하다, 추후 정리가 필요함
     
     기능설명 : 파라미터로 받은 스트링값으로 분류 후 해당하는 QueryDB로 이동한다.
     */
    func GoMessage(_ what: String, _ index: IndexPath?){
        /*
         총 3가지의 메세지가 사용,
         switch 문으로 분류 후 변수에 메세지 내용을 넣어준다.
            "입력" 인 경우에 메세지의 텍스트필드에 값이 없어여 함으로 item 변수를 비워주고 실행한다.
         */
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
            // 메세지의 타이틀과 설명 부분
           let Alert = UIAlertController(title: "Todo List", message: whatMessage , preferredStyle: .alert)
        /*
        오직 "완료" 일 경우에만 메세지 함수의 index 값을 nil 이 아는 값으로 받는다.
        "완료" 의 경우 메세지의 텍스트필드는 readonly 여야 한다.
        "완료" 의 경우 다른 메세지는 cell 클릭시 item 변수에 해당 데이터를 받지만,
         길게 눌렀을 때에는 데이터를 받을 수 없다.
         고로 파라미터로 받은 index 값을 사용하여 내 Model 에 들어있는 값을 찾아서 보여준다.
         
        */
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
        /*
         "완료" 의 경우에 메세지에 상태 체크에 대한 버튼이 하나 추가된다.
         그럼으로 버튼을 "완료" 일 때만 추가해준다.
         */
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
                 //
               switch what{
               case "입력":
                   let result = todoListDB.insertDB(title: Alert.textFields![0].text!,order: ListData.count + 1)
                   getResult = result
                   self.readValue()
               case "수정":
                   let result = todoListDB.UpdateDB(id: self.id, title: Alert.textFields![0].text!)
                   getResult = result
                   self.readValue()
               case "완료":
                   // 완료를 눌렀을 경우 readonly 처리를 위해 변수에 값을 넣는다.
                   whatState = "off"
                   //print("가져온 아이디와 상태", ListData[index!.row].id, ListData[index!.row].state)
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
        // 클릭시 수정 함수로 연결한다.
        item = ListData[indexPath.row].title
        id = ListData[indexPath.row].id
            print("Selected item: \(item)")
        
                    GoMessage("수정",nil)
        }
    
    }
//MARK: Cell 에 데이터 넣기
// 셀의 동작,기능을 정의하기 위해 익스텐션으로 UITableViewDataSource 를 받는다
extension ViewController: UITableViewDataSource
{
    // 나의 셀을 언제나 변경 가능하게 항상 true 값을 리턴한다.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
          return true
      }
    
    // Cell 을 단순 클릭시 작동하는 함수부분
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        /*
         텍스트값에 데이터를 넣기위한 부분
         */
        content.text =  ListData[indexPath.row].title
        /*
         셀의 작업 완료/비완료 컬럼을 추가하여 그 상태에 따른 readonly 처리와 이미지 변경을 삼항연산자로 처리했다.
         */
        cell.isUserInteractionEnabled =  ListData[indexPath.row].state == "on" ?  true : false
        //print("완료 상태" , ListData[indexPath.row].state)
        content.image  = ListData[indexPath.row].state == "on" ? UIImage(systemName: "pencil.circle") : UIImage(systemName: "checkmark")
        
        // return 이 cell 임으로 content 를 cell 로 지정
        cell.contentConfiguration = content
        
        return cell
    }
    
        //MARK: CellDelete
    // 셀을 삭제하는 함수부분
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let todoListDB = TodoListDB()
                _ = todoListDB.DeleteDB(id: ListData[indexPath.row].id)
                ListData.remove(at: indexPath.row)
                // Delete the row from the data source
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else if editingStyle == .insert {
                
            }
        }
        // cell Delete 글자 한글로 바꾸기
        func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
            return "삭제"
        }
    
    // Cell 을 이동하기 위한 함수부분
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        // 이동할 item 의 복사
        let itemToMove = ListData[fromIndexPath.row]
        
       
        // 이동할 item의 삭제
        ListData.remove(at: fromIndexPath.row)
        // 이동할 위치에 insert
        ListData.insert(itemToMove, at: to.row)
        listSort2()
        //listSort() // 폐기********
        
    }
    // DB 와 Cell의 순서를 같게하는 함수
    // 이거는 문제를 잘못이해해서 버림..
    // 기능 설명 : sort 컬럼을 추가해서 그 컬럼을 기준으로 order by 하여 테이블 순서 변경할려고 시도
    // 허나 테이블의 데이터(row) 자체 순서를 바꾸어야 함으로 사용 X  2 번을 제작함
    func listSort(){
        let todolistDB = TodoListDB()
        for (index,dataId) in ListData.enumerated(){
                //print("어뉴머레이트값" ,index, dataId)
            let result = todolistDB.UpdateOrder(order: index + 1, id: dataId.id)
            
            if !result{
                print("순서변경중 에러")
            }else{
                //readValue()
            }
        }
      
    }
    // cell 순서를 바꾸면 테이블을 전체 삭제 후, 다시 인서트 하는 방식의 함수
    
    /*
     기능 설명 : 1. 먼저 셀을 이동하면 테이블의 데이터를 전부 지운다
               2. 아직 내가 만든 모델에 저장된 리스트는 남아있다
               3. 그 후 내 모델에 남아있는 데이터를 가지고 순서대로 인서트한다
     
     ListData.enumerated() 를 사용하여 인서트를 순서대로 실행한다.
        print에 찍히는 data 값은 이러하다
     
     인서트할 값들 0 SaveData(id: 22, title: "셋째", state: "on", order: 3)
     인서트할 값들 1 SaveData(id: 20, title: "첫번째", state: "on", order: 1)
     인서트할 값들 2 SaveData(id: 23, title: "넷째", state: "on", order: 4)
     인서트할 값들 3 SaveData(id: 21, title: "둘째", state: "on", order: 2)
     
     
     */
    func listSort2(){
         let todolistDB = TodoListDB()
        let result = todolistDB.deleteAll()
        // 정상적으로 삭제 완료 후 다시 인서트를 실행한다
        if result{
            for (index, data) in ListData.enumerated(){
                print("인서트할 값들" ,index, data)
                _ = todolistDB.insertNew(title: data.title, order: data.order ,state: data.state)
            }
        }else{
            print("삭제하고 다시 인서트중 에러")
        }
    }
    // tableviewController 에서는 없이 바로 사용했지만 무슨 일인지 이것이 필요하다.
    /*
     구글링의 결과.
     나중에 다시 다듬을 필요 있다.
     cell 을 이동,삭제할때 필요한 함수부분
     */
    @objc func toggleEditing() {
            // 편집 모드 토글
            let isEditing = !self.isEditing
            self.setEditing(isEditing, animated: true)
            tvMyList.setEditing(isEditing, animated: true)

            // 편집 모드에 따라 버튼 타이틀 변경
            if isEditing {
                navigationItem.leftBarButtonItem?.title = "Done"
            } else {
                navigationItem.leftBarButtonItem?.title = "Edit"
            }
        }
    }
            /*
             길게 눌렀을 때 작동하는 함수부분
             
            나의 tableview 에서 인덱스 값을 가져와 Alert 함수에 파라미터를 보낸다.
             */
        // viewcontroller 에 익스텐션을 추가한다
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


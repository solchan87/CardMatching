//
//  ViewController.swift
//  CardMatching
//
//  Created by SolChan Ahn on 2018. 2. 2..
//  Copyright © 2018년 SolChan Ahn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // 카드 리스트를 담은 상수
    let cardList = [("cardKing", 1), ("cardKing", 1), ("cardJoker", 2), ("cardJoker", 2), ("cardClubs", 3), ("cardClubs", 3), ("cardDiamonds", 4), ("cardDiamonds", 4), ("cardHeart", 5), ("cardHeart", 5), ("cardSpades", 6), ("cardSpades", 6)]
    
    // 메인 화면과 결과 화면을 만든다.
    var mainView: UIView?
    var resultView: UIView?
    
    // 선택된 카드를 담는 변수
    var firstCard: UIButton?
    var secondCard: UIButton?
    
    // 결과 화면에 표시될 버튼과 결과 메세지
    var startBtn: UIButton?
    var resultMsg: UILabel?
    var resultCount: Int = 0
    
    // 맞춘 카드 갯수를 체크하는 함수
    var cardCount: Int = 0{
        willSet(count){ // 값이 변하기 직전 실행
            if count == 0{
                endGame()
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // 슈퍼 뷰위에 메인 화면을 만든다.
        mainView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view.addSubview(mainView!)
        
        cardSetting()
        creatResultView()
        
    }
    
    
    /// 카드 리스트의 튜플을 섞어주는 함수
    ///
    /// - Parameter cardList: 카드 리스트
    /// - Returns: 섞인 카드 리스트를 반환한다
    func cardShuffle(cardList: [(String, Int)]) -> [(String, Int)]{
        var tempList = cardList
        var resultList: [(String, Int)] = []
        // 빈 배열에 카드 리스트의 랜덤 인덱스에 있는 튜플을 결과 리스트에 넣어서 카드를 섞어준다.
        while tempList.count != 0{
            let index: Int = Int(arc4random_uniform(UInt32(tempList.count - 1)))
            resultList.append(tempList[index])
            tempList.remove(at: index)
        }
        
        return resultList
    }
    
    
    /// 카드를 다 맞춘 후 결과를 보여주는 결과 표시창을 만드는 함수 - 최초 실행
    /// 결과 버튼만 만들 경우 재시작 시 새로 만든 카드 뷰들에 가려지는
    /// 단점과 가독성 문제 때문에 메인 화면 위에 결과 화면을 만들었다.
    func creatResultView(){
        
        resultView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        // 가독성을 위해서 알파값을 줘서 화면이 어두워지는 효과를 준다.
        resultView!.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.addSubview(resultView!)
        
        // 카드를 다 맞추면, 다시 카드를 뿌려주는 함수를 실행하는 버튼
        let startBtnWidth: CGFloat = 250
        let centerPoint: CGFloat = (view.frame.size.width / 2) - (startBtnWidth / 2)
        
        startBtn = UIButton(type: .custom)
        startBtn!.frame = CGRect(x: centerPoint, y: view.frame.size.height / 1.7, width: startBtnWidth, height: 50)
        startBtn!.backgroundColor = .orange
        startBtn!.layer.cornerRadius = 10
        startBtn!.setTitle("다시 시작하기", for: .normal)
        startBtn!.titleLabel!.font = UIFont(name: "NanumSquareRoundB", size: 25)
        startBtn!.addTarget(self, action: #selector(self.startCardGame(_:)), for: .touchUpInside)
        
        resultView!.addSubview(startBtn!)
        
        // 결과 메세지를 보여주는 레이블을 정의하는 구문
        resultMsg = UILabel(frame: CGRect(x: 0, y: view.frame.size.height / 3, width: view.frame.size.width, height: 200))
        resultMsg!.numberOfLines = 0
        resultMsg!.textAlignment = .center
        resultMsg!.textColor = .white
        resultMsg!.font = UIFont(name: "NanumSquareRoundB", size: 23)
        
        resultView!.addSubview(resultMsg!)
        
        // 결과 창을 만들어 놓고 처음에 안보여 주도록 한다.
        resultView!.isHidden = true
    }
    
    
    /// 카드를 뿌려주는 함수
    func cardSetting(){
        // 시도 횟수 카운트를 0으로 초기화 한다.
        resultCount = 0
        
        // 카드 리스트를 cardShuffle 함수로 섞어준다.
        let sendCardList = cardShuffle(cardList: cardList)
        //카드 사이 공간의 길이를 정의한다.
        let margin: Int = Int(self.view.frame.size.width / 16)
        
        let width: CGFloat = self.view.frame.size.width / 4
        let height: CGFloat = width * 1.45
        let colum: Int = 3
        
        for index in 0..<sendCardList.count{
            
            let col = index % colum
            let row = index / colum
            // 카드사이 공간을 col과 row를 참조하여 배치한다.
            let x: CGFloat = (width * CGFloat(col)) + CGFloat((col + 1) * margin)
            let y: CGFloat = (height * CGFloat(row)) + CGFloat((row + 1) * margin)
           
            let card = CreateCard(frame: CGRect(x: x, y: y, width: width, height: height))
            card.setCard()
            card.mixCard(cTuple: sendCardList[index])
            card.addTarget(self, action: #selector(self.checkCard(_:)), for: .touchUpInside)
            mainView!.addSubview(card)
            
        }
        // 카드의 총 갯수를 선택한다.
        cardCount = cardList.count
    }
    
    
    /// 선택한 카드가 같을 경우 카드를 삭제하는 함수
    func removeCard(){
        
        // 버튼의 부모 뷰를 불러와서 삭제한다.
        firstCard!.superview!.removeFromSuperview()
        secondCard!.superview!.removeFromSuperview()
        
        // 삭제한 후 임시 카드 변수를 nil로 초기화 한다.
        firstCard = nil
        secondCard = nil
        
        //카드가 맞을 경우 카드 리스트 카운트에서 2만큼 빼준다.
        cardCount -= 2
    }
    
    func endGame(){
        // 게임이 끝날때 시도 횟수를 반영하여 메세지를 다시 정의한다.
        resultMsg!.text =
        """
        \(resultCount) 번을 시도하여,
        카드를 모두 맞췄습니다.
        
        축하드립니다!
        """
        
        // 숨겨놨던 결과 화면을 다시 보여준다.
        resultView!.isHidden = false
    }
    
    // 카드 버튼을 클릭할때마다 상태를 확인하는 함수
    @objc func checkCard(_ sender: UIButton){
        
        // 카드가 이미 2개 선택 된 경우 초기화 하면서 카드를 선택할 수 있도록 한다.
        // 결과가 새로운 카드를 클릭할때까지 보여주기 위해서 앞에 배치함.
        if secondCard != nil{
            firstCard!.isHidden = false
            secondCard!.isHidden = false
            
            firstCard = nil
            secondCard = nil
        }
        // 첫번째 카드를 선택할때 시도
        if firstCard == nil{
            // 카드를 선택하면 카드 뒷면 버튼을 숨겨서 앞면을 보여준다.
            sender.isHidden = true
            // 선택한 카드를 첫번째 임시 카드 보관 변수에 넣는다.
            firstCard = sender
        }else{
            sender.isHidden = true
            // 선택한 카드를 두번째 임시 카드 보관 변수에 넣는다.
            secondCard = sender
            resultCount += 1
            
            // 선택한 함수의 태그가 맞을 경우 두개의 카드를 삭제하는 함수를 실행한다.
            if firstCard!.tag == secondCard!.tag{
                removeCard()
            }
        }
    }
    
    // 카드 결과창에서 새로운 게임을 시작하는 함수
    @objc func startCardGame(_ sender: UIButton){
        // 결과창을 숨긴다.
        resultView!.isHidden = true
        cardSetting()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


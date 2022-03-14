//
//  BookingVC.swift
//  TenTwentyTask
//
//  Created by usama on 14/03/2022.
//

import UIKit

protocol BookingInjector {
    func inject(viewModel: BookingViewModel)
}


class BookingVC: BaseVC {
    
    @IBOutlet weak var timeLocation: UILabel!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var tonightLbl: UILabel!
    @IBOutlet weak var cinemaNumber: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var bookingVM: BookingViewModel!

    var centerCell: Int = 0
    var numberOfCellPerRow: Double = 9 {
        didSet {
            centerCell = (Int(numberOfCellPerRow) / 2) + 1
        }
    }
    var seats: [Seating] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        setCollectionView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        initUI()
        setDummyData()
    }
}


extension BookingVC {
    
    private func initUI() {
        let alignment: NSTextAlignment = UIDevice.current.orientation.isLandscape ? .right : .left
        tonightLbl.textAlignment = alignment
        movieTitle.textAlignment = alignment
        timeLocation.textAlignment = alignment
        
        movieTitle.text = bookingVM.movie.title

    }
    
    
    private func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.registerNibs(cells: [BookingTextCell.self,
                                            BookingImageCell.self])
        setDummyData()
        rotateCinemaNumber()
    }
    
    private func rotateCinemaNumber() {
        cinemaNumber.transform = CGAffineTransform(rotationAngle: 80.1)
    }
    
    private func setDummyData() {
        // numberOfCellPerRow = collectionView.bounds.width / 40
        // numberOfCellPerRow = floor(numberOfCellPerRow)
        numberOfCellPerRow = 9
        seats.removeAll()
        Array(1..<10).forEach({
            seats.append(Seating(number: "\($0)", type: .text, isCenter: centerCell == $0))
        })
        Array(1...99).forEach({
            let isCenter = centerCell == $0
            seats.append(Seating(type: .seat, isCenter: isCenter))
            if isCenter { centerCell += Int(numberOfCellPerRow) }
        })
        
        collectionView.reloadData()
    }
}


extension BookingVC: BookingInjector {
    func inject(viewModel: BookingViewModel) {
        bookingVM = viewModel
    }
}

extension BookingVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { seats.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let seat = seats[indexPath.item]
        switch seat.type {
        case .text:
            let cell: BookingTextCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.numberLbl.text = seat.number
            cell.isHidden = seat.isCenter
            return cell
        case .seat:
            let cell: BookingImageCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.seat = seat
            return cell
        }
    }
    
}

extension BookingVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 30, height: 30)
    }
}

extension BookingVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let seat = seats[indexPath.item]
        if seat.isCenter && seat.type == .text { return }
        seats[indexPath.item].isSelected.toggle()
        collectionView.reloadItems(at: [indexPath])
    }
}
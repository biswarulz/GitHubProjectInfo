//
//  ProjectDetailViewController.swift
//  GitHubProjects
//
//  Created by Biswajyoti Sahu on 17/09/19.
//  Copyright © 2019 Biswajyoti Sahu. All rights reserved.
//

import UIKit

class ProjectDetailViewController: UIViewController {
    
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var commonTableView: UITableView!
    
    lazy var detailViewModel: ProjectDetailViewModel = {
        return ProjectDetailViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initViewModel()
    }
    
    func initView() {
        
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: view.frame.size.height + 100)
        scrollView.addSubview(view)
        let url = URL(string: detailViewModel.selectedItem?.owner.avatarURL ?? "")!
        detailViewModel.fetchImage(url) {[weak self] (imageData) in
            DispatchQueue.main.async {
                self?.ownerImageView.image = UIImage(data: imageData)
            }
        }
        nameLabel.text = detailViewModel.selectedItem?.fullName
        descriptionLabel.text = detailViewModel.selectedItem?.description
        segmentControl.selectedSegmentIndex = 0
        commonTableView.estimatedRowHeight = 100
        commonTableView.rowHeight = UITableView.automaticDimension
    }
    
    func initViewModel() {
        
        detailViewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.detailViewModel.alertMessage {
                    self?.showAlert( message )
                }
            }
        }
        
        detailViewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.detailViewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.commonTableView.alpha = 0.0
                    })
                }else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.commonTableView.alpha = 1.0
                    })
                }
            }
        }
        
        detailViewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.commonTableView.reloadData()
            }
        }
        
        detailViewModel.initFetchForIssues()
        detailViewModel.initFetchForContribution()
    }
    
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func didSegmentValueChanged(_ sender: UISegmentedControl) {
        detailViewModel.selectedSegmentControlIndex = sender.selectedSegmentIndex
        commonTableView.reloadData()
    }
    
}

extension ProjectDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailViewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectDetailCellIdentifier", for: indexPath) as? IssueListTableViewCell else {
            return UITableViewCell()
        }
        if segmentControl.selectedSegmentIndex == 0 {
            let cellVM = detailViewModel.getIssueCellViewModel(at: indexPath)
            let imageURL = URL(string: cellVM.avatarImagePath)!
            detailViewModel.fetchImage(imageURL) { (imageData) in
                DispatchQueue.main.async {
                    cell.avatarImageView.image = UIImage(data: imageData)
                }
            }
            cell.issueListCellViewModel = cellVM
        } else {
            let cellVM = detailViewModel.getContributionCellViewModel(at: indexPath)
            let imageURL = URL(string: cellVM.avatarImagePath)!
            detailViewModel.fetchImage(imageURL) { (imageData) in
                DispatchQueue.main.async {
                    cell.avatarImageView.image = UIImage(data: imageData)
                }
            }
            cell.contributionListCellViewModel = cellVM
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
}

class IssueListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    var issueListCellViewModel: IssueListCellViewModel?  {
        didSet {
            nameLabel.text = issueListCellViewModel?.issueName
            infoLabel.text = issueListCellViewModel?.issueInfo
        }
    }
    
    var contributionListCellViewModel: ContributionListCellViewModel?  {
        didSet {
            nameLabel.text = contributionListCellViewModel?.user
            infoLabel.text = contributionListCellViewModel?.contributionInfo
        }
    }
}
